# ``HummingbirdTLS``

Add TLS support to Hummingbird server

## Overview

HummingbirdTLS adds a single function `addTLS(tlsConfiguration:)` to ``HummingbirdCore/HBHTTPServer``. Setting up a server with TLS is simple as passing a NIOSSL `TLSConfiguration` struct to the server.

```swift
// Load certificates and private key to construct server TLS configuration
let certificateChain = try NIOSSLCertificate.fromPEMFile(arguments.certificateChain)
let privateKey = try NIOSSLPrivateKey(file: arguments.privateKey, format: .pem)
let tlsConfiguration = TLSConfiguration.makeServerConfiguration(
    certificateChain: certificateChain.map { .certificate($0) },
    privateKey: .privateKey(privateKey)
)
// Add TLS support to server
app.server.addTLSConfiguration(tlsConfiguration: tlsConfiguration)
```

## Topics

## See Also

- ``Hummingbird``
- ``HummingbirdCore``
- ``HummingbirdHTTP2``