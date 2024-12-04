# ``HummingbirdFluent``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Integration with Vapor's Fluent ORM framework.

```swift
let fluent = Fluent()
// add sqlite database
fluent.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)

// add router with one route to return a Todo type
let router = Router()
router.get("todo/{id}") { request, context in
    let id = try await context.parameters.require("id", as: UUID.self)
    return Todo.find(id, on: fluent.db())
}

var app = Application(router: router)
// add fluent as a service to manage its lifecycle
app.addServices(fluent)
try await app.runService()
```

## Storage

HummingbirdFluent provides a driver for the persist framework to store key, value pairs between requests.

```swift
let fluent = Fluent()
// add sqlite database
fluent.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
let persist = FluentPersistDriver(fluent: fluent)
if doingMigration {
    // fluent persist driver requires a migrate the first time you run
    try await fluent.migrate()
}
let router = Router()
// return value from sqlite database
router.get("{id}") { request, context -> String? in
    let id = try context.parameters.require("id")
    try await persist.get(key: id, as: String.self)
}
// set value in sqlite database
router.put("{id}") { request, context -> String? in
    let id = try context.parameters.require("id")
    let value = try request.uri.queryParameters.require("value")
    try await persist.set(key: id, value: value)
}
var app = Application(router: router)
// add fluent and persist driver as services to manage their lifecycle
app.addServices(fluent, persist)
try await app.runService()
```

For more information:
- Follow the tutorial: <doc:Fluent>
- Read the [Fluent docs](https://docs.vapor.codes/fluent/overview/)

## Topics

### Fluent

- ``Fluent``
- ``FluentMigrations``

### Storage

- ``FluentPersistDriver``
