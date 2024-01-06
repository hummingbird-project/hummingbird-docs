import ArgumentParser

@main
struct HummingbirdTodos: AsyncParsableCommand {
    func run() async throws {
        print("Hello, world!")
    }
}