# ``HummingbirdJobs``

Offload work your server would be doing to another server. 

## Overview

A Job consists of some metadata and an execute method to run the job. You can setup HummingbirdJobs to use different drivers for storing job metadata. The module comes with a driver that stores jobs in local memory and uses your current server to process the jobs, but there is also an implementation ``/HummingbirdJobsRedis`` that comes with the hummingbird-redis package that stores jobs in a Redis database. 

### Setting up Jobs

Before you can start adding or processing jobs you need to setup a Jobs queue to push jobs onto. Below we create a job queue stored in local memory.
```swift
let jobQueue = JobQueue(.memory, numWorkers: 1, logger: logger)
```

### Creating a Job

First you must define your job. A job consists of three things, an identifier, the parameters required to run the job and a function that executes the job. 

First we define the parameters and the identifier. The parameters need to conform to `Sendable` and `Codable`. 

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
If you want to process jobs on a separate server you will need to use a job queue driver that saves to some external storage eg ``HummingbirdJobsRedis/RedisQueue``.

## Topics

### Jobs

- ``JobContext``
- ``JobDefinition``
- ``JobIdentifier``
- ``JobParameters``

### Queues

- ``JobQueue``
- ``JobQueueDriver``
- ``QueuedJob``
- ``MemoryQueue``

### Error

- ``JobQueueError``

## See Also

- ``Hummingbird``
- ``HummingbirdJobsRedis``
