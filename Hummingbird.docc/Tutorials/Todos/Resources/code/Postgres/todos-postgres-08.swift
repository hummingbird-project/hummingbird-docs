import ArgumentParser
import Hummingbird
@_spi(ConnectionPool) import PostgresNIO

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
    var postgresClient: PostgresClient?
    if !args.inMemoryTesting {
        let client = PostgresClient(
            configuration: .init(host: "localhost", username: "todos", password: "todos", database: "hummingbird", tls: .disable),
            backgroundLogger: logger
        )
        postgresClient = client
    }
    // add Todos API
    TodoController(repository: TodoMemoryRespository()).addRoutes(to: router.group("todos"))
    // create application
    var app = HBApplication(
        router: router,
        configuration: .init(address: .hostname(args.hostname, port: args.port)),
        logger: logger
    )
    if let postgresClient {
        app.addServices(postgresClient) // COMPILE ERROR
    }
    return app
}
