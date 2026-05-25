# Authorization

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Role and permission-based authorization for Hummingbird requests.

## Overview

Authorization determines whether an authenticated identity is permitted to perform a specific action.
It is evaluated *after* authentication — the identity is already resolved in the request context.

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

``AuthorizationPolicyMiddleware`` sits in the route group chain after the authenticator:

```swift
router.group()
    .add(middleware: MyAuthenticator())
    .add(middleware: AuthorizationPolicyMiddleware(RolePolicy("admin")))
    .get("dashboard") { _, _ in ... }
```

Unauthenticated requests (no identity) are rejected with `401 Unauthorized`.
Authenticated requests that fail the policy are rejected with `403 Forbidden`.

## Writing policies

Conform to ``AuthorizationPolicy`` to create reusable rules:

```swift
struct OwnerPolicy: AuthorizationPolicy {
    func isAuthorized(identity: User, request: Request) async throws -> Bool {
        identity.id == request.uri.queryParameters.get("userId")
    }
}
```

For one-off rules use ``ClosureAuthorizationPolicy``:

```swift
.add(middleware: AuthorizationPolicyMiddleware(
    ClosureAuthorizationPolicy { user, request in
        user.id == request.uri.queryParameters.get("userId")
    }
))
```

## Role-based authorization

Conform your identity type to ``RoleProviding`` to use ``RolePolicy``.
The `Roles` associated type accepts any `SetAlgebra` — `Set<Role>`, a typed enum,
or an `OptionSet` for compact bitmask storage:

```swift
// Set with a typed enum
enum Role: String, Hashable, Sendable { case admin, editor, moderator }
struct User: RoleProviding { var roles: Set<Role> }

// OptionSet — single Int32 column, bitwise membership check
struct Role: OptionSet, Sendable {
    let rawValue: Int32
    static let admin  = Role(rawValue: 1 << 0)
    static let editor = Role(rawValue: 1 << 1)
}
struct User: RoleProviding { var roles: Role }
```

```swift
.add(middleware: AuthorizationPolicyMiddleware(RolePolicy("admin")))
```

## Permission-based authorization

Conform your identity type to ``PermissionProviding`` to use ``PermissionPolicy``.
`OptionSet` is a natural fit when permissions map to a fixed bitmask:

```swift
struct Permission: OptionSet, Sendable {
    let rawValue: Int32
    static let postsRead   = Permission(rawValue: 1 << 0)
    static let postsWrite  = Permission(rawValue: 1 << 1)
    static let postsDelete = Permission(rawValue: 1 << 2)
}
struct User: PermissionProviding { var permissions: Permission }
```

```swift
.add(middleware: AuthorizationPolicyMiddleware(PermissionPolicy(Permission.postsWrite)))
```

A type can conform to both, allowing ``RolePolicy`` and ``PermissionPolicy`` to be mixed freely.

## Combining policies

`allOf { }` requires all policies to pass; `anyOf { }` requires at least one:

```swift
// AND
.add(middleware: AuthorizationPolicyMiddleware(allOf {
    RolePolicy("editor")
    PermissionPolicy("posts:publish")
}))

// OR
.add(middleware: AuthorizationPolicyMiddleware(anyOf {
    RolePolicy("admin")
    PermissionPolicy("posts:delete")
}))

// NOT
.add(middleware: AuthorizationPolicyMiddleware(Not(RolePolicy("banned"))))

// Nested: (admin OR (editor AND posts:publish)) AND NOT banned
.add(middleware: AuthorizationPolicyMiddleware(allOf {
    anyOf {
        RolePolicy("admin")
        allOf { RolePolicy("editor"); PermissionPolicy("posts:publish") }
    }
    Not(RolePolicy("banned"))
}))
```

Use `if` inside a builder block for conditional policies:

```swift
.add(middleware: AuthorizationPolicyMiddleware(allOf {
    RolePolicy("editor")
    if requiresApproval { PermissionPolicy("posts:approved") }
}))
```

## Customising the denial error

Pass `deniedError` to override the default `403 Forbidden`:

```swift
// 404 avoids leaking whether the resource exists
.add(middleware: AuthorizationPolicyMiddleware(
    RolePolicy("admin"),
    deniedError: HTTPError(.notFound)
))
```

`deniedError` accepts any `HTTPResponseError`:

```swift
struct ForbiddenError: HTTPResponseError {
    var status: HTTPResponse.Status { .forbidden }
    func response(from request: Request, context: some RequestContext) -> Response {
        Response(status: .forbidden, headers: ["X-Reason": "insufficient-role"])
    }
}

.add(middleware: AuthorizationPolicyMiddleware(RolePolicy("admin"), deniedError: ForbiddenError()))
```

## Authorization scope — filtering collections

``AuthorizationPolicyMiddleware`` gates a single resource. For collection routes
(`GET /items`) use ``AuthorizationScope`` to filter the results:

```swift
struct DocumentScope: AuthorizationScope {
    typealias Identity = User
    typealias Filter = ClosureQueryFilter<Document>

    func filter(for identity: User, request: Request) async throws -> ClosureQueryFilter<Document> {
        // store.list returns Set<UUID> — no conversion needed, O(1) contains
        let allowed = try await store.list(subject: identity.id, action: "read")
        return ClosureQueryFilter { document in
            document.id.map { allowed.contains($0) } ?? false
        }
    }
}
```

Apply it with ``Sequence/filter(scope:identity:request:)``:

```swift
func list(_ request: Request, context: Context) async throws -> [DocumentResponse] {
    let identity = try context.requireIdentity()
    return try await Document.query(on: db).all()
        .filter(scope: documentScope, identity: identity, request: request)
        .map { DocumentResponse(from: $0) }
}
```

| Route             | Type                    | Usage                                        |
|-------------------|-------------------------|----------------------------------------------|
| `GET /items/:id`  | ``AuthorizationPolicy`` | `AuthorizationPolicyMiddleware` in chain     |
| `GET /items`      | ``AuthorizationScope``  | `.filter(scope:identity:request:)` on array  |

## See Also

- ``AuthorizationPolicyMiddleware``
- ``AuthorizationPolicy``
- ``AuthorizationScope``
- ``QueryFilter``
- ``RolePolicy``
- ``PermissionPolicy``
- <doc:AuthenticatorMiddlewareGuide>
