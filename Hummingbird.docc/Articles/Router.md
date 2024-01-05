# Router

The router directs requests to their handlers based on the contents of their path. 

## Overview

The default router that comes with Hummingbird uses a Trie based lookup. Routes are added using the function `on`. You provide the URI path, the method and the handler function. Below is a simple route which returns "Hello" in the body of the response.

```swift
let router = HBRouter()
router.on("/hello", method: .GET) { request, context in
    return "Hello"
}
```
If you don't provide a path then the default is for it to be "/".

### Methods

There are shortcut functions for the most common HTTP methods. The above can be written as

```swift
let router = HBRouter()
app.router.get("/hello") { request, context in
    return "Hello"
}
```

There are shortcuts for `put`, `post`, `head`, `patch` and `delete` as well.

### Response generators

Route handlers are required to return a type conforming to the `HBResponseGenerator` protocol. The `HBResponseGenerator` protocol requires a type to be able to generate an `HBResponse`. For example `String` has been extended to conform to `HBResponseGenerator` by returning an `HBResponse` with status `.ok`,  a content-type header of `text-plain` and a body holding the contents of the `String`. 
```swift
/// Extend String to conform to ResponseGenerator
extension String: HBResponseGenerator {
    /// Generate response holding string
    public func response(from request: HBRequest, context: some HBBaseRequestContext) -> HBResponse {
        let buffer = context.allocator.buffer(string: self)
        return HBResponse(status: .ok, headers: ["content-type": "text/plain; charset=utf-8"], body: .byteBuffer(buffer))
    }
}
```

In addition to `String` `ByteBuffer`, `HTTPResponseStatus` and `Optional` have also been extended to conform to `HBResponseGenerator`.

It is also possible to extend `Codable` objects to generate `HBResponse` by conforming these objects to `HBResponseEncodable`. The object will use the response encoder attached to your context to encode these objects. If an object conforms to `HBResponseEncodable` then also so do arrays and dictionaries of these objects.

### Wildcards

You can use wildcards to match sections of a path component.

A single `*` will skip one path component

```swift
app.router.get("/files/*") { request, context in
    return request.uri.description
}
```
Will match 
```
GET /files/test
GET /files/test2
```

A `*` at the start of a route component will match all path components with the same suffix.

```swift
app.router.get("/files/*.jpg") { request, context in
    return request.uri.description
}
```
Will work for 
```
GET /files/test.jpg
GET /files/test2.jpg
```

A `*` at the end of a route component will match all path components with the same prefix.

```swift
app.router.get("/files/image.*") { request, context in
    return request.uri.description
}
```
Will work for 
```
GET /files/image.jpg
GET /files/image.png
```

A `**` will match and capture all remaining path components.

```swift
app.router.get("/files/**") { request, context in
    // return catchAll captured string
    return context.parameters.getCatchAll().joined(separator: "/")
}
```
The above will match routes and respond as follows 
```
GET /files/image.jpg returns "image.jpg" in the response body
GET /files/folder/image.png returns "folder/image.png" in the response body
```

### Parameter Capture

You can extract parameters out of the URI by prefixing the path with a colon. This indicates that this path section is a parameter. The parameter name is the string following the colon. You can get access to the parameters extracted from the URI with `HBRequest.parameters`. If there are no URI parameters in the path, accessing `HBRequest.parameters` will cause a crash, so don't use it if you haven't specified a parameter in the route path. This example extracts an id from the URI and uses it to return a specific user. so "/user/56" will return user with id 56. 

```swift
app.router.get("/user/:id") { request in
    let id = request.parameters.get("id", as: Int.self) else { throw HBHTTPError(.badRequest) }
    return getUser(id: id)
}
```
In the example above if I fail to access the parameter as an `Int` then I throw an error. If you throw an `HBHTTPError` it will get converted to a valid HTTP response.

The parameter name in your route can also be of the form `{id}`, similar to OpenAPI specifications. With this form you can also extract parameter values from the URI that are prefixes or suffixes of a path component.

```swift
app.router.get("/files/{image}.jpg") { request in
    let imageName = request.parameters.get("image") else { throw HBHTTPError(.badRequest) }
    return getImage(image: imageName)
}
```
In the example above we match all paths that are a file with a jpg extension inside the files folder and then call a function with that image name.

### Groups

Routes can be grouped together in a `HBRouterGroup`.  These allow for you to prefix a series of routes with the same path and more importantly apply middleware to only those routes. The example below is a group that includes five handlers all prefixed with the path "/todos".

```swift
let app = HBApplication()
app.router.group("/todos")
    .put(use: createTodo)
    .get(use: listTodos)
    .get("{id}", getTodo)
    .patch("{id}", editTodo)
    .delete("{id}", deleteTodo)
```

### Route handlers

A route handler `HBRouteHandler` allows you to encapsulate all the components required for a route, and provide separation of the extraction of input parameters from the request and the processing of those parameters. An example could be structrured as follows

```swift
struct AddOrder: HBRouteHandler {
    struct Input: Decodable {
        let name: String
        let amount: Double
    }
    struct Output: HBResponseEncodable {
        let id: String
    }
    let input: Input
    let user: User
    
    init(from request: HBRequest, context: some HBAuthRequestContextProtocol) async throws {
        self.input = try await request.decode(as: Input.self, context: context)
        self.user = try context.auth.require(User.self)
    }
    func handle(context: some HBAuthRequestContextProtocol) async throws -> Output {
        let order = Order(user: self.user.id, details: self.input)
        let order = try await order.save(on: db)
        return Output(id: order.id)
    }
}
```
Here you can see the `AddOrder` route handler encapsulates everything you need to know about the add order route. The `Input` and `Output` structs are defined and any additional input parameters that need extracted from the `HBRequest`. The input parameters are extracted in the `init` and then the those parameters are processed in the `handle` function. In this example we need to decode the `Input` from the `HBRequest` and using the authentication framework from `HummingbirdAuth` we get the authenticated user. 

The following will add the handler to the application
```swift
application.router.put("order", use: AddOrder.self)
```

### Request body

By default the request body is an AsyncSequence of ByteBuffers. You can treat it as a series of buffers or collect it into one larger buffer.

```swift
// process each buffer in the sequence separately
for try await buffer in request.body {
    process(buffer)
}
```
```swift
// collect all the buffers in the sequence into a single buffer
let buffer = try await request.body.collate(maxSize: maximumBufferSizeAllowed)
}
```

Once you have read the sequence of buffers you cannot read it again. If you want to read the contents of a request body in middleware before it reaches the route handler, but still have it available for the route handler you can use `HBRequest.collateBody(context:)`. After this point though the request body cannot be treated as a sequence of buffers as it has already been collapsed into a single buffer. 

### Editing response in handler

The standard way to provide a custom response from a route handler is to return a `HBResponse` from that handler. This method loses a lot of the automation of encoding responses, generating the correct status code etc. 

Instead you can return what is called a `HBEditedResponse`. This includes a type that can generate a response on its own via the `HBResponseGenerator` protocol and includes additional edits to the response.

```swift
application.router.post("test") { request -> HBEditedResponse in
    return .init(
        status: .accepted,
        headers: [.contentType: "application/json"],
        response: #"{"test": "value"}"#
    )
}
```

## Topics

### Reference

- ``HBRouter``
- ``HBRouterGroup``
- ``HBRouterMethods``
