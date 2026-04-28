# Securing Your Application

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Secure your application from common vulnerabilities.

## Overview

HTTP Servers are vulnerable to a large variety of attacks. Some of these are designed to crash or slow down your application and others are designed to expose sensitive data. In this document we detail some of the common vulnerabilities of HTTP servers and show how either your application is already protected against them or what steps you can take to protect your application.

## Denial of service

Denial of service attacks come in many forms. Most of them attempt to exhaust a resource of some form.

### Memory

An attacker may attempt to crash your application by sending it many large requests. As long as you are not collating these requests into single large buffers, Hummingbird protects you from these kind of attacks. Request bodies are streamed and back-pressure is used to ensure only so much of a request is in memory at any one point.

If you are collating a request body into one buffer, provide a sensible maximum size for the buffer. Don't use `Int.max`.

```swift
let body = try request.body.collect(upTo: 256*1024)
```

When you are using a request decoder from the ``Hummingbird/RequestContext`` the decoder normally needs to collate the request body into a single buffer. You can control the maximum size of this buffer by creating a `RequestContext` that overrides the ``Hummingbird/RequestContext/maxUploadSize`` variable. This defaults to 2MB.

```swift
struct MaxUploadRequestContext: RequestContext {
    init(source: Source) {
        self.coreContext = .init(source: source)
    }

    var coreContext: CoreRequestContextStorage
    /// Set maximum upload to 64KB
    var maxUploadSize: Int { 64 * 1024 }
}
```

### Process

Another form of attack is to flood a server with many connections. Hummingbird uses SwiftNIO to manage its connections and it is capable of dealing with many connections, but if each connection hits a route that requires a large amount of processing or requires work from another upstream service the attack can slow down your server, or even bring it to a halt. The best way to avoid this is to limit the number of connections your server will accept. This way you can control the load on your server.

Currently by default this is not enabled, but when configuring your Hummingbird application you can add configuration in to limit the number of connections.

```swift
// Create application that only allows 256 connections
let app = Application(
    router: router,
    configuration: .init(
        address: .hostname("127.0.0.1", port: 8080),
        availableConnectionsDelegate: .maximum(256, logger: logger)
    ),
    logger: logger
)
```

### Connections

While SwiftNIO is capable of dealing with many connections, it is still preferable you don't have more connections open than necessary. Another kind of attack is a slowloris attack where the attacker opens many connections and then drip feeds them data. With this the attacker can keep open many connections with minimal bandwidth.

Protection against this is not on by default but Hummingbird provides options to check for idle connections.

```swift
let app = Application(
    router: router,
    server: .http1(configuration: .init(idleTimeout: .seconds(30))),
    configuration: .init(address: .hostname("127.0.0.1", port: 8080)),
    logger: logger
)
```

If the full request header doesn't appear within this idle time or there is a period of time between each part of the request body greater than the idle time then the connection will be closed.