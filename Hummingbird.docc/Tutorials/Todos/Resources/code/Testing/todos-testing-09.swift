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

    struct CreateRequest: Encodable {
        let title: String
        let order: Int?
    }
    func create(title: String, order: Int? = nil, client: some TestClientProtocol) async throws -> Todo {
        let request = CreateRequest(title: title, order: order)
        let buffer = try JSONEncoder().encodeAsByteBuffer(request, allocator: ByteBufferAllocator())
        return try await client.execute(uri: "/todos", method: .post, body: buffer) { response in
            XCTAssertEqual(response.status, .created)
            return try JSONDecoder().decode(Todo.self, from: response.body)
        }
    }

    // MARK: Tests
    
    func testCreate() async throws {
        let app = try await buildApplication(TestArguments())
        try await app.test(.router) { client in
            let todo = try await self.create(title: "My first todo", client: client)
            XCTAssertEqual(todo.title, "My first todo")
        }
    }
}