# ``HummingbirdAuth``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Authentication framework and extensions for Hummingbird.

Includes authenticator middleware setup, bearer and basic authentication extraction from your Request headers. session authentication. Additional modules are available that support ``HummingbirdBcrypt`` encryption, one time passwords (``HummingbirdOTP``) and include a Basic user/password authentication middleware (``HummingbirdBasicAuth``).

## Topics

### Guides

- <doc:AuthenticatorMiddlewareGuide>
- <doc:Sessions>
- <doc:OneTimePasswords>
- <doc:Authorization>

### Request Contexts

- ``BasicAuthRequestContext``
- ``AuthRequestContext``

### Authenticators

- ``AuthenticatorMiddleware``
- ``ClosureAuthenticator``
- ``IsAuthenticatedMiddleware``

### Authorization

- ``AuthorizationPolicyMiddleware``
- ``AuthorizationPolicy``
- ``ClosureAuthorizationPolicy``

### Policy Combinators

- ``Not``
- ``allOf(_:)``
- ``anyOf(_:)``

### Role and Permission Policies

- ``RoleProviding``
- ``RolePolicy``
- ``PermissionProviding``
- ``PermissionPolicy``

### Header Authentication

- ``BasicAuthentication``
- ``BearerAuthentication``

### Sessions

- ``SessionMiddleware``
- ``SessionRequestContext``
- ``SessionContext``
- ``SessionData``
- ``BasicSessionRequestContext``
- ``SessionStorage``
- ``SessionCookieParameters``

### Session authenticator

- ``SessionAuthenticator``
- ``UserSessionRepository``
- ``UserSessionClosureRepository``
- ``UserRepositoryContext``

## See Also

- ``HummingbirdBasicAuth``
- ``HummingbirdBcrypt``
- ``HummingbirdOTP``
