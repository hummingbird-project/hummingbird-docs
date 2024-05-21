# ``HummingbirdTLS``

Add TLS support to Hummingbird server

## Overview

HummingbirdTLS provides TLS support via ``TLSChannel``. You can add this to your application using ``HummingbirdCore/HTTPServerBuilder/tls(_:tlsConfiguration:)``.

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
    server: .tls(.http1(), tlsConfiguration: tlsConfiguration)
)
```

The function `tls` can be used to wrap any other child channel in the example above we use it to wrap an HTTP1 channel.

## Topics

## See Also

- ``Hummingbird``
- ``HummingbirdCore``
- ``HummingbirdHTTP2``