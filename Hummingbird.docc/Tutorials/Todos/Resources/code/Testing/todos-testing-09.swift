@Suite
struct AppTests {
    struct CreateRequest: Encodable {
        let title: String
        let order: Int?
    }

    func create(title: String, order: Int? = nil, client: some TestClientProtocol) async throws -> Todo {
        let request = CreateRequest(title: title, order: order)
        let buffer = try JSONEncoder().encodeAsByteBuffer(request, allocator: ByteBufferAllocator())
        return try await client.execute(uri: "/todos", method: .post, body: buffer) { response in
            #expect(response.status == .created)
            return try JSONDecoder().decode(Todo.self, from: response.body)
        }
    }

    @Test func testCreate() async throws {
        let app = try await buildApplication(reader: reader)
        try await app.test(.router) { client in
            let todo = try await Self.create(title: "My first todo", client: client)
            #expect(todo.title == "My first todo")
        }
    }
}