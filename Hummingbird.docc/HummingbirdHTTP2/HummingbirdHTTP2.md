# ``HummingbirdHTTP2``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Add HTTP2 support to Hummingbird server.

## Overview

HummingbirdHTTP2 is bundled with Hummingbird, but is not enabled by default. To enable HTTP2 support, you need to add the target dependency to your target:

```sh
swift package add-target-dependency HummingbirdHTTP2 <MyApp> --package hummingbird
```

Make sure to replace `<MyApp>` with the name of your App's target.

HummingbirdHTTP2 provides HTTP2 upgrade support via ``HTTP2UpgradeChannel``. You can add this to your application using ``HummingbirdCore/HTTPServerBuilder/http2Upgrade(tlsConfiguration:additionalChannelHandlers:)``.

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

### Server

- ``/HummingbirdCore/HTTPServerBuilder/http2Upgrade(tlsConfiguration:configuration:)``
- ``/HummingbirdCore/HTTPServerBuilder/http2Upgrade(tlsChannelConfiguration:configuration:)``
- ``/HummingbirdCore/HTTPServerBuilder/plaintextHTTP2(configuration:)``
- ``HTTP2UpgradeChannel``
- ``HTTP2Channel``

### Configuration

- ``HTTP2ChannelConfiguration``
- ``TLSChannelConfiguration``

## See Also

- ``Hummingbird``
- ``HummingbirdCore``
- ``HummingbirdTLS``
