# ``/Jobs/JobQueueDriver``

@Metadata {
    @DocumentationExtension(mergeBehavior: override)
}
Protocol for job queue driver

## Overview

Defines the requirements for job queue implementation.

## Topics

### Associated Types

- ``JobID``

### Lifecycle

- ``waitUntilReady()``
- ``stop()``
- ``shutdownGracefully()``

### Jobs

- ``registerJob(_:)``
- ``push(_:options:)``
- ``finished(jobID:)``
- ``failed(jobID:error:)``
- ``retry(_:jobRequest:options:)``

### Implementations

- ``memory``
- ``valkey(_:configuration:logger:)``
- ``postgres(client:migrations:configuration:logger:)``
