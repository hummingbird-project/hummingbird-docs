# Hummingbird

@Metadata {
    @TechnologyRoot
}

Lightweight, flexible, modern server framework written in Swift.

## Hummingbird

Hummingbird is a lightweight and flexible web application framework. It provides a router for directing different endpoints to their handlers, middleware for processing requests before they reach your handlers and processing the responses returned, custom encoding/decoding of requests/responses, TLS and HTTP2.

```swift
import Hummingbird

// create router and add a single GET /hello route
let router = Router()
router.get("hello") { request, _ -> String in
    return "Hello"
}
// create application using router
let app = Application(
    router: router,
    configuration: .init(address: .hostname("127.0.0.1", port: 8080))
)
// run hummingbird application
try await app.runService()
```

### Hummingbird Extensions

Hummingbird is designed to require the least number of dependencies possible, but this means many features are unavailable to the core libraries. Additional features are provided through extensions. The Hummingbird repository comes with additional modules

- ``HummingbirdJobs``: framework for pushing work onto a queue to be processed outside of a request (possibly by another server instance)
- ``HummingbirdTLS``: TLS support.
- ``HummingbirdHTTP2``: Support for HTTP2 upgrades.

- ``HummingbirdTesting``: helper functions to aid testing Hummingbird projects.

## Topics

### Getting Started

- <doc:GettingStarted>

### Guides

- <doc:MigratingToV2>
- <doc:RouterGuide>
- <doc:RequestContexts>
- <doc:EncodingAndDecoding>
- <doc:MiddlewareGuide>
- <doc:ErrorHandling>
- <doc:LoggingMetricsAndTracing>
- <doc:ServiceLifecycle>
- <doc:Testing>
- <doc:PersistentData>
- <doc:JobsGuide>
- <doc:AuthenticatorMiddleware>
- <doc:Sessions>
- <doc:OneTimePasswords>

### Tutorials

- <doc:Todos>

## See Also

- ``/Hummingbird``
- ``/HummingbirdCore``
- ``/HummingbirdAuth``
- ``/HummingbirdFluent``
- ``/HummingbirdJobs``
- ``/HummingbirdLambda``
- ``/Mustache``
- ``/HummingbirdRedis``
- ``/HummingbirdTesting``
- ``/HummingbirdWebSocket``
