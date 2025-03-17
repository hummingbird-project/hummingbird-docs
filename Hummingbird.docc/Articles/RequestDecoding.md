# Request Decoding

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Decoding of Requests with JSON content and other formats.

## Overview

Hummingbird uses `Codable` to decode requests. It defines what decoder to use via the ``RequestContext/requestDecoder`` parameter of your ``RequestContext``. By default this is set to decode JSON, using `JSONDecoder` that comes with Swift Foundation.

Requests are converted to Swift objects using the ``/HummingbirdCore/Request/decode(as:context:)`` method in the following manner.

```swift
struct User: Decodable {
    let email: String
    let firstName: String
    let surname: String
}
router.post("user") { request, context -> HTTPResponse.Status in
    // decode user from request
    let user = try await request.decode(as: User.self, context: context)
    // create user and if ok return `.ok` status
    try await createUser(user)
    return .ok
}
```
Like the standard `Codable` decode functions `Request.decode(as:context:)` can throw an error if decoding fails. The decode function is also async as the request body is an asynchronous sequence of `ByteBuffers`. We need to collate the request body into one buffer before we can decode it.

### Date decoding

As mentioned above the default is to use `JSONDecoder` for decoding `Request` bodies. This default is also set to use ISO 8601 dates in the form `YYYY-MM-DDThh:mm:ssZ`. If you generating requests for a Hummingbird server using `JSONEncoder` you can output ISO 8601 dates by setting `JSONEncoder.dateEncodingStrategy` to `.iso8601`.

## Setting up a custom decoder

If you want to use a different format, a different JSON encoder or want to support multiple formats, you need to setup you own `requestDecoder` in a custom request context. Your request decoder needs to conform to the `RequestDecoder` protocol which has one requirement ``RequestDecoder/decode(_:from:context:)``. For instance `Hummingbird` also includes a decoder for URL encoded form data. Below you can see a custom request context setup to use ``URLEncodedFormDecoder`` for request decoding. The router is then initialized with this context. Read <doc:RequestContexts> to find out more about request contexts. 

```swift
struct URLEncodedRequestContext: RequestContext {
    var requestDecoder: URLEncodedFormDecoder { .init() }
    ...
}
let router = Router(context: URLEncodedRequestContext.self)
```

## Decoding based on Request headers

Because the full request is supplied to the `RequestDecoder`. You can make decoding decisions based on headers in the request. In the example below we are decoding using either the `JSONDecoder` or `URLEncodedFormDecoder` based on the "content-type" header.

```swift
struct MyRequestDecoder: RequestDecoder {
    func decode<T>(_ type: T.Type, from request: Request, context: some RequestContext) async throws -> T where T : Decodable {
        guard let header = request.headers[.contentType].first else { throw HTTPError(.badRequest) }
        guard let mediaType = MediaType(from: header) else { throw HTTPError(.badRequest) }
        switch mediaType {
        case .applicationJson:
            return try await JSONDecoder().decode(type, from: request, context: context)
        case .applicationUrlEncoded:
            return try await URLEncodedFormDecoder().decode(type, from: request, context: context)
        default:
            throw HTTPError(.badRequest)
        }
    }
}
```

## See Also 

- ``RequestDecoder``
- ``RequestContext``
