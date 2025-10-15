# Guidelines for Building Hummingbird Apps

When you start a new app, especially with a new framework, you will find many useful tips and tools. Here are lessons we learned from building Hummingbird and from our community. Please send us feedback or suggestions for this document anytime!

## Dependencies

Hummingbird won't enforce any dependencies, or provide special treatment for dependencies on a framework level. However, we'll provide some guidelines and tips for _common_ dependencies and how to use them.

### Module Structure

Every Hummingbird project needs a main executable target. In the example below, this is the **MyApp** target.


If you have an OpenAPI specification for your API, create a separate OpenAPI module using [swift-openapi-generator](https://github.com/apple/swift-openapi-generator). This module generates the API server code.

```
├── Sources
│   ├── MyApp
│   └── MyAppAPI # Optional
│       
├── Tests
│   └── MyAppTests
│
└── Package.swift
```

## App Module Structure

The **MyApp** module is the primary module for the project. It contains the entry point for the application in **App.swift**, and has folders for **routes**, **database**, **services**, **middleware** and **config**.


```
├── Routes
│   ├── ...Routes.swift
│   └── BuildRouter.swift
│
├── Database
│   ├── Models
│   └── Migrations
│
├── Services
│   └── OTelService.swift
│   └── DatabaseService.swift
│
├── Middleware
│   └── AuthMiddleware.swift
│
├── Application+build.swift
└── App.swift
```

### App.swift


The **App.swift** file starts the application. It is a command line tool built with [swift-argument-parser](https://github.com/apple/swift-argument-parser). You can change the app's settings using command line arguments.

The `MyApp` type follows the `MyAppArguments` protocol, which you define to set command line arguments for the app. This lets you configure Hummingbird with different settings for unit tests or other environments.

```swift
import ArgumentParser
import Hummingbird

@main
struct MyApp: AsyncParsableCommand, MyAppArguments {
    @Option(name: .shortAndLong)
    var httpHostname: String = "127.0.0.1"

    @Option(name: .shortAndLong)
    var httpPort: Int = 8080

    /// The connection string for the PostgreSQL database
    @Option(name: .shortAndLong)
    var postgres: String = "postgres://localhost:5432/myapp"

    func run() async throws {
        let app = try await buildApplication(self)
        try await app.runService()
    }
}
```

### Application+Build.swift


We suggest creating an **Application+build.swift** file with the `buildApplication` function. Call this function from `App.swift` to build your app.

This file also sets a global default `RequestContext` type. The default `typealias` makes it easy to change the type without updating the whole app.

```swift
// Customize the RequestContext type to your needs
typealias AppRequestContext = BasicRequestContext

protocol MyAppArguments {
    var httpHostname: String { get }
    var httpPort: Int { get }
    var postgres: String { get }
}

func buildApplication(_ arguments: some MyAppArguments) async throws -> Application {
    let router = Router(context: AppRequestContext.self)
    router.add("users", routes: UserController().routes)
    let logger = Logger(label: "MyApp")

    let app = Application(
        router: router,
        configuration: .init(
            address: .hostname(arguments.httpHostname, port: arguments.httpPort),
            serverName: "MyApp"
        ),
        logger: logger
    )
    app.addServices(PostgresService(connectionString: arguments.postgres))
    return app
}
```

## Routes and Controllers


Put functions for routes in the **routes** folder. Controller types can be flexible over a ``RequestContext`` type, so you can use them with any Router, RouterGroup, or other implementation.

Take a look at **UserController.swift** as an example:

```swift
struct UserController<Context: RequestContext> {
    var routes: RouteCollection<Context> {
        return RouteCollection(context: Context.self)
            .get { request, context in
                ...
            }
    }
}
```

Controllers can specify dependencies on services they need, like a database connection. To do so, add these properties on the controller:

```swift
struct UserController<Context: RequestContext> {
    // Dependency on MongoDB
    let database: MongoDatabase

    var routes: RouteCollection<Context> {
        return RouteCollection(context: Context.self)
            .get { request, context in
                ...
            }
    }
}
```

If you need the ability to inject dependencies, you can use a `protocol` to abstract the implementation of the dependency.

```swift
protocol SomeInjectableService {
    func doSomething()
}

struct UserController<
    Context: RequestContext,
    SomeDependency: SomeInjectableService
> {
    let service: SomeDependency

    var routes: RouteCollection<Context> {
        return RouteCollection(context: Context.self)
            .get { request, context in
                self.service.doSomething()
                ...
            }
    }
}
```


Combine all controller routes into one router in **BuildRouter.swift**:

```swift
let router = Router(context: MyContext.self)
router.add("users", routes: UserController().routes)
```

## Request Context


We suggest refining AppContext requirements so each route only gets what it needs. For example:

```swift
// Good: This lets you use a different RequestContext for login routes
struct UserController<Context: RequestContext> { ... }
```


If a route needs something special, like authentication, use _protocol composition_ to refine the RequestContext.

```swift
// Good: This uses protocol composition to refine the RequestContext
// and lets you use different types to meet the requirements
struct UserProfileController<
    Context: RequestContext & AuthenticatedRequestContext
> { ... }
```

Users should define various traits related to a request's state (context) in separate protocols.

```swift
protocol RateLimitedRequestContext {
    var rateLimitStatus: RateLimitStatus { get }
    var ipAddress: String { get }
}

protocol AuthenticatedRequestContext {
    var user: User { get }
}
```

## Middleware

Middleware follow the same RequestContext conventions and recommendations as Routes. There's one distinction between Routes in that middleware can modify the request context.

In many applications, Middleware can be re-used across multiple routes. By using a generic middleware, you can ensure that the middleware is applicable to a variety of routes or route groups.

```swift
public struct AuthenticationGuardMiddleware<Context: AuthRequestContext>: RouterMiddleware {
    public init() {}

    public func handle(_ request: Request, context: Context, next: (Request, Context) async throws -> Response) async throws -> Response {
        guard context.identity != nil else {
            throw HTTPError(.unauthorized)
        }
        return try await next(request, context)
    }
}
```

### Child Request Contexts

When a route (group) requires additional refinement over a context, you can define that refinement as a ``ChildRequestContext``.

During refinement, you can specify additional properties or leverage the throwing initializer to unwrap optional properties or validate properties.

In the following example, the top-level context has an _optional_ `User` instance, set by a ``RouterMiddleware`` that validates a token.

The `ChildRequestContext` unwraps the user property from the original RequestContext. If the request is not verified, it throws an error.

```swift
struct MyAppRequestContext: RequestContext {
    public var coreContext: CoreRequestContextStorage
    // User is optional, because it's not required for all routes
    public var user: User?

    public init(source: Source) {
        self.coreContext = .init(source: source)
        self.routerContext = .init()
        self.user = nil
    }
}

struct AuthenticatedRequestContext: ChildRequestContext {
    public var coreContext: CoreRequestContextStorage
    // The Compiler guarantees that the User is present
    public var user: User

    init(context: MyAppRequestContext) throws {
        guard let user = context.user else {
            throw HTTPError(.unauthorized)
        }

        self.coreContext = context.coreContext
        self.user = user
    }
}
```

ChildRequestContexts are a powerful way of enforcing compile-time guarantees that requests adhere to certain requirements. And by expressing these requirements as protocol conformances, you can compose these properties and flexibly express those requirements.

```swift
func getMyProfile(
    request: Request,
    context: some AuthenticatedRequestContext
) async throws -> User.Profile {
    ...
}
```

In addition, you can compose and refine protocol requirements:

```swift
public protocol AutenticatedRequestContext: RequestContext { .. }
public protocol AdminRequestContext: AuthenticatedRequestContext { .. }
```

You can also specify a tuple of conformances in routes and middleware:

```swift
// Banning users is only allowed from pre-authorized IP addresses
func banUser(
    request: Request,
    context: some AdminRequestContext & IPWhitelistedRequestContext
) async throws -> Response {
    ...
    return Response(status: .ok)
}
```

## Services

Users should define externally managed resources in "Services".


Each service controls its own life cycle using [swift-service-lifecycle](https://github.com/swift-server/swift-service-lifecycle). Services start in the order you add them to the app, and stop in reverse order.

When you add services to a Hummingbird app, the app starts after your services and stops before them.

```swift
let app = Application()
let postgres = PostgresService(connectionString: arguments.postgres)
app.addServices(
    OpenTelemetryService(),
    // Postgres reports to OTel through the global logger, so initialized later
    postgres,
    // Depends on postgres, so initialized later
    PostgresJobQueueService(postgres: postgres)
)
```


## Monitoring and Logging

Swift's monitoring APIs help you track and log your app. Hummingbird supports [swift-log](https://github.com/apple/swift-log), [swift-metrics](https://github.com/apple/swift-metrics) and [swift-distributed-tracing](https://github.com/apple/swift-distributed-tracing). These tools report to your global monitoring backend if you set one up.

### Logging Recommendations

Use the [Logging Guidelines](https://www.swift.org/documentation/server/guides/libraries/log-levels.html) from the Swift Server Workgroup. Leverage **structured logging** to make logs more readable and searchable. By default, the app writes logs to `stdout` and ignores metrics and traces.

✅ Good:

```swift
logger.info("User logged in", metadata: ["user_id": .string(user.id)])
```

❌ Bad:

```swift
logger.info("User \(user.id) logged in")
```

See the [OTel Example Project](https://github.com/hummingbird-project/hummingbird-examples/tree/main/open-telemetry) for a complete example.

## Scaling Your App

Hummingbird is explicitly designed for resource efficiency. A good example is how HTTP bodies are always represented as a stream (`AsyncSequence`) of bytes. This means that the server can stream data to the client without having to buffer the entire response in memory. Likewise, any uploads from a user through Hummingbird can be efficiently handled through the `AsyncSequence` APIs.

- Set a realistic expectation of how large that image can be.
- Make sure you enforce that limit in your API, regardless of whether you're collecting or streaming.
- Avoid collecting the data into a single buffer, whenever possible. Use streaming APIs instead.
- Try to move the CPU and RAM intensive work of providing the correct format to the client if possible.
    - This means your API only needs to validate the data before processing/saving.
- Use libraries that support streaming data if your dataset is large.

Some libraries that play well into this:
- [MultipartKit 5](https://github.com/vapor/multipart-kit) (beta) will support streaming multipart parsing.
- [IkigaJSON](https://github.com/orlandos-nl/ikigajson) supports streaming JSON lines or JSON arrays.
- [Server Sent Events](https://github.com/orlandos-nl/ssekit) supports streaming Server Sent Events.
- [Swift-WebSocket](https://github.com/hummingbird-project/swift-websocket) and [Hummingbird-WebSocket](https://github.com/hummingbird-project/hummingbird-websocket) support streaming over WebSocket connections.
- [PostgreNIO](https://github.com/vapor/posrtgresnio), [Valkey-Swift](https://github.com/valkey-io/valkey-swift) and [MongoKitten](https://github.com/orlandos-nl/mongokitten) all support streaming in their database operations.

You can handle the request and response bodies as an `AsyncSequence`.

Requests can iterate over the body as an `AsyncSequence`. This will provide backpressure to the source if any part of the system cannot keep up.

```swift
router.get { req, context in
    for try await chunk in req.body {
        // Do something with the chunk, like writing to the filesystem
    }
    
    return Response(status: .ok)
}
```

In the above example, if a component is slow, the server slows down the client to match the speed. This prevents too much memory from building up in the server.

- Stream data in chunks using in ``ResponseBody.init(contentLength:_:)``.
- Use a ``ResponseBodyWriter`` to send the response body with backpressure.

### Persistence

Use [swift-jobs](https://github.com/hummingbird-project/swift-jobs) or other job queue tools to run long tasks or tasks you can run at the same time as background jobs. This helps your app handle more requests by adding more Hummingbird app instances.

Avoid local database systems such as [SQLite](https://sqlite.org), including wrappers like [GRDB](https://github.com/groue/GRDB.swift), as these only reside on the local machine.

Use databases like Postgres or Redis to save data and cache. These work well with Swift and have good community support.