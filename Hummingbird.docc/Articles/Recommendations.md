## Dependencies

Hummingbird won't enforce any dependencies, or provide special treatment for dependencies on a framework level. However, we'll provide some guidelines and tips for _common_ dependencies and how to use them.

## Project Structure

The project structure is a recommended project layout, defining what modules are recommended to create and how these modules are structured in terms of folders and files.

### Module Structure

Every Hummingbird projects neds a primary executable target. This is the **MyApp** target in the example below.

If a user has an OpenAPI specification for their API, a separate OpenAPI module is recommended based on [swift-openapi-generator](https://github.com/apple/swift-openapi-generator). This module will be used to generate the API server code.

```
├── Sources
│   ├── MyApp
│   └── MyAppOpenAPI # Optional
│       
├── Tests
│   └── MyAppTests
│
└── Package.swift
```

## App Module Structure

The **MyApp** module is the primary module for the project. It contains the entry point for the application in **App.swift**, and has folders for **routes**, **database**, **repositories**, **services**, **middleware** and **config**.


```
├── Routes
│   ├── ...Routes.swift
│   └── BuildRouter.swift
│
├── Database
│   ├── Models
│   └── Migrations
│
├── Repositories
│   └── UserRepository.swift
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

The **App.swift** file is the entry point for the application. It's a command line tool based on [swift-argument-parser](https://github.com/apple/swift-argument-parser), allowing deployments to customize the application's configuration through command line arguments.

The `MyApp` type also confirms to `MyAppArguments`, which is a user-defined protocol that specifies the command line arguments for the application. This enables the Hummingbird Application to be configured with different settings when running in a unit test, or other environments.

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

The **Application+build.swift** file is a recommended file that contains the `buildApplication` function. This function is used to build the application, and is used in the `App.swift` file.

The file also contains a global default `RequestContext` type, which is used to customize the context carried through the request lifecycle for the application. The default `typealias` enables users to easily customize the type without having to change the entire application.

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

The **routes** folder contains functions that apply routes to the router through "controller" types. Each Controller is generically contrained over the ``RequestContext`` type, so that it can be used with any Router, RouterGroup or other implementation.

Let's take **UserController.swift** as an example:

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

struct UserController<Context: RequestContext> {
    let service: any SomeInjectableService

    var routes: RouteCollection<Context> {
        return RouteCollection(context: Context.self)
            .get { request, context in
                self.service.doSomething()
                ...
            }
    }
}
```

All Controllers' routes are combined into a single router in **BuildRouter.swift**:

```swift
let router = Router(context: MyContext.self)
router.add("users", routes: UserController().routes)
```

## Request Context

It's also recommended to users that they refine the AppContext requirements for only as much as strictly required by the routes. For example:

```swift
// ✅ This is recommended, because it allows a different RequestContext to be used for login routes
struct UserController<Context: RequestContext> { ... }
```

If a route has requirements for the request, like being authenticated, it's recommended to leverage _protocol composition_ to refine the RequestContext.

```swift
// ✅ This is recommended, because it leverages protocol composition to refine the RequestContext
// while still being flexible enough to allow different concrete types to fulfil the requirements
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
```

```swift
struct AuthenticatedRequestContext: ChildRequestContext {
    public var coreContext: CoreRequestContextStorage
    // User is required in all routes, and this is statically known
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

## Services

Users should define (external) resources in `Services`. For example:

- PostgreSQL
- S3 Bucket Management
- Job Queues
- Caching
- OpenTelemetry
- File System Access

Each service manages it's lifecycle through [swift-service-lifecycle](https://github.com/swift-server/swift-service-lifecycle). The order of services is important, as services are initialized in the order they are added to the application, and teared down in reverse order.

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

## Observability

Swift's Observability APIs offer a powerful and flexible way to instrument and observe the application. Hummingbird already reports to [swift-log](https://github.com/apple/swift-log) and provides middleware for [swift-metrics](https://github.com/apple/swift-metrics) and [swift-distributed-tracing](https://github.com/apple/swift-distributed-tracing). These will report to the globally set up observability backend(s) automatically, if they're set up.

By default, logs are emitted to `stdout`, and metrics + traces are discarded. If you want to trace signals in a single place, we recommend using [swift-otel](https://github.com/swift-otel/swift-otel) as an observability backend.

See the [OTel Example Project](https://github.com/hummingbird-project/hummingbird-examples/tree/main/open-telemetry) for a complete example.

### Logging Recommendations

Use the [Logging Guidelines](https://www.swift.org/documentation/server/guides/libraries/log-levels.html) set forth by the Swift Server Workgroup. It's strongly recommended to leverage **structured logging** to make logs more readable and searchable.

✅ Good:

```swift
logger.info("User logged in", metadata: ["user_id": .string(user.id)])
```

❌ Bad:

```swift
logger.info("User \(user.id) logged in")
```

## Scalability

Hummingbird is explicitly designed for resource efficiency. A good example is how HTTP bodies are always represented as an `AsyncSequence` of bytes. This means that the server can stream data to the client without having to buffer the entire response in memory. Likewise, any uploads from a user through Hummingbird can be efficiently handled through the `AsyncSequence` APIs.

It's highly recommended that you avoid `collect`ing responses into memory if possible. Instead, attempt to leverage the `AsyncSequence` APIs to stream data.

Any data that needs to be stored in contiguous memory, like a JSON blob, should be strictly limited in the maximum size as to avoid (memory) resource exhaustion and performance issues.

### Handling Bodies

If you're using standard libraries like Foundation's `JSONDecoder`, limit the body size to "reasonable" sizes. What is considered reasonable depends per application, but lower is generally better.

[MultipartKit 5](https://github.com/vapor/multipart-kit) will support streaming multipart parsing, in addition to [IkigaJSON](https://github.com/orlandos-nl/ikigajson) for streaming JSON parsing.

You can handle the request/response bodies as an `AsyncSequence`, so you can iterate over the body. This will provide backpressure to the source if any part of the system cannot keep up.

```swift
router.get { req, context in
    for try await chunk in req.body {
        // Do something with the chunk, like writing to the filesystem
    }
    
    return Response(status: .ok)
}
```

In the above example, if the disk cannot keep up, the client's upload speed will be throttled to match the disk's speed. This prevents excessive memory build up in the server.

### Persistence

Leverage [swift-jobs](https://github.com/hummingbird-project/swift-jobs) or other job queue implementations to offload long running tasks, or tasks that can be parallelized to a background job. This will enable you to scale your application horizontally by adding more instances of your Hummingbird app.

Avoid local database systems such as [SQLite](https://sqlite.org), including wrappers like [GRDB](https://github.com/groue/GRDB.swift), as these only reside on the local machine.

Database such as [Postgres](https://www.postgresql.org) or [Valkey](https://valkey.io/)/[Redis](https://redis.io) are highly scalable and mature solutions for persistence and/or caching. These databases have mature libraries for Swift, and are well supported by the community.