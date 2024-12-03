# Middleware

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Processing requests and responses outside of request handlers. 

## Overview

Middleware can be used to edit requests before they are forwared to the router, edit the responses returned by the route handlers or even shortcut the router and return their own responses. Middleware is added to the application as follows.

```swift
let router = Router()
router.add(middleware: MyMiddlware())
```

In the example above the `MyMiddleware` is applied to every request that comes into the server.

### Groups

Middleware can also be applied to a specific set of routes using groups. Below is a example of applying an authentication middleware `BasicAuthenticatorMiddleware` to routes that need protected.

```swift
let router = Router()
router.put("/user", createUser)
router.group()
    .add(middleware: BasicAuthenticatorMiddleware())
    .post("/user", loginUser)
```
The first route that calls `createUser` does not have the `BasicAuthenticatorMiddleware` applied to it. But the route calling `loginUser` which is inside the group does have the middleware applied.

### Middleware result builder

You can add multiple middleware to the router using the middleware stack result builder ``MiddlewareFixedTypeBuilder``.

```swift
let router = Router()
router.add {
    LogRequestsMiddleware()
    MetricsMiddleware()
    TracingMiddleware()
}
```

This gives a slight performance boost over adding them individually.

### Writing Middleware

All middleware has to conform to the protocol ``Hummingbird/RouterMiddleware``. This requires one function `handle(_:context:next)` to be implemented. At some point in this function unless you want to shortcut the router and return your own response you should call `next(request, context)` to continue down the middleware stack and return the result, or a result processed by your middleware. 

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
