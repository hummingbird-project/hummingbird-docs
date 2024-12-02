import Hummingbird
import Logging
import MongoKitten

/// Application arguments protocol. We use a protocol so we can call
/// `buildApplication` inside Tests as well as in the App executable.
/// Any variables added here also have to be added to `App` in App.swift and
/// `TestArguments` in AppTest.swift
public protocol AppArguments {
    var connectionString: String { get }
    var hostname: String { get }
    var port: Int { get }
    var logLevel: Logger.Level? { get }
}

// Request context used by application
typealias AppRequestContext = BasicRequestContext

///  Build application
/// - Parameter arguments: application arguments
public func buildApplication(_ arguments: some AppArguments) async throws -> some ApplicationProtocol {
    let environment = Environment()
    let logger = {
        var logger = Logger(label: "MeowSocial")
        logger.logLevel =
        arguments.logLevel ??
        environment.get("LOG_LEVEL").flatMap { Logger.Level(rawValue: $0) } ??
            .info
        return logger
    }()

    let mongo = try await MongoDatabase.connect(to: arguments.connectionString)

    let router = buildRouter(db: mongo)
    let app = Application(
        router: router,
        configuration: .init(
            address: .hostname(arguments.hostname, port: arguments.port),
            serverName: "MeowSocial"
        ),
        logger: logger
    )
    return app
}

/// Build router
func buildRouter(db: MongoDatabase) -> Router<AppRequestContext> {
    let router = Router(context: AppRequestContext.self)
    // Add middleware
    router.addMiddleware {
        // logging middleware
        LogRequestsMiddleware(.info)
    }
    // Add default endpoint
    router.get("/") { _,_ in
        return "Hello!"
    }
    // List all kittens
    router.get("/kittens") { _, _ in
        return try await db[Kitten.collection].find().decode(Kitten.self).drain()
    }
    router.put("/kittens") { request, context -> Kitten in
        let body = try await request.decode(as: CreateKittenRequest.self, context: context)
        let kitten = Kitten(
            _id: ObjectId(),
            name: body.name
        )
        try await db[Kitten.collection].insertEncoded(kitten)
        return kitten
    }
    return router
}

struct CreateKittenRequest: Codable {
    let name: String
}
