# ``JobsPostgres``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Postgres implementation for Hummingbird jobs framework

## Overview

JobsPostgres provides a Hummingbird Jobs Queue driver using [PostgresNIO](https://api.vapor.codes/postgresnio/documentation/postgresnio/) and the ``PostgresMigrations`` library.

## Setup

The Postgres job queue driver uses `PostgresClient` from `PostgresNIO` and ``PostgresMigrations/DatabaseMigrations`` from the ``PostgresMigrations`` library to perform the database migrations needed for the driver.

The Postgres job queue configuration includes two values.
- `pollTime`: This is the amount of time between the last time the queue was empty and the next time the driver starts looking for pending jobs.
- `queueName`: Name of queue used to differentiate itself from other queues.

```swift
import JobsPostgres
import PostgresNIO
import ServiceLifecycle

let postgresClient = PostgresClient(...)
let postgresMigrations = DatabaseMigrations()
let jobQueue = JobQueue(
    .postgres(
        client: postgresClient,
        migrations: postgresMigrations,
        configuration: .init(
            pollTime: .milliseconds(50),
            queueName: "MyJobQueue"
        ),
        logger: logger
    ), 
    logger: logger
)
```

The easiest way to ensure the migrations are run is to use the ``PostgresMigrations/DatabaseMigrationService`` and add that as a `Service` to your `ServiceGroup`. The job queue service will not run until the migrations have been run in either `dryRun` mode or for real.

```swift
let migrationService = DatabaseMigrationService(
    client: postgresClient,
    migrations: postgresMigrations,
    logger: logger,
    dryRun: false
)
let serviceGroup = ServiceGroup(
    configuration: .init(
        services: [postgresClient, migrationService, jobQueue],
        gracefulShutdownSignals: [.sigterm, .sigint],
        logger: jobQueue.queue.logger
    )
)
try await serviceGroup.run()
```

## Additional Features

There are features specific to the Postgres Job Queue implementation. Some of these are available in other queues and others not.

### Push Options

When pushing a job to the queue there are a couple of options you can provide. 

#### Delaying jobs

As with all queue drivers you can add a delay before a job is processed. The job will sit in the pending queue and will not be available for processing until time has passed its delay until time.

```swift
// Add TestJob to the queue, but don't process it for 2 minutes
try await jobQueue.push(TestJob(), options: .init(delayUntil: .now + 120))
```

#### Job Priority

The postgres queue allows you to give a job a priority. Jobs with higher priorities are run before jobs with lower priorities. There are five priorities `.lowest`, `.lower`, `.normal`, `.higher` and `.highest`. 

```swift
// Add BackgroundJob to the queue. It will only get processed if there are no jobs
// with a higher priority on the queue.
try await jobQueue.push(BackgroundJob(), options: .init(priority: .lowest))
```

### Cancellation

The ``JobsPostgres/PostgresJobQueue`` conforms to protocol ``Jobs/CancellableJobQueue``. This requires support for cancelling jobs that are in the pending queue. It adds one new function ``JobsPostgres/PostgresJobQueue/cancel(jobID:)``. If you supply this function with the `JobID` returned by ``JobsPostgres/PostgresJobQueue/push(_:options:)`` it will remove it from the pending queue. 

```swift
// Add TestJob to the queue and immediately cancel it
let jobID = try await jobQueue.push(TestJob(), options: .init(delayUntil: .now + 120))
try await jobQueue.cancel(jobID: jobID)
```

### Pause and Resume

The ``JobsPostgres/PostgresJobQueue`` conforms to protocol ``Jobs/ResumableJobQueue``. This requires support for pausing and resuming jobs that are in the pending queue. It adds two new functions ``JobsPostgres/PostgresJobQueue/pause(jobID:)`` and ``JobsPostgres/PostgresJobQueue/resume(jobID:)``. If you supply these function with the `JobID` returned by ``JobsPostgres/PostgresJobQueue/push(_:options:)`` you can remove from the pending queue and add them back in at a later date.

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
    .postgres(
        client: postgresClient,
        migrations: postgresMigrations,
        configuration: .init(
            queueName: "MyJobQueue", 
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

If you do opt to retain jobs after processing you will probably eventually want to clean them up. The Postgres queue provides a method `cleanup` which allows you to remove or attempt to re-run jobs based on what state they are in. You should be careful not to do anything to pending or processing jobs while the job queue is being processed as it might confuse the job processor.

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

- ``PostgresJobQueue``

## See Also

- ``Jobs``
- ``JobsValkey``
- ``Hummingbird``
- ``HummingbirdPostgres``
