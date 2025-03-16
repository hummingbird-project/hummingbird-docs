# Response Encoding

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Writing Responses using JSON and other formats.

## Overview

Hummingbird uses `Codable` to encode responses. If your router handler returns a type conforming to ``ResponseEncodable`` this will get converted to a ``HummingbirdCore/Response`` using the encoder ``RequestContext/responseEncoder`` parameter of your ``RequestContext``. By default this is set to create a JSON Response using `JSONEncoder` that comes with Swift Foundation.

```swift
struct User: ResponseEncodable {
    let email: String
    let name: String
}

router.get("user") { request, _ -> User in
    let user = User(email: "js@email.com", name: "John Smith")
    return user
}
```
 With the above code and the default JSON encoder you will get a response with header `content-type` set to `application/json; charset=utf-8` and body 
 ```jsonb
 {"email":"js@email.com","name":"John Smith"}
 ```

 ## Setting up a custom encoder

If you want to use a different format, a different JSON encoder or want to support multiple formats, you need to setup you own `responseEncoder` in a custom request context. Your response encoder needs to conform to the `ResponseEncoder` protocol which has one requirement ``ResponseEncoder/encode(_:from:context:)``. For instance `Hummingbird` also includes a encoder for URL encoded form data. Below you can see a custom request context setup to use ``URLEncodedFormEncoder`` for response encoding. The router is then initialized with this context. Read <doc:RequestContexts> to find out more about request contexts. 

```swift
struct URLEncodedRequestContext: RequestContext {
    var responseEncoder: URLEncodedFormEncoder { .init() }
    ...
}
let router = Router(context: URLEncodedRequestContext.self)
```

## Encoding based on Request headers

Because the original request is supplied to the `ResponseEncoder`. You can make encoding decisions based on headers in the request. In the example below we are encoding using either the `JSONEncoder` or `URLEncodedFormEncoder` based on the "accept" header from the request.

```swift
struct MyResponsEncoder: ResponseEncoder {
    func encode(_ value: some Encodable, from request: Request, context: some RequestContext) throws -> Response {
        guard let header = request.headers[values: .accept].first else { throw HTTPError(.badRequest) }
        guard let mediaType = MediaType(from: header) else { throw HTTPError(.badRequest) }
        switch mediaType {
        case .applicationJson:
            return try JSONEncoder().encode(value, from: request, context: context)
        case .applicationUrlEncoded:
            return try URLEncodedFormEncoder().encode(value, from: request, context: context)
        default:
            throw HTTPError(.badRequest)
        }
    }
}
```

## See Also 

- ``ResponseEncoder``
- ``RequestContext``
