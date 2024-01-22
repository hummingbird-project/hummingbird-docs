import ArgumentParser
import Hummingbird
@_spi(ConnectionPool) import PostgresNIO
import ServiceLifecycle

/// Build a HBApplication
func buildApplication(_ args: some AppArguments) async throws -> some HBApplicationProtocol {
    var logger = Logger(label: "Todos")
    logger.logLevel = .debug
    // create router
    let router = HBRouter()
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
    // create application
    var app = HBApplication(
        router: router,
        configuration: .init(address: .hostname(args.hostname, port: args.port)),
        logger: logger
    )
    // if we setup a postgres service then add as a service and run createTable before
    // server starts
    if let postgresRepository {
        app.addServices(PostgresClientService(client: postgresRepository.client))
        app.runBeforeServerStart {
            try await postgresRepository.createTable()
        }
    }
    return app
}
