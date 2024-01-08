import Foundation
@_spi(ConnectionPool) import PostgresNIO

extension TodoPostgresRepository {
    /// Update todo. Returns updated todo if successful
    func update(id: UUID, title: String?, order: Int?, completed: Bool?) async throws -> Todo? {
        return try await self.client.withConnection{ connection in 
            // UPDATE query
            let query: PostgresQuery = """
                UPDATE todos SET \(optionalUpdateFields: (("title", title), ("order", order), ("completed", completed))) WHERE id = \(id)
                """
            // if bind count is 1 then we aren't updating anything. Return nil
            if query.binds.count == 1 {
                return nil
            }
            _ = try await connection.query(query, logger: logger
            )
            // SELECT so I can get the full details of the TODO back
            let stream = try await connection.query("""
                SELECT "id", "title", "order", "url", "completed" FROM todos WHERE "id" = \(id)
                """, logger: logger
            )
            for try await (id, title, order, url, completed) in stream.decode((UUID, String, Int?, String, Bool?).self, context: .default) {
                return Todo(id: id, title: title, order: order, url: url, completed: completed)
            }
            return nil
        }
    }
}
