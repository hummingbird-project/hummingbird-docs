# ``HummingbirdCore``

Swift NIO based HTTP server. 

## Overview

HummingbirdCore contains a Swift NIO based server. The server is setup with a type conforming `ChannelSetup` which defines how the server responds. It has two functions `initialize` defines how to setup a server channel ie should it be HTTP1, should it include TLS etc and `handle` defines how we should respond to individual messages. For example the following is an HTTP1 server that always returns a response containing the word "Hello" in the body. 

```swift
let server = Server(
    childChannelSetup: HTTP1Channel { _, context in
        let responseBody = channel.allocator.buffer(string: "Hello")
        return Response(status: .ok, body: .init(byteBuffer: responseBody))
    },
    configuration: .init(address: .hostname(port: 8080)),
    eventLoopGroup: eventLoopGroup,
    logger: Logger(label: "HelloServer")
)
```

Hummingbird makes use of [Swift Service Lifecycle](https://github.com/swift-server/swift-service-lifecycle) to manage startup and shutdown. `Server` conforms to the `Service` protocol required by Swift Service Lifecycle. The following will start the above server and ensure it shuts down gracefully on a shutdown signal.

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

- ``Server``
- ``ServerConfiguration``
- ``ServerChildChannel``
- ``HTTPChannelHandler``
- ``HTTP1Channel``
- ``Address``
- ``TSTLSOptions``
- ``HTTPUserEventHandler``

### Request

- ``Request``
- ``URI``
- ``RequestBody``

### Response

- ``Response``
- ``ResponseBody``
- ``ResponseBodyWriter``

### Errors

- ``HTTPError``
- ``HTTPResponseError``

### Miscellaneous

- ``FlatDictionary``
- ``Parser``


## See Also

- ``Hummingbird``
- ``HummingbirdHTTP2``
- ``HummingbirdTLS``
