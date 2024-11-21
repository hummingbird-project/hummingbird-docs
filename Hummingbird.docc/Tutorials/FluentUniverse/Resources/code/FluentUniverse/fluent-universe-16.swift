import Hummingbird
import Logging
import FluentSQLiteDriver
import Foundation
import HummingbirdFluent

/// Application arguments protocol. We use a protocol so we can call
/// `buildApplication` inside Tests as well as in the App executable.
/// Any variables added here also have to be added to `App` in App.swift and
/// `TestArguments` in AppTest.swift
public protocol AppArguments {
    var inMemoryDatabase: Bool { get }
    var migrate: Bool { get }
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
        var logger = Logger(label: "TodosFluent")
        logger.logLevel =
        arguments.logLevel ??
        environment.get("LOG_LEVEL").flatMap { Logger.Level(rawValue: $0) } ??
            .info
        return logger
    }()

    let fluent = Fluent(logger: logger)
    // add sqlite database
    if arguments.inMemoryDatabase {
        fluent.databases.use(.sqlite(.memory), as: .sqlite)
    } else {
        fluent.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
    }
    // add migrations
    await fluent.migrations.add(CreateGalaxy())

    let fluentPersist = await FluentPersistDriver(fluent: fluent)

    // migrate
    if arguments.migrate || arguments.inMemoryDatabase {
        try await fluent.migrate()
    }

    let router = buildRouter(fluent: fluent)
    var app = Application(
        router: router,
        configuration: .init(
            address: .hostname(arguments.hostname, port: arguments.port),
            serverName: "TodosFluent"
        ),
        logger: logger
    )
    let galaxy = Galaxy(name: "Andromeda")
    try await galaxy.create(on: fluent.db())

    app.addServices(fluent, fluentPersist)
    return app
}

/// Build router
func buildRouter(fluent: Fluent) -> Router<AppRequestContext> {
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
    // List all galaxies
    router.get("/galaxies") { _,_ -> [Galaxy] in
        try await Galaxy.query(on: self.fluent.db()).all()
    }
    router.put("/galaxies") { req, content -> HTTPResponseStatus in
        let galaxy = try await req.decode(as: Galaxy.self, context: context)
        try await galaxy.save(on: fluent.db())
        return .created
    }
    return router
}
