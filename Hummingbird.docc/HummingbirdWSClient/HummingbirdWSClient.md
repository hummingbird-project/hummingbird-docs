# ``HummingbirdWSClient``

Adds support for connecting to WebSocket. 

## Overview

WebSockets is a protocol providing simultaneous two-way communication channels over a single TCP connection. Unlike HTTP where client requests are paired with a server response, WebSockets allow for communication in both directions asynchronously. It is designed to work over the HTTP ports 80 and 443 via an upgrade process where an initial HTTP request is sent before the connection is upgraded to a WebSocket connection.

HummingbirdWSClient provides a way to connect to WebSocket servers.

## Topics

### Guides

- <doc:WebSocketClientGuide>

### Client

- ``WebSocketClient``
- ``WebSocketClientConfiguration``
- ``AutoPingSetup``
- ``WebSocketCloseFrame``
- ``WebSocketClientError``

### Handler

- ``WebSocketDataHandler``
- ``WebSocketInboundStream``
- ``WebSocketOutboundWriter``
- ``WebSocketDataFrame``
- ``WebSocketContext``

### Messages

- ``WebSocketMessage``
- ``WebSocketInboundMessageStream``

### Extensions

- ``WebSocketExtension``
- ``WebSocketExtensionBuilder``
- ``WebSocketExtensionHTTPParameters``
- ``WebSocketExtensionFactory``

## See Also

- ``Hummingbird``
- ``HummingbirdWebSocket``
- ``HummingbirdWSCompression``
