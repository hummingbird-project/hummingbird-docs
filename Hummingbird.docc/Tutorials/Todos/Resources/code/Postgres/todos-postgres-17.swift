import Foundation
@_spi(ConnectionPool) import PostgresNIO

extension TodoPostgresRepository {
    /// List all todos
    func list() async throws -> [Todo] { 
        try await self.client.withConnection { connection in
            let stream = try await connection.query("""
                SELECT "id", "title", "order", "url", "completed" FROM todos
                """, logger: logger
            )
            var todos: [Todo] = []
            for try await (id, title, order, url, completed) in stream.decode((UUID, String, Int?, String, Bool?).self, context: .default) {
                let todo = Todo(id: id, title: title, order: order, url: url, completed: completed)
                todos.append(todo)
            }
            return todos
        }
    }
}
