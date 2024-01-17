import Foundation
import Hummingbird

struct TodoController<Context: HBRequestContext, Repository: TodoRepository> {
    // Todo repository
    let repository: Repository

    // add Todos API to router group
    func addRoutes(to group: HBRouterGroup<Context>) {
        group
            .get(":id", use: get)
            .get(use: list)
            .post(use: create)
    }

    /// Get todo entrypoint
    @Sendable func get(request: HBRequest, context: Context) async throws -> Todo? {
        let id = try context.parameters.require("id")
        guard let uuid = UUID(uuidString: id) else { throw HBHTTPError(.badRequest) }
        return try await self.repository.get(id: uuid)
    }

    /// Get list of todos entrypoint
    @Sendable func list(request: HBRequest, context: Context) async throws -> [Todo] {
        return try await self.repository.list()
    }

    struct CreateRequest: Decodable {
        let title: String
        let order: Int?
    }
    /// Create todo entrypoint
    @Sendable func create(request: HBRequest, context: Context) async throws -> HBEditedResponse<Todo> {
        let request = try await request.decode(as: CreateRequest.self, context: context)
        let todo = try await self.repository.create(title: request.title, order: request.order, urlPrefix: "http://localhost:8080/todos/")
        return HBEditedResponse(status: .created, response: todo)
    }
}