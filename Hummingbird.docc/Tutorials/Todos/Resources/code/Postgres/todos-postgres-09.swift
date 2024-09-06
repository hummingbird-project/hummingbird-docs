///  Build application
/// - Parameter arguments: application arguments
public func buildApplication(_ arguments: some AppArguments) async throws -> some ApplicationProtocol {
    let environment = Environment()
    let logger = {
        var logger = Logger(label: "todos-postgres-tutorial")
        logger.logLevel =
            arguments.logLevel ??
            environment.get("LOG_LEVEL").map { Logger.Level(rawValue: $0) ?? .info } ??
            .info
        return logger
    }()
    if !arguments.inMemoryTesting {
        let client = PostgresClient(
            configuration: .init(host: "localhost", username: "todos", password: "todos", database: "hummingbird", tls: .disable),
            backgroundLogger: logger
        )
    }
    let router = buildRouter()
    var app = Application(
        router: router,
        configuration: .init(
            address: .hostname(arguments.hostname, port: arguments.port),
            serverName: "todos-postgres-tutorial"
        ),
        logger: logger
    )
    return app
}

