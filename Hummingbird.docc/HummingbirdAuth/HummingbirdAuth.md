# ``HummingbirdAuth``

Authentication framework and extensions for Hummingbird.

Includes Authenticator middleware setup, bearer and basic authentication extraction from your Request headers, Bcrypt encryption for passwords and one time password support.

## Topics

### Articles

- <doc:AuthenticatorMiddleware>
- <doc:Sessions>
- <doc:OneTimePasswords>

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

### Encryption

- ``Bcrypt``

### Sessions

- ``SessionMiddleware``
- ``SessionStorage``

### OTP

- ``HOTP``
- ``TOTP``
- ``OTPHashFunction``

## See Also

- ``Hummingbird``
