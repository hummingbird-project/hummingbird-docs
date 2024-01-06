@testable import HummingbirdTodos
import Foundation
import Hummingbird
import HummingbirdXCT
import XCTest

final class HummingbirdTodosTests: XCTestCase {
    ...

    func testDeletingTodoTwiceReturnsBadRequest() async throws {}
    func testGettingTodoWithInvalidUUIDReturnsBadRequest() async throws {}
    func test30ConcurrentlyCreatedTodosAreAllCreated() async throws {}
    func testUpdatingNonExistentTodoReturnsBadRequest() async throws {}
}