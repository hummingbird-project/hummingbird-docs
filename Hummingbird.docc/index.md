# Hummingbird Documentation

@Metadata {
    @TechnologyRoot
    @PageImage(purpose: icon, source: "logo")
}

Documentation for Hummingbird the lightweight, flexible, modern server framework.

## Hummingbird

Hummingbird is a lightweight and flexible web application framework. It provides a router for directing different endpoints to their handlers, middleware for processing requests before they reach your handlers and processing the responses returned, custom encoding/decoding of requests and responses, TLS and HTTP2.

If you're new to Hummingbird, start here: <doc:Todos>

```swift
import Hummingbird
// create router and add a single GET /hello route
let router = Router()
    .get("hello") { request, _ -> String in
        return "Hello"
    }
// create application using router
let app = Application(router: router)
// run hummingbird application
try await app.runService()
```

Below is a list of guides and tutorials to help you get started with building your own Hummingbird based web application.

## Topics

### Getting Started

- <doc:GettingStarted>
- <doc:Todos>

### Hummingbird Server

- <doc:RouterGuide>
- <doc:RequestDecoding>
- <doc:ResponseEncoding>
- <doc:RequestContexts>
- <doc:MiddlewareGuide>
- <doc:ErrorHandling>
- <doc:LoggingMetricsAndTracing>
- <doc:RouterBuilderGuide>
- <doc:ServerProtocol>
- <doc:ServiceLifecycle>
- <doc:Testing>
- <doc:PersistentData>
- <doc:MigratingToV2>

### Authentication

- <doc:AuthenticatorMiddlewareGuide>
- <doc:Sessions>
- <doc:OneTimePasswords>

### WebSockets

- <doc:WebSocketServerUpgrade>
- <doc:WebSocketClientGuide>

### Database Integration

- <doc:MigrationsGuide>
- <doc:Fluent>
- <doc:MongoKitten>

### Offloading work

- <doc:JobsGuide>

### Mustache

- <doc:MustacheSyntax>
- <doc:MustacheFeatures>

### Examples

- <doc:ExamplesGuide>

### Reference Documentation

- ``/Hummingbird``
- ``/HummingbirdCore``
- ``/HummingbirdAuth``
- ``/HummingbirdCompression``
- ``/HummingbirdFluent``
- ``/HummingbirdLambda``
- ``/HummingbirdPostgres``
- ``/HummingbirdValkey``
- ``/HummingbirdWebSocket``
- ``/Jobs``
- ``/Mustache``
- ``/PostgresMigrations``
- ``/WSClient``
