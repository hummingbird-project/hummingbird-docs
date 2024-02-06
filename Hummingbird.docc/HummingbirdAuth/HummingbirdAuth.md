# ``HummingbirdAuth``

Authentication framework and extensions for Hummingbird.

Includes Authenticator middleware setup, bearer and basic authentication extraction from your Request headers, Bcrypt encryption for passwords and one time password support.

## Topics

### Articles

- <doc:Authenticators>
- <doc:Sessions>
- <doc:OneTimePasswords>

### Request Contexts

- ``HBBasicAuthRequestContext``
- ``HBAuthRequestContext``
- ``HBLoginCache``

### Authenticators

- ``HBAuthenticator``
- ``HBAuthenticatable``
- ``IsAuthenticatedMiddleware``

### Header Authentication

- ``BasicAuthentication``
- ``BearerAuthentication``

### Encryption

- ``Bcrypt``

### Sessions

- ``HBSessionAuthenticator``
- ``HBSessionStorage``

### OTP

- ``HOTP``
- ``TOTP``
- ``OTPHashFunction``

## See Also

- ``Hummingbird``
