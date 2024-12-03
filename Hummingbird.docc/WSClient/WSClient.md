# ``WSClient``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Support for connecting to WebSocket server. 

## Overview

WebSockets is a protocol providing simultaneous two-way communication channels over a single TCP connection. Unlike HTTP where client requests are paired with a server response, WebSockets allow for communication in both directions asynchronously. It is designed to work over the HTTP ports 80 and 443 via an upgrade process where an initial HTTP request is sent before the connection is upgraded to a WebSocket connection.

WSClient provides a way to connect to WebSocket servers.

## Topics

### Client

- ``WebSocketClient``
- ``WebSocketClientConfiguration``
- ``/WSCore/AutoPingSetup``
- ``/WSCore/WebSocketCloseFrame``
- ``WebSocketClientError``

### Handler

- ``/WSCore/WebSocketDataHandler``
- ``/WSCore/WebSocketInboundStream``
- ``/WSCore/WebSocketOutboundWriter``
- ``/WSCore/WebSocketDataFrame``
- ``/WSCore/WebSocketContext``

### Messages

- ``/WSCore/WebSocketMessage``
- ``/WSCore/WebSocketInboundMessageStream``

### Extensions

- ``/WSCore/WebSocketExtension``
- ``/WSCore/WebSocketExtensionBuilder``
- ``/WSCore/WebSocketExtensionHTTPParameters``
- ``/WSCore/WebSocketExtensionFactory``

## See Also

- ``WSCompression``
