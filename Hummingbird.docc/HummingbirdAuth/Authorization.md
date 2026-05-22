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

Authorization is another middleware in the chain, added with `.add(middleware:)`:

```swift
router.group()
    .add(middleware: MyAuthenticator())                    // 1. resolve the caller's identity
    .add(middleware: AuthorizationPolicyMiddleware(         // 2. check authorization
        RolePolicy("admin")
    ))
    .get("dashboard") { _, _ in ... }
```

Unauthenticated requests (no identity) are rejected with `401 Unauthorized`.
Authenticated requests that fail the policy are rejected with `403 Forbidden`.

## Writing policies

An ``AuthorizationPolicy`` answers one question: given this identity and this request, should access be granted?

```swift
struct OwnerPolicy: AuthorizationPolicy {
    func isAuthorized(identity: User, request: Request) async throws -> Bool {
        identity.id == request.uri.queryParameters.get("userId")
    }
}
```

For one-off rules, pass ``ClosureAuthorizationPolicy`` directly:

```swift
.add(middleware: AuthorizationPolicyMiddleware(
    ClosureAuthorizationPolicy { user, request in
        user.id == request.uri.queryParameters.get("userId")
    }
))
```

## Role-based authorization

Conform your identity type to ``RoleProviding`` to use ``RolePolicy``:

```swift
struct User: RoleProviding {
    var roles: Set<String>
}

// or with a typed enum
enum Role: String, Hashable, Sendable { case admin, editor, moderator }
struct User: RoleProviding { var roles: Set<Role> }
```

```swift
.add(middleware: AuthorizationPolicyMiddleware(RolePolicy("admin")))
```

## Permission-based authorization

Conform your identity type to ``PermissionProviding`` to use ``PermissionPolicy``:

```swift
enum Permission: String, Hashable, Sendable {
    case postsRead = "posts:read"
    case postsWrite = "posts:write"
}
struct User: PermissionProviding { var permissions: Set<Permission> }
```

```swift
.add(middleware: AuthorizationPolicyMiddleware(PermissionPolicy("posts:publish")))
```

A type can conform to both, allowing roles and permissions to be mixed freely.

## Combining policies

All policies in `allOf { }` must pass (AND semantics).
Use ``anyOf(_:_:)`` or ``allOf(_:_:)`` inside the block for OR / nested AND:

```swift
// AND — both must pass
.add(middleware: AuthorizationPolicyMiddleware(
    allOf(RolePolicy("editor"), PermissionPolicy("posts:publish"))
))

// OR — either satisfies
.add(middleware: AuthorizationPolicyMiddleware(
    anyOf(RolePolicy("admin"), PermissionPolicy("posts:delete"))
))

// NOT
.add(middleware: AuthorizationPolicyMiddleware(Not(RolePolicy("banned"))))

// Nested: (admin OR (editor AND publish permission)) AND NOT banned
.add(middleware: AuthorizationPolicyMiddleware(
    allOf {
        anyOf(RolePolicy("admin"),
              allOf(RolePolicy("editor"), PermissionPolicy("posts:publish")))
        Not(RolePolicy("banned"))
    }
))
```

For conditional policies use the builder form with `if`:

```swift
.add(middleware: AuthorizationPolicyMiddleware(
    allOf {
        RolePolicy("editor")
        PermissionPolicy("posts:publish")
        if requiresApproval { PermissionPolicy("posts:approved") }
    }
))
```

## Customising the denial error

By default ``AuthorizationPolicyMiddleware`` throws `403 Forbidden`. Pass `deniedError` to override:

```swift
// Return 404 to avoid leaking whether the resource exists
.add(middleware: AuthorizationPolicyMiddleware(
    RolePolicy("admin"),
    deniedError: HTTPError(.notFound)
))
```

`deniedError` accepts any ``HTTPResponseError`` — including custom types that control
the response body and headers:

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

``AuthorizationPolicy`` is a *gate*: it answers "can you see this specific resource?" and
produces a `403` if not. For collection routes (`GET /items`) a gate is the wrong
abstraction — you want a *filter* that shapes the query before it runs.

``AuthorizationScope`` answers the complementary question: *"given who you are, which
resources can you see?"* The async work (store lookups, OPA calls, Casbin queries) lives
in ``AuthorizationScope/filter(for:request:)``; the returned ``QueryFilter`` applies
synchronously to each resource.

```swift
struct DocumentScope: AuthorizationScope {
    typealias Identity = User
    typealias Filter = ClosureQueryFilter<Document>

    func filter(for identity: User, request: Request) async throws -> ClosureQueryFilter<Document> {
        // One async call — OPA list, Casbin enforcement, store query
        let ids = try await policyEngine.list(subject: identity.name, action: "read")
        let allowed = Set(ids)
        // Returned filter is sync: O(1) lookup per document
        return ClosureQueryFilter { document in
            document.id.map { allowed.contains($0) } ?? false
        }
    }
}
```

Apply the scope inside a list handler. Single-resource routes use ``AuthorizationPolicyMiddleware``
as normal; the scope is applied inside the collection handler:

```swift
// Single resource — middleware gate
.add(middleware: AuthorizationPolicyMiddleware(CanPolicy("read", store: store)))
.get(use: getDocument)

// Collection — scope applied inside the handler
func list(_ request: Request, context: Context) async throws -> [DocumentResponse] {
    guard let identity = context.identity else { throw HTTPError(.unauthorized) }
    let filter = try await scope.filter(for: identity, request: request)
    return try await Document.query(on: db).all()
        .asyncFilter { try await filter.matches($0) }
        .map { DocumentResponse(from: $0) }
}
```

The two protocols divide cleanly across route shapes:

| Route | Protocol | Mechanism |
|---|---|---|
| `GET /documents/:id` | ``AuthorizationPolicy`` | `AuthorizationPolicyMiddleware` in chain |
| `GET /documents` | ``AuthorizationScope`` | `filter(for:request:)` inside handler |

## See Also

- ``AuthorizationPolicyMiddleware``
- ``AuthorizationPolicy``
- ``AuthorizationScope``
- ``QueryFilter``
- ``RolePolicy``
- ``PermissionPolicy``
- <doc:AuthenticatorMiddlewareGuide>
