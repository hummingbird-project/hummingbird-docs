@testable import Todos
import Foundation
import Hummingbird
import HummingbirdXCT
import XCTest

extension TodosTests {
    func testPatch() async throws {
        let app = try await buildApplication(TestArguments())
        try await app.test(.router) { client in
            // create todo
            let todo = try await self.create(title: "Deliver parcels to James", client: client)
            // rename it
            _ = try await self.patch(id: todo.id, title: "Deliver parcels to Claire", client: client)
            let editedTodo = try await self.get(id: todo.id, client: client)
            XCTAssertEqual(editedTodo?.title, "Deliver parcels to Claire")
            // set it to completed
            _ = try await self.patch(id: todo.id, completed: true, client: client)
            let editedTodo2 = try await self.get(id: todo.id, client: client)
            XCTAssertEqual(editedTodo2?.completed, true)
            // revert it
            _ = try await self.patch(id: todo.id, title: "Deliver parcels to James", completed: false, client: client)
            let editedTodo3 = try await self.get(id: todo.id, client: client)
            XCTAssertEqual(editedTodo3?.title, "Deliver parcels to James")
            XCTAssertEqual(editedTodo3?.completed, false)
        }
    }
}