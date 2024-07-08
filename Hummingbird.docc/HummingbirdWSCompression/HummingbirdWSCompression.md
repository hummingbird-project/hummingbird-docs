# ``HummingbirdWSCompression``

Compression support for WebSockets

## Overview

This library provides an implementation of the WebSocket compression extension `permessage-deflate` as detailed in [RFC 7692](https://datatracker.ietf.org/doc/html/rfc7692.html). You add the extension in the configuration for either your WebSocket upgrade or WebSocket client.

```swift
let app = Application(
    router: Router(),
    server: .http1WebSocketUpgrade(
        configuration: .init(extensions: [.perMessageDeflate(minFrameSizeToCompress: 16)])
    ) { _, _, _ in
        return .upgrade([:]) { inbound, _, _ in
            var iterator = inbound.messages(maxSize: .max).makeAsyncIterator()
            let firstMessage = try await iterator.next()
            XCTAssertEqual(firstMessage, .text("Hello, testing compressed data"))
        }
    }
)
```

## Topics

### Compression extension

- ``/HummingbirdWSCore/WebSocketExtensionFactory/perMessageDeflate(clientMaxWindow:clientNoContextTakeover:serverMaxWindow:serverNoContextTakeover:compressionLevel:memoryLevel:maxDecompressedFrameSize:minFrameSizeToCompress:)``
- ``/HummingbirdWSCore/WebSocketExtensionFactory/perMessageDeflate(maxWindow:noContextTakeover:maxDecompressedFrameSize:minFrameSizeToCompress:)``

## See Also

- ``Hummingbird``
- ``HummingbirdWebSocket``
- ``HummingbirdWSClient``
