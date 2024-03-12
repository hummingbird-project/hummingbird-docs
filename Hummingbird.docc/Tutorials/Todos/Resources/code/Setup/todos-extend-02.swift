import ArgumentParser
import Hummingbird

@main
struct Todos: AsyncParsableCommand {
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
        // create application
        let app = Application(router: router, logger: logger)
        // run application
        try await app.runService()
    }
}