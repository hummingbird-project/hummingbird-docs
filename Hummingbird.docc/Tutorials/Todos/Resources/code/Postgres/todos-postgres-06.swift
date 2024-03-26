import ArgumentParser
import Hummingbird
import Logging

/// Build a Application
func buildApplication(_ args: some AppArguments) async throws -> some ApplicationProtocol {
    var logger = Logger(label: "Todos")
    logger.logLevel = .debug
    // create router
    let router = Router()
    // add logging middleware
    router.middlewares.add(LogRequestsMiddleware(.info))
    // add hello route
    router.get("/") { request, context in
        "Hello\n"
    }
    // add Todos API
    TodoController(repository: TodoMemoryRepository()).addRoutes(to: router.group("todos"))
    // create application
    let app = Application(
        router: router,
        configuration: .init(address: .hostname(args.hostname, port: args.port)),
        logger: logger
    )
    return app
}
