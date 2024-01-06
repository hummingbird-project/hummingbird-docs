@testable import HummingbirdTodos
import Hummingbird
import HummingbirdXCT
import XCTest

final class HummingbirdTodosTests: XCTestCase {
    struct TestArguments: AppArguments {
        let hostname = "127.0.0.1"
        let port = 8080
        let testing = true
    }

    func testCreate() async throws {
        let app = try await buildApplication(TestArguments())
        try await app.test(.router) { client in
            try await client.XCTExecute(uri: "/todos", method: .post, body: ByteBuffer(string: #"{"title":"My first todo"}"#)) { response in
                XCTAssertEqual(response.status, .created)
                let body = try XCTUnwrap(response.body)
                let todo = try JSONDecoder().decode(Todo.self, from: body)
                XCTAssertEqual(todo.title, "My first todo")
            }
        }
    }
}