# ``HummingbirdHTTP2``

Add HTTP2 support to Hummingbird server

## Overview

HummingbirdTLS adds a single type ``HTTP2Channel``. If you want a server to support HTTP2 then build a ``HTTP2Channel`` with your HTTP responder callback and a `TLSConfiguration` struct from [NIOSSL](https://github.com/apple/swift-nio-ssl) as parameters.

```swift
// Load certificates and private key to construct server TLS configuration
let certificateChain = try NIOSSLCertificate.fromPEMFile(arguments.certificateChain)
let privateKey = try NIOSSLPrivateKey(file: arguments.privateKey, format: .pem)
let tlsConfiguration = TLSConfiguration.makeServerConfiguration(
    certificateChain: certificateChain.map { .certificate($0) },
    privateKey: .privateKey(privateKey)
)
// Create HTTP2 Channel
let http2Channel = HTTP2Channel(tlsConfiguration: tlsConfiguration) { _, context in
    let responseBody = channel.allocator.buffer(string: "Hello v2.0")
    return HBResponse(status: .ok, body: .init(byteBuffer: responseBody))
}
let server = HBServer(
    childChannelSetup: http2Channel,
    configuration: .init(address: .hostname(port: 8080)),
    eventLoopGroup: eventLoopGroup,
    logger: Logger(label: "HelloServer")
)
```

## Topics

## See Also

- ``Hummingbird``
- ``HummingbirdCore``
- ``HummingbirdTLS``