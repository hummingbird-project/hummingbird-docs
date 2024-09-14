# ``HummingbirdWSClient``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

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
- ``/HummingbirdWSCore/AutoPingSetup``
- ``/HummingbirdWSCore/WebSocketCloseFrame``
- ``WebSocketClientError``

### Handler

- ``/HummingbirdWSCore/WebSocketDataHandler``
- ``/HummingbirdWSCore/WebSocketInboundStream``
- ``/HummingbirdWSCore/WebSocketOutboundWriter``
- ``/HummingbirdWSCore/WebSocketDataFrame``
- ``/HummingbirdWSCore/WebSocketContext``

### Messages

- ``/HummingbirdWSCore/WebSocketMessage``
- ``/HummingbirdWSCore/WebSocketInboundMessageStream``

### Extensions

- ``/HummingbirdWSCore/WebSocketExtension``
- ``/HummingbirdWSCore/WebSocketExtensionBuilder``
- ``/HummingbirdWSCore/WebSocketExtensionHTTPParameters``
- ``/HummingbirdWSCore/WebSocketExtensionFactory``

## See Also

- ``Hummingbird``
- ``HummingbirdWebSocket``
- ``HummingbirdWSCompression``
