# ``Hummingbird/HBApplicationProtocol``

@Metadata {
    @DocumentationExtension(mergeBehavior: override)
}
Application protocol bringing together all the components of Hummingbird

## Overview

`HBApplicationProtocol` is a protocol used to define your application. It provides the glue between your router and HTTP server.

Implementing a `HBApplicationProtocol` requires two member variables: `responder` and `server`.

```swift
struct MyApp: HBApplicationProtocol {
    /// The responder will return an `HBResponse` given an `HBRequest` and a context
    var responder: some HBResponder<HBBasicRequestContext> {
        let router = HBRouter(context: Context.self)
        router.get("hello") { _,_ in "Hello" }
        return router.buildResponder()
    }
    /// Defines your server type. This is the default value so in
    /// effect is unnecessary
    var server: HBHTTPChannelBuilder<some HBChildChannel> { .http1() }
}
let app = MyApp()
try await app.runService()
```

If you don't want to create your own type, Hummingbird provides ``HBApplication`` a concrete implementation of `HBApplicationProtocol`.
