# Testing

Using the HummingbirdXCT framework to test your application

## Overview

Writing tests for application APIs is an important part of the development process. They ensure everything works as you expected and that you don't break functionality with future changes. Hummingbird provides a framework for testing your application as if it is a running server and you are a client connecting to it.

## Example

Lets create a simple application that says hello back to you. ie If your request is to `/hello/adam` it returns "Hello adam!".

```swift
let router = HBRouter()
router.get("hello/{name}") { _,context in
    return try "Hello \(context.parameters.require("name"))!"
}
let app = HBApplication(router: router)
```

## Testing

We can test the application returns the correct text as follows

```swift
func testApplicationReturnsCorrectText() async throw {
    try await app.test(.router) { client in
        try await client.XCTExecute(
            uri: "/hello/john",
            method: .get,
            headers: [:],  // default value
            body: nil      // default value
        ) { response in
            XCTAssertEqual(response.status, .ok)
            let body = try XCTUnwrap(response.body)
            XCTAssertEqual(String(buffer: body), "Hello john!")
        }
    }
}
```

### `HBApplication.test`

The ``/Hummingbird/HBApplicationProtocol/test(_:_:)`` function takes two parameters, first the test framework to use and then the closure to run with the framework client. The test framework defines how we are going to test our application. There are three possible frameworks

#### Router (.router)

The router test framework will send requests directly to the router. It does not need a running server to run tests. The main advantages of this is it is the quickest way to test your application but will not test anything outside of the router. In most cases you won't need more than this.

#### Live (.live)

The live framework uses a live server, with an HTTP client attached on a single connection.

#### AsyncHTTPClient (.ahc)

The AsyncHTTPClient framework is the same as the live framework except it uses [AsyncHTTPClient](https://github.com/swift-server/async-http-client) from swift-server as its HTTPClient. You can use this to test TLS and HTTP2 connections.

### Executing requests and testing the response

The function ``HummingbirdXCT/HBXCTClientProtocol/XCTExecute(uri:method:headers:body:testCallback:)`` sends a request to your application and provides the response in a closure. If you return something from the closure then this is returned by `XCTExecute`. In the following example we are testing whether a session cookie works.

```swift
func testApplicationReturnsCorrectText() async throw {
    try await app.test(.router) { client in
        // test login, returns a set-cookie header and extract
        let cookie = try await client.XCTExecute(
            uri: "/user/login", 
            method: .post, 
            headers: [.authorization: "Basic blahblah"]
        ) { response in
            XCTAssertEqual(response.status, .ok)
            return try XCTUnwrap(response.headers[.setCookie])
        }
        // check session cookie works
        try await client.XCTExecute(
            uri: "/user/is-authenticated", 
            method: .get, 
            headers: [.cookie: cookie]
        ) { response in
            XCTAssertEqual(response.status, .ok)
        }
    }
}
```
