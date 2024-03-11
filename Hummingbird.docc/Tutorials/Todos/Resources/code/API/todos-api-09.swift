import Foundation
import Hummingbird

struct TodoController<Context: RequestContext, Repository: TodoRepository> {
    // Todo repository
    let repository: Repository

    // add Todos API to router group
    func addRoutes(to group: RouterGroup<Context>) {
        group
            .get(":id", use: get)
    }

    /// Get todo entrypoint
    @Sendable func get(request: Request, context: Context) async throws -> Todo? {
        let id = try context.parameters.require("id", as: UUID.self)
        return try await self.repository.get(id: id)
    }
}
