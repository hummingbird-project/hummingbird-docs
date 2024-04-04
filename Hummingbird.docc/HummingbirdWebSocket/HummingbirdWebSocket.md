# ``HummingbirdWebSocket``

Adds support for upgrading HTTP connections to WebSocket. 

## Overview

To add WebSocket upgrade support to your server you need to use `.http1WebSocketUpgrade` instead of `.http1` as the server parameter in the ``Hummingbird/Application`` initalizer. WebSocket upgrade requires two functions, one that decides whether the upgrade should happen and one the manages the WebSocket once the upgrade has occurred. There are two methods to set this up. You can either provide two closures as follows

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

The WebSocket handle function has three parameters: an inbound sequence of WebSocket data or text messages, an outbound WebSocket packet writer and a context parameter. The WebSocket is kept open as long as you don't leave this function. PING, PONG and CLOSE messages are managed internally. If you want to send a regular PING keep-alive you can control that via the WebSocket configuration. Data and text messages split across multiple packets are collated automatically.

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