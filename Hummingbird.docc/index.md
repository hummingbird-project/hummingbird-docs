# Hummingbird Guides

@Metadata {
    @TechnologyRoot
    @PageImage(purpose: icon, source: "logo")
}

Documentation for Hummingbird the lightweight, flexible, modern server framework.

## Hummingbird

Hummingbird is a lightweight and flexible web application framework. It provides a router for directing different endpoints to their handlers, middleware for processing requests before they reach your handlers and processing the responses returned, custom encoding/decoding of requests/responses, TLS and HTTP2.

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
- <doc:RequestContexts>
- <doc:EncodingAndDecoding>
- <doc:MiddlewareGuide>
- <doc:ErrorHandling>
- <doc:LoggingMetricsAndTracing>
- <doc:ServiceLifecycle>
- <doc:Testing>
- <doc:PersistentData>
- <doc:MigratingToV2>

### Authentication

- <doc:AuthenticatorMiddleware>
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

- <doc:Pragmas>
- <doc:TemplateInheritance>
- <doc:Transforms>
- <doc:Lambdas>
- <doc:MustacheSyntax>

## See Also

- ``/Hummingbird``
- ``/HummingbirdCore``
- ``/HummingbirdAuth``
- ``/HummingbirdFluent``
- ``/HummingbirdLambda``
- ``/HummingbirdPostgres``
- ``/HummingbirdRedis``
- ``/HummingbirdTesting``
- ``/HummingbirdWebSocket``
- ``/Jobs``
- ``/Mustache``
