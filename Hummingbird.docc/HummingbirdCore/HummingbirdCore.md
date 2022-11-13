# ``HummingbirdCore``

Swift NIO based HTTP server. 

## Overview

HummingbirdCore contains a Swift NIO based HTTP server. When starting the server you provide it with a struct that conforms to `HBHTTPResponder` to define how the server should respond to requests. For example the following is a responder that always returns a response containing the word "Hello" in the body. 

```swift
struct HelloResponder: HBHTTPResponder {
    func respond(to request: HBHTTPRequest, context: ChannelHandlerContext, onComplete: @escaping (Result<HBHTTPResponse, Error>) -> Void) {
        let responseHead = HTTPResponseHead(version: .init(major: 1, minor: 1), status: .ok)
        let responseBody = context.channel.allocator.buffer(string: "Hello")
        let response = HBHTTPResponse(head: responseHead, body: .byteBuffer(responseBody))
        onComplete(.success(response))
    }
}
```

You then initialise a `HBHTTPServer`, call `start` on it and then `wait`.

```swift
let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
let server = HBHTTPServer(
    group: eventLoopGroup, 
    configuration: .init(address: .hostname("127.0.0.1", port: 8080))
)
try server.start(responder: HelloResponder()).wait()
// Wait until server closes which never happens as server channel is never closed
try server.wait()
```

## Swift service lifecycle

If you are using HummingbirdCore outside of Hummingbird ideally you would use it along with the swift-server library [swift-service-lifecycle](https://github.com/swift-server/swift-service-lifecycle). This gives you a framework for clean initialization and shutdown of your server. The following sets up a Lifecycle that initializes the HTTP server and stops it when the application shuts down.
```swift
import Lifecycle
import LifecycleNIOCompat

let lifecycle = ServiceLifecycle()
lifecycle.register(
    label: "HTTP Server",
    start: .eventLoopFuture { self.server.start(responder: MyResponder()) },
    shutdown: .eventLoopFuture(self.server.stop)
)
lifecycle.start { error in
    if let error = error {
        print("ERROR: \(error)")
    }
}
lifecycle.wait()
```

## Topics

### Server

- ``HBHTTPServer``
- ``HBHTTPResponder``
- ``HBChannelInitializer``
- ``HTTP1ChannelInitializer``
- ``HBBindAddress``
- ``TSTLSOptions``

### Request

- ``HBHTTPRequest``
- ``HBRequestBody``
- ``HBByteBufferStreamer``
- ``HBStreamerProtocol``
- ``HBRequestBodyStreamerSequence``
- ``HBStreamCallback``
- ``HBStreamerOutput``

### Response

- ``HBHTTPResponse``
- ``HBResponseBody``
- ``HBResponseBodyStreamer``

### Errors

- ``HBHTTPError``
- ``HBHTTPResponseError``

## See Also

- ``Hummingbird``
