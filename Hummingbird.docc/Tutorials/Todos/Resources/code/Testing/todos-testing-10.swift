@testable import Todos
import Foundation
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

    func get(id: UUID, client: some TestClientProtocol) async throws -> Todo? {
        try await client.execute(uri: "/todos/\(id)", method: .get) { response in
            // either the get request returned an 200 status or it didn't return a Todo
            XCTAssert(response.status == .ok || response.body.readableBytes == 0)
            if response.body.readableBytes > 0 {
                return try JSONDecoder().decode(Todo.self, from: response.body)
            } else {
                return nil
            }
        }
    }

    func list(client: some TestClientProtocol) async throws -> [Todo] {
        try await client.execute(uri: "/todos", method: .get) { response in
            XCTAssertEqual(response.status, .ok)
            return try JSONDecoder().decode([Todo].self, from: response.body)
        }
    }

    struct UpdateRequest: Encodable {
        let title: String?
        let order: Int?
        let completed: Bool?
    }
    func patch(id: UUID, title: String? = nil, order: Int? = nil, completed: Bool? = nil, client: some TestClientProtocol) async throws -> Todo? {
        let request = UpdateRequest(title: title, order: order, completed: completed)
        let buffer = try JSONEncoder().encodeAsByteBuffer(request, allocator: ByteBufferAllocator())
        return try await client.execute(uri: "/todos/\(id)", method: .patch, body: buffer) { response in
            XCTAssertEqual(response.status, .ok)
            if response.body.readableBytes > 0 {
                return try JSONDecoder().decode(Todo.self, from: response.body)
            } else {
                return nil
            }
        }
    }

    func delete(id: UUID, client: some TestClientProtocol) async throws -> HTTPResponse.Status {
        try await client.execute(uri: "/todos/\(id)", method: .delete) { response in
            response.status
        }
    }

    func deleteAll(client: some TestClientProtocol) async throws -> Void {
        try await client.execute(uri: "/todos", method: .delete) { _ in }
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