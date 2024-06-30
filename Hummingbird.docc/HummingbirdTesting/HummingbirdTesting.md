# ``HummingbirdTesting``

Test framework for Hummingbird.

## Overview

Provides methods for easy setup of unit tests using XCTest framework. 

### Usage

Setup your server and run requests to the routes you want to test.

```swift
let router = Router()
router.get("test") { _ in
    return "testing"
}
let app = Application(router: router)
try await app.test(.router) { client in
    try await client.execute(uri: "test", method: .GET) { response in
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(String(buffer: response.body), "testing")
    }
}
```

## Topics

### Guides

- <doc:Testing>

### Test Setup

- ``TestingSetup``
- ``TestHTTPScheme``
- ``/Hummingbird/ApplicationProtocol/test(_:_:)``

## See Also

- ``Hummingbird``


