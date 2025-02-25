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

- ``onInit()``
- ``stop()``
- ``shutdownGracefully()``

### Jobs

- ``push(_:options:)``
- ``finished(jobID:)``
- ``failed(jobID:error:)``

### Metadata

- ``getMetadata(_:)``
- ``setMetadata(key:value:)``

### Implementations

- ``memory``
- ``redis(_:configuration:)``
- ``postgres(client:migrations:configuration:logger:)``
