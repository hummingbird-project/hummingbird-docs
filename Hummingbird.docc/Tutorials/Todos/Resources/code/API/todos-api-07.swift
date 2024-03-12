import Hummingbird

struct TodoController<Context: RequestContext, Repository: TodoRepository> {
    // Todo repository
    let repository: Repository

    // add Todos API to router group
    func addRoutes(to group: RouterGroup<Context>) {
    }
}