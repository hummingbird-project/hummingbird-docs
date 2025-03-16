# Router

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

The router directs requests to their handlers based on the contents of their path. 

## Overview

The default router that comes with Hummingbird uses a Trie based lookup. Routes are added using the function ``Hummingbird/Router/on(_:method:use:)``. You provide the URI path, the method and the handler function. Below is a simple route which returns "Hello" in the body of the response.

```swift
let router = Router()
router.on("/hello", method: .GET) { request, context in
    return "Hello"
}
```
If you don't provide a path then the default is for it to be "/".

### Methods

There are shortcut functions for the most common HTTP methods. The above can be written as

```swift
let router = Router()
router.get("/hello") { request, context in
    return "Hello"
}
```

There are shortcuts for `put`, `post`, `head`, `patch` and `delete` as well.

### Response generators

Route handlers are required to return a type conforming to the `ResponseGenerator` protocol. The `ResponseGenerator` protocol requires a type to be able to generate an `Response`. For example `String` has been extended to conform to `ResponseGenerator` by returning an `Response` with status `.ok`,  a content-type header of `text-plain` and a body holding the contents of the `String`. 
```swift
/// Extend String to conform to ResponseGenerator
extension String: ResponseGenerator {
    /// Generate response holding string
    public func response(from request: Request, context: some RequestContext) -> Response {
        let buffer = ByteBuffer(string: self)
        return Response(
            status: .ok,
            headers: [.contentType: "text/plain; charset=utf-8"],
            body: .init(byteBuffer: buffer)
        )
    }
}
```

In addition to `String` `ByteBuffer`, `HTTPResponseStatus` and `Optional` have also been extended to conform to `ResponseGenerator`.

It is also possible to extend `Codable` objects to generate `Response` by conforming these objects to `ResponseEncodable`. The object will use the response encoder attached to your context to encode these objects. If an object conforms to `ResponseEncodable` then also so do arrays and dictionaries of these objects.

### Wildcards

You can use wildcards to match sections of a path component.

A single `*` will skip one path component

```swift
router.get("/files/*") { request, context in
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
router.get("/files/*.jpg") { request, context in
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
router.get("/files/image.*") { request, context in
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
router.get("/files/**") { request, context in
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

You can extract parameters out of the URI by prefixing the path with a colon. This indicates that this path section is a parameter. The parameter name is the string following the colon. You can get access to the URI extracted parameters from the context. This example extracts an id from the URI and uses it to return a specific user. so "/user/56" will return user with id 56. 

```swift
router.get("/user/:id") { request, context in
    let id = context.parameters.get("id", as: Int.self) else { throw HTTPError(.badRequest) }
    return getUser(id: id)
}
```
In the example above if I fail to access the parameter as an `Int` then I throw an error. If you throw an ``/Hummingbird/HTTPError`` it will get converted to a valid HTTP response.

The parameter name in your route can also be of the form `{id}`, similar to OpenAPI specifications. With this form you can also extract parameter values from the URI that are prefixes or suffixes of a path component.

```swift
router.get("/files/{image}.jpg") { request, context in
    let imageName = context.parameters.get("image") else { throw HTTPError(.badRequest) }
    return getImage(image: imageName)
}
```
In the example above we match all paths that are a file with a jpg extension inside the files folder and then call a function with that image name.

### Query parameters

The `Request` url query parameters are available via a number of methods from `Request` member ``/HummingbirdCore/Request/uri``. You can get the full query string using ``/HummingbirdCore/URI/query``. You can get the query string broken up into individual parameters and percent decoded using ``/HummingbirdCore/URI/queryParameters``.

```swift
router.get("/user") { request, context in
    let id = request.uri.queryParameters.get("id", as: Int.self) else { throw HTTPError(.badRequest) }
    return getUser(id: id)
}
```

You can also use ``/HummingbirdCore/URI/decodeQuery(as:context:)`` to convert the query parameters into a Swift object.

```swift
struct Coordinate: Decodable {
    let x: Double
    let y: Double
}
router.get("tile") { request, context in
    let position = request.uri.decodeQuery(as: Coordinate.self, context: context)
    return tiles.get(at: position)
}
```

### Groups

Routes can be grouped together in a ``RouterGroup``.  These allow for you to prefix a series of routes with the same path and more importantly apply middleware to only those routes. The example below is a group that includes five handlers all prefixed with the path "/todos".

```swift
let app = Application()
router.group("/todos")
    .put(use: createTodo)
    .get(use: listTodos)
    .get("{id}", getTodo)
    .patch("{id}", editTodo)
    .delete("{id}", deleteTodo)
```

### RequestContext transformation

The `RequestContext` can be transformed for the routes in a route group. The `RequestContext` you are converting to needs to conform to ``ChildRequestContext``. This requires a parent context ie the `RequestContext` you are converting from and a ``ChildRequestContext/init(context:)`` function to perform the conversion.

```swift
struct MyNewRequestContext: ChildRequestContext {
    typealias ParentContext = MyRequestContext
    init(context: ParentContext) throws {
        self.coreContext = context.coreContext
        ...
    }
}
```
Once you have defined how to perform the transform from your original `RequestContext` the conversion is added as follows

```swift
let app = Application(context: MyRequestContext.self)
router.group("/todos", context: MyNewRequestContext.self)
    .put(use: createTodo)
    .get(use: listTodos)
```

### Route Collections

A ``RouteCollection`` is a collection of routes and middleware that can be added to a `Router` in one go. It has the same API as `RouterGroup`, so can have groups internal to the collection to allow for Middleware to applied to only sub-sections of the `RouteCollection`. 

```swift
struct UserController<Context: RequestContext> {
    var routes: RouteCollection<Context> {
        let routes = RouteCollection()
        routes.post("signup", use: signUp)
        routes.group("login")
            .add(middleware: BasicAuthenticationMiddleware())
            .post(use: login)
        return routes
    }
}
```

You add the route collection to your router using ``Router/addRoutes(_:atPath:)``.

```swift
let router = Router()
router.add("users", routes: UserController().routes)
```

### Request Body

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

Once you have read the sequence of buffers you cannot read it again. If you want to read the contents of a request body in middleware before it reaches the route handler, but still have it available for the route handler you can use `Request.collectBody(upTo:)`. After this point though the request body cannot be treated as a sequence of buffers as it has already been collapsed into a single buffer. 

### Writing the response body

The response body is returned back to the server as a closure that will write the body. The closure is provided with a writer type conforming to ``HummingbirdCore/ResponseBodyWriter`` and the closure uses this to write the buffers that make up the body. In most cases you don't need to know this as ``HummingbirdCore/ResponseBody`` has initializers that take a single `ByteBuffer`, a sequence of `ByteBuffers` and an `AsyncSequence` of `ByteBuffers` which covers most of the kinds of responses. 

In the situation where you need something a little more flexible you can use the closure form. Below is a `ResponseBody` that consists of 10 buffers of random data written with a one second pause between each buffer.

```swift
let responseBody = ResponseBody { writer in
    for _ in 0..<10 {
        try await Task.sleep(for: .seconds(1))
        let buffer = (0..<size).map { _ in UInt8.random(in: 0...255) }
        try await writer.write(buffer)
    }
    writer.finish(nil)
}
```
Once you have finished writing your response body you need to tell the writer you have finished by calling ``HummingbirdCore/ResponseBodyWriter/finish(_:)``. At this point you can write trailing headers by passing them to the `finish` function. NB Trailing headers are only sent if your response body is chunked and does not include a content length header.

### Editing response in handler

The standard way to provide a custom response from a route handler is to return a `Response` from that handler. This method loses a lot of the automation of encoding responses, generating the correct status code etc. 

Instead you can return what is called a `EditedResponse`. This includes a type that can generate a response on its own via the `ResponseGenerator` protocol and includes additional edits to the response.

```swift
router.post("test") { request, _ -> EditedResponse in
    return .init(
        status: .accepted,
        headers: [.contentType: "application/json"],
        response: #"{"test": "value"}"#
    )
}
```

## See Also

- ``HummingbirdCore/Request``
- ``HummingbirdCore/Response``
- ``Router``
- ``RouteCollection``
- ``RouterGroup``
