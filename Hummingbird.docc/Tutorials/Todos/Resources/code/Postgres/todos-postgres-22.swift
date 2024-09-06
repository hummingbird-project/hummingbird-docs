import Hummingbird
import HummingbirdTesting
import Logging
import XCTest

@testable import App

final class AppTests: XCTestCase {
    struct TestArguments: AppArguments {
        let hostname = "127.0.0.1"
        let port = 8080
        let logLevel: Logger.Level? = nil
        let inMemoryTesting = false
    }

