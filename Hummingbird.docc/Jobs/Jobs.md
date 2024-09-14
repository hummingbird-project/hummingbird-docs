# ``Jobs``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Offload work your server would be doing to another server. 

## Overview

A Job consists of a payload and an execute method to run the job. `Jobs` provides a framework for pushing jobs onto a queue and processing them. If the driver backing up the job queue uses persistent storage then a separate server can be used to process the jobs.

## Topics

### Guides

- <doc:JobsGuide>

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

### Scheduler

- ``JobSchedule``
- ``Schedule``

### Error

- ``JobQueueError``

## See Also

- ``Hummingbird``
- ``JobsRedis``
- ``JobsPostgres``
