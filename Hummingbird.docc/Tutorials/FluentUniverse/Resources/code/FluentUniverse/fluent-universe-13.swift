import FluentKit
import Foundation
import Hummingbird

final class Galaxy: Model, @unchecked Sendable, ResponseCodable {
    // Name of the table or collection.
    static let schema = "galaxies"

    // Unique identifier for this Galaxy.
    @ID(key: .id)
    var id: UUID?

    // The Galaxy's name.
    @Field(key: "name")
    var name: String

    // Creates a new, empty Galaxy.
    init() { }

    // Creates a new Galaxy with all properties set.
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

struct CreateGalaxy: AsyncMigration {
    func prepare(on database: Database) async throws {
        return try await database.schema(Galaxy.schema)
            .id()
            .field("name", .string, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        return try await database.schema(Galaxy.schema).delete()
    }
}
