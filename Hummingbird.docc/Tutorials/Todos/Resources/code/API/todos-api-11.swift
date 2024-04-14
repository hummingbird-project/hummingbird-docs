import Foundation
import Hummingbird

struct TodoController<Repository: TodoRepository> {
    // Todo repository
    let repository: Repository

    // add Todos API to router group
    func addRoutes(to group: RouterGroup<some RequestContext>) {
        group
            .get(":id", use: get)
            .post(use: create)
    }

    /// Get todo entrypoint
    @Sendable func get(request: Request, context: some RequestContext) async throws -> Todo? {
        let id = try context.parameters.require("id", as: UUID.self)
        return try await self.repository.get(id: id)
    }

    struct CreateRequest: Decodable {
        let title: String
        let order: Int?
    }
    /// Create todo entrypoint
    @Sendable func create(request: Request, context: some RequestContext) async throws -> EditedResponse<Todo> {
        let request = try await request.decode(as: CreateRequest.self, context: context)
        let todo = try await self.repository.create(title: request.title, order: request.order, urlPrefix: "http://localhost:8080/todos/")
        return EditedResponse(status: .created, response: todo)
    }
}
