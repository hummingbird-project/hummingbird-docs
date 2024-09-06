import Hummingbird

struct TodoController {
    // return todo endpoints
    var endpoints: RouteCollection<AppRequestContext> {
        return RouteCollection(context: AppRequestContext.self)
    }
}