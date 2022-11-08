# Hummingbird

@Metadata {
    @TechnologyRoot
}

Lightweight, flexible server framework written in Swift.

Hummingbird consists of three main components, the core HTTP server, a minimal web application framework and the extension modules.

### HummingbirdCore

``HummingbirdCore`` contains a Swift NIO based HTTP server. The HTTP server is initialized with a object conforming to protocol `HBHTTPResponder` which defines how your server responds to an HTTP request. The HTTP server can be extended to support TLS and HTTP2 via the ``HummingbirdTLS`` and ``HummingbirdHTTP2`` libraries also available in the hummingbird-core repository.

HummingbirdCore can be used separately from Hummingbird if you want to write your own web application framework.

### Hummingbird

``Hummingbird`` is a lightweight and flexible web application framework that runs on top of HummingbirdCore. It is designed to require the minimum number of dependencies: `swift-backtrace`, `swift-log`, `swift-nio`, `swift-nio-extras`, `swift-service-lifecycle` and `swift-metrics` and makes no use of Foundation.

It provides a router for directing different endpoints to their handlers, middleware for processing requests before they reach your handlers and processing the responses returned, support for adding channel handlers to extend the HTTP server, extending the core data types and providing custom encoding/decoding of `Codable` objects.

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

### Hummingbird Extensions

Hummingbird is designed to require the least number of dependencies possible, but this means many features are unavailable to the core libraries. Additional features are provided through extensions. The Hummingbird repository comes with three additional targets ``HummingbirdFoundation``, ``HummingbirdJobs`` and ``HummingbirdXCT``. The ``HummingbirdFoundation`` library contains a number of features that can only really be implemented with the help of Foundation. This include JSON encoding/decoding, URLEncodedForms, static file serving, and cookies. The ``HummingbirdJobs`` library provides support a framework for pushing work onto a queue to be processed outside of a request (possibly by another node). ``HummingbirdXCT`` library adds helper functions to aiding testing Hummingbird projects.

## Topics

### User Guides

- <doc:Encoding%20and%20Decoding>
- <doc:Error%20Handling>
- <doc:Extending%20Hummingbird>
- <doc:Persistent%20Data>
- <doc:Router>

## See Also

- ``HummingbirdCore``
- ``HummingbirdAuth``
- ``HummingbirdCompression``
- ``HummingbirdFoundation``
- ``HummingbirdJobs``
- ``HummingbirdLambda``
- ``HummingbirdWebSocket``
