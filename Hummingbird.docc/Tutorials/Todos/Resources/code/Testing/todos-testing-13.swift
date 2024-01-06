@testable import HummingbirdTodos
import Foundation
import Hummingbird
import HummingbirdXCT
import XCTest

extension HummingbirdTodosTests {
    func testDeletingTodoTwiceReturnsBadRequest() async throws {}
    func testGettingTodoWithInvalidUUIDReturnsBadRequest() async throws {}
    func test30ConcurrentlyCreatedTodosAreAllCreated() async throws {}
    func testUpdatingNonExistentTodoReturnsBadRequest() async throws {}
}