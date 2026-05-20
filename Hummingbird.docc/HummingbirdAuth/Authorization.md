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

Add `.authorized { }` after your authenticator in the route group chain:

```swift
router.group()
    .add(middleware: MyAuthenticator())   // 1. resolve the caller's identity
    .authorized {                          // 2. check authorization — 403 if denied
        RolePolicy("admin")
    }
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

For one-off rules, use ``ClosureAuthorizationPolicy`` directly in the block:

```swift
.authorized {
    ClosureAuthorizationPolicy { user, request in
        user.id == request.uri.queryParameters.get("userId")
    }
}
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
.authorized { RolePolicy("admin") }
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
.authorized { PermissionPolicy("posts:publish") }
```

A type can conform to both, allowing roles and permissions to be mixed freely.

## Combining policies

All policies listed directly in `.authorized { }` must pass (AND semantics).
Use ``anyOf(_:_:)`` or ``allOf(_:_:)`` inside the block for OR / nested AND:

```swift
// AND — both must pass
.authorized {
    RolePolicy("editor")
    PermissionPolicy("posts:publish")
}

// OR — either satisfies
.authorized {
    anyOf(RolePolicy("admin"), PermissionPolicy("posts:delete"))
}

// NOT
.authorized {
    Not(RolePolicy("banned"))
}

// Nested: (admin OR (editor AND publish permission)) AND NOT banned
.authorized {
    anyOf(RolePolicy("admin"),
          allOf(RolePolicy("editor"), PermissionPolicy("posts:publish")))
    Not(RolePolicy("banned"))
}
```

For more than two policies in OR position, use the builder form:

```swift
.authorized {
    allOf {
        RolePolicy("editor")
        PermissionPolicy("posts:publish")
        if requiresApproval { PermissionPolicy("posts:approved") }
    }
}
```

## Customising the denial error

By default ``AuthorizationPolicyMiddleware`` throws `403 Forbidden`. Pass `deniedError` to override:

```swift
// Return 404 to avoid leaking whether the resource exists
.authorized(deniedError: HTTPError(.notFound)) {
    RolePolicy("admin")
}
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

.authorized(deniedError: ForbiddenError()) {
    RolePolicy("admin")
}
```

## See Also

- ``AuthorizationPolicyMiddleware``
- ``AuthorizationPolicy``
- ``RolePolicy``
- ``PermissionPolicy``
- <doc:AuthenticatorMiddlewareGuide>
