# ``Hummingbird/RouterMiddleware``

@Metadata {
    @DocumentationExtension(mergeBehavior: override)
}
Version of ``MiddlewareProtocol`` whose Input is ``HummingbirdCore/Request`` and output is ``HummingbirdCore/Response``. 

## Overview

All middleware has to conform to the protocol `RouterMiddleware`. This requires one function `handle(_:context:next)` to be implemented. At some point in this function unless you want to shortcut the router and return your own response you should call `next(request, context)` to continue down the middleware stack and return the result, or a result processed by your middleware. 

The following is a simple logging middleware that outputs every URI being sent to the server

```swift
public struct LogRequestsMiddleware<Context: RequestContext>: RouterMiddleware {
    public func handle(_ request: Request, context: Context, next: (Request, Context) async throws -> Response) async throws -> Response {
        // log request URI
        context.logger.log(level: .debug, String(describing:request.uri.path))
        // pass request onto next middleware or the router and return response
        return try await next(request, context)
    }
}
```
