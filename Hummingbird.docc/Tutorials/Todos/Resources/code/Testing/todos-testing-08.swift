@Suite
struct AppTests {
    @Test func testCreate() async throws {
        let app = try await buildApplication(reader: reader)
        try await app.test(.router) { client in
            try await client.execute(uri: "/todos", method: .post, body: ByteBuffer(string: #"{"title":"My first todo"}"#)) { response in
                #expect(response.status == .created)
                let todo = try JSONDecoder().decode(Todo.self, from: response.body)
                #expect(todo.title == "My first todo")
            }
        }
    }
}