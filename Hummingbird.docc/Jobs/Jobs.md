# ``Jobs``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Offload work your server would be doing to another server. 

## Overview

A Job consists of a payload and an execute method to run the job. `Jobs` provides a framework for pushing jobs onto a queue and processing them. If the driver backing up the job queue uses persistent storage then a separate server can be used to process the jobs.

## Topics

### Jobs

- ``JobContext``
- ``JobDefinition``
- ``JobParameters``

### Queues

- ``JobQueue``
- ``JobQueueOptions``
- ``JobOptions``
- ``JobQueueDriver``
- ``MemoryQueue``

### Scheduler

- ``JobSchedule``
- ``Schedule``

### Middleware

- ``JobMiddleware``
- ``MetricsJobMiddleware``
- ``TracingJobMiddleware``
- ``JobMiddlewareBuilder``

### Error

- ``JobQueueError``

### JobQueue Drivers

- ``AnyDecodableJob``
- ``JobInstanceProtocol``
- ``JobInstanceData``
- ``JobQueueResult``
- ``JobRegistry``
- ``JobRequest``

## See Also

- ``JobsRedis``
- ``JobsPostgres``
