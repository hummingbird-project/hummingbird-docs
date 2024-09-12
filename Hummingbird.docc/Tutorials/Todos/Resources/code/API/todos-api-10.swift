import Foundation
import Hummingbird

struct TodoController<Repository: TodoRepository> {
    // Todo repository
    let repository: Repository

    // return todo endpoints
    var endpoints: RouteCollection<AppRequestContext> {
        return RouteCollection(context: AppRequestContext.self)
            .get(":id", use: get)
            .post(use: create)
    }

    /// Get todo endpoint
    @Sendable func get(request: Request, context: some RequestContext) async throws -> Todo? {
        let id = try context.parameters.require("id", as: UUID.self)
        return try await self.repository.get(id: id)
    }

    struct CreateRequest: Decodable {
        let title: String
        let order: Int?
    }
    /// Create todo endpoint
    @Sendable func create(request: Request, context: some RequestContext) async throws -> Todo {
        let request = try await request.decode(as: CreateRequest.self, context: context)
        return try await self.repository.create(title: request.title, order: request.order, urlPrefix: "http://localhost:8080/todos/")
    }
}
