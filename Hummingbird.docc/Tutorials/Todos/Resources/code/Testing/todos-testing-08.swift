import Foundation
import Hummingbird
import HummingbirdTesting
import Logging
import XCTest

@testable import App

final class AppTests: XCTestCase {
    struct TestArguments: AppArguments {
        let hostname = "127.0.0.1"
        let port = 0
        let logLevel: Logger.Level? = .trace
    }

    func testCreate() async throws {
        let app = try await buildApplication(TestArguments())
        try await app.test(.router) { client in
            try await client.execute(uri: "/todos", method: .post, body: ByteBuffer(string: #"{"title":"My first todo"}"#)) { response in
                XCTAssertEqual(response.status, .created)
                let todo = try JSONDecoder().decode(Todo.self, from: response.body)
                XCTAssertEqual(todo.title, "My first todo")
            }
        }
    }
}