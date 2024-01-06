@testable import HummingbirdTodos
import Foundation
import Hummingbird
import HummingbirdXCT
import XCTest

final class HummingbirdTodosTests: XCTestCase {
    ...
    func testAPI() async throws {
        let app = try await buildApplication(TestArguments())
        try await app.test(.router) { client in
            // create two todos
            let todo1 = try await self.create(title: "Wash my hair", client: client)
            let todo2 = try await self.create(title: "Brush my teeth", client: client)
            // get first todo
            let getTodo = try await self.get(id: todo1.id, client: client)
            XCTAssertEqual(getTodo, todo1)
            // patch second todo
            let optionalPatchedTodo = try await self.patch(id: todo2.id, completed: true, client: client)
            let patchedTodo = try XCTUnwrap(optionalPatchedTodo)
            XCTAssertEqual(patchedTodo.completed, true)
            XCTAssertEqual(patchedTodo.title, todo2.title)
            // get all todos and check first todo and patched second todo are in the list
            let todos = try await self.list(client: client)
            XCTAssertNotNil(todos.firstIndex(of: todo1))
            XCTAssertNotNil(todos.firstIndex(of: patchedTodo))
            // delete a todo and verify it has been deleted
            let status = try await self.delete(id: todo1.id, client: client)
            XCTAssertEqual(status, .ok)
            let deletedTodo = try await self.get(id: todo1.id, client: client)
            XCTAssertNil(deletedTodo)
            // delete all todos and verify there are none left
            try await self.deleteAll(client: client)
            let todos2 = try await self.list(client: client)
            XCTAssertEqual(todos2.count, 0)
        }
    }
}