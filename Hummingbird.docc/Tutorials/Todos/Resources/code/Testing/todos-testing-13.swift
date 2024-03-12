@testable import Todos
import Foundation
import Hummingbird
import HummingbirdTesting
import XCTest

extension TodosTests {
    func testDeletingTodoTwiceReturnsBadRequest() async throws {}
    func testGettingTodoWithInvalidUUIDReturnsBadRequest() async throws {}
    func test30ConcurrentlyCreatedTodosAreAllCreated() async throws {}
    func testUpdatingNonExistentTodoReturnsBadRequest() async throws {}
}