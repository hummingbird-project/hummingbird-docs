# TLS and HTTP/2

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Adding support for TLS and HTTP/2 upgrades.

## Overview

By default a Hummingbird application runs with a HTTP/1.1 server. The Hummingbird comes with additional libraries that allow you to change this to leverage TLS, HTTP/2 and WebSockets.

### Setting server protocol

When you create your ``Application`` there is a parameter `server` that is used to define the server protocol and its configuration. Below we are creating a server that support HTTP1 with a idle timeout for requests set to one minutes.

```swift
let app = Application(
    router: router,
    server: .http1(idleTimeout: .seconds(60))
)
```

## HTTPS/TLS

HTTPS is pretty much a requirement for a server these days. Many people run Nginx in front of their server to implement HTTPS, but it is also possible to setup HTTPS inside your Hummingbird application. 

```swift
import HummingbirdTLS
import NIOSSL

let tlsConfiguration = TLSConfiguration.makeServerConfiguration(
    certificateChain: try NIOSSLCertificate.fromPEMFile("/path/to/certificate.pem").map { .certificate($0) },
    privateKey: .privateKey(try NIOSSLPrivateKey(file: "/path/to/privatekey.pem", format: .pem))
)
let app = Application(
    router: router,
    server: .tls(.http1(), tlsConfiguration: tlsConfiguration)
)
```

HTTPS is the HTTP protocol with an added encryption layer of TLS to protect the traffic. The `tls` function applies the encryption layer using the crytographic keys supplied in the `TLSConfiguration`.

## HTTP2

HTTP2 is becoming increasingly common. It allows you to service multiple HTTP requests concurrently over one connection. The HTTP2 protocol does not require you to use TLS but it is in effect only supported over TLS as there aren't any web browsers that support HTTP2 without TLS. Given this the Hummingbird implementation also requires TLS.

```swift
import HummingbirdHTTP2

let app = Application(
    router: router,
    server: .http2(
        tlsConfiguration: tlsConfiguration,
        configuration: .init(
            idleTimeout: .seconds(60),
            gracefulCloseTimeout: .seconds(15),
            maxAgeTimeout: .seconds(900),
            streamConfiguration: .init(idleTimeout: .seconds(60))
        )
    )
)
```

The HTTP2 upgrade protocol has a fair amount of configuration. It includes a number of different timeouts, 
- `idleTimeout`: How long a connection is kept open while idle.
- `gracefulCloseTimeout`: The maximum amount of time to wait for the client to respond before all streams are closed during graceful close of the connection.
- `maxAgeTimeout`: a maximum amount of time a connection should be open.
Then each HTTP2 stream (request) has its own idle timeout as well.

## Topics

### Reference

- ``HummingbirdHTTP2``
- ``HummingbirdTLS``
