# ``/Jobs/JobService``

@Metadata {
    @DocumentationExtension(mergeBehavior: override)
}
Bring together a job queue and job scheduler.

## Overview

Contains both a ``Jobs/JobQueue`` and a ``Jobs/JobSchedule`` and creates the related scheduler and job queue processor services. If supported by the underlying driver it will schedule jobs to cleanup old data, and rescue orphaned jobs from a crashed server.

## Topics

### Job Queue

- ``registerJob(_:)``
- ``push(jobRequest:options:)``
- ``cancelJob(jobID:)``
- ``pauseJob(jobID:)``
- ``resumeJob(jobID:)``

### Job Scheduler

- ``addScheduledJob(_:parameters:schedule:accuracy:)``
- ``addScheduledJob(_:schedule:accuracy:)``
