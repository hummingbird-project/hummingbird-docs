# ``HummingbirdWebSocket``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Adds support for upgrading HTTP connections to WebSocket. 

## Overview

WebSockets is a protocol providing simultaneous two-way communication channels over a single TCP connection. Unlike HTTP where client requests are paired with a server response, WebSockets allow for communication in both directions asynchronously. It is designed to work over the HTTP ports 80 and 443 via an upgrade process where an initial HTTP request is sent before the connection is upgraded to a WebSocket connection.

HummingbirdWebSocket allows you to implement an HTTP1 server with WebSocket upgrade.

## Topics

### Guides

- <doc:WebSocketServerUpgrade>

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

- <doc:index>
- ``Hummingbird``
- ``/WSClient``
- ``/WSCompression``
- ``HummingbirdWSTesting``