import Configuration
import Foundation
import Hummingbird
import HummingbirdTesting
import Logging
import Testing

@testable import App

private let reader = ConfigReader(providers: [
    InMemoryProvider(values: [
        "host": "127.0.0.1",
        "port": "0",
        "log.level": "trace"
    ])
])
