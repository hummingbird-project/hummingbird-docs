# ``HummingbirdRouter``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

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

## Topics

### Guides

- <doc:RouterBuilderGuide>

### RouterBuilder

- ``/HummingbirdRouter/RouterBuilder``
- ``/HummingbirdRouter/RouterController``

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

## See Also

- ``Hummingbird``
