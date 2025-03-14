# ``HummingbirdPostgres``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

`PostgresMigrations` provides a system for managing migrations on a Postgres database.s

`HummingbirdPostgres` provides a Postgres implementation of the persist framework. It uses `PostgresClient` from [PostgresNIO](https://github.com/vapor/postgres-nio) as its database client.

To add `HummingbirdPostgres` to your project, run the following command in your Terminal:

```sh
# From the root directory of your project
# Where Package.swift is located

# Add the package to your dependencies
swift package add-dependency https://github.com/hummingbird-project/hummingbird-postgres.git --from 0.5.4

# Add the target dependency to your target
swift package add-target-dependency HummingbirdPostgres <MyApp> --package hummingbird-postgres
```

Make sure to replace `<MyApp>` with the name of your App's target.

```swift
import PostgresMigrations
import Logging
import PostgresNIO

 struct MyFirstMigration: DatabaseMigration {
    func apply(connection: PostgresConnection, logger: Logger) async throws {
        // Run any queries you need to apply the migration
        // For example, create a table
        try await connection.query("CREATE TABLE my_table (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), name TEXT NOT NULL)", logger: logger)
    }
    func revert(connection: PostgresConnection, logger: Logger) async throws {
        // Revert the migration
        // For example, drop the table
        try await connection.query("DROP TABLE my_table", logger: logger)
    }
}
```

Add your migrations to the `PostgresMigrations` group.

```swift
 // Connect to your database
let postgresClient: PostgresClient = ...

// Create a migrations instances
let migrations = DatabaseMigrations()

// Register your migration(s)
await migrations.add(MyFirstMigration())

// Run the migrations
try await migrations.apply(
    client: postgresClient,
    logger: Logger(label: "com.example.myapp.migrations"),
    dryRun: false
)
```

## Topics

### Persist

- ``PostgresPersistDriver``

## See Also

- ``PostgresMigrations``
- ``JobsPostgres``

