///  Build application
/// - Parameter reader: configuration reader
func buildApplication(reader: ConfigReader) async throws -> some ApplicationProtocol {
    let logger = {
        var logger = Logger(label: "Todos")
        logger.logLevel = reader.string(forKey: "log.level", as: Logger.Level.self, default: .info)
        return logger
    }()
    let inMemoryTesting = reader.bool(forKey: "db.inMemoryTesting", default: false)
    var postgresClient: PostgresClient?
    if !inMemoryTesting {
        let client = PostgresClient(
            configuration: .init(host: "localhost", username: "todos", password: "todos", database: "hummingbird", tls: .disable),
            backgroundLogger: logger
        )
        postgresClient = client
    }
    let router = buildRouter()
    var app = Application(
        router: router,
        configuration: ApplicationConfiguration(reader: reader.scoped(to: "http")),
        logger: logger
    )
    if let postgresClient {
        app.addServices(postgresClient)
    }
    return app
}


