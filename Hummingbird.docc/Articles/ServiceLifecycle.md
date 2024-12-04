# Service Lifecycle

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Integration with Swift Service Lifecycle

## Overview

To provide a mechanism to cleanly start and shutdown a Hummingbird application we have integrated with [Swift Service Lifecycle](https://github.com/swift-server/swift-service-lifecycle). This provides lifecycle management for service startup, shutdown and shutdown triggering by signals such as SIGINT and SIGTERM.

## Service Lifecycle

To use Swift Service Lifecycle you have to conform the service you want managed to the protocol [`Service`](https://swiftpackageindex.com/swift-server/swift-service-lifecycle/main/documentation/servicelifecycle/service). Internally this needs to call `withGracefulShutdownHandler` to handle graceful shutdown when we receive a shutdown signal.

```swift
struct MyService: Service {
    func run() async throws {
        withGracefulShutdownHandler {
            // run service
        } onGracefulShutdown {
            // shutdown service
        }
    }
}
```

Once you have this setup you can then include the service in a list of services added to a service group and have its lifecycle managed.

```swift
let serviceGroup = ServiceGroup(
    configuration: .init(
        services: [MyService(), MyOtherService()],
        gracefulShutdownSignals: [.sigterm, .sigint]
        logger: logger
    )
)
try await serviceGroup.run()
```

## Hummingbird Integration

``Application`` conforms to `Service` and also provides a helper function that constructs the `ServiceGroup` including the application and then runs it.

```swift
let app = Application(router: router)
try await app.runService()
```

All of the types that Hummingbird introduces that require some form of lifecycle management conform to `Service`. ``Application`` holds an internal `ServiceGroup` and any service you want managed can be added to the internal group using ``Application/addServices(_:)``.

```swift
var app = Application(router: router)
app.addServices(postgresClient, sessionStorage)
try await app.runService()
```

## Managing server startup

In some situations you might want some services to start up before you startup your HTTP server, for instance when doing a database migration. With ``Application`` you can add processes to run before starting up the server, but while other services are running using ``Application/beforeServerStarts(perform:)``. You can call `beforeServerStarts` multiple times to add multiple processes to be run before we startup the server.

```swift
var app = Application(router: router)
app.addServices(dbClient)
app.beforeServerStarts {
    try await dbClient.migrate()
}
try await app.runService()
```

Read the Swift Service Lifecycle [documentation](https://swiftpackageindex.com/swift-server/swift-service-lifecycle/main/documentation/servicelifecycle) to find out more.

## See Also

- ``Application``
