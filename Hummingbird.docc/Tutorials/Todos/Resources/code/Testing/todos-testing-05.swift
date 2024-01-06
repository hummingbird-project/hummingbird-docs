import ArgumentParser
import Hummingbird

@main
struct HummingbirdTodos: AsyncParsableCommand {
    @Option(name: .shortAndLong)
    var hostname: String = "127.0.0.1"

    @Option(name: .shortAndLong)
    var port: Int = 8080

    func run() async throws {
        // create application
        let app = try await buildApplication(self)
        // run application
        try await app.runService()
    }
}

/// Build a HBApplication
func buildApplication(_ args: HummingbirdTodos) async throws -> some HBApplicationProtocol {
    // create router
    let router = HBRouter(context: TodoRequestContext.self)
    // add logging middleware
    router.middlewares.add(HBLogRequestsMiddleware(.info))
    // add hello route
    router.get("/") { request, context in
        "Hello\n"
    }
    // add Todos API
    TodoController(repository: TodoMemoryRespository()).addRoutes(to: router.group("todos"))
    // create application
    let app = HBApplication(
        router: router,
        configuration: .init(address: .hostname(args.hostname, port: args.port))
    )
    return app
}

