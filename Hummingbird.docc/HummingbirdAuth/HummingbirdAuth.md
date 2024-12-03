# ``HummingbirdAuth``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Authentication framework and extensions for Hummingbird.

Includes authenticator middleware setup, bearer and basic authentication extraction from your Request headers. session authentication. Additional modules are available that support ``HummingbirdBcrypt`` encryption, one time passwords (``HummingbirdOTP``) and include a Basic user/password authentication middleware (``HummingbirdBasicAuth``).

## Topics

### Request Contexts

- ``BasicAuthRequestContext``
- ``AuthRequestContext``

### Authenticators

- ``AuthenticatorMiddleware``
- ``ClosureAuthenticator``
- ``IsAuthenticatedMiddleware``

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
