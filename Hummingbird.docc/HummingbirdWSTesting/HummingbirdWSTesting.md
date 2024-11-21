# ``HummingbirdWSTesting``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Testing framework for WebSockets

## Overview

Integrates with the Hummingbird test framework ``HummingbirdTesting``.

```swift
let router = Router(context: BasicWebSocketRequestContext.self)
router.ws("/ws") { _, outbound, _ in
    try await outbound.write(.text("Hello"))
}
let application = Application(
    router: router,
    server: .http1WebSocketUpgrade(webSocketRouter: router)
)
_ = try await application.test(.live) { client in
    try await client.ws("/ws") { inbound, _, _ in
        var inboundIterator = inbound.messages(maxSize: .max).makeAsyncIterator()
        let msg = try await inboundIterator.next()
        XCTAssertEqual(msg, .text("Hello"))
    }
}
```

WebSocket testing requires a live server so it only works with the `.live` and `.ahc` test frameworks.

## Topics

### Testing

- ``HummingbirdTesting/TestClientProtocol/ws(_:configuration:logger:handler:)``

## See Also

- ``Hummingbird``
- ``HummingbirdWebSocket``
- ``WSClient``
