@testable import HummingbirdTodos
import Hummingbird
import HummingbirdXCT
import XCTest

final class HummingbirdTodosTests: XCTestCase {
    struct TestArguments: AppArguments {
        let hostname = "127.0.0.1"
        let port = 8080
        let testing = true
    }

    func testCreate() async throws {
        let app = try await buildApplication(TestArguments())
    }
}