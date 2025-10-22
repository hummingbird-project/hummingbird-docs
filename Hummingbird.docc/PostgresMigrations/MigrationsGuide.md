# Postgres Migrations

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Managing database structure changes.

## Overview

Database migrations are a controlled set of incremental changes applied to a database. You can use a migration list to transition a database from one state to a new desired state. A migration can involve creating/deleting tables, adding/removing columns, changing types and constraints. The ``PostgresMigrations`` library that comes with HummingbirdPostgres provides support for setting up your own database migrations. 

> Note: If you are using Fluent then you should use the migration support that comes with Fluent.

Each migration includs an `apply` method that applies the change and a `revert` method that reverts the change.

```swift
struct CreateMyTableMigration: DatabaseMigration {
    func apply(connection: PostgresConnection, logger: Logger) async throws {
        try await connection.query(
            """
            CREATE TABLE my_table (
                "id" text PRIMARY KEY,
                "name" text NOT NULL
            )
            """,
            logger: logger
        )
    }

    func revert(connection: PostgresConnection, logger: Logger) async throws {
        try await connection.query(
            "DROP TABLE my_table",
            logger: logger
        )
    }
}
```

As an individual migration can be dependent on the results of a previous migration the order they are applied has to be the same everytime. Migrations allow for database changes to be repeatable, shared and testable without loss of data.

### Adding migrations

You need to create a ``/PostgresMigrations/DatabaseMigrations`` object to store your migrations in. Only create one of these, otherwise you could confuse your database about what migrations need applied. Adding a migration is as simple as calling `add`.

```swift
import HummingbirdPostgres

let migrations = DatabaseMigrations()
await migrations.add(CreateMyTableMigration())
```

### Applying migrations

As you need an active `PostgresClient` to apply migrations you need to run the migrate once you have called `PostgresClient.run`. It is also preferable to have run your migrations before your server is active and accepting connections. The best way to do this is use ``Hummingbird/Application/beforeServerStarts(perform:)``.

```swift
var app = Application(router: router)
// add postgres client as a service to ensure it is active
app.addServices(postgresClient)
app.beforeServerStarts {
    try await migrations.apply(client: postgresClient, logger: logger, dryRun: true)
}
```
You will notice in the code above the parameter `dryRun` is set to true. This is because applying migrations can be a destructive process and should be a supervised. If there is a change in the migration list, with `dryRun` set to true, the `apply` function will throw an error and list the migrations it would apply or revert. At that point you can make a call on whether you want to apply those changes and run the same process again except with `dryRun` set to false.

### Reverting migrations

You can use ``/PostgresMigrations/DatabaseMigrations/revert(client:groups:options:logger:dryRun:)`` to revert all the migrations and will reset your database back to its starting point. If it comes across a migration name in the database it doesn't recognise, it will throw the error ``/PostgresMigrations/DatabaseMigrationError/cannotRevertMigration``. In this situation you have two options.
1) Register the missing migration using ``/PostgresMigrations/DatabaseMigrations/register(_:)``. The system will now know about this migration but it will not apply it.
2) Run the `revert` function again but including either option ``/PostgresMigrations/DatabaseMigrations/RevertOptions/ignoreUnknownMigrations`` or ``/PostgresMigrations/DatabaseMigrations/RevertOptions/removeUnknownMigrations``.

```swift
await migrations.revert(
    client: postgresClient, 
    options: .ignoreUnknownMigrations, 
    logger: logger, 
    dryRun: false
)
```

### Inconsistencies between expected and applied migrations 

If the order your application expects migrations to be applied and the order they have actually been applied is different then when you call ``/PostgresMigrations/DatabaseMigrations/apply(client:groups:options:logger:dryRun:)`` it will throw a ``/PostgresMigrations/DatabaseMigrationError/appliedMigrationsInconsistent`` error. This can occur when you have inserted a new migration in the middle of the migration list, removed a migration from the middle of the migration list or have swapped the order of applying migrations. 

The best way to fix this is to ensure the order of migrations you would like to apply is consistent with the list of already applied migrations in your database. If this is not possible though you can use the function ``/PostgresMigrations/DatabaseMigrations/revertInconsistent(client:groups:options:logger:dryRun:)`` to revert applied migrations until the applied migration list is consistent with the list the application expects. This is a destructive function. Always run it with `dryRun` set to `true` first. With this set, it will output to the log the list of operations it will perform but not actually perform them. 

```swift
await migrations.revertInconsistent(
    client: postgresClient, 
    logger: logger, 
    dryRun: true
)
```

The default operation is to find the first inconsistency in the lists and then revert every migration after that as it cannot be certain they will have been applied correctly. This is obviously very destructive. You have a number of options that affect this operation.
- ``/PostgresMigrations/DatabaseMigrations/RevertInconsistentOptions/ignoreUnknownMigrations`` will ignore any applied migrations the system doesn't know about.
- ``/PostgresMigrations/DatabaseMigrations/RevertInconsistentOptions/removeUnknownMigrations`` will remove any applied migrations the system doesn't know about. This will also revert any migrations that follow the unknown migration. 
- ``/PostgresMigrations/DatabaseMigrations/RevertInconsistentOptions/disableRevertsFollowingRevert`` disables reverting any migrations that follow a migration that has been reverted. You should use this with care as subsequent migrations may depend on the reverted migration. With this option set if it finds a migration that has not been applied in the middle of the applied migrations it will ignore that migration and not revert any subsequent migrations.

This function is provided as a way to fixup inconsistencies but it should not be relied upon. Ensuring the order your migrations are applied is consistent is the best way to proceed.

### Migration groups

A migration group is a group of migrations that can be applied to a database independent of all other migrations outside that group. By default all migrations are added to the `.default` migration group. Each group is applied independently to your database. A group allows for a modular piece of code to add additional migrations without affecting the ordering of other migrations and causing deletion of data.

To create a group you need to extend `/PostgresMigrations/DatabaseMigrationsGroup` and add a new static variable for the migration group id.

```swift
extension DatabaseMigrationGroup {
    public static var myGroup: Self { .init("my_group") }
}
```

Then every migration that belongs to that group must set its group member variable

```swift
extension CreateMyTableMigration {
    var group: DatabaseMigrationGroup { .myGroup }
}
```

You should only use groups if you can guarantee the migrations inside it will always be independent of migrations outside the group. 

The persist driver that come with ``HummingbirdPostgres`` and the job queue driver from ``JobsPostgres`` both use groups to separate their migrations from any the user might add.

## See Also

- ``PostgresMigrations/DatabaseMigration``
- ``PostgresMigrations/DatabaseMigrations``
