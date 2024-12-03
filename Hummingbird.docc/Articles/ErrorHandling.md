# Error Handling

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

How to build errors for the server to return.

## Overview

If a middleware or route handler throws an error the server needs to know how to handle this. If the server does not know how to handle the error then the only thing it can return to the client is a status code of 500 (Internal Server Error). This is not overly informative.

## HTTPError

Hummingbird uses the Error object ``Hummingbird/HTTPError`` throughout its codebase. The server recognises this and can generate a more informative response for the client from it. The error includes the status code that should be returned and a response message if needed. For example 

```swift
router.get("user") { request, context -> User in
    guard let userId = request.uri.queryParameters.get("id", as: Int.self) else {
        throw HTTPError(.badRequest, message: "Invalid user id")
    }
    ...
}
```
The `HTTPError` generated here will be recognised by the server and it will generate a status code 400 (Bad Request) with the body "Invalid user id".

## HTTPResponseError

The server knows how to respond to a `HTTPError` because it conforms to protocol ``Hummingbird/HTTPResponseError``. You can create your own `Error` object and conform it to `HTTPResponseError` and the server will know how to generate a sensible error from it. The example below is a error class that outputs an error code in the response headers.

```swift
struct MyError: HTTPResponseError {
    init(_ status: HTTPResponseStatus, errorCode: String) {
        self.status = status
        self.errorCode = errorCode
    }

    let errorCode: String

    // required by HTTPResponseError protocol
    let status: HTTPResponseStatus

    // required by HTTPResponseError protocol
    func response(from request: Request, context: some RequestContext) throws -> Response {
        .init(
            status: self.status,
            headers: ["error-code": self.errorCode]
        )
    }
}
```
