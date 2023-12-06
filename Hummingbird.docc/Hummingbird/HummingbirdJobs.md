# ``HummingbirdJobs``

Offload work your server would be doing to another server. 

## Overview

A Job consists of some metadata and an execute method to run the job. You can setup HummingbirdJobs to use different drivers for storing job metadata. The module comes with a driver that stores jobs in local memory and uses your current server to process the jobs, but there is also an implementation ``/HummingbirdJobsRedis`` that comes with the hummingbird-redis package that stores jobs in a Redis database. 

### Setting up Jobs

Before you can start adding or processing jobs you need to setup a Jobs queue to push jobs onto. Below we create a job queue stored in local memory.
```swift
let jobQueue = HBMemoryJobQueue()
```

### Creating a Job

First you must define your job. Create an object that inherits from `HBJob`. This protocol requires you to implement a static variable `name` and a function `func execute(on:logger)`. The `name` variable should be unique to this job definition. It is used in the serialisation of the job. The `execute` function does the work of the job and returns an `EventLoopFuture` that should be fulfilled when the job is complete. Below is an example of a job that calls a `sendEmail()` function.
```swift
struct SendEmailJob: HBJob {
    static let name = "SendEmail"
    let to: String
    let subject: String
    let message: String
    
    /// do the work
    func execute(logger: Logger) async throws {
        return try await sendEmail(to: self.to, subject: self.subject, message: self.message)
    }
}
```
Before you can use this job you have to register it. 
```swift
SendEmailJob.register()
```
Now you job is ready to create. Jobs can be queued up using the function `push` on `HBJobQueue`.
```swift
let job = SendEmailJob(
    to: "joe@email.com",
    subject: "Testing Jobs",
    message: "..."
)
jobQueue.push(job: job)
```

### Processing Jobs

To process jobs you need to create a ``HBJobQueueHandler``. This defines the job queue it should service and how many jobs will be processed concurrently. 

The ``HBJobQueueHandler`` conforms to `Service` from Swift Service Lifecycle so can be added to a `ServiceGroup`
```swift
let serviceGroup = ServiceGroup(
    services: [server, jobQueueHandler],
    configuration: .init(gracefulShutdownSignals: [.sigterm, .sigint]),
    logger: logger
)
try await serviceGroup.run()
```
Or it can be added to the array of jobs that `HBApplication` manages
```swift
let app = HBApplication(...)
app.addService(jobQueueHandler)
```
If you are running your job queue handler on a separate server you will need to use a job queue driver that saves to some external storage eg ``HBRedisJobQueue``.

## Topics

### Jobs

- ``HBJob``
- ``JobIdentifier``
- ``HBJobInstance``

### Queues

- ``HBJobQueue``
- ``HBQueuedJob``
- ``HBMemoryJobQueue``
- ``HBJobQueueHandler``

### Error

- ``JobQueueError``

## See Also

- ``Hummingbird``
- ``HummingbirdJobsRedis``
