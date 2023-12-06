# ``HummingbirdTLS``

Add TLS support to Hummingbird server

## Overview

HummingbirdTLS adds a single type ``TLSChannel``. If you want a server to support TLS then build a ``TLSChannel`` with your base channel setup type and a `TLSConfiguration` struct from [NIOSSL](https://github.com/apple/swift-nio-ssl) as parameters.

```swift
let http1Channel = HTTP1Channel { _, context in
    let responseBody = channel.allocator.buffer(string: "Hello")
    return HBResponse(status: .ok, body: .init(byteBuffer: responseBody))
}
// Load certificates and private key to construct server TLS configuration
let certificateChain = try NIOSSLCertificate.fromPEMFile(arguments.certificateChain)
let privateKey = try NIOSSLPrivateKey(file: arguments.privateKey, format: .pem)
let tlsConfiguration = TLSConfiguration.makeServerConfiguration(
    certificateChain: certificateChain.map { .certificate($0) },
    privateKey: .privateKey(privateKey)
)
// Create TLS Channel
let tlsChannel = TLSChannel(http1Channel, tlsConfiguration: tlsConfiguration)
let server = HBServer(
    childChannelSetup: tlsChannel,
    configuration: .init(address: .hostname(port: 8080)),
    eventLoopGroup: eventLoopGroup,
    logger: Logger(label: "HelloServer")
)
```

## Topics

## See Also

- ``Hummingbird``
- ``HummingbirdCore``
- ``HummingbirdHTTP2``