# Request Contexts

Controlling contextual data provided to middleware and route handlers

## Overview

All request handlers and middleware handlers have two function parameters: the request and a context. The context provides contextual data for processing your request. The context parameter is a generic value which must conform to the protocol ``RequestContext``. This requires a minimal set of values needed by Hummingbird to process your request. This includes a `Logger`, `ByteBufferAllocator`, request decoder, response encoder and the resolved endpoint path.

When you create your ``Router`` you provide the request context type you want to use. If you don't provide a context it will default to using ``BasicRequestContext`` the default implementation of a request context provided by Hummingbird.

```swift
let router = Router(context: MyContext.self)
```

## Creating a context type

As mentioned above your context type must conform to ``RequestContext``. This requires an `init()` and a single member variable

```swift
struct MyRequestContext: RequestContext {
    var coreContext: CoreRequestContext

    init(channel: Channel, logger: Logger) {
        self.coreContext = .init(allocator: channel.allocator, logger: logger)
    }
}
```

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
    var coreContext: CoreRequestContext
    var additionalData: String?

    init(channel: Channel, logger: Logger) {
        self.coreContext = .init(allocator: channel.allocator, logger: logger)
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

## Authentication Middleware

The most obvious example of this is passing user authentication information forward. The authentication framework from ``HummingbirdAuth`` makes use of this. If you want to use the authentication and sessions middleware your context will also need to conform to ``HummingbirdAuth/AuthRequestContext``. 

```swift
public struct MyRequestContext: AuthRequestContext {
    public var coreContext: CoreRequestContext
    // required by AuthRequestContext
    public var auth: LoginCache

    public init(channel: Channel, logger: Logger) {
        self.coreContext = .init(allocator: channel.allocator, logger: logger)
        self.auth = .init()
    }
}
```

``HummingbirdAuth`` does provide ``HummingbirdAuth/BasicAuthRequestContext``: a default implementation of ``HummingbirdAuth/AuthRequestContext``.

## BaseRequestContext

`RequestContext` conforms to the protocol ``Hummingbird/BaseRequestContext``. `BaseRequestContext` defines requirements for accessing data from your context, while `RequestContext` defines requirements for initialization from a Swift NIO `Channel`. You will find in the codebase where data access is required the request context is required to conform to `BaseRequestContext` but ``Application`` still requires the context to conform to `RequestContext` as it needs to be able to create a context for each request. 

This allows us to support running from AWS Lambda where we have no `Channel` to create the context from. Instead we have another protocol ``HummingbirdLambda/LambdaRequestContext`` that defines how we create a context from the lambda context and event that triggered the request.

## Topics

### Reference

- ``Hummingbird/BaseRequestContext``
- ``RequestContext``
- ``BasicRequestContext``
- ``Router``
