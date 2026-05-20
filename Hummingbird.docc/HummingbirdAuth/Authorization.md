# Authorization

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Role and permission-based authorization for Hummingbird requests.

## Overview

Authorization determines whether an authenticated identity is permitted to perform a specific action on a resource. It is evaluated *after* authentication — the caller's identity is already resolved in the request context before any authorization policy runs.

## Getting started

Authorization is part of the ``HummingbirdAuth`` library in the [hummingbird-auth](https://github.com/hummingbird-project/hummingbird-auth) package. If you don't already have it as a dependency, add it with:

```
swift package add-dependency https://github.com/hummingbird-project/hummingbird-auth.git --from "2.1.0"
```

Then add the target dependency, replacing `<MyApp>` with the name of your application target:

```
swift package add-target-dependency HummingbirdAuth <MyApp> --package hummingbird-auth
```

## The middleware chain

Authorization slots in after authentication as a three-step chain:

```swift
router.group()
    .add(middleware: MyAuthenticator())           // 1. resolve the caller's identity
    .add(middleware: IsAuthenticatedMiddleware()) // 2. reject unauthenticated (401)
    .add(middleware: IsAuthorizedMiddleware(...)) // 3. reject unauthorised (403)
    .get("admin/dashboard") { _, _ in ... }
```

## Authorization policies

An ``AuthorizationPolicy`` answers one question: given this identity and this request, should access be granted? Implement the protocol to create reusable, named rules:

```swift
struct AdminPolicy: AuthorizationPolicy {
    func isAuthorized(identity: User, request: Request) async throws -> Bool {
        identity.roles.contains("admin")
    }
}
```

For one-off rules, ``ClosureAuthorizationPolicy`` avoids defining a full type:

```swift
IsAuthorizedMiddleware(
    ClosureAuthorizationPolicy { user, request in
        user.id == request.uri.queryParameters.get("userId")
    }
)
```

## Combining policies

Policies compose with ``AllOf``, ``AnyOf``, and ``Not``:

```swift
// All must pass (short-circuits on first failure)
AllOf(RolePolicy("editor"), PermissionPolicy("posts:publish"))

// At least one must pass (short-circuits on first success)
AnyOf(RolePolicy("admin"), RolePolicy("moderator"))

// Inverts a policy
Not(RolePolicy("banned"))
```

Combinators nest freely to express complex rules:

```swift
IsAuthorizedMiddleware(
    AllOf(
        AnyOf(RolePolicy("admin"), RolePolicy("editor")),
        Not(RolePolicy("banned"))
    )
)
```

## Role-based authorization

Conform your identity type to ``RoleProviding`` to use ``RolePolicy``. The `Roles` associated type can be any `SetAlgebra` collection — `Set<String>` and typed enums are the most common choices:

```swift
// String roles
struct User: RoleProviding {
    var roles: Set<String>
}

// Typed enum roles (recommended — compile-time exhaustiveness)
enum Role: String, Hashable, Sendable {
    case admin, editor, moderator
}

struct User: RoleProviding {
    var roles: Set<Role>
}
```

Use ``RolePolicy`` in your middleware chain:

```swift
// Require a single role
IsAuthorizedMiddleware(RolePolicy("admin"))

// Require any one of several roles
IsAuthorizedMiddleware(AnyOf(RolePolicy("admin"), RolePolicy("moderator")))
```

## Permission-based authorization

Conform your identity type to ``PermissionProviding`` to use ``PermissionPolicy``. Permissions are typically fine-grained scoped strings or enum cases:

```swift
enum Permission: String, Hashable, Sendable {
    case postsRead   = "posts:read"
    case postsWrite  = "posts:write"
    case postsDelete = "posts:delete"
}

struct User: PermissionProviding {
    var permissions: Set<Permission>
}
```

An identity type can conform to both ``RoleProviding`` and ``PermissionProviding``, allowing ``RolePolicy`` and ``PermissionPolicy`` to be mixed freely:

```swift
struct User: RoleProviding, PermissionProviding {
    var roles: Set<String>
    var permissions: Set<String>
}

// Require editor role AND publish permission, OR be an admin
IsAuthorizedMiddleware(
    AnyOf(
        RolePolicy("admin"),
        AllOf(RolePolicy("editor"), PermissionPolicy("posts:publish"))
    )
)
```

## Customising the denial error

By default ``IsAuthorizedMiddleware`` throws `403 Forbidden` when a policy denies the request. Pass any ``HTTPResponseError``-conforming value as `deniedError` to override this. A common reason is returning `404 Not Found` to avoid leaking whether a resource exists to callers who are not permitted to see it:

```swift
router.group()
    .add(middleware: MyAuthenticator())
    .add(middleware: IsAuthorizedMiddleware(
        RolePolicy("admin"),
        deniedError: HTTPError(.notFound)
    ))
    .get("secret-resource") { _, _ in ... }
```

Because `deniedError` accepts any ``HTTPResponseError``, you can supply your own type for full control over the response body and headers:

```swift
struct AuthorizationError: HTTPResponseError {
    var status: HTTPResponse.Status { .forbidden }
    func response(from request: Request, context: some RequestContext) -> Response {
        Response(status: .forbidden, headers: ["X-Reason": "insufficient-role"])
    }
}

IsAuthorizedMiddleware(RolePolicy("admin"), deniedError: AuthorizationError())
```

## See Also

- ``IsAuthorizedMiddleware``
- ``AuthorizationPolicy``
- ``RolePolicy``
- ``PermissionPolicy``
- <doc:AuthenticatorMiddlewareGuide>
