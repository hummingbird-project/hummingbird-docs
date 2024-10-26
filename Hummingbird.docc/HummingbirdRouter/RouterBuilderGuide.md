# Result Builder Router

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Building your router using a result builder. 

## Overview

`HummingbirdRouter` provides an alternative to the standard trie based ``Hummingbird/Router`` that is in the Hummingbird module. ``/HummingbirdRouter/RouterBuilder`` uses a result builder to construct your router.

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

## RequestContext

To be able to use the result builder router you need to provide a ``RequestContext`` that conforms to ``HummingbirdRouter/RouterRequestContext``. This contains an additional support struct ``HummingbirdRouter/RouterBuilderContext`` required by the result builder.

```swift
struct MyRequestContext: RouterRequestContext {
    public var routerContext: RouterBuilderContext
    public var coreContext: CoreRequestContextStorage

    public init(source: Source) {
        self.coreContext = .init(source: source)
        self.routerContext = .init()
    }
}
```

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

You can transform the ``/Hummingbird/RequestContext`` to a different type for a group of routes using ``/HummingbirdRouter/RouteGroup/init(_:context:builder:)``. When you define the `RequestContext` type you are converting to you need to define how you initialize it from the original `RequestContext`.

```swift
struct MyNewRequestContext: ChildRequestContext {
    typealias ParentContext = BasicRouterRequestContext
    init(context: ParentContext) {
        self.coreContext = context.coreContext
        ...
    }
}
```
Once you have defined how to perform the transform from your original `RequestContext` the conversion is added as follows

```swift
let router = RouterBuilder(context: BasicRouterRequestContext.self) {
    RouteGroup("user", context: MyNewRequestContext.self) {
        BasicAuthenticationMiddleware()
        Route(.post, "login") { request, context in
            ...
        }
    }
}
```

### Controllers

It is common practice to group routes into controller types that perform operations on a common type eg user management, CRUD operations for an asset type. By conforming your controller type to ``HummingbirdRouter/RouterController`` you can add the contained routes directly into your router eg

```swift
struct TodoController<Context: RouterRequestContext>: RouterController {
    var body: some RouterMiddleware<Context> {
        RouteGroup("todos") {
            Put(handler: self.put)
            Get(handler: self.get)
            Patch(handler: self.update)
            Delete(handler: self.delete)
        }
    }
}
let router = RouterBuilder(context: BasicRouterRequestContext.self) {
    TodoController()
}
```

### Differences from trie router

There is one subtle difference between the result builder based `RouterBuilder` and the more traditional trie based `Router` that comes with `Hummingbird` and this is related to how middleware are processed in groups. 

With the trie based `Router` a request is matched against an endpoint and then only runs the middleware applied to that endpoint. 

With the result builder a request is processed by each element of the router result builder until it hits a route that matches its URI and method. If it hits a ``/HummingbirdRouter/RouteGroup`` and this matches the current request uri path component then the request (with matched URI path components dropped) will be processed by the children of the `RouteGroup` including its middleware. The request path matching and middleware processing is done at the same time which means middleware only needs its parent `RouteGroup` paths to be matched for it to run.

## Topics

### Reference

- ``/HummingbirdRouter/RouterBuilder``
