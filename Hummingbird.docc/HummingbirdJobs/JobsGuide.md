# Jobs

Offload work your server would be doing to another server. 

## Overview

A Job consists of a payload and an execute method to run the job. HummingbirdJobs provides a framework for pushing jobs onto a queue and processing them at a later point. If the driver backing up the job queue uses persistent storage then a separate server can be used to process the jobs. The module comes with a driver that stores jobs in local memory and uses your current server to process the jobs, but there are also implementations in ``/HummingbirdJobsRedis`` and ``HummingbirdJobsPostgres`` that implemeent the job queue using a Redis database or Postgres database. 

### Setting up Jobs

Before you can start adding or processing jobs you need to setup a Jobs queue to push jobs onto. Below we create a job queue stored in local memory.
```swift
let jobQueue = JobQueue(.memory, numWorkers: 1, logger: logger)
```

### Creating a Job

First you must define your job. A job consists of three things, an identifier, the parameters required to run the job and a function that executes the job. 

First we define the parameters and the identifier. The parameters need to conform to `Sendable` and `Codable`. Note when adding the identifier you are extending `JobIdentifier<JobParameterType>` and not just `JobIdentifier`.

```swift
struct SendEmailJobParameters: Codable, Sendable {
    let to: String
    let subject: String
    let body: String
}

extension JobIdentifier<SendEmailJobParameters> {
    static let sendEmailJob: Self { "SendEmail" }
}
```

Then we register the job with a job queue and also provide a closure that executes the job.

```swift
jobQueue.registerJob(id: .sendEmailJob) { parameters, context in
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
jobQueue.push(id: .sendEmailJob, .init(
    to: "john@email.com",
    subject: "Test email",
    body: "Hello?"
))
```
### Job parameters

As an alternative to creating a parameter type and separate identifier you can create a type the conforms to ``/HummingbirdJobs/JobParameters`` to define both the parameters and identifier in one place.

```swift
struct SendEmailJobParameters: JobParameters {
    static let jobID = "SendEmail"
    let to: String
    let subject: String
    let body: String
}

Registering the job will then be done with

```swift
jobQueue.registerJob(parameters: SendEmailJobParameters.self) { parameters, context in
    try await myEmailService.sendEmail(to: parameters.to, subject: parameters.subject, body: parameters.body)
}
```

And requesting a job be executed is done with

```swift
let job = SendEmailJobParameters(
    to: "joe@email.com",
    subject: "Testing Jobs",
    message: "..."
)
jobQueue.push(job)
```

### Processing Jobs

When you create a `JobQueue` the `numWorkers` parameter indicates how many workers you want servicing the job queue. If you want to activate these workers you need to add the job queue to your `ServiceGroup`.

```swift
let serviceGroup = ServiceGroup(
    services: [server, jobQueue],
    configuration: .init(gracefulShutdownSignals: [.sigterm, .sigint]),
    logger: logger
)
try await serviceGroup.run()
```
Or it can be added to the array of jobs that `Application` manages
```swift
let app = Application(...)
app.addServices(jobQueue)
```
If you want to process jobs on a separate server you will need to use a job queue driver that saves to some external storage eg ``HummingbirdJobsRedis/RedisQueue`` or ``HummingbirdJobsPostgres/PostgresQueue``.

## Topics

### Reference

- ``/HummingbirdJobs/JobIdentifier``
- ``/HummingbirdJobs/JobQueue``
- ``/HummingbirdJobs/JobParameters``
- ``/HummingbirdJobs/JobDefinition``

## See Also

- ``HummingbirdJobs``
- ``HummingbirdJobsRedis``
- ``HummingbirdJobsPostgres``
