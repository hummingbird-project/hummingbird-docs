# ``HummingbirdValkey``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Add Valkey/Redis support to Hummingbird server with valkey-swift.

## Overview

HummingbirdValkey provides a driver for the Hummingbird persist framework to store key, value pairs between requests.

```swift
let valkeyClient = ValkeyClient(
    .hostname(Self.valkeyHostname, port: 6379),
    logger: Logger(label: "Valkey")
)
let persist = ValkeyPersistDriver(client: valkeyClient)
let router = Router()
// return value from valkey database
router.get("{id}") { request, context -> String? in
    let id = try context.parameters.require("id")
    try await persist.get(key: id, as: String.self)
}
// set value in valkey database
router.put("{id}") { request, context -> String? in
    let id = try context.parameters.require("id")
    let value = try request.uri.queryParameters.require("value")
    try await persist.set(key: id, value: value)
}
var app = Application(router: router)
// add Valkey client as service to manage its lifecycle
app.addServices(valkeyClient)
try await app.runService()
```

## Topics

### Storage

- ``ValkeyPersistDriver``

## See Also

- ``JobsValkey``