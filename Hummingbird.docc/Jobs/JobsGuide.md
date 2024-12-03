# Jobs

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Offload work your server would be doing to another server. 

## Overview

A Job consists of a payload and an execute method to run the job. HummingbirdJobs provides a framework for pushing jobs onto a queue and processing them at a later point. If the driver backing up the job queue uses persistent storage then a separate server can be used to process the jobs. The module comes with a driver that stores jobs in local memory and uses your current server to process the jobs, but there are also implementations in ``JobsRedis`` and ``JobsPostgres`` that implemeent the job queue using a Redis database or Postgres database. 

### Setting up a Job queue

Before you can start adding or processing jobs you need to setup a Jobs queue to push jobs onto. Below we create a job queue stored in local memory that will process four jobs concurrently.

```swift
let jobQueue = JobQueue(.memory, numWorkers: 4, logger: logger)
```

### Creating a Job

First you must define your job. A job consists of three things, an identifier, the parameters required to run the job and a function that executes the job. 

We use a struct conforming to ``Jobs/JobParameters`` to define the job parameters and identifier.

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

Now your job is ready to create. Jobs can be queued up using the function `push` on `JobQueue`.

```swift
let job = SendEmailJobParameters(
    to: "joe@email.com",
    subject: "Testing Jobs",
    message: "..."
)
jobQueue.push(job)
```

### Processing Jobs

When you create a `JobQueue` the `numWorkers` parameter indicates how many jobs you want serviced concurrently by the job queue. If you want to activate these workers you need to add the job queue to your `ServiceGroup`.

```swift
let serviceGroup = ServiceGroup(
    services: [server, jobQueue],
    configuration: .init(gracefulShutdownSignals: [.sigterm, .sigint]),
    logger: logger
)
try await serviceGroup.run()
```
Or it can be added to the array of services that `Application` manages
```swift
let app = Application(...)
app.addServices(jobQueue)
```
If you want to process jobs on a separate server you will need to use a job queue driver that saves to some external storage eg ``JobsRedis/RedisJobQueue`` or ``JobsPostgres/PostgresJobQueue``.
