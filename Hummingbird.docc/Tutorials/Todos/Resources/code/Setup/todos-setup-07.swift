import ArgumentParser
import Hummingbird

@main
struct Todos: AsyncParsableCommand {
    func run() async throws {
        // create router
        let router = Router()
        // add hello route
        router.get("/") { request, context in
            "Hello\n"
        }
        // create application
        let app = Application(router: router)
        // run application
        try await app.runService()
    }
}