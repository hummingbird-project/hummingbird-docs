# Authenticators

Request authentication middleware

## Overview

Authenticators are middleware that are used to check if a request is authenticated and then augment the request with the authentication data. Authenticators should conform to protocol `HBAuthenticator`. This requires you implement the function `authenticate(request: HBRequest) -> EventLoopFuture<Value?>` where `Value` is the authentication data and conforms to the protocol `HBAuthenticatable`.

## Usage

A simple username, password authenticator could be implemented as follows. If the authenticator is successful it returns a `User` struct, otherwise it returns `nil`.

```swift
struct BasicAuthenticator: HBAuthenticator {
    func authenticate(request: HBRequest) -> EventLoopFuture<User?> {
        // Basic authentication info in the "Authorization" header, is accessible
        // via request.auth.basic
        guard let basic = request.authBasic else { return request.success(nil) }

        // check if user exists in the database and then verify the entered password
        // against the one stored in the database. If it is correct then login in user
        return database.getUserWithUsername(basic.username, on: request.eventLoop).flatMap { user in
            // did we find a user
            guard let user = user else { return request.success(nil) }
            // verify password against password hash stored in database. If valid
            // return the user. HummingbirdAuth provides an implementation of Bcrypt. 
            return Bcrypt.verify(basic.password, hash: user.passwordHash, for: request).map { success in
                guard success else { return nil }
                return user
            }
        }
    }
}
```
An authenticator is middleware so can be added to your application like any other middleware

```swift
app.middleware.add(BasicAuthenticator())
```

Then in your request handler you can access your authentication data with `request.authGet`.

```swift
/// Get current logged in user
func current(_ request: HBRequest) throws -> User {
    // get authentication data for user. If it doesnt exist then throw unauthorized error
    guard let user = request.authGet(User.self) else { throw HBHTTPError(.unauthorized) }
    return user
}
```

You can require that that authentication was successful and authentication data is available by either adding the middleware ``HummingbirdAuth/IsAuthenticatedMiddleware`` after your authentication middleware

```swift
app.middleware.add(BasicAuthenticator())
app.middleware.add(IsAuthenticatedMiddleware<User>())
```

Or you can use `request.requireAuth` to access the authentication data. In both of these cases if data is not available a unauthorised error is thrown and a 404 response is returned by the server.

## See Also

- ``HummingbirdAuth/HBAuthenticator``
- ``HummingbirdAuth/HBAsyncAuthenticator``
- ``HummingbirdAuth/HBAuthenticatable``
- ``HummingbirdAuth/IsAuthenticatedMiddleware``