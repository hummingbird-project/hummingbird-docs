# ``HummingbirdHTTP2``

Add HTTP2 support to Hummingbird server

## Overview

HummingbirdHTTP2 adds a single function `addHTTP2Upgrade(tlsConfiguration:)` to ``HummingbirdCore/HBHTTPServer``. Setting up a server with HTTP2 is simple as passing a NIOSSL `TLSConfiguration` struct to the server.

```swift
// Load certificates and private key to construct server TLS configuration
let certificateChain = try NIOSSLCertificate.fromPEMFile(arguments.certificateChain)
let privateKey = try NIOSSLPrivateKey(file: arguments.privateKey, format: .pem)
let tlsConfiguration = TLSConfiguration.makeServerConfiguration(
    certificateChain: certificateChain.map { .certificate($0) },
    privateKey: .privateKey(privateKey)
)
// Add TLS support to server
app.server.addHTTP2Upgrade(tlsConfiguration: tlsConfiguration)
```

HTTP2 secure upgrade requires a TLS connection so this will add a TLS handler as well. Do not call addTLS() inconjunction with this as you will then be adding two TLS handlers.

## Topics

### NIOSSL Symbols

- ``NIOSSLCertificate``
- ``NIOSSLPrivateKey``
- ``TLSConfiguration``
  
## See Also

- ``Hummingbird``
- ``HummingbirdCore``
- ``HummingbirdTLS``