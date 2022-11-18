# Sessions

Session based authentication

Sessions allow you to persist user data between multiple requests to the server. They work by creating a temporary session object that is stored in a key/value store. The key or session id is returned in the response. Subsequent requests can then access the session object by supplying the session id in their request. This object can then be used to authenicate the user. Normally the session id is stored in a cookie.

## Setup

Before you can use sessions you need to add them to the application. When adding them you choose where you want to store the session key/value store. HummingbirdAuth only provides the option to store it memory, but if you include the ``HummingbirdFluent`` or ``HummingbirdRedis`` packages you can store it in a fluent or redis database.

```swift
app.addSessions(using: .memory)
```

If you don't provide a `using` parameter and you have already called ``Hummingbird.addPersist`` to setup the persist framework, sessions will use the same storage method as persist.

By default sessions store the session id in a `SESSION_ID` cookie. At initialisation it is possible to set it up to use a different cookie.

```swift
app.addSessions(using: .memory, sessionID: .cookie("MY_SESSION_ID"))
```

It is also possible to set it up to use a header instead

```swift
app.addSessions(using: .memory, sessionID: .header("SESSION_ID"))
```

## Saving a session

Once a user is authenticated you need to save a session for the user. 

```swift
func login(_ request: HBRequest) async throws -> HTTPResponseStatus {
    // get authenticated user
    guard let user = request.authGet(User.self),
            let userId = user.id else { return request.failure(.unauthorized) }
    // create session lasting 1 hour
    try await request.session.save(session: userId, expiresIn: .minutes(60))
    return .ok
}
```
In this example the `userId` is saved with the session id.

## Sessions Authentication

To authenticate a user using a session id you need to add a session authenticator to the application. This extracts the session id from the request, gets the associated value for the session id from the key/value store and then converts this associated value into the authenticated user. Most of this work is done for you, but the conversion from session object to user most be provided by the application. To do this create an authenticator middleware that conforms to either ``HummingbirdAuth/HBSessionAuthenticator`` or ``HummingbirdAuth/HBAsyncSessionAuthenticator`` and override the `getValue` function. 

```swift
struct MySessionAuthenticator: HBSessionAuthenticator {
    /// session object
    typealias Session = UUID
    /// authenticated user
    typealias Value = User

    /// convert from session object to authenticated user
    func getValue(from session: Session, request: Hummingbird.HBRequest) async throws -> Value? {
        return try await User.find(session, on: request.db)
    }
}
```

Add the authenticator as middleware to the routes you want to enable session authentication for

```swift
application.router.group()
    .add(middleware: MySessionAuthenticator())
    .get("session") { request -> HTTPResponseStatus in
        _ = try request.authRequire(User.self)
        return .ok
    }

Your route will be able to access the authenticated user via `request.authRequire` or `request.authGet`.
