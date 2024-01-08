import ArgumentParser
import Hummingbird
@_spi(ConnectionPool) import PostgresNIO
import ServiceLifecycle

/// Build a HBApplication
func buildApplication(_ args: some AppArguments) async throws -> some HBApplicationProtocol {
    var logger = Logger(label: "Todos")
    logger.logLevel = .debug
    // create router
    let router = HBRouter(context: TodoRequestContext.self)
    // add logging middleware
    router.middlewares.add(HBLogRequestsMiddleware(.info))
    // add hello route
    router.get("/") { request, context in
        "Hello\n"
    }
    // add Todos API
    var postgresRepository: TodoPostgresRepository?
    if !args.inMemoryTesting {
        let client = PostgresClient(
            configuration: .init(host: "localhost", username: "todos", password: "todos", database: "hummingbird", tls: .disable),
            backgroundLogger: logger
        )
        let repository = TodoPostgresRepository(client: client, logger: logger)
        postgresRepository = repository
        TodoController(repository: repository).addRoutes(to: router.group("todos"))
    } else {
        TodoController(repository: TodoMemoryRepository()).addRoutes(to: router.group("todos"))
    }
    let staticPostgresRepository = postgresRepository
    // create application
    var app = HBApplication(
        router: router,
        configuration: .init(address: .hostname(args.hostname, port: args.port)),
        onServerRunning: { _ in
            try? await staticPostgresRepository?.createTable()
        },
        logger: logger
    )
    if let postgresRepository {
        app.addServices(PostgresClientService(client: postgresRepository.client))
    }
    return app
}
