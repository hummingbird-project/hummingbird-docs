import Foundation
@_spi(ConnectionPool) import PostgresNIO

extension TodoPostgresRepository {
    /// Delete todo. Returns true if successful
    func delete(id: UUID) async throws -> Bool {
        return try await self.client.withConnection{ connection in
            let selectStream = try await connection.query("""
                SELECT "id" FROM todos WHERE "id" = \(id)
                """, logger: logger
            )
            // if we didn't find the item with this id then return false
            if try await selectStream.decode((UUID).self, context: .default).first(where: { _ in true} ) == nil {
                return false
            }
            _ = try await connection.query("DELETE FROM todos WHERE id = \(id);", logger: logger)
            return true
        }
    }
    /// Delete all todos
    func deleteAll() async throws {
        return try await self.client.withConnection{ connection in
            try await connection.query("DELETE FROM todos;", logger: logger)
        }
    }
}
