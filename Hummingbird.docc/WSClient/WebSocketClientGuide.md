# WebSocket Client

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Connecting to WebSocket servers.

A WebSocket connection is only setup after an initial HTTP upgrade request has been sent. ``WSClient/WebSocketClient`` manages the process of sending the initial HTTP request and then the handling of the WebSocket once it has been upgraded.

## Setup

A WebSocket client is created with the server URL, a closure to handle the connection and optional configuration values. To connect call ``WSClient/WebSocketClient/run()``. This will exit once the WebSocket connection has closed.

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

`WebSocketClient` supports unencrypted and TLS connections. These are indicated via the URL scheme: `ws` and `wss` respectively. If you provide an `NIOTSEventLoopGroup` for the `EventLoopGroup` at initialization then client will use the Network.framework to setup the WebSocket connection. 

## Handler

The handler closure works exactly like the WebSocket server handler. You are provided with a inbound sequence of frames and an outbound WebSocket frame writer. The connection will close as sooon as you exit the function. PING, PONG and CLOSE frames are all dealt with internally. If you want to send a regular PING keep-alive you can control that via the WebSocket configuration. By default clients do not send a regular PING.

More details on the WebSocket handler can be found in the <doc:WebSocketServerUpgrade#WebSocket-Handler> section of the WebSocket server upgrade guide.

## Reference

- ``WSClient/WebSocketClient``
