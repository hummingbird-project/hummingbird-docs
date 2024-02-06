# ``HummingbirdCore``

Swift NIO based HTTP server. 

## Overview

HummingbirdCore contains a Swift NIO based server. The server is setup with a type conforming `HBChannelSetup` which defines how the server responds. It has two functions `initialize` defines how to setup a server channel ie should it be HTTP1, should it include TLS etc and `handle` defines how we should respond to individual messages. For example the following is an HTTP1 server that always returns a response containing the word "Hello" in the body. 

```swift
let server = HBServer(
    childChannelSetup: HTTP1Channel { _, context in
        let responseBody = channel.allocator.buffer(string: "Hello")
        return HBResponse(status: .ok, body: .init(byteBuffer: responseBody))
    },
    configuration: .init(address: .hostname(port: 8080)),
    eventLoopGroup: eventLoopGroup,
    logger: Logger(label: "HelloServer")
)
```

Hummingbird makes use of [Swift Service Lifecycle](https://github.com/swift-server/swift-service-lifecycle) to manage startup and shutdown. `HBServer` conforms to the `Service` protocol required by Swift Service Lifecycle. The following will start the above server and ensure it shuts down gracefully on a shutdown signal.

```swift
let serviceGroup = ServiceGroup(
    services: [server],
    configuration: .init(gracefulShutdownSignals: [.sigterm, .sigint]),
    logger: logger
)
try await serviceGroup.run()
```

## Topics

### Server

- ``HBServer``
- ``HBServerConfiguration``
- ``HBChildChannel``
- ``HTTPChannelHandler``
- ``HTTP1Channel``
- ``HBAddress``
- ``TSTLSOptions``
- ``HBHTTPUserEventHandler``

### Request

- ``HBRequest``
- ``HBURL``
- ``HBRequestBody``

### Response

- ``HBResponse``
- ``HBResponseBody``
- ``HBResponseBodyWriter``

### Errors

- ``HBHTTPError``
- ``HBHTTPResponseError``

### Miscellaneous

- ``FlatDictionary``
- ``HBParser``


## See Also

- ``Hummingbird``
- ``HummingbirdHTTP2``
- ``HummingbirdTLS``
