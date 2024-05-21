# ``Hummingbird``

Lightweight, modern, flexible server framework written in Swift.

Hummingbird is a lightweight, modern, flexible server framework designed to require the minimum number of dependencies.

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

## Topics

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

### Tutorials

- <doc:Todos>

### Application

- ``Application``
- ``ApplicationProtocol``
- ``ApplicationConfiguration``
- ``EventLoopGroupProvider``

### Router

- ``Router``
- ``RouterGroup``
- ``RouteCollection``
- ``RouterMethods``
- ``RouterOptions``
- ``HTTPResponder``
- ``HTTPResponderBuilder``
- ``CallbackResponder``
- ``RouterResponder``
- ``EndpointPath``
- ``RouterPath``

### Request/Response

- ``Request``
- ``Parameters``
- ``MediaType``
- ``CacheControl``
- ``Response``
- ``ResponseBodyWriter``
- ``EditedResponse``
- ``Cookie``
- ``Cookies``

### Request context

- ``BaseRequestContext``
- ``RequestContext``
- ``CoreRequestContext``
- ``BasicRequestContext``
- ``RemoteAddressRequestContext``

### Encoding/Decoding

- ``RequestDecoder``
- ``ResponseEncoder``
- ``ResponseEncodable``
- ``ResponseGenerator``
- ``ResponseCodable``
- ``URLEncodedFormDecoder``
- ``URLEncodedFormEncoder``

### Middleware

- ``MiddlewareProtocol``
- ``RouterMiddleware``
- ``MiddlewareGroup``
- ``CORSMiddleware``
- ``FileMiddleware``
- ``LogRequestsMiddleware``
- ``MetricsMiddleware``
- ``TracingMiddleware``

### Storage

- ``PersistDriver``
- ``MemoryPersistDriver``
- ``PersistError``

### File management

- ``FileIO``

### Miscellaneous

- ``Environment``
- ``DateCache``

## See Also

- ``HummingbirdCore``
- ``HummingbirdJobs``
- ``HummingbirdTesting``
- ``HummingbirdAuth``
- ``HummingbirdFluent``
- ``HummingbirdLambda``
- ``Mustache``
- ``HummingbirdPostgres``
- ``HummingbirdRedis``
- ``HummingbirdRouter``
- ``HummingbirdWebSocket``
