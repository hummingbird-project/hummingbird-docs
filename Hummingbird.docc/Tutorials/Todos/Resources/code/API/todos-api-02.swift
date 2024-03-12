import ArgumentParser
import Hummingbird

@main
struct Todos: AsyncParsableCommand {
    @Option(name: .shortAndLong)
    var hostname: String = "127.0.0.1"

    @Option(name: .shortAndLong)
    var port: Int = 8080

    func run() async throws {
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
        TodoController().addRoutes(to: router.group("todos"))
        // create application
        let app = Application(
            router: router,
            configuration: .init(address: .hostname(self.hostname, port: self.port))
        )
        // run application
        try await app.runService()
    }
}