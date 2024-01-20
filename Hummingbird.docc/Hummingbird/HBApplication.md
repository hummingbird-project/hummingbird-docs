# ``Hummingbird/HBApplication``

@Metadata {
    @DocumentationExtension(mergeBehavior: override)
}
Application type bringing together all the components of Hummingbird

## Overview

`HBApplication` is a concrete implementation of ``HBApplicationProtocol``. It provides the glue between your router and the HTTP server. 

```swift
// create router
let router = HBRouter()
router.get("hello") { _,_ in
    return "hello"
}
// create application
let app = HBApplication(
    router: router, 
    server: .http1()    // This is the default value
)
// run application
try await app.runService()
```

## Generic Type

`HBApplication` is a generic type, if you want to pass it around it is easier to use the opaque type `some HBApplicationProtocol` than work out its exact parameters types.

```swift
func buildApplication() -> some HBApplicationProtocol {
    let router = HBRouter()
    router.get("hello") { _,_ in
        return "hello"
    }
    // create application
    let app = HBApplication(router: router)
}
```

## Services

`HBApplication` has its own `ServiceGroup` which is used to manage the lifecycle of all the services it creates. You can add your own services to this group to have them managed as well. 

```swift
var app = HBApplication(router: router)
app.addServices(postgresClient, jobQueueHandler)
```

Check out [swift-service-lifecycle](https://github.com/swift-server/swift-service-lifecycle) for more details on service lifecycle management.
