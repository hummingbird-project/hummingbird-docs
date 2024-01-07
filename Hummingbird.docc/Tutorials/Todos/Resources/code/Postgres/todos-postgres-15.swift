import Foundation
@_spi(ConnectionPool) import PostgresNIO

struct TodoPostgresRepository: TodoRepository {
    let client: PostgresClient

    /// Create Todos table
    func createTable() async throws {
        _ = try await client.withConnection { connection in
            connection.query("""
                CREATE TABLE IF NOT EXISTS todos (
                    "id" uuid PRIMARY KEY,
                    "title" text NOT NULL,
                    "order" integer,
                    "completed" boolean,
                    "url" text
                )
                """,
                logger: logger
            )
        }
    }

    /// Create todo.
    func create(title: String, order: Int?, urlPrefix: String) async throws -> Todo {
        let id = UUID()
        let url = urlPrefix + id.uuidString
        _ = try await self.client.withConnection{ connection in 
            try await connection.query(
                "INSERT INTO todos (id, title, url, \"order\") VALUES (\(id), \(title), \(url), \(order));", 
                logger: logger
            )
        }
        return Todo(id: id, title: title, order: order, url: url, completed: nil)
    }
    /// Get todo.
    func get(id: UUID) async throws -> Todo? { nil }
    /// List all todos
    func list() async throws -> [Todo] { [] }
    /// Update todo. Returns updated todo if successful
    func update(id: UUID, title: String?, order: Int?, completed: Bool?) async throws -> Todo? { nil }
    /// Delete todo. Returns true if successful
    func delete(id: UUID) async throws -> Bool { false }
    /// Delete all todos
    func deleteAll() async throws {}
}
