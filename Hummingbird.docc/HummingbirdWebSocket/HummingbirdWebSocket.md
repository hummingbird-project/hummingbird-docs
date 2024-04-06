# ``HummingbirdWebSocket``

Adds support for upgrading HTTP connections to WebSocket. 

## Overview

WebSockets is a protocol providing simultaneous two-way communication channels over a single TCP connection. Unlike HTTP where client requests are paired with a server response, WebSockets allow for communication in both directions asynchronously. It is designed to work over the HTTP ports 80 and 443 via an upgrade process where an initial HTTP request is sent before the connection is upgraded to a WebSocket connection.

HummingbirdWebSocket allows you to implement both HTTP1 server upgrades and client connections.

## Topics

### Guides

- <doc:WebSocketServerUpgrade>
- <doc:WebSocketClientGuide>

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