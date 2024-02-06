# ``Hummingbird``

Lightweight, modern, flexible server framework written in Swift.

Hummingbird is a lightweight, modern, flexible server framework designed to require the minimum number of dependencies.

It provides a router for directing different endpoints to their handlers, middleware for processing requests before they reach your handlers and processing the responses returned, custom encoding/decoding of requests/responses, TLS and HTTP2.

```swift
import Hummingbird

// create router and add a single GET /hello route
let router = HBRouter()
router.get("hello") { request, _ -> String in
    return "Hello"
}
// create application using router
let app = HBApplication(
    responder: router.buildResponder(),
    configuration: .init(address: .hostname("127.0.0.1", port: 8080))
)
// run hummingbird application
try await app.runService()
```

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

### Tutorials

- <doc:Todos>

### Application

- ``HBApplication``
- ``HBApplicationProtocol``
- ``HBApplicationConfiguration``
- ``EventLoopGroupProvider``

### Router

- ``HBRouter``
- ``HBRouterGroup``
- ``HBRouterMethods``
- ``HBRouteHandler``
- ``HBResponder``
- ``HBResponderBuilder``
- ``HBCallbackResponder``
- ``HBRouterResponder``
- ``EndpointPath``
- ``RouterPath``

### Request/Response

- ``HBRequest``
- ``HBParameters``
- ``HBMediaType``
- ``HBCacheControl``
- ``HBResponse``
- ``HBResponseBodyWriter``
- ``HBEditedResponse``
- ``HBCookie``
- ``HBCookies``

### Request context

- ``HBBaseRequestContext``
- ``HBRequestContext``
- ``HBCoreRequestContext``
- ``HBBasicRequestContext``
- ``HBRemoteAddressRequestContext``

### Encoding/Decoding

- ``HBRequestDecoder``
- ``HBResponseEncoder``
- ``HBResponseEncodable``
- ``HBResponseGenerator``
- ``HBResponseCodable``
- ``JSONDecoder``
- ``JSONEncoder``
- ``URLEncodedFormDecoder``
- ``URLEncodedFormEncoder``

### Middleware

- ``Middleware``
- ``MiddlewareProtocol``
- ``HBMiddlewareProtocol``
- ``HBMiddlewareGroup``
- ``HBCORSMiddleware``
- ``HBFileMiddleware``
- ``HBLogRequestsMiddleware``
- ``HBMetricsMiddleware``
- ``HBTracingMiddleware``

### Storage

- ``HBPersistDriver``
- ``HBMemoryPersistDriver``
- ``HBPersistError``

### File management

- ``HBFileIO``

### Miscellaneous

- ``HBEnvironment``
- ``HBDateCache``
- ``GracefulShutdownWaiter``

## See Also

- ``HummingbirdCore``
- ``HummingbirdJobs``
- ``HummingbirdXCT``
- ``HummingbirdAuth``
- ``HummingbirdFluent``
- ``HummingbirdLambda``
- ``HummingbirdMustache``
- ``HummingbirdRedis``
- ``HummingbirdRouter``
