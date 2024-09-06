import Hummingbird

struct TodoController<Repository: TodoRepository> {
    // Todo repository
    let repository: Repository

    // return todo endpoints
    var endpoints: RouteCollection<AppRequestContext> {
        return RouteCollection(context: AppRequestContext.self)
    }
}