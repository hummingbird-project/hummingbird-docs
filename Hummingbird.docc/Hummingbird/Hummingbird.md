# ``Hummingbird``

Lightweight, modern, flexible server framework written in Swift.

Hummingbird is a lightweight, modern, flexible server framework designed to require the minimum number of dependencies.

It provides a router for directing different endpoints to their handlers, middleware for processing requests before they reach your handlers and processing the responses returned, support for adding channel handlers to extend the HTTP server and providing custom encoding/decoding of Codable objects.

The interface is fairly standard. Anyone who has had experience of Vapor, Express.js etc will recognise most of the APIs. Simple setup is as follows

```swift
import Hummingbird

let router = HBRouter()
router.get("hello") { request, _ -> String in
    return "Hello"
}
let app = HBApplication(
    responder: router.buildResponder(),
    configuration: .init(address: .hostname("127.0.0.1", port: 8080))
)
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
- ``HBRouterMethodOptions``
- ``HBRouteHandler``
- ``HBResponder``
- ``HBCallbackResponder``
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
- ``NullDecoder``
- ``NullEncoder``

### Middleware

- ``Middleware``
- ``MiddlewareProtocol``
- ``HBMiddlewareProtocol``
- ``HBMiddlewareGroup``
- ``HBCORSMiddleware``
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
- ``HummingbirdFoundation``
- ``HummingbirdJobs``
- ``HummingbirdXCT``
- ``HummingbirdAuth``
- ``HummingbirdMustache``
- ``HummingbirdLambda``
- ``HummingbirdRedis``
- ``HummingbirdRouter``
