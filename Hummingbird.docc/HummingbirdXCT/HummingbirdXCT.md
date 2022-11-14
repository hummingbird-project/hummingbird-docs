# ``HummingbirdXCT``

Test framework for Hummingbird

## Overview

Provides methods for easy setup of unit tests using XCTest framework. 

### Usage

Setup your server and add features you want to test.

```swift
let app = HBApplication(testing: .embedded)
app.router.get("test") { _ in
    return "testing"
}
try app.XCTStart()
defer { app.XCTStop() }
```

And then test those features work as expected.

```swift
app.XCTExecute(uri: "test", method: .GET) { response in
    XCTAssertEqual(response.status, .ok)
    XCTAssertEqual(String(buffer: body), "testing")
}
```

## Topics

### Test Setup

- ``XCTTestingSetup``

## See Also

- ``Hummingbird``


