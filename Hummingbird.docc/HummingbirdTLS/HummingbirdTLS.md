# ``HummingbirdTLS``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Add TLS support to Hummingbird server.

## Overview

HummingbirdTLS is bundled with Hummingbird, but is not enabled by default. To enable TLS support, you need to add the target dependency to your target:

```sh
swift package add-target-dependency HummingbirdTLS <MyApp> --package hummingbird
```

Make sure to replace `<MyApp>` with the name of your App's target.

HummingbirdTLS provides TLS protocol support via ``TLSChannel``. You can add this to your application using ``HummingbirdCore/HTTPServerBuilder/tls(_:tlsConfiguration:)``.

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

The function `tls` can be used to wrap another protocol. In the example above we use it to wrap HTTP1 server, and you can also wrap a WebSocket Supporting HTTP/1 server.

## Topics

### Server

- ``/HummingbirdCore/HTTPServerBuilder/tls(_:tlsConfiguration:)``
- ``/HummingbirdCore/HTTPServerBuilder/tls(_:configuration:)``
- ``TLSChannel``

## See Also

- ``Hummingbird``
- ``HummingbirdCore``
- ``HummingbirdHTTP2``
- ``HummingbirdWebSocket``
