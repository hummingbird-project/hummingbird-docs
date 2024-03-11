@testable import Todos
import Hummingbird
import HummingbirdTesting
import XCTest

final class TodosTests: XCTestCase {
    struct TestArguments: AppArguments {
        let hostname = "127.0.0.1"
        let port = 8080
        let inMemoryTesting = true
    }

    func testCreate() async throws {
        let app = try await buildApplication(TestArguments())
        try await app.test(.router) { client in
            try await client.XCTExecute(uri: "/todos", method: .post, body: ByteBuffer(string: #"{"title":"My first todo"}"#)) { response in
                XCTAssertEqual(response.status, .created)
                let todo = try JSONDecoder().decode(Todo.self, from: response.body)
                XCTAssertEqual(todo.title, "My first todo")
            }
        }
    }
}