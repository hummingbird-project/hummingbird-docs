import Foundation
import Hummingbird
import HummingbirdTesting
import Logging
import XCTest

@testable import App

extension AppTests {
    func testDeletingTodoTwiceReturnsBadRequest() async throws {}
    func testGettingTodoWithInvalidUUIDReturnsBadRequest() async throws {}
    func test30ConcurrentlyCreatedTodosAreAllCreated() async throws {}
    func testUpdatingNonExistentTodoReturnsBadRequest() async throws {}
}