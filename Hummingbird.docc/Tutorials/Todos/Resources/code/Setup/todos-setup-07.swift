import ArgumentParser
import Hummingbird

@main
struct Todos: AsyncParsableCommand {
    func run() async throws {
        var logger = Logger(label: "Todos")
        logger.logLevel = .debug
        // create router
        let router = HBRouter()
        // add hello route
        router.get("/") { request, context in
            "Hello\n"
        }
        // create application
        let app = HBApplication(router: router, logger: logger)
        // run application
        try await app.runService()
    }
}