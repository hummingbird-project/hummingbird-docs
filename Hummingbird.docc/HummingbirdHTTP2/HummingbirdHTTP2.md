# ``HummingbirdHTTP2``

Add HTTP2 support to Hummingbird server

## Overview

HummingbirdHTTP2 provides HTTP2 upgrade support via ``HTTP2Channel``. You can add this to your application using ``HummingbirdCore/HBHTTPChannelBuilder/http2(tlsConfiguration:additionalChannelHandlers:)``.

```swift
// Load certificates and private key to construct server TLS configuration
let certificateChain = try NIOSSLCertificate.fromPEMFile(arguments.certificateChain)
let privateKey = try NIOSSLPrivateKey(file: arguments.privateKey, format: .pem)
let tlsConfiguration = TLSConfiguration.makeServerConfiguration(
    certificateChain: certificateChain.map { .certificate($0) },
    privateKey: .privateKey(privateKey)
)

let router = HBRouter()
let app = HBApplication(
    router: router,
    server: .http2(tlsConfiguration: tlsConfiguration)
)
```

## Topics

## See Also

- ``Hummingbird``
- ``HummingbirdCore``
- ``HummingbirdTLS``