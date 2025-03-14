# ``HummingbirdWebSocket``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Adds support for upgrading HTTP connections to WebSocket. 

## Overview

WebSockets is a protocol providing simultaneous two-way communication channels over a single TCP connection. Unlike HTTP where client requests are paired with a server response, WebSockets allow for communication in both directions asynchronously, for a prolonged period of time.

It is designed to work over the HTTP ports 80 and 443 via an upgrade process where an initial HTTP request is sent before the connection is upgraded to a WebSocket connection.

HummingbirdWebSocket allows you to implement an HTTP1 server with WebSocket upgrade. HummingbirdWebSocket is Autobahn compliant and supports both compression and TLS.

To add `HummingbirdWebSocket` to your project, run the following command in your Terminal:

```sh
# From the root directory of your project
# Where Package.swift is located

# Add the package to your dependencies
swift package add-dependency https://github.com/hummingbird-project/hummingbird-websocket.git --from 2.2.0

# Add the target dependency to your target
swift package add-target-dependency HummingbirdWebSocket <MyApp> --package hummingbird-websocket
```

Make sure to replace `<MyApp>` with the name of your App's target.

To integrate `HummingbirdWebSocket` into your project, you need to specify WebSocket support in your `Application`'s configuration:

```swift
import Hummingbird
import HummingbirdWebSocket

let app = Application(
    router: router,
    server: .http1WebSocketUpgrade { request, channel, logger in
        // upgrade if request URI is "/ws"
        guard request.uri == "/ws" else { return .dontUpgrade }
        // The upgrade response includes the headers to include in the response and 
        // the WebSocket handler
        return .upgrade([:]) { inbound, outbound, context in
            // Send "Hello" to the client
            try await outbound.write(.text("Hello"))
            // Ending this function automatically closes the connection
        }
    }
)
```

Get started with the WebSockets here: <doc:WebSocketServerUpgrade>

## Topics

### Configuration

### Server

- ``/HummingbirdCore/HTTPServerBuilder/http1WebSocketUpgrade(configuration:additionalChannelHandlers:shouldUpgrade:)-3n8zf``
- ``/HummingbirdCore/HTTPServerBuilder/http1WebSocketUpgrade(configuration:additionalChannelHandlers:shouldUpgrade:)-6siva``
- ``/HummingbirdCore/HTTPServerBuilder/http1WebSocketUpgrade(webSocketRouter:configuration:additionalChannelHandlers:)``
- ``HTTP1WebSocketUpgradeChannel``
- ``WebSocketServerConfiguration``
- ``/WSCore/AutoPingSetup``
- ``ShouldUpgradeResult``

### Handler

- ``/WSCore/WebSocketDataHandler``
- ``/WSCore/WebSocketInboundStream``
- ``/WSCore/WebSocketOutboundWriter``
- ``/WSCore/WebSocketDataFrame``
- ``/WSCore/WebSocketContext``

### Messages

- ``/WSCore/WebSocketMessage``
- ``/WSCore/WebSocketInboundMessageStream``

### Router

- ``WebSocketRequestContext``
- ``BasicWebSocketRequestContext``
- ``WebSocketRouterContext``
- ``WebSocketHandlerReference``
- ``WebSocketUpgradeMiddleware``
- ``RouterShouldUpgrade``

### Extensions

- ``/WSCore/WebSocketExtension``
- ``/WSCore/WebSocketExtensionBuilder``
- ``/WSCore/WebSocketExtensionContext``
- ``/WSCore/WebSocketExtensionHTTPParameters``
- ``/WSCore/WebSocketExtensionFactory``

## See Also

- ``/WSCompression``
- ``HummingbirdWSTesting``