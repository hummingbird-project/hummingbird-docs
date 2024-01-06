import ArgumentParser
import Hummingbird

@main
struct HummingbirdTodos: AsyncParsableCommand {
    func run() async throws {
        // create router
        let router = HBRouter()
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