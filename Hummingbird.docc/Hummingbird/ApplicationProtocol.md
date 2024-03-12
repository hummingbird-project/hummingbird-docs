# ``Hummingbird/ApplicationProtocol``

@Metadata {
    @DocumentationExtension(mergeBehavior: override)
}
Application protocol bringing together all the components of Hummingbird

## Overview

`ApplicationProtocol` is a protocol used to define your application. It provides the glue between your router and HTTP server.

Implementing a `ApplicationProtocol` requires two member variables: `responder` and `server`.

```swift
struct MyApp: ApplicationProtocol {
    /// The responder will return an `Response` given an `Request` and a context
    var responder: some Responder<BasicRequestContext> {
        let router = Router(context: Context.self)
        router.get("hello") { _,_ in "Hello" }
        return router.buildResponder()
    }
    /// Defines your server type. This is the default value so in
    /// effect is unnecessary
    var server: HTTPChannelBuilder<some ChildChannel> { .http1() }
}
let app = MyApp()
try await app.runService()
```

If you don't want to create your own type, Hummingbird provides ``Application`` a concrete implementation of `ApplicationProtocol`.
