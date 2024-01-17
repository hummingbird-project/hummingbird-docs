import Foundation
@_spi(ConnectionPool) import PostgresNIO

extension TodoPostgresRepository {
    /// Update todo. Returns updated todo if successful
    func update(id: UUID, title: String?, order: Int?, completed: Bool?) async throws -> Todo? {
        return try await self.client.withConnection{ connection in 
            let query: PostgresQuery
            // UPDATE query. Work out query based on whick values are not nil
            // The string interpolations are building a PostgresQuery with bindings and is safe from sql injection
            if let title {
                if let order {
                    if let completed {
                        query = "UPDATE todos SET title = \(title), order = \(order), completed = \(completed) WHERE id = \(id)"
                    } else {
                        query = "UPDATE todos SET title = \(title), order = \(order) WHERE id = \(id)"
                    }
                } else {
                    if let completed {
                        query = "UPDATE todos SET title = \(title), completed = \(completed) WHERE id = \(id)"
                    } else {
                        query = "UPDATE todos SET title = \(title) WHERE id = \(id)"
                    }
                }
            } else {
                if let order {
                    if let completed {
                        query = "UPDATE todos SET order = \(order), completed = \(completed) WHERE id = \(id)"
                    } else {
                        query = "UPDATE todos SET order = \(order) WHERE id = \(id)"
                    }
                } else {
                    if let completed {
                        query = "UPDATE todos SET completed = \(completed) WHERE id = \(id)"
                    } else {
                        return nil
                    }
                }
            }
            _ = try await connection.query(query, logger: self.logger)

            // SELECT so I can get the full details of the TODO back
            // The string interpolation is building a PostgresQuery with bindings and is safe from sql injection
            let stream = try await connection.query(
                """
                SELECT "id", "title", "order", "url", "completed" FROM todos WHERE "id" = \(id)
                """,
                logger: self.logger
            )
            for try await(id, title, order, url, completed) in stream.decode((UUID, String, Int?, String, Bool?).self, context: .default) {
                return Todo(id: id, title: title, order: order, url: url, completed: completed)
            }
            return nil
        }
    }
}
