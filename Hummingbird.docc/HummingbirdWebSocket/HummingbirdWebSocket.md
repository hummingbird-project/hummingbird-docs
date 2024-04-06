# ``HummingbirdWebSocket``

Adds support for upgrading HTTP connections to WebSocket. 

## Overview

HummingbirdWebSocket provides both HTTP1 server upgrade and client implementations of WebSocket connections.

## Server

To add WebSocket upgrade support to your server you need to use `.http1WebSocketUpgrade` instead of `.http1` as the server parameter in the ``Hummingbird/Application`` initalizer. A WebSocket upgrade requires two functions, one that decides whether the upgrade should happen and one that manages the WebSocket once the upgrade has occurred. There are two methods to set this up. You can provide a closure which returns another closure to handle the WebSocket if the upgrade is successful.

```swift
let app = Application(
    router: router,
    server: .http1WebSocketUpgrade { request, channel, logger in
        // upgrade if request URI is "/ws"
        guard request.uri == "/ws" else { return .dontUpgrade }
        // The upgrade response includes the headers to include in the response and 
        // the WebSocket handler
        return .upgrade([:]) { inbound, outbound, context in
            for try await packet in inbound {
                // send "Received" for every packet we receive
                try await outbound.write(.text("Received"))
            }
        }
    }
)
```

Or you can provide a ``Hummingbird/Router`` using a ``Hummingbird/RequestContext`` that conforms to ``WebSocketRequestContext``. The router can be the same router as you use for your HTTP requests, but it is preferable to use a separate router.

```swift
let wsRouter = Router(context: BasicWebSocketRequestContext.self)
// An upgrade only occurs if a WebSocket path is matched
wsRouter.ws("/ws") { request, context in
    // allow upgrade
    .upgrade([:])
} onUpgrade: { inbound, outbound, context in
    for try await packet in inbound {
        // send "Received" for every packet we receive
        try await outbound.write(.text("Received"))
    }
}
let app = Application(
    router: router,
    server: .http1WebSocketUpgrade(webSocketRouter: wsRouter)
)
```
Using a router means you can add middleware to process the initial upgrade request before it is handled eg for authenticating the request. 

## WebSocket Handler

The WebSocket handle function has three parameters: an inbound sequence of WebSocket data or text messages, an outbound WebSocket packet writer and a context parameter. The WebSocket is kept open as long as you don't leave this function. PING, PONG and CLOSE messages are managed internally. If you want to send a regular PING keep-alive you can control that via the WebSocket configuration. By default servers send a PING every 30 seconds. Data and text messages split across multiple packets are collated automatically.

Below is a simple input and response style connection a message is read from the inbound stream, processed and then a response is written back. If the connection is closed the inbound stream will end and we exit the function.

```swift
func webSocketHandler(inbound: WebSocketInboundStream, outbound: WebSocketOutboundWriter, context: some WebSocketContext) async throws {
    for try await message in inbound {
        let response = await process(message)
        try await outbound.write(response)
    }
}
```

If the reading and writing from your WebSocket connection is separate then you can use a structured `TaskGroup`
```swift
func webSocketHandler(inbound: WebSocketInboundStream, outbound: WebSocketOutboundWriter, context: some WebSocketContext) async throws {
    try await withThrowingTaskGroup(of: Void.self) { group in
        group.addTask {
            for try await message in inbound {
                await process(message)
            }
        }
        group.addTask {
            for await message in outboundMessageSource {
                try await outbound.write(message)
            }
        }
        try await group.next()
        // once one task has finished, cancel the other
        group.cancelAll()
    }
}
```
You should not use unstructured Tasks to manage your WebSockets. If you use an unstructured Task there is a possibility you will find the WebSocket being closed from underneath you. 

## WebSocket Client

Given the WebSocket client implementation is almost identical to the server implementation HummingbirdWebSocket also comes with a WebSocket client. On top of the standard unencrypted connection it also supports TLS and connections using the macOS Network framework. You create a WebSocket client with the server URL and a closure to handle the connection. The closure works exactly like the WebSocket server handler detailed above. And then you call ``WebSocketClient/run()``.

```swift
let ws = WebSocketClient(URI("ws://mywebsocket/ws")) { inbound, outbound, context in
    try await outbound.write(.text("Hello"))
    for try await frame in inbound {
        context.logger.info(frame)
    }
}
try await ws.run()
```

As a shortcut you can call the following which will initialize and run the WebSocket client in one function call

```swift
try await WebSocketClient.connect(URI("ws://mywebsocket/ws")) { inbound, outbound, context in
    try await outbound.write(.text("Hello"))
    for try await frame in inbound {
        context.logger.info(frame)
    }
}
```

## WebSocket Context

The context that is passed to the WebSocket handler along with the inbound stream and outbound writer is different depending on how you setup your WebSocket connection. In the case where you provide a `shouldUpgrade` closure to the server (the first example at the top) and in the situation where you are running a client connection the context only holds a `Logger` for logging output and a `ByteBufferAllocator` if you need to allocate `ByteBuffers`. 

If the WebSocket was setup with a router, then the context also includes the ``Hummingbird/Request`` that initiated the WebSocket upgrade and the ``Hummingbird/RequestContext`` from that same call. With this you can configure your WebSocket connection based on details from the initial request. Below we are using a query parameter to add a named WebSocket to a connection manager

```swift
wsRouter.ws("chat") { request, _ in
    // only allow upgrade if username query parameter exists
    guard request.uri.queryParameters["username"] != nil else {
        return .dontUpgrade
    }
    return .upgrade([:])
} onUpgrade: { inbound, outbound, context in
    // only allow upgrade to continue if username query parameter exists
    guard let name = context.request.uri.queryParameters["username"] else { return }
    await connectionManager.manageUser(name: String(name), inbound: inbound, outbound: outbound)
}
```

Alternatively you could use the `RequestContext` to extract authentication data to get the user's name.

## Topics

### Configuration

- ``WebSocketServerConfiguration``
- ``WebSocketClientConfiguration``
- ``AutoPingSetup``

### Server

- ``HTTP1WebSocketUpgradeChannel``
- ``ShouldUpgradeResult``

### Client

- ``WebSocketClient``
- ``WebSocketClientError``

### Handler

- ``WebSocketDataHandler``
- ``WebSocketInboundStream``
- ``WebSocketOutboundWriter``
- ``WebSocketDataFrame``
- ``WebSocketContext``
- ``BasicWebSocketContext``

### Router

- ``WebSocketContextFromRouter``
- ``WebSocketRequestContext``
- ``WebSocketHandlerReference``
- ``BasicWebSocketRequestContext``
- ``WebSocketUpgradeMiddleware``
- ``RouterShouldUpgrade``

### Extensions

- ``WebSocketExtensionHTTPParameters``
- ``WebSocketExtensionFactory``

## See Also

- ``Hummingbird``