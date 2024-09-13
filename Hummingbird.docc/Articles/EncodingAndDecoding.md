# Encoding and Decoding

Hummingbird uses `Codable` to decode requests and encode responses. 

The request context ``RequestContext`` that is provided alongside your ``/HummingbirdCore/Request`` has two member variables ``RequestContext/requestDecoder`` and ``RequestContext/responseEncoder``. These define how requests/responses are decoded/encoded. 

The `decoder` must conform to ``RequestDecoder`` which requires a ``RequestDecoder/decode(_:from:context:)`` function that decodes a `Request`.

```swift
public protocol RequestDecoder {
    func decode<T: Decodable>(_ type: T.Type, from request: Request, context: some RequestContext) throws -> T
}
```

The `encoder` must conform to ``ResponseEncoder`` which requires a ``ResponseEncoder/encode(_:from:context:)`` function that creates a `Response` from a `Codable` value and the original request that generated it.

```swift
public protocol ResponseEncoder {
    func encode<T: Encodable>(_ value: T, from request: Request, context: some RequestContext) throws -> Response
}
```

Both of these look very similar to the `Encodable` and `Decodable` protocol that come with the `Codable` system except you have additional information from the `Request` and `RequestContext` types on how you might want to decode/encode your data.

## Setting up your encoder/decoder

The default implementations of `requestDecoder` and `responseEncoder` are `Hummingbird/JSONDecoder` and `Hummingbird/JSONEncoder` respectively. They have been extended to conform to the relevant protocols so they can be used to decode requests and encode responses. 

If you don't want to use JSON you need to setup you own `requestDecoder` and `responseEncoder` in a custom request context. For instance `Hummingbird` also includes a decoder and encoder for URL encoded form data. Below you can see a custom request context setup to use ``URLEncodedFormDecoder`` for request decoding and ``URLEncodedFormEncoder`` for response encoding. The router is then initialized with this context. Read <doc:RequestContexts> to find out more about request contexts. 

```swift
struct URLEncodedRequestContext: RequestContext {
    var requestDecoder: URLEncodedFormDecoder { .init() }
    var responseEncoder: URLEncodedFormEncoder { .init() }
    ...
}
let router = Router(context: URLEncodedRequestContext.self)
```

## Decoding Requests

Once you have a decoder you can implement decoding in your routes using the ``/HummingbirdCore/Request/decode(as:context:)`` method in the following manner

```swift
struct User: Decodable {
    let email: String
    let firstName: String
    let surname: String
}
app.router.post("user") { request, context -> HTTPResponse.Status in
    // decode user from request
    let user = try await request.decode(as: User.self, context: context)
    // create user and if ok return `.ok` status
    try await createUser(user)
    return .ok
}
```
Like the standard `Decoder.decode` functions `Request.decode` can throw an error if decoding fails. The decode function is also async as the request body is an asynchronous sequence of `ByteBuffers`. We need to collate the request body into one buffer before we can decode it.

## Encoding Responses

To have an object encoded in the response we have to conform it to `ResponseEncodable`. This then allows you to create a route handler that returns this object and it will automatically get encoded. If we extend the `User` object from the above example we can do this

```swift
extension User: ResponseEncodable {}

app.router.get("user") { request -> User in
    let user = User(email: "js@email.com", name: "John Smith")
    return user
}
```

## Decoding/Encoding based on Request headers

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

In a similar manner you could also create a `ResponseEncoder` based on the "accepts" header in the request.

## Topics

### Reference

- ``RequestDecoder``
- ``ResponseEncoder``
