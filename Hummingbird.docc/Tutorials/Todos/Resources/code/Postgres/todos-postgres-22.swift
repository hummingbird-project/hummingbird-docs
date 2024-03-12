@testable import Todos
import Foundation
import Hummingbird
import HummingbirdTesting
import XCTest


final class TodosTests: XCTestCase {
    struct TestArguments: AppArguments {
        let hostname = "127.0.0.1"
        let port = 8080
        let inMemoryTesting = false
    }

