import Foundation
import Hummingbird

struct TodoController<Repository: TodoRepository> {
    // Todo repository
    let repository: Repository

    // add Todos API to router group
    func addRoutes(to group: RouterGroup<some RequestContext>) {
        group
            .get(":id", use: get)
    }

    /// Get todo endpoint
    @Sendable func get(request: Request, context: some RequestContext) async throws -> Todo? {
        let id = try context.parameters.require("id", as: UUID.self)
        return try await self.repository.get(id: id)
    }
}
