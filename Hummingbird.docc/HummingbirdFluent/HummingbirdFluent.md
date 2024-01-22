# ``HummingbirdFluent``

Integration with Vapor Fluent ORM framework.

```swift
let fluent = HBFluent()
// add sqlite database
fluent.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)

// add router with one route to return a Todo type
let router = HBRouter()
router.get("todo/{id}") { request, context in
    let id = try await context.parameters.get("id", as: UUID.self)
    return Todo.find(id, on: fluent.db())
}

var app = HBApplication(router: router)
// add fluent as a service to manage its lifecycle
app.addServices(fluent)
try await app.runService()
```

Read the [Vapor docs](https://docs.vapor.codes/fluent/overview/) for more information on Fluent.

## Topics

### Fluent

- ``HBFluent``

### Storage

- ``HBFluentPersistDriver``

## See Also

- ``Hummingbird``
