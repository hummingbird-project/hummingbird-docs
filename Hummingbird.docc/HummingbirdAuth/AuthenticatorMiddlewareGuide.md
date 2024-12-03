# Authenticator Middleware

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Request authentication middleware

## Overview

Authenticators are middleware that are used to check if a request is authenticated and then pass authentication data to functions further down the callstack via the request context. Authenticators should conform to protocol ``HummingbirdAuth/AuthenticatorMiddleware``. This requires you implement the function ``HummingbirdAuth/AuthenticatorMiddleware/authenticate(request:context:)`` that returns a value conforming to `Sendable`.

To use an authenticator it is required that your request context conform to ``HummingbirdAuth/AuthRequestContext``. When you return valid authentication data from your `authenticate` function it is recorded in the ``HummingbirdAuth/AuthRequestContext/identity`` member of your request context.

## Usage

A simple username, password authenticator could be implemented as follows. If the authenticator is successful it returns a `User` struct, otherwise it returns `nil`.

```swift
struct BasicAuthenticator: AuthenticatorMiddleware {
    func authenticate<Context: AuthRequestContext>(request: Request, context: Context) async throws -> Identity? {
        // Basic authentication info in the "Authorization" header, is accessible
        // via request.headers.basic
        guard let basic = request.headers.basic else { return nil }
        // check if user exists in the database and then verify the entered password
        // against the one stored in the database. If it is correct then login in user
        let user = try await database.getUserWithUsername(basic.username)
        // did we find a user
        guard let user = user else { return nil }
        // verify password against password hash stored in database. If valid
        // return the user. HummingbirdAuth provides an implementation of Bcrypt
        // This should be run on the thread pool as it is a long process.
        return try await NIOThreadPool.singleton.runIfActive {
            if Bcrypt.verify(basic.password, hash: user.passwordHash) {
                return user
            }
            return nil
        }
    }
}
```
An authenticator is middleware so can be added to your application like any other middleware

```swift
router.add(middleware: BasicAuthenticator())
```

Then in your request handler you can access your authentication data with `context.identity`.

```swift
/// Get current logged in user
func current(_ request: Request, context: MyContext) throws -> User {
    // get authentication data for user. If it doesnt exist then throw unauthorized error
    let user = context.requireIdentity()
    return user
}
```

You can require that that authentication was successful and authentication data is available by adding the middleware ``HummingbirdAuth/IsAuthenticatedMiddleware`` after your authentication middleware

```swift
router.addMiddleware {
    BasicAuthenticator()
    IsAuthenticatedMiddleware()
}
```
