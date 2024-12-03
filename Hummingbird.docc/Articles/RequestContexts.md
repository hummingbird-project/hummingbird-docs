# Request Contexts

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Controlling contextual data provided to middleware and route handlers

## Overview

All request handlers and middleware handlers have two function parameters: the request and a context. The context provides contextual data for processing your request. The context parameter is a generic value which must conform to the protocol ``RequestContext``. This requires a minimal set of values needed by Hummingbird to process your request. This includes a `Logger`, `ByteBufferAllocator`, request decoder, response encoder and the resolved endpoint path.

When you create your ``Router`` you provide the request context type you want to use. If you don't provide a context it will default to using ``BasicRequestContext`` the default implementation of a request context provided by Hummingbird.

```swift
let router = Router(context: MyRequestContext.self)
```

## Creating a context type

As mentioned above your context type must conform to ``RequestContext``. This requires an `init(source:)` and a single member variable `coreContext`.

```swift
struct MyRequestContext: RequestContext {
    var coreContext: CoreRequestContextStorage

    init(source: Source) {
        self.coreContext = .init(source: source)
    }
}
```
The ``Hummingbird/CoreRequestContextStorage`` holds the base set of information needed by the Hummingbird `Router` to process a `Request`.

The `init` takes one parameter of type `Source`. `Source` is an associatedtype for the `RequestContext` protocol and provides setup data for the `RequestContext`. By default this is set to ``Hummingbird/ApplicationRequestContextSource`` which provides access to the `Channel` that created the request.

If you are using ``HummingbirdLambda`` your RequestContext will need to conform to ``HummingbirdLambda/LambdaRequestContext`` and in that case the `Source` is a ``HummingbirdLambda/LambdaRequestContextSource`` which provide access to the `Event` that triggered the lambda and the `LambdaContext` from swift-aws-lambda-runtime.

## Encoding/Decoding

By default request decoding and response encoding uses `JSONDecoder` and `JSONEncoder` respectively. You can override this by setting the `requestDecoder` and `responseEncoder` member variables in your `RequestContext`. Below we are setting the `requestDecoder` and `responseEncoder` to a decode/encode JSON with a `dateDecodingStratrgy` of seconds since 1970. The default in Hummingbird is ISO8601.

```swift
struct MyRequestContext: RequestContext {
    /// Set request decoder to be JSONDecoder with alternate dataDecodingStrategy
    var requestDecoder: MyDecoder {
        var decoder = JSONDecoder()
        decoder.dateEncodingStrategy = .secondsSince1970
        return decoder
    }
    /// Set response encoder to be JSONEncode with alternate dataDecodingStrategy
    var responseEncoder: MyEncoder {
        var encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        return encoder
    }
}
```

You can find out more about request decoding and response encoding in <doc:EncodingAndDecoding>.

## Passing data forward

The other reason for using a custom context is to pass data you have extracted in a middleware to subsequent middleware or the route handler. 

```swift
/// Example request context with an additional field
struct MyRequestContext: RequestContext {
    var coreContext: CoreRequestContextStorage
    var additionalData: String?

    init(source: Source) {
        self.coreContext = .init(source: source)
        self.additionalData = nil
    }
}

/// Middleware that sets the additional field in 
struct MyMiddleware: MiddlewareProtocol {
    func handle(
        _ request: Request, 
        context: MyRequestContext, 
        next: (Request, MyRequestContext) async throws -> Response
    ) async throws -> Response {
        var context = context
        context.additionalData = getData(request)
        return try await next(request, context)
    }
}
```

Now anything run after `MyMiddleware` can access the `additionalData` set in `MyMiddleware`. 

## Using RequestContextSource

You can also use the RequestContext to store information from the ``RequestContextSource``. If you are running a Hummingbird server then this contains the Swift NIO `Channel` that generated the request. Below is an example of extracting the remote IP from the Channel and passing it to an endpoint.

```swift
/// RequestContext that includes a copy of the Channel that created it
struct AppRequestContext: RequestContext {
    var coreContext: CoreRequestContextStorage
    let channel: Channel

    init(source: Source) {
        self.coreContext = .init(source: source)
        self.channel = source.channel
    }

    /// Extract Remote IP from Channel
    var remoteAddress: SocketAddress? { self.channel.remoteAddress }
}

let router = Router(context: AppRequestContext.self)
router.get("ip") { _, context in
    guard let ip = context.remoteAddress else { throw HTTPError(.badRequest) }
    return "Your IP is \(ip)"
}
```

## Authentication Middleware

The most obvious example of this is passing user authentication information forward. The authentication framework from ``HummingbirdAuth`` makes use of this. If you want to use the authentication and sessions middleware your context will also need to conform to ``HummingbirdAuth/AuthRequestContext``. 

```swift
public struct MyRequestContext: AuthRequestContext {
    public var coreContext: CoreRequestContextStorage
    // required by AuthRequestContext
    public var identity: User?

    public init(source: Source) {
        self.coreContext = .init(source: source)
        self.identity = nil
    }
}
```

``HummingbirdAuth`` does provide ``HummingbirdAuth/BasicAuthRequestContext``: a default implementation of ``HummingbirdAuth/AuthRequestContext``.
