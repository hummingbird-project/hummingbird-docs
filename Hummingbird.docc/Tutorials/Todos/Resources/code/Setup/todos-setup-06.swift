import ArgumentParser

@main
struct Todos: AsyncParsableCommand {
    func run() async throws {
        print("Hello, world!")
    }
}