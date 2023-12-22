# ``Hummingbird``

Lightweight, flexible server framework written in Swift.

``Hummingbird`` is a lightweight, flexible server framework designed to require the minimum number of dependencies.

It provides a router for directing different endpoints to their handlers, middleware for processing requests before they reach your handlers and processing the responses returned, support for adding channel handlers to extend the HTTP server, extending the core ``HBApplication`` and ``HBRequest`` types and providing custom encoding/decoding of `Codable` objects.

The interface is fairly standard. Anyone who has had experience of Vapor, Express.js etc will recognise most of the APIs. Simple setup is as follows

```swift
import Hummingbird

let app = HBApplication(configuration: .init(address: .hostname("127.0.0.1", port: 8080)))
app.router.get("hello") { request -> String in
    return "Hello"
}
try app.start()
app.wait()
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
- ``ServiceLifecycleProvider``

### Router

- ``HBRouterBuilder``
- ``HBRouterGroup``
- ``HBRouterMethods``
- ``HBRouterMethodOptions``
- ``HBRouteHandler``
- ``HBRequestDecodable``
- ``HBAsyncRouteHandler``
- ``HBResponder``
- ``HBCallbackResponder``
- ``HBAsyncCallbackResponder``

### Request/Response

- ``HBRequest``
- ``HBURL``
- ``HBParameters``
- ``HBMediaType``
- ``HBRequestContext``
- ``HTTPHeadersPatch``
- ``HBResponse``

### Encoding/Decoding

- ``HBRequestDecoder``
- ``HBResponseEncoder``
- ``HBResponseEncodable``
- ``HBResponseGenerator``
- ``HBResponseCodable``

### Middleware

- ``HBMiddleware``
- ``HBAsyncMiddleware``
- ``HBMiddlewareGroup``
- ``HBCORSMiddleware``
- ``HBLogRequestsMiddleware``
- ``HBMetricsMiddleware``

### Extending the Application

- ``HBExtensible``
- ``HBExtensions``

### Connection Pool

- ``HBConnectionPool``
- ``HBConnection``
- ``HBConnectionSource``
- ``HBAsyncConnection``
- ``HBAsyncConnectionSource``
- ``HBConnectionPoolGroup``
- ``HBConnectionPoolError``

### Storage

- ``HBPersistDriver``
- ``HBPersistDriverFactory``
- ``HBPersistError``

### Miscellaneous

- ``FlatDictionary``
- ``HBEnvironment``
- ``HBDateCache``
- ``HBParser``

## See Also

- ``HummingbirdCore``
- ``HummingbirdAuth``
- ``HummingbirdCompression``
- ``HummingbirdFluent``
- ``HummingbirdFoundation``
- ``HummingbirdJobs``
- ``HummingbirdLambda``
- ``HummingbirdRedis``
- ``HummingbirdWebSocket``
- ``HummingbirdXCT``
