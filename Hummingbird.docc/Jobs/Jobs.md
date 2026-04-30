# ``Jobs``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Durable job execution. Offload work your server would be doing to another server. 

## Overview

A Job consists of a payload and an execute method to run the job. `Jobs` provides a framework for pushing jobs onto a queue and processing them. If the driver backing up the job queue uses persistent storage then a separate server can be used to process the jobs.

## Getting started

The Job queue support can be found in the [swift-jobs](https://github.com/hummingbird-project/swift-jobs) repository. To add the library as a dependency in your project use the following command line.

```
swift package add-dependency https://github.com/hummingbird-project/swift-jobs.git --from "1.1.0"
```

To add the target dependency to your application use the following, replacing the `<MyApp>` text with the name of your application target.

```
swift package add-target-dependency Jobs <MyApp> --package swift-jobs
```

## Topics

### Articles

- <doc:JobsGuide>

### Jobs

- ``JobName``
- ``JobDefinition``
- ``JobParameters``
- ``JobExecutionContext``
- ``JobService``

### Queues

- ``JobQueue``
- ``JobQueueProtocol``
- ``JobQueueOptions``
- ``JobQueueContext``
- ``JobQueueProcessor``
- ``JobQueueProcessorOptions``
- ``JobQueueDriver``
- ``MemoryQueue``
- ``JobOptionsProtocol``

### Optional features

- ``CancellableJobQueue``
- ``ResumableJobQueue``
- ``JobMetadataDriver``
- ``JobMetadataKey``

### Scheduler

- ``JobSchedule``
- ``Schedule``

### Middleware

- ``JobMiddleware``
- ``MetricsJobMiddleware``
- ``TracingJobMiddleware``
- ``JobMiddlewareBuilder``
- ``JobPushQueueContext``
- ``JobPopQueueContext``
- ``JobCompletedQueueContext``

### Error

- ``JobQueueError``

### JobQueue Drivers

- ``AnyDecodableJob``
- ``JobInstanceProtocol``
- ``JobInstanceData``
- ``JobQueueResult``
- ``JobRegistry``
- ``JobRequest``
- ``JobRetryOptions``

### Retry

- ``JobRetryStrategy``
- ``ExponentialJitterJobRetryStrategy``
- ``NoRetryJobRetryStrategy``
- ``JobSleep``

## See Also

- ``JobsValkey``
- ``JobsPostgres``
