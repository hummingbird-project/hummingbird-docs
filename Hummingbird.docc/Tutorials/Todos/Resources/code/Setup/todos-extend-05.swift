import ArgumentParser
import Hummingbird

@main
struct HummingbirdTodos: AsyncParsableCommand {
    @Option(name: .shortAndLong)
    var hostname: String = "127.0.0.1"

    @Option(name: .shortAndLong)
    var port: Int = 8080

    func run() async throws {
        // create router
        let router = HBRouter(context: TodoRequestContext.self)
        // add logging middleware
        router.middlewares.add(HBLogRequestsMiddleware(.info))
        // add hello route
        router.get("/") { request, context in
            "Hello\n"
        }
        // create application
        let app = HBApplication(router: router)
        // run application
        try await app.runService()
    }
}