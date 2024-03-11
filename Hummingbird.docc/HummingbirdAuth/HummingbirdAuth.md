# ``HummingbirdAuth``

Authentication framework and extensions for Hummingbird.

Includes Authenticator middleware setup, bearer and basic authentication extraction from your Request headers, Bcrypt encryption for passwords and one time password support.

## Topics

### Articles

- <doc:Authenticator%20Middleware>
- <doc:Sessions>
- <doc:OneTimePasswords>

### Request Contexts

- ``BasicAuthRequestContext``
- ``AuthRequestContext``
- ``LoginCache``

### Authenticators

- ``Authenticator``
- ``Authenticatable``
- ``IsAuthenticatedMiddleware``

### Header Authentication

- ``BasicAuthentication``
- ``BearerAuthentication``

### Encryption

- ``Bcrypt``

### Sessions

- ``SessionAuthenticator``
- ``SessionStorage``

### OTP

- ``HOTP``
- ``TOTP``
- ``OTPHashFunction``

## See Also

- ``Hummingbird``
