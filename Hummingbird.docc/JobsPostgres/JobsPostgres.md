# ``JobsPostgres``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Postgres implementation for Hummingbird jobs framework

## Overview

Hummingbird Jobs Queue driver using PostgresNIO.

The postgres job queue driver uses ``PostgresMigrations/DatabaseMigration`` from the ``PostgresMigrations`` library to perform the database migrations need for the driver. These need to be added to the 

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
    numWorkers: 4, 
    logger: logger
)
let migrationService = PostgresMigrationService(
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

## Topics

### Job Queue

- ``PostgresJobQueue``

## See Also

- ``Jobs``
- ``JobsRedis``
- ``Hummingbird``
- ``HummingbirdPostgres``
