# Jobs

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Offload work your server would be doing to another server. 

## Overview

A Job consists of a payload and an execute method to run the job. Swift Jobs provides a framework for pushing jobs onto a queue and processing them at a later point. If the driver backing up the job queue uses persistent storage then a separate server can be used to process the jobs. The module comes with a driver that stores jobs in local memory and uses your current server to process the jobs, but there are also implementations in ``JobsValkey`` and ``JobsPostgres`` that implement the job queue using a Valkey/Redis database or Postgres database. 

### Setting up a Job queue

Before you can start adding or processing jobs you need to setup a Jobs queue to push jobs onto. Below we create a job queue stored in local memory.

```swift
let jobQueue = JobQueue(.memory, logger: logger)
```

### Creating a Job

Creating a job requires an identifier, the parameters for the job and the function that runs the job. We use a struct conforming to ``Jobs/JobParameters`` to define the job parameters and identifier.

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
jobQueue.registerJob(parameters: SendEmailJobParameters.self) { parameters, context in
    try await myEmailService.sendEmail(to: parameters.to, subject: parameters.subject, body: parameters.body)
}
```

Now your job is ready to create. Jobs can be queued up using the function ``Jobs/JobQueue/push(_:options:)`` from `JobQueue`.

```swift
let job = SendEmailJobParameters(
    to: "joe@email.com",
    subject: "Testing Jobs",
    message: "..."
)
jobQueue.push(job)
```

Alternatively you can create a job using a ``Jobs/JobName``. This associates a type with a name, but that type can be used multiple times with different job names.

```swift
let printStringJob = JobName<String>("Print String")
jobQueue.registerJob(printStringJob) { parameters, context in
    print(parameters)
}
```

You then queue your job for execution using ``Jobs/JobQueue/push(_:parameters:options:)``

```swift
jobQueue.push(printStringJob, parameters: "Testing,testing,1,2,3")
```

### Processing Jobs

To start processing jobs on your queue you need a ``Jobs/JobQueueProcessor``. You can create the job processor for a job queue by calling ``Jobs/JobQueue/processor(options:)``. The options passed in when creating your `JobQueueProcessor` includes the parameter `numWorkers` which indicates how many jobs you want to run concurrently. If you want to activate the `JobQueueProcessor` you can call the ``Jobs/JobQueueProcessor/run()`` method but it is preferable to use [Swift Service Lifecycle](https://github.com/swift-server/swift-service-lifecycle) to manage the running of the processor to ensure clean shutdown when your application is shutdown.

```swift
let jobProcessor = jobQueue.processor(options: .init(numWorkers: 8))
let serviceGroup = ServiceGroup(
    services: [server, jobProcessor],
    configuration: .init(gracefulShutdownSignals: [.sigterm, .sigint]),
    logger: logger
)
try await serviceGroup.run()
```
Or it can be added to the array of services that `Application` manages
```swift
let app = Application(...)
app.addServices(jobProcessor)
```
If you want to process jobs on a separate server you will need to use a job queue driver that saves to some external storage eg ``JobsRedis/RedisJobQueue`` or ``JobsPostgres/PostgresJobQueue``.

## Job Scheduler

The Jobs framework comes with a scheduler `Service` that allows you to schedule jobs to occur at regular times. Job schedules are defined using the ``Jobs/JobSchedule`` type.

```swift
var jobSchedule = JobSchedule()
jobSchedule.addJob(BirthdayRemindersJob(), schedule: .daily(hour: 9))
jobSchedule.addJob(CleanupStaleSessionDataJob(), schedule: .weekly(day: .sunday, hour: 4))
```

To get your `JobSchedule` to schedule jobs on a `JobQueue` you need to create the scheduler `Service` and then add it to your `Application` service list or `ServiceGroup`.

```swift
var app = Application(router: router)
app.addService(jobSchedule.scheduler(on: jobQueue, named: "MyScheduler"))
```

### Schedule types

A ``Jobs/Schedule`` can be setup in a number of ways. It includes functions to trigger once every minute, hour, day, month, week day and functions to trigger on multiple minutes, hours, etc.

```swift
jobSchedule.addJob(TestJobParameters(), schedule: .hourly(minute: 30))
jobSchedule.addJob(TestJobParameters(), schedule: .yearly(month: 4, date: 1, hour: 8))
jobSchedule.addJob(TestJobParameters(), schedule: .onMinutes([0,15,30,45]))
jobSchedule.addJob(TestJobParameters(), schedule: .onDays([.saturday, .sunday], hour: 12, minute: 45))
```

If these aren't flexible enough a `Schedule` can be setup using a five value crontab format. Most crontabs are supported but combinations setting both week day and date are not supported.

```swift
jobSchedule.addJob(TestJobParameters(), schedule: .crontab("0 12 * * *")) // daily at 12 o'clock
jobSchedule.addJob(TestJobParameters(), schedule: .crontab("0 */4 * * sat,sun")) // every four hours on Saturday and Sunday
jobSchedule.addJob(TestJobParameters(), schedule: .crontab("@daily")) // crontab default, every day at midnight 
```

### Schedule accuracy

You can setup how accurate you want your scheduler to adhere to the schedule regardless of whether the scheduler is running or not. Obviously if your scheduler is not running it cannot schedule jobs. But you can use the `accuracy` parameter of a schedule to indicate what you want your scheduler to do once it comes back online after having been down. 

Setting it to `.all` will schedule a job for every trigger point it missed eg if your scheduler was down for 6 hours and you had a hourly schedule it would push a job to the JobQueue for every one of those hours missed. Setting it to `.latest` will mean it only schedules a job for last trigger point if it was missed. If you don't set the value then it will default to `.latest`.

```swift
jobSchedule.addJob(TestJobParameters(), schedule: .hourly(minute: 30), accuracy: .all)
```

## See Also

- ``Jobs/JobParameters``
- ``Jobs/JobQueue``
- ``Jobs/JobSchedule``
