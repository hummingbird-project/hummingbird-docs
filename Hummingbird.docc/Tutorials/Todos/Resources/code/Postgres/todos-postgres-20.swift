import Foundation
import PostgresNIO

extension TodoPostgresRepository {
    /// Delete todo. Returns true if successful
    func delete(id: UUID) async throws -> Bool {
        let selectStream = try await self.client.query("""
            SELECT "id" FROM todos WHERE "id" = \(id)
            """, logger: logger
        )
        // if we didn't find the item with this id then return false
        if try await selectStream.decode((UUID).self, context: .default).first(where: { _ in true} ) == nil {
            return false
        }
        try await client.query("DELETE FROM todos WHERE id = \(id);", logger: logger)
        return true
    }
    /// Delete all todos
    func deleteAll() async throws {
        try await self.client.query("DELETE FROM todos;", logger: logger)
    }
}
