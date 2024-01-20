# ``HummingbirdLambda``

Run Hummingbird inside an AWS Lambda

## Usage

Create struct conforming to `HBLambda`. Setup your router in the `buildResponder` function: add routes, middleware etc and then return its responder.

```swift
@main
struct MyHandler: HBLambda {
    typealias Event = APIGatewayRequest
    typealias Output = APIGatewayResponse
    typealias Context = HBBasicLambdaRequestContext<Event>

    /// build responder that will create a response from a request
    func buildResponder() -> some HBResponder<Context> {
        let router = HBRouter(context: Context.self)
        router.get("hello/{name}") { request, context in
            let name = try context.parameters.require("name")
            return "Hello \(name)"
        }
        return router.buildResponder()
    }
}
```

The `Event` and `Output` types define your input and output objects. If you are using an `APIGateway` REST interface to invoke your Lambda then set these to `APIGateway.Request` and `APIGateway.Response` respectively. If you are using an `APIGateway` HTML interface then set these to `APIGateway.V2.Request` and `APIGateway.V2.Response`. The protocols ``HBAPIGatewayLambda`` and ``HBAPIGatewayV2Lambda`` set these up for you.

If you are using any other `In`/`Out` types you will need to implement the `request(context:application:from:)` and `output(from:)` methods yourself.

## Topics

### Lambda protocols

- ``HBLambda``
- ``HBAPIGatewayLambda``
- ``HBAPIGatewayV2Lambda``

### Request context

- ``HBLambdaRequestContext``
- ``HBBasicLambdaRequestContext``

## See Also

- ``Hummingbird``