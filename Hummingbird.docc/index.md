# Hummingbird

@Metadata {
    @TechnologyRoot
}

Lightweight, flexible, modern server framework written in Swift.

## HummingbirdCore

HummingbirdCore contains a Swift NIO based server framework. The server framework `Server` can be used to support many protocols but is primarily designed to support HTTP. By default it is setup to be an HTTP/1.1 server, but it can support TLS and HTTP2 via the `HummingbirdTLS` and `HummingbirdHTTP2` modules.

HummingbirdCore can be used separately from Hummingbird if you want to write your own web application framework.

## Hummingbird

Hummingbird is a lightweight and flexible web application framework that runs on top of HummingbirdCore. It is designed to require the minimum number of dependencies and makes no use of Foundation.

It provides a router for directing different endpoints to their handlers, middleware for processing requests before they reach your handlers and processing the responses returned, custom encoding/decoding of requests/responses, TLS and HTTP2.

```swift
import Hummingbird

// create router and add a single GET /hello route
let router = Router()
router.get("hello") { request, _ -> String in
    return "Hello"
}
// create application using router
let app = Application(
    responder: router.buildResponder(),
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

### Guides

- <doc:MigratingToV2>
- <doc:Router>
- <doc:RequestContexts>
- <doc:EncodingAndDecoding>
- <doc:ErrorHandling>
- <doc:LoggingMetricsAndTracing>
- <doc:PersistentData>
- <doc:ServiceLifecycle>
- <doc:Testing>
- <doc:Authenticator%20Middleware>
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
- ``/HummingbirdMustache``
- ``/HummingbirdRedis``
- ``/HummingbirdTesting``
