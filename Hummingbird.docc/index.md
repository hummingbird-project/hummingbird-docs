# Hummingbird

@Metadata {
    @TechnologyRoot
    @PageImage(purpose: icon, source: "logo")
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

### Extending Hummingbird

The Hummingbird package comes with a number of modules to extend your application.

- ``HummingbirdTLS``: TLS support.
- ``HummingbirdHTTP2``: Support for HTTP2 upgrades.
- ``HummingbirdTesting``: helper functions to aid testing Hummingbird projects.

Support for other features come via additional packages in the [hummingbird project](https://github.com/hummingbird-project).

- [HummingbirdAuth](https://github.com/hummingbird-project/hummingbird-auth): Authentication framework
- [HummingbirdWebSocket](https://github.com/hummingbird-project/hummingbird-websocket): WebSocket support
- [HummingbirdLambda](https://github.com/hummingbird-project/hummingbird-lambda): Run Hummingbird on AWS Lambda
- [HummingbirdPostgres](https://github.com/hummingbird-project/hummingbird-lambda): Integration with PostgresNIO
- [HummingbirdFluent](https://github.com/hummingbird-project/hummingbird-fluent): Integration with Vapor's FluentKit ORM
- [HummingbirdRedis](https://github.com/hummingbird-project/hummingbird-redis): Redis support via RediStack
- [Jobs](https://github.com/hummingbird-project/swift-jobs): Job Queue Framework
- [Mustache](https://github.com/hummingbird-project/swift-mustache): Mustache templating engine

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
