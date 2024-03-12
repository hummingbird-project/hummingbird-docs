# ``HummingbirdHTTP2``

Add HTTP2 support to Hummingbird server

## Overview

HummingbirdHTTP2 provides HTTP2 upgrade support via ``HTTP2UpgradeChannel``. You can add this to your application using ``HummingbirdCore/HTTPChannelBuilder/http2Upgrade(tlsConfiguration:additionalChannelHandlers:)``.

```swift
// Load certificates and private key to construct server TLS configuration
let certificateChain = try NIOSSLCertificate.fromPEMFile(arguments.certificateChain)
let privateKey = try NIOSSLPrivateKey(file: arguments.privateKey, format: .pem)
let tlsConfiguration = TLSConfiguration.makeServerConfiguration(
    certificateChain: certificateChain.map { .certificate($0) },
    privateKey: .privateKey(privateKey)
)

let router = Router()
let app = Application(
    router: router,
    server: .http2Upgrade(tlsConfiguration: tlsConfiguration)
)
```

## Topics

## See Also

- ``Hummingbird``
- ``HummingbirdCore``
- ``HummingbirdTLS``