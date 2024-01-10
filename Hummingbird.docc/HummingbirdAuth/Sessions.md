# Sessions

Session based authentication

Sessions allow you to persist user authentication data between multiple requests to the server. They work by creating a temporary session object that is stored in a key/value store. The key or session id is returned in the response. Subsequent requests can then access the session object by supplying the session id in their request. This object can then be used to authenicate the user. Normally the session id is stored in a cookie.

## Setup

Before you can use sessions you need a ``HummingbirdAuth/HBSessionStorage`` to store your session data and a persist key value store. You can find out more about the persist framework here <doc: PersistentData>. In the example below we are using an in memory key value store, but ``HummingbirdFluent/HBFluentPersistDriver`` and ``HummingbirdRedis/HBRedisPersistDriver`` provide solutions that stores the session data in a database or redis database respectively.

```swift
let persist = HBMemoryPersistDriver()
let sessions = HBSessionStorage(persist)
```

By default sessions store the session id in a `SESSION_ID` cookie. At initialisation it is possible to set it up to use a different cookie.

```swift
app.addSessions(using: .memory, sessionID: .cookie("MY_SESSION_ID"))
```

## Saving a session

Once a user is authenticated you need to save a session for the user. 

```swift
func login(_ request: HBRequest) async throws -> HTTPResponseStatus {
    // get authenticated user
    let user = try context.auth.require(User.self)
    guard let userId = user.id else { return request.failure(.unauthorized) }
    // create session lasting 1 hour
    let cookie = try await request.session.save(session: userId, expiresIn: .minutes(60))
    let response = HBResponse(status: .ok)
    response.setCookie(cookie)
    return response
}
```

In this example the `userId` is saved with the session id. When you call `session.save` it returns a cookie to be returned in your response.

## Sessions Authentication

To authenticate a user using a session id you need to add a session authenticator to the application. This extracts the session id from the request, gets the associated value for the session id from the key/value store and then converts this associated value into the authenticated user. Most of this work is done for you, but the conversion from session object to user most be provided by the application. To do this create an authenticator middleware that conforms to  ``HummingbirdAuth/HBSessionAuthenticator`` and implement the `getValue` function and provide a reference to a ``HummingbirdAuth/HBSessionStorage`` object. 

```swift
struct MySessionAuthenticator<Context: HBAuthRequestContextProtocol>: HBSessionAuthenticator {
    /// requirement, where to get session data from
    let sessionStorage: HBSessionStorage
    func getValue(from session: UUID, request: HBRequest, context: Context) async throws -> User? {
        return try await getUserFromDatabase(id: session)
    }
}
```

Add the authenticator as middleware to the routes you want to enable session authentication for. As with all authenticators your request context will need to conform to ``HummingbirdAuth/HBAuthRequestContextProtocol``.

```swift
router.group()
    .add(middleware: MySessionAuthenticator())
    .get("session") { request, context -> HTTPResponse.Status in
        _ = try context.auth.require(User.self)
        return .ok
    }
```

Your route will be able to access the authenticated user via `context.auth.require` or `context.auth.get`.

## See Also

- ``HummingbirdAuth/HBSessionStorage``
- ``HummingbirdAuth/HBSessionAuthenticator``
