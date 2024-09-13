# ``HummingbirdRouter``

Alternative result builder based router for Hummingbird. 

## Overview

HummingbirdRouter provides an alternative to the standard trie based router that is in the Hummingbird module. ``/HummingbirdRouter/RouterBuilder`` uses a result builder to construct your router.

```swift
let router = RouterBuilder(context: BasicRouterRequestContext.self) {
    CORSMiddleware()
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

A request is processed by each element of the router result builder until it hits a route that matches its URI and method. If it hits a ``/HummingbirdRouter/RouteGroup`` and this matches the current request uri path component then the request (with matched URI path components dropped) will be processed by the children of the `RouteGroup`. When the request hits a route and the uri matches it will run that route and pass the response back to be processed by all the middleware that processed the request but in reverse order.

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

Routes can be initialised with their own result builder as long as they end with a route ``/HummingbirdRouter/Handle`` function that returns the response. This allows us to apply middleware to individual routes. 

```swift
Post("login") {
    BasicAuthenticationMiddleware()
    Handle  { request, context in
        ...
    }
}
```

If you are not adding the handler inline you can add the function reference without the ``/HummingbirdRouter/Handle``.  

```swift
@Sendable func processLogin(request: Request, context: MyContext) async throws -> Response {
    // process login
}
RouterBuilder(context: BasicRouterRequestContext.self) {
    ...
    Post("login") {
        BasicAuthenticationMiddleware()
        processLogin
    }
}
```

## RequestContext transformation

You can transform the ``/Hummingbird/RequestContext`` to a different type for a group of routes using ``/HummingbirdRouter/ContextTransform``. When you define the `RequestContext` type you are converting to you need to define how you initialize it from the original `RequestContext`.

```swift
struct MyNewRequestContext: RequestContext {
    typealias Source = BasicRouterRequestContext
    init(source: Source) {
        self.coreContext = .init(source: source)
        ...
    }
}
```
Once you have defined how to perform the transform from your original `RequestContext` the conversion is added as follows

```swift
let router = RouterBuilder(context: BasicRouterRequestContext.self) {
    RouteGroup("user") {
        ContextTransform(to: MyNewRequestContext.self) {
            BasicAuthenticationMiddleware()
            Route(.post, "login") { request, context in
                ...
            }
        }
    }
}
```
It is best to wrap the `ContextTransform` inside a `RouteGroup` so you are only performing the transform when necessary.

## Topics

### RouterBuilder

- ``/HummingbirdRouter/RouterBuilder``

### Request Context

- ``/HummingbirdRouter/RouterRequestContext``
- ``/HummingbirdRouter/BasicRouterRequestContext``
- ``/HummingbirdRouter/RouterBuilderContext``

### Result Builder

- ``/HummingbirdRouter/RouterBuilder``
- ``/HummingbirdRouter/RouteGroup``
- ``/HummingbirdRouter/Route``
- ``/HummingbirdRouter/Get(_:builder:)``
- ``/HummingbirdRouter/Get(_:handler:)``
- ``/HummingbirdRouter/Head(_:builder:)``
- ``/HummingbirdRouter/Head(_:handler:)``
- ``/HummingbirdRouter/Put(_:builder:)``
- ``/HummingbirdRouter/Put(_:handler:)``
- ``/HummingbirdRouter/Post(_:builder:)``
- ``/HummingbirdRouter/Post(_:handler:)``
- ``/HummingbirdRouter/Patch(_:builder:)``
- ``/HummingbirdRouter/Patch(_:handler:)``
- ``/HummingbirdRouter/Delete(_:builder:)``
- ``/HummingbirdRouter/Delete(_:handler:)``
- ``/HummingbirdRouter/Handle``
