# ``HummingbirdWebSocket``

Adds support for upgrading HTTP connections to WebSocket. 

## Overview

WebSockets is a protocol providing simultaneous two-way communication channels over a single TCP connection. Unlike HTTP where client requests are paired with a server response, WebSockets allow for communication in both directions asynchronously. It is designed to work over the HTTP ports 80 and 443 via an upgrade process where an initial HTTP request is sent before the connection is upgraded to a WebSocket connection.

HummingbirdWebSocket allows you to implement an HTTP1 server with WebSocket upgrade.

## Topics

### Guides

- <doc:WebSocketServerUpgrade>

### Configuration

### Server

- ``/HummingbirdCore/HTTPServerBuilder/http1WebSocketUpgrade(configuration:additionalChannelHandlers:shouldUpgrade:)-8zeh2``
- ``/HummingbirdCore/HTTPServerBuilder/http1WebSocketUpgrade(configuration:additionalChannelHandlers:shouldUpgrade:)-9qdwg``
- ``/HummingbirdCore/HTTPServerBuilder/http1WebSocketUpgrade(webSocketRouter:configuration:additionalChannelHandlers:)``
- ``HTTP1WebSocketUpgradeChannel``
- ``WebSocketServerConfiguration``
- ``AutoPingSetup``
- ``ShouldUpgradeResult``

### Handler

- ``WebSocketDataHandler``
- ``WebSocketInboundStream``
- ``WebSocketOutboundWriter``
- ``WebSocketDataFrame``
- ``WebSocketContext``

### Messages

- ``WebSocketMessage``
- ``WebSocketInboundMessageStream``

### Router

- ``WebSocketRequestContext``
- ``BasicWebSocketRequestContext``
- ``WebSocketRouterContext``
- ``WebSocketHandlerReference``
- ``WebSocketUpgradeMiddleware``
- ``RouterShouldUpgrade``

### Extensions

- ``WebSocketExtension``
- ``WebSocketExtensionBuilder``
- ``WebSocketExtensionContext``
- ``WebSocketExtensionHTTPParameters``
- ``WebSocketExtensionFactory``

## See Also

- ``Hummingbird``
- ``HummingbirdWSClient``
- ``HummingbirdWSCompression``
- ``HummingbirdWSTesting``