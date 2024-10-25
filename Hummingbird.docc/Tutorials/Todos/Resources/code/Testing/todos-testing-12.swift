import Foundation
import Hummingbird
import HummingbirdTesting
import Logging
import XCTest

@testable import App

extension AppTests {
    func testAPI() async throws {
        let app = try await buildApplication(TestArguments())
        try await app.test(.router) { client in
            // create two todos
            let todo1 = try await Self.create(title: "Wash my hair", client: client)
            let todo2 = try await Self.create(title: "Brush my teeth", client: client)
            // get first todo
            let getTodo = try await Self.get(id: todo1.id, client: client)
            XCTAssertEqual(getTodo, todo1)
            // patch second todo
            let optionalPatchedTodo = try await Self.patch(id: todo2.id, completed: true, client: client)
            let patchedTodo = try XCTUnwrap(optionalPatchedTodo)
            XCTAssertEqual(patchedTodo.completed, true)
            XCTAssertEqual(patchedTodo.title, todo2.title)
            // get all todos and check first todo and patched second todo are in the list
            let todos = try await Self.list(client: client)
            XCTAssertNotNil(todos.firstIndex(of: todo1))
            XCTAssertNotNil(todos.firstIndex(of: patchedTodo))
            // delete a todo and verify it has been deleted
            let status = try await Self.delete(id: todo1.id, client: client)
            XCTAssertEqual(status, .ok)
            let deletedTodo = try await Self.get(id: todo1.id, client: client)
            XCTAssertNil(deletedTodo)
            // delete all todos and verify there are none left
            try await Self.deleteAll(client: client)
            let todos2 = try await Self.list(client: client)
            XCTAssertEqual(todos2.count, 0)
        }
    }
}
