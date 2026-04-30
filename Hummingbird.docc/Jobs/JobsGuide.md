# Jobs

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Durable job execution. Offload work your server would be doing to another server. 

## Overview

A Job consists of a payload and an execute method to run the job. Swift Jobs provides a framework for pushing jobs onto a queue and processing them at a later point. If the driver backing up the job queue uses persistent storage then a separate server can be used to process the jobs. 

The ``Jobs`` framework comes with a driver that stores jobs in local memory and processes them locally, but this should only ever be used for debugging purposes. A production grade server should use one of ``JobsValkey`` and ``JobsPostgres`` that implement the job queue using a Valkey/Redis database or Postgres database respectively. 

## Getting started

The Job queue support can be found in the [swift-jobs](https://github.com/hummingbird-project/swift-jobs) repository. To add the library as a dependency in your project use the following command line.

```
swift package add-dependency https://github.com/hummingbird-project/swift-jobs.git --from "1.1.0"
```

To add the target dependency to your application use the following, replacing the `<MyApp>` text with the name of your application target.

```
swift package add-target-dependency Jobs <MyApp> --package swift-jobs
```

### Setting up a Job service

To process jobs a JobService is needed. ``Jobs/JobService`` combines a job queue, job queue processor and job scheduler into one type. Below we create a job service using the Valkey driver for swift-jobs.

```swift
let jobService = JobService(
    .valkey(
        valkeyClient, 
        configuration: .init(queueName: "MyQueue"),
        logger: logger
    ),
    logger: logger
)
```

### Creating a Job Definition

Creating a job definition requires an identifier, the parameters for the job and the function that runs the job. We use a struct conforming to ``Jobs/JobParameters`` to define the job parameters and identifier.

```swift
struct SendEmailJobParameters: JobParameters {
    /// jobName is used to create the job identifier. It should be unique
    static let jobName = "SendEmail"
    let to: String
    let subject: String
    let body: String
}
```

Then we register the job with a job queue and also provide a closure that executes the job.

```swift
jobService.registerJob(parameters: SendEmailJobParameters.self) { parameters, context in
    try await myEmailService.sendEmail(to: parameters.to, subject: parameters.subject, body: parameters.body)
}
```

Now your job is ready to create. Jobs can be queued up using the function ``Jobs/JobService/push(_:options:)`` from `JobService`.

```swift
let job = SendEmailJobParameters(
    to: "joe@email.com",
    subject: "Testing Jobs",
    message: "..."
)
jobService.push(job)
```

Alternatively you can create a job using a ``Jobs/JobName``. This associates a type with a name, but that type can be used multiple times with different job names. Remember each job should have a unique job name.

```swift
let printStringJob = JobName<String>("Print String")
jobService.registerJob(printStringJob) { parameters, context in
    print(parameters)
}
```

You then queue your job for execution using ``Jobs/JobQueue/push(_:parameters:options:)``

```swift
jobService.push(printStringJob, parameters: "Testing,testing,1,2,3")
```

A common way to do this is to extend ``Jobs/JobName`` with a static variable to aid autocomplete.

```swift
extension JobName where Parameters == String {
    static var printString: Self { .init("Print String") }
}
jobService.registerJob(.printString) { parameters, context in
    print(parameters)
}
jobService.push(.printString, parameters: "Testing,testing,1,2,3")
```

### Processing Jobs

To start processing jobs you need to run the job queue processor. You can do this using ``Jobs/JobService/run()`` from `JobService`, although it is preferable to use [Swift Service Lifecycle](https://github.com/swift-server/swift-service-lifecycle) to manage the running of the processor to ensure clean shutdown when your application is shutdown. You can control how many jobs the job queue processor runs concurrently, via options setup when initializing the `JobService`.

```swift
let jobService = JobService(
    .valkey(
        valkeyClient, 
        configuration: .init(queueName: "MyQueue"),
        logger: logger
    ),
    logger: logger,
    options: .init(processor: .init(numWorkers: 64))
)
let serviceGroup = ServiceGroup(
    services: [server, jobService],
    configuration: .init(gracefulShutdownSignals: [.sigterm, .sigint]),
    logger: logger
)
try await serviceGroup.run()
```

If you are running a Hummingbird server you can add the job processor to the array of services that `Application` manages.

```swift
let app = Application(...)
app.addServices(jobService)
```

If you want to process jobs on a separate server you will need to use a job queue driver that saves to some external storage eg ``JobsValkey/ValkeyJobQueue`` or ``JobsPostgres/PostgresJobQueue``.

### Retrying Jobs

When a job fails most swift-job drivers save them separately so you can manually retry them at a later date. But you can also automate retrying of a failed job by defining a retry strategy for it.

The retry strategy is defined at the point you create a job. By default this is set to `.dontRetry` which will not attempt to retry a failed job. Swift-jobs provides a standard retry strategy ``Jobs/ExponentialJitterJobRetryStrategy`` where the backoff between each retry exponentially increases with a random jitter applied. The retry strategy for a job is defined at the same time you create a `JobDefinition` or when you register a job handler using `jobQueue.registerJob()`. As an alternative to ``Jobs/ExponentialJitterJobRetryStrategy``, the shorthand `.exponentialJitter()` is available.

```swift
let emailJob = JobDefinition(
    parameters: SendEmailJobParameters.self, 
    retryStrategy: .exponentialJitter(
        maxAttempts: 4, // number of times to retry
        maxBackoff: 60, // maximum when calculating the backoff 
        minJitter: -0.25, // min jitter as a ratio of calculated backoff
        maxJitter: 0.33 // max jitter as a ratio of calculated backoff
    )
) { parameters, context in
    try sendEmail(parameters)
}
jobService.registerJob(emailJob)
```

``Jobs/JobRetryStrategy`` is a protocol. So you can define your own retry strategies as well.

```swift
struct MyRetryStrategy: JobRetryStrategy {
    /// Should we retry a failed job
    func shouldRetry(attempt: Int, error: any Error) -> Bool {
        isItSunday()
    }

    ///  Calculate backoff amount
    func calculateBackoff(attempt: Int) -> Duration {
        .seconds(60*60*24)
    }
}
```

### Sleeping jobs

If a job starts and the resources it relies on are not ready, or you want to reschedule a job based on some other condition, you can get the job to sleep for a specified period and attempt at a later point using the ``Jobs/JobSleep`` error. If a job handler throws this error the job is re-queued to run at the time specified in the error.

```swift
jobService.registerJob(parameters: MyJob.self) { parameters, context in
    guard let resource = getResource(parameters.resourceID) else {
        // resource isn't ready lets sleep for 30 mins
        throw JobSleep(for: .seconds(30*60))
    }
    try await processResource(resource)
}
```

## Job Scheduler

The Jobs framework also comes with a scheduler that allows you to schedule jobs to occur at regular times. You can add a scheduled job using ``Jobs/JobService/addScheduledJob(_:schedule:accuracy:)`` from `JobService`.

```swift
jobService.addScheduledJob(BirthdayRemindersJob(), schedule: .daily(hour: 9))
jobService.addScheduledJob(CleanupStaleSessionDataJob(), schedule: .weekly(day: .sunday, hour: 4))
```

When `JobService` is running it will add jobs to the queue at the scheduled times. You need to ensure all your job schedules are defined before running the service. If your job queue driver supports it, it will add background schedule jobs for cleaning up the underlying storage and rescuing orphaned jobs where a server crashed.

When the `JobService` is run on multiple servers the scheduler process will attempt to gain control of the schedule but only one can have control at any time. Once a scheduler has control it keeps control for a defined period. At regular intervals it will keep extending the time it has control. The other schedulers will continue to attempt to claim control. If the scheduler who has control crashes then no longer than the the length of the two time intervals another scheduler will take control. At that point it will attempt to schedule any missed jobs. With this you can ensure the schedule is always running. You can control the length of the time intervals using the scheduler options in the `JobService` initializer.

```swift
let jobService = JobService(
    .valkey(
        valkeyClient, 
        configuration: .init(queueName: "MyQueue"),
        logger: logger
    ),
    logger: logger,
    options: .init(
        scheduler: .init(schedulerLock: .init(.acquire(every: .seconds(60), for: .seconds(70))))
    )
)
```

### Schedule types

A ``Jobs/Schedule`` can be setup in a number of ways. It includes functions to trigger once every minute, hour, day, month, week day and functions to trigger on multiple minutes, hours, etc.

```swift
jobService.addScheduledJob(TestJobParameters(), schedule: .hourly(minute: 30))
jobService.addScheduledJob(TestJobParameters(), schedule: .yearly(month: 4, date: 1, hour: 8))
jobService.addScheduledJob(TestJobParameters(), schedule: .onMinutes([0,15,30,45]))
jobService.addScheduledJob(TestJobParameters(), schedule: .onDays([.saturday, .sunday], hour: 12, minute: 45))
```

If these aren't flexible enough a `Schedule` can be setup using a five value crontab format. Most crontabs are supported but combinations setting both week day and date are not supported.

```swift
jobService.addScheduledJob(TestJobParameters(), schedule: .crontab("0 12 * * *")) // daily at 12 o'clock
jobService.addScheduledJob(TestJobParameters(), schedule: .crontab("0 */4 * * sat,sun")) // every four hours on Saturday and Sunday
jobService.addScheduledJob(TestJobParameters(), schedule: .crontab("@daily")) // crontab default, every day at midnight 
```

### Schedule accuracy

When the scheduler hits a point to run a job, it adds it to the job queue. This does mean if the job queue is busy, the scheduled job may not execute at the exact time expected. You can mitigate this by running scheduled jobs on a separate queue or if you are using the Postgres driver you can set the priority for scheduled jobs to be higher.

Also you can setup how accurate you want your scheduler to adhere to the schedule regardless of whether the scheduler is running or not. Obviously if your scheduler is not running it cannot schedule jobs. But you can use the `accuracy` parameter of a schedule to indicate what you want your scheduler to do once it comes back online after having been down. 

Setting it to `.all` will schedule a job for every trigger point it missed eg if your scheduler was down for 6 hours and you had a hourly schedule it would push a job to the JobQueue for every one of those hours missed. Setting it to `.latest` will mean it only schedules a job for last trigger point missed. If you don't set the value then it will default to `.latest`.

```swift
jobService.addScheduledJob(
    TestJobParameters(), 
    schedule: .hourly(minute: 30), 
    accuracy: .all
)
```

## Topics

### Reference

- ``JobsValkey``
- ``JobsPostgres``
