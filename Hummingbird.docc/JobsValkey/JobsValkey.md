# ``JobsValkey``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Valkey/Redis implementation for Hummingbird jobs framework

## Overview

Hummingbird Jobs Queue driver using [valkey-swift](https://github.com/valkey-io/valkey-swift).

#### Using HummingbirdValkey

If you choose to use `HummingbirdValkey` you can setup a JobQueue using `valkey-swift` as follows

```swift
let valkeyClient = try ValkeyClient(
    .hostname(valkeyHost, port: 6379),
    logger: logger
)
let jobQueue = JobQueue(
    .valkey(
        valkeyClient, 
        configuration: .init(
            queueKey: "MyJobQueue", 
            pollTime: .milliseconds(50)
        )
    ),
    logger: logger
)
let serviceGroup = ServiceGroup(
    configuration: .init(
        services: [valkeyClient, jobQueue],
        gracefulShutdownSignals: [.sigterm, .sigint],
        logger: logger
    )
)
try await serviceGroup.run()
```
The Valkey job queue configuration includes two values.
- `queueKey`: Prefix to all the Valkey keys used to store queues.
- `pollTime`: This is the amount of time between the last time the queue was empty and the next time the driver starts looking for pending jobs.

## Additional Features

There are features specific to the Valkey Job Queue implementation.

### Push Options

When pushing a job to the queue there are a number of options you can provide. 

#### Delaying jobs

As with all queue drivers you can add a delay before a job is processed. The job will sit in the pending queue and will not be available for processing until time has passed its delay until time.

```swift
// Add TestJob to the queue, but don't process it for 2 minutes
try await jobQueue.push(TestJob(), options: .init(delayUntil: .now + 120))
```

### Cancellation

The ``JobsValkey/ValkeyJobQueue`` conforms to protocol ``Jobs/CancellableJobQueue``. This requires support for cancelling jobs that are in the pending queue. It adds one new function ``JobsValkey/ValkeyJobQueue/cancel(jobID:)``. If you supply this function with the `JobID` returned by ``JobsValkey/ValkeyJobQueue/push(_:options:)`` it will remove it from the pending queue. 

```swift
// Add TestJob to the queue and immediately cancel it
let jobID = try await jobQueue.push(TestJob(), options: .init(delayUntil: .now + 120))
try await jobQueue.cancel(jobID: jobID)
```

### Pause and Resume

The ``JobsValkey/ValkeyJobQueue`` conforms to protocol ``Jobs/ResumableJobQueue``. This requires support for pausing and resuming jobs that are in the pending queue. It adds two new functions ``JobsValkey/ValkeyJobQueue/pause(jobID:)`` and ``JobsValkey/ValkeyJobQueue/resume(jobID:)``. If you supply these function with the `JobID` returned by ``JobsValkey/ValkeyJobQueue/push(_:options:)`` you can remove from the pending queue and add them back in at a later date.

```swift
// Add TestJob to the queue and immediately remove it and then add it back to the queue
let jobID = try await jobQueue.push(TestJob(), options: .init(delayUntil: .now + 120))
try await jobQueue.pause(jobID: jobID)
try await jobQueue.resume(jobID: jobID)
```

### Job retention

The queue has options to retain jobs once it has finished with them depending on status. By default the queue will retain failed jobs and drop cancelled or completed jobs, but these decisions are configurable.

```swift
let jobQueue = JobQueue(
    .valkey(
        valkeyClient, 
        configuration: .init(
            queueKey: "MyJobQueue", 
            retentionPolicy: .init(
                completedJobs: .retain, 
                failedJobs: .retain, 
                cancelledJobs: .doNotRetain
            )
        )
    ),
    logger: logger
)
```

### Job queue cleanup

If you do opt to retain jobs after processing you will probably eventually want to clean them up. The Valkey queue provides a method `cleanup` which allows you to remove or attempt to re-run jobs based on what state they are in. You should be careful not to do anything to pending or processing jobs while the job queue is being processed as it might confuse the job processor.

```swift
jobQueue.queue.cleanup(
    pendingJobs: .doNothing,
    processingJobs: .doNothing,
    completedJobs: .remove(maxAge: .seconds(7*24*60*60)),
    failedJobs: .rerun,
    cancelledJobs: .remove, 
)
```

#### Scheduling cleanup

Given this is a job you will probably want to do regularly the queue also provides a job you can use in conjunction with the `JobScheduler` that will do the cleanup for you. 

```swift
var jobSchedule = JobSchedule()
jobSchedule.addJob(
    jobQueue.queue.cleanupJob,
    parameters: .init(completedJobs: .remove, failedJobs: .rerun, cancelledJobs: .remove),
    schedule: .weekly(day: .sunday)
)
```

You can find out more about the Job scheduler in the Jobs guide <doc:JobsGuide#Job-Scheduler>

## Topics

### Job Queue

- ``ValkeyJobQueue``

## See Also

- ``Jobs``
- ``JobsPostgres``
- ``Hummingbird``
