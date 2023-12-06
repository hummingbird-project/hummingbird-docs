# ``Hummingbird``

Lightweight, modern, flexible server framework written in Swift.

``Hummingbird`` is a lightweight, modern, flexible server framework designed to require the minimum number of dependencies.

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

### Articles

- <doc:EncodingAndDecoding>
- <doc:ErrorHandling>
- <doc:ExtendingHummingbird>
- <doc:LoggingMetricsAndTracing>
- <doc:PersistentData>
- <doc:Router>

### Application

- ``HBApplication``
- ``HBApplicationProtocol``
- ``HBApplicationConfiguration``
- ``HBApplicationContext``
- ``EventLoopGroupProvider``

### Router

- ``HBRouter``
- ``HBRouterGroup``
- ``HBRouterMethods``
- ``HBRouterMethodOptions``
- ``HBRouteHandler``
- ``HBRequestDecodable``
- ``HBResponder``
- ``HBCallbackResponder``
- ``EndpointPath``

### Request/Response

- ``HBRequest``
- ``HBParameters``
- ``HBMediaType``
- ``HBCacheControl``
- ``HBResponse``
- ``HBResponseBodyWriter``
- ``HBEditedResponse``
- ``HBBaseRequestContext``
- ``HBRequestContext``
- ``HBBasicRequestContext``
- ``HBRemoteAddressRequestContext``

### Encoding/Decoding

- ``HBRequestDecoder``
- ``HBResponseEncoder``
- ``HBResponseEncodable``
- ``HBResponseGenerator``
- ``HBResponseCodable``

### Middleware

- ``HBMiddleware``
- ``HBMiddlewareGroup``
- ``HBCORSMiddleware``
- ``HBLogRequestsMiddleware``
- ``HBMetricsMiddleware``
- ``HBTracingMiddleware``
- ``HBSetCodableMiddleware``

### Storage

- ``HBPersistDriver``
- ``HBMemoryPersistDriver``
- ``HBPersistError``

### Miscellaneous

- ``HBEnvironment``
- ``HBDateCache``
- ``HBFileIO``
- ``GracefulShutdownWaiter``

## See Also

- ``HummingbirdCore``
- ``HummingbirdFoundation``
- ``HummingbirdJobs``
- ``HummingbirdLambda``
- ``HummingbirdXCT``
