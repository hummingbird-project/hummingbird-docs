# Encoding and Decoding

Hummingbird uses `Codable` to decode requests and encode responses. 

The request context ``HBBaseRequestContext`` that is provided alongside your ``HBRequest`` has two member variables ``HBBaseRequestContext/requestDecoder`` and ``HBBaseRequestContext/responseEncoder``. These define how requests/responses are decoded/encoded. 

The `decoder` must conform to ``HBRequestDecoder`` which requires a ``HBRequestDecoder/decode(_:from:context:)`` function that decodes a `HBRequest`.

```swift
public protocol HBRequestDecoder {
    func decode<T: Decodable>(_ type: T.Type, from request: HBRequest, context: some HBBaseRequestContext) throws -> T
}
```

The `encoder` must conform to ``HBResponseEncoder`` which requires a ``HBResponseEncoder/encode(_:from:context:)`` function that creates a `HBResponse` from a `Codable` value and the original request that generated it.

```swift
public protocol HBResponseEncoder {
    func encode<T: Encodable>(_ value: T, from request: HBRequest, context: some HBBaseRequestContext) throws -> HBResponse
}
```

Both of these look very similar to the `Encodable` and `Decodable` protocol that come with the `Codable` system except you have additional information from the `HBRequest` and `HBBaseRequestContext` types on how you might want to decode/encode your data.

## Setting up your encoder/decoder

The default implementations of `requestDecoder` and `responseEncoder` are `Null` implementations that will assert if used. So you have to setup your `decoder` and `encoder` before you can use `Codable` in Hummingbird. ``HummingbirdFoundation`` includes two such implementations. ``HummingbirdFoundation/JSONEncoder`` and ``HummingbirdFoundation/JSONDecoder`` have been extended to conform to the relevant protocols. To use them you need to setup a custom request context. Read <doc:RequestContexts> to find out more about request contexts. Below we are setting up the context to provide JSON encoding and decoding.

```swift
struct JSONRequestContext: HBRequestContext {
    var requestDecoder: JSONDecoder { .init() }
    var responseEncoder: JSONEncoder { .init() }
    ...
}
```

`HummingbirdFoundation` also includes a decoder and encoder for url encoded form data. To use these you setup the relevant member variables in your request context as follows

```swift
struct JSONRequestContext: HBRequestContext {
    var requestDecoder: URLEncodedFormDecoder { .init() }
    var responseEncoder: URLEncodedFormEncoder { .init() }
    ...
}
```

## Decoding Requests

Once you have a decoder you can implement decoding in your routes using the ``HBRequest/decode(as:context:)`` method in the following manner

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
Like the standard `Decoder.decode` functions `HBRequest.decode` can throw an error if decoding fails. The decode function is also async as the request body is an asynchronous sequence of `ByteBuffers`. We need to collate the request body into one buffer before we can decode it.

## Encoding Responses

To have an object encoded in the response we have to conform it to `HBResponseEncodable`. This then allows you to create a route handler that returns this object and it will automatically get encoded. If we extend the `User` object from the above example we can do this

```swift
extension User: HBResponseEncodable {}

app.router.get("user") { request -> User in
    let user = User(email: "js@email.com", name: "John Smith")
    return user
}
```

## Decoding/Encoding based on Request headers

Because the full request is supplied to the `HBRequestDecoder`. You can make decoding decisions based on headers in the request. In the example below we are decoding using either the `JSONDecoder` or `/HummingbirdFoundation/URLEncodedFormDecoder` based on the "content-type" header.

```swift
struct MyRequestDecoder: HBRequestDecoder {
    func decode<T>(_ type: T.Type, from request: HBRequest, context: some HBBaseRequestContext) async throws -> T where T : Decodable {
        guard let header = request.headers[.contentType].first else { throw HBHTTPError(.badRequest) }
        guard let mediaType = HBMediaType(from: header) else { throw HBHTTPError(.badRequest) }
        switch mediaType {
        case .applicationJson:
            return try await JSONDecoder().decode(type, from: request, context: context)
        case .applicationUrlEncoded:
            return try await URLEncodedFormDecoder().decode(type, from: request, context: context)
        default:
            throw HBHTTPError(.badRequest)
        }
    }
}
```

In a similar manner you could also create a `HBResponseEncoder` based on the "accepts" header in the request.

## Topics

### Reference

- ``HBRequestDecoder``
- ``HBResponseEncoder``
