import ArgumentParser
import Hummingbird

@main
struct Todos: AsyncParsableCommand, AppArguments {
    @Option(name: .shortAndLong)
    var hostname: String = "127.0.0.1"

    @Option(name: .shortAndLong)
    var port: Int = 8080

    @Flag
    var inMemoryTesting: Bool = false

    func run() async throws {
        // create application
        let app = try await buildApplication(self)
        // run application
        try await app.runService()
    }
}

/// Arguments extracted from commandline
protocol AppArguments {
    var hostname: String { get}
    var port: Int { get }
    var inMemoryTesting: Bool { get }
}

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
    TodoController(repository: TodoMemoryRepository()).addRoutes(to: router.group("todos"))
    // create application
    let app = HBApplication(
        router: router,
        configuration: .init(address: .hostname(args.hostname, port: args.port)),
        logger: logger
    )
    return app
}
