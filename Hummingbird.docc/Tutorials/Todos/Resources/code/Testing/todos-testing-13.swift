extension AppTests {
    @Test func testDeletingTodoTwiceReturnsBadRequest() async throws {}
    @Test func testGettingTodoWithInvalidUUIDReturnsBadRequest() async throws {}
    @Test func test30ConcurrentlyCreatedTodosAreAllCreated() async throws {}
    @Test func testUpdatingNonExistentTodoReturnsBadRequest() async throws {}
}