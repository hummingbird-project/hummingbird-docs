# ``HummingbirdAuth``

Authentication framework and extensions for Hummingbird.

Includes Authenticator middleware setup, bearer and basic authentication extraction from your Request headers, Bcrypt encryption for passwords and one time password support.

## Topics

### Articles

- <doc:Authenticators>
- <doc:Sessions>
- <doc:OneTimePasswords>

### Authenticators

- ``HBAuthenticator``
- ``HBAsyncAuthenticator``
- ``HBAuthenticatable``
- ``IsAuthenticatedMiddleware``

### Header Authentication

- ``BasicAuthentication``
- ``BearerAuthentication``

### Encryption

- ``Bcrypt``

### Sessions

- ``SessionManager``
- ``HBSessionAuthenticator``
- ``HBAsyncSessionAuthenticator``

### OTP

- ``HOTP``
- ``TOTP``
- ``OTPHashFunction``

## See Also

- ``Hummingbird``
