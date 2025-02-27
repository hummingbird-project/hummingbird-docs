/// Build router
func buildRouter(_ repository: some TodoRepository) -> Router<AppRequestContext> {
    let router = Router(context: AppRequestContext.self)
    // Add middleware
    router.addMiddleware {
        // logging middleware
        LogRequestsMiddleware(.info)
    }
    // Add default endpoint
    router.get("/") { _,_ in
        return "Hello!"
    }
    router.addRoutes(TodoController(repository: repository).endpoints, atPath: "/todos")
    return router
}
