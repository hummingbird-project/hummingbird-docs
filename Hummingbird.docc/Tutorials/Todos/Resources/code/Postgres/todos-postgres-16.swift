import Foundation
import PostgresNIO

extension TodoPostgresRepository {
    /// Get todo.
    func get(id: UUID) async throws -> Todo? { 
        try await self.client.query("""
            SELECT "id", "title", "order", "url", "completed" FROM todos WHERE "id" = \(id)
            """, logger: logger
        )
        for try await (id, title, order, url, completed) in stream.decode((UUID, String, Int?, String, Bool?).self, context: .default) {
            return Todo(id: id, title: title, order: order, url: url, completed: completed)
        }
        return nil
    }
}
