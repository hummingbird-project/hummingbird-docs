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
- ``BasicWebSocketContext``

### Messages

- ``WebSocketMessage``
- ``WebSocketInboundMessageStream``

### Router

- ``WebSocketContextFromRouter``
- ``WebSocketRequestContext``
- ``WebSocketHandlerReference``
- ``BasicWebSocketRequestContext``
- ``WebSocketUpgradeMiddleware``
- ``RouterShouldUpgrade``

### Extensions

- ``WebSocketExtension``
- ``WebSocketExtensionBuilder``
- ``WebSocketExtensionHTTPParameters``
- ``WebSocketExtensionFactory``

## See Also

- ``Hummingbird``
- ``HummingbirdWSClient``