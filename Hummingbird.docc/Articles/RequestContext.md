# Request Context

Controlling contextual data provided to middleware and route handlers

## Overview

All request handlers and middleware handlers have two function parameters: the request and a context. The context provides contextual data for processing your request. The context parameter is a generic value which must conform to the protocol ``HBRequestContext``. This requires a minimal set of values needed by Hummingbird to process your request. This includes a `Logger`, `ByteBufferAllocator`, request decoder, response encoder and the resolved endpoint path.

When you create your ``HBRouter`` you provide the request context type you want to use. If you don't provide a context it will default to using ``HBBasicRequestContext`` the default implementation of a request context provided by Hummingbird.

```swift
let router = HBRouter(context: MyContext.self)
```

## Creating a context type

As mentioned above your context type must conform to ``HBRequestContext``. This requires an `init()` and a single member variable

```swift
struct MyRequestContext: HBRequestContext {
    var coreContext: HBCoreRequestContext

    init(allocator: ByteBufferAllocator, logger: Logger) {
        self.coreContext = .init(
            allocator: allocator,
            logger: logger
        )
    }
}
```

## Encoding/Decoding

The most likely reason you would setup your own context is because you want to set the request decoder and response encoder. By replacing the contents of the `init` above with the following you have setup JSON decoding and encoding of requests and responses.

```swift
self.coreContext = .init(
    requestDecoder: JSONDecoder(),
    responseEncoder: JSONEncoder(),
    allocator: allocator,
    logger: logger
```

You can find out more about request decoding and response encoding in <doc:EncodingAndDecoding>.

## Passing data forward

The other reason for using a custom context is to pass data you have extracted in a middleware to subsequent middleware or the route handler. 

```swift
/// Example request context with an additional field
struct MyRequestContext: HBRequestContext {
    var coreContext: HBCoreRequestContext
    var additionalData: String?

    init(allocator: ByteBufferAllocator, logger: Logger) {
        self.coreContext = .init(
            allocator: allocator,
            logger: logger
        )
        self.additionalData = nil
    }
}

/// Middleware that sets the additional field in 
struct MyMiddleware: HBMiddlewareProtocol {
    func handle(
        _ request: HBRequest, 
        context: MyRequestContext, 
        next: (HBRequest, MyRequestContext) async throws -> HBResponse
    ) async throws -> HBResponse {
        var context = context
        context.additionalData = getData(request)
        return try await next(request, context)
    }
}
```

Now anything run after `MyMiddleware` can access the `additionalData` set in `MyMiddleware`. 

## Authentication Middleware

The most obvious example of this is passing user authentication information forward. The authentication framework from ``HummingbirdAuth`` makes use of this. If you want to use the authentication and sessions middleware your context will also need to conform to ``HummingbirdAuth/HBAuthRequestContextProtocol``. 

```swift
public struct MyRequestContext: HBAuthRequestContextProtocol {
    public var coreContext: HBCoreRequestContext
    // required by HBAuthRequestContextProtocol
    public var auth: HBLoginCache

    public init(
        allocator: ByteBufferAllocator,
        logger: Logger
    ) {
        self.coreContext = .init(allocator: allocator, logger: logger)
        self.auth = .init()
    }
}
```

``HummingbirdAuth`` does provide ``HummingbirdAuth/HBAuthRequestContext``: a default implementation of ``HummingbirdAuth/HBAuthRequestContextProtocol``.

## Topics

### Reference

- ``HBRequestContext``
- ``HBBasicRequestContext``
- ``HBRouter``
