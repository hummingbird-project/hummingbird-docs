# ``HummingbirdRouter``

Alternative result builder based router for Hummingbird. 

## Overview

HummingbirdRouter provides an alternative to the standard trie based router that is in the Hummingbird module. ``HummingbirdRouter/HBRouterBuilder`` uses a result builder to construct your router.

```swift
let router = HBRouterBuilder(context: HBBasicRouterRequestContext.self) {
    HBCORSMiddleware()
    Route(.get, "health") { _,_ in
        HTTPResponse.Status.ok
    }
    RouteGroup("user") {
        BasicAuthenticationMiddleware()
        Route(.post, "login") { request, context in
            ...
        }
    }
}
```

A request is processed by each element of the router result builder until it hits a route that matches its URI. If it hits a ``RouteGroup`` and this matches the current request uri path component then the request (with matched URI path components dropped) will be processed by the children of the `RouteGroup`. When the request hits a route and the uri matches it will run that route and pass the response back to be processed by all the middleware that processed the request but in reverse order.

## Common Route Verbs

The common HTTP verbs: GET, PUT, POST, PATCH, HEAD, DELETE, have their own shortcut functions.

```swift
Route(.get, "health") { _,_ in
    HTTPResponse.Status.ok
}
```
can be written as
```swift
Get("health") { _,_ in
    HTTPResponse.Status.ok
}
```

## Route middleware

Routes can be initialised with their own result builder as long as they end with a route ``Handle`` function that returns the response. This allows us to apply middleware to individual routes. 

```swift
Post("login") {
    BasicAuthenticationMiddleware()
    Handle  { request, context in
        ...
    }
}
```

If you are not adding the handler inline you can add the function reference without the ``Handle``.  

```swift
@Sendable func processLogin(request: HBRequest, context: MyContext) async throws -> HBResponse {
    // process login
}
HBRouterBuilder(context: HBBasicRouterRequestContext.self) {
    ...
    Post("login") {
        BasicAuthenticationMiddleware()
        processLogin
    }
}
```

## Topics

### RouterBuilder

- ``HBRouterBuilder``

### Request Context

- ``HBRouterRequestContext``
- ``HBBasicRouterRequestContext``
- ``HBRouterBuilderContext``

### Result Builder

- ``HBRouterBuilder``
- ``RouteGroup``
- ``Route``
- ``Get(_:builder:)``
- ``Get(_:handler:)``
- ``Head(_:builder:)``
- ``Head(_:handler:)``
- ``Put(_:builder:)``
- ``Put(_:handler:)``
- ``Post(_:builder:)``
- ``Post(_:handler:)``
- ``Patch(_:builder:)``
- ``Patch(_:handler:)``
- ``Delete(_:builder:)``
- ``Delete(_:handler:)``
- ``Handle``

### Result Builders

- ``MiddlewareFixedTypeBuilder``
- ``RouteBuilder``