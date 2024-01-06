@testable import HummingbirdTodos
import Foundation
import Hummingbird
import HummingbirdXCT
import XCTest

final class HummingbirdTodosTests: XCTestCase {
    ...
    func testPatch() async throws {
        let app = try await buildApplication(TestArguments())
        try await app.test(.router) { client in
            // create todo
            let todo = try await self.create(title: "Deliver parcels to James", client: client)
            _ = try await self.patch(id: todo.id, title: "Deliver parcels to Claire", client: client)
            let editedTodo = try await self.get(id: todo.id, client: client)
            XCTAssertEqual(editedTodo?.title, "Deliver parcels to Claire")
            _ = try await self.patch(id: todo.id, completed: true, client: client)
            let editedTodo2 = try await self.get(id: todo.id, client: client)
            XCTAssertEqual(editedTodo2?.completed, true)
        }
    }
}