import Foundation
@_spi(ConnectionPool) import PostgresNIO

extension TodoPostgresRepository {
    /// Update todo. Returns updated todo if successful
    func update(id: UUID, title: String?, order: Int?, completed: Bool?) async throws -> Todo? {
        return try await self.client.withConnection{ connection in 
            /// if value is non-optional then add SET entry
            func appendColumn<Value: PostgresDynamicTypeEncodable>(comma: String, column: String, value: Value?, to query: inout PostgresQuery.StringInterpolation) -> String {
                if let value {
                    query.appendInterpolation(unescaped: "\(comma) \"\(column)\" = ")
                    query.appendInterpolation(value)
                    return ","
                }
                return comma
            }
            // construct query using the StringInterpolation
            var query = PostgresQuery.StringInterpolation(literalCapacity: 3, interpolationCount: 3)
            query.appendInterpolation(unescaped: "UPDATE todos SET")
            var comma = appendColumn(comma: "", column: "title", value: title, to: &query)
            comma = appendColumn(comma: comma, column: "order", value: order, to: &query)
            comma = appendColumn(comma: comma, column: "completed", value: completed, to: &query)
            query.appendInterpolation(unescaped: " WHERE id = ")
            query.appendInterpolation(id)
            if comma != "," {
                throw HBHTTPError(.badRequest)
            }

            // UPDATE query
            _ = try await connection.query(
                PostgresQuery(stringInterpolation: query), 
                logger: logger
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
