/// Build router
func buildRouter() -> Router<AppRequestContext> {
    let router = Router(context: AppRequestContext.self)
    // Add middleware
    router.add {
        // logging middleware
        LogRequestsMiddleware(.info)
    }
    // Add health endpoint
    router.get("/health") { _, _ -> HTTPResponse.Status in
        return .ok
    }
    return router
}