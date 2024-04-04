# ``HummingbirdWebSocket``

Adds support for upgrading HTTP connections to WebSocket. 

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