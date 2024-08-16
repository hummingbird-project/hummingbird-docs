# ``HummingbirdAuth``

Authentication framework and extensions for Hummingbird.

Includes Authenticator middleware setup, bearer and basic authentication extraction from your Request headers. session authentication. Additional modules are available that support ``Bcrypt`` encryption, one time passwords (``OTP``) and include a Basic user/password authentication middleware (``HummingbirdBasicAuth``).

## Topics

### Articles

- <doc:AuthenticatorMiddleware>
- <doc:Sessions>

### Request Contexts

- ``BasicAuthRequestContext``
- ``AuthRequestContext``
- ``LoginCache``

### Authenticators

- ``AuthenticatorMiddleware``
- ``Authenticatable``
- ``IsAuthenticatedMiddleware``

### Header Authentication

- ``BasicAuthentication``
- ``BearerAuthentication``

### Sessions

- ``SessionAuthenticator``
- ``SessionStorage``
- ``SessionUserRepository``
- ``UserSessionClosure``
- ``SessionMiddleware``

## See Also

- ``Bcrypt``
- ``OTP``
- ``HummingbirdBasicAuth``
- ``Hummingbird``
