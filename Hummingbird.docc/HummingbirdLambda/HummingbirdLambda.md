# ``HummingbirdLambda``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Run Hummingbird inside an AWS Lambda.

Package that allows you to use the Hummingbird Router and Middleware inside an AWS Lambda.

## Usage

Creating a Hummingbird Lambda is very similar to how you create a Hummingbird server application. You create your
router, create a ``LambdaFunction`` using the router and then run the lambda function.

```swift
typealias AppRequestContext = BasicLambdaRequestContext<APIGatewayV2Request>

// Create router and add a single route returning "Hello" and name in its body
let router = Router(context: AppRequestContext.self)
router.get("hello/{name}") { request, context in
    let name = try context.parameters.require("name")
    return "Hello \(name)"
}
// create APIGatewayV2 lambda using router and run.
let lambda = LambdaFunction(
    router: router,
    event: APIGatewayV2Request.self,
    output: APIGatewayV2Response.self
)
try await lambda.runService()
```

## Topics

### Lambda function

- ``LambdaFunction``
- ``LambdaFunctionProtocol``
- ``APIGatewayLambdaFunction``
- ``APIGatewayV2LambdaFunction``
- ``FunctionURLLambdaFunction``

### Request context

- ``LambdaRequestContext``
- ``BasicLambdaRequestContext``
- ``LambdaRequestContextSource``

## See Also

- ``HummingbirdLambdaTesting``
