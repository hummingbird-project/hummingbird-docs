# ``HummingbirdLambda``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Run Hummingbird inside an AWS Lambda.

## Usage

Create struct conforming to `LambdaFunction`. Setup your router in the `buildResponder` function: add routes, middleware etc and then return its responder.

```swift
@main
struct MyHandler: LambdaFunction {
    typealias Event = APIGatewayRequest
    typealias Output = APIGatewayResponse
    typealias Context = BasicLambdaRequestContext<APIGatewayRequest>

    init(context: LambdaInitializationContext) {}
    
    /// build responder that will create a response from a request
    func buildResponder() -> some Responder<Context> {
        let router = Router(context: Context.self)
        router.get("hello/{name}") { request, context in
            let name = try context.parameters.require("name")
            return "Hello \(name)"
        }
        return router.buildResponder()
    }
}
```

The `Event` and `Output` types define your input and output objects. If you are using an `APIGateway` REST interface to invoke your Lambda then set these to `APIGateway.Request` and `APIGateway.Response` respectively. If you are using an `APIGateway` HTML interface then set these to `APIGateway.V2.Request` and `APIGateway.V2.Response`. The protocols ``APIGatewayLambdaFunction`` and ``APIGatewayV2LambdaFunction`` set these up for you.

If you are using any other `In`/`Out` types you will need to implement the `request(context:application:from:)` and `output(from:)` methods yourself.

## Topics

### Lambda protocols

- ``LambdaFunction``
- ``APIGatewayLambdaFunction``
- ``APIGatewayV2LambdaFunction``

### Request context

- ``LambdaRequestContext``
- ``BasicLambdaRequestContext``
- ``LambdaRequestContextSource``

## See Also

- ``HummingbirdLambdaTesting``
