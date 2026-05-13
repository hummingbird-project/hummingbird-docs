# Securing Your Application

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Secure your application from common vulnerabilities.

## Overview

HTTP Servers are vulnerable to a large variety of attacks. Some of these are designed to crash or slow down your application and others are designed to expose sensitive data. In this document we detail some of the common vulnerabilities of HTTP servers and show how either your application is already protected against them or what steps you can take to protect your application.

## Denial of service

Denial of service attacks come in many forms. Most of them attempt to exhaust a resource of some form.

### Memory

An attacker may attempt to crash your application by sending it many large requests. As long as you are not collating these requests into single large buffers, Hummingbird protects you from these kind of attacks. Request bodies are streamed and back-pressure is used to ensure only so much of a request is in memory at any one point.

If you are collating a request body into one buffer, provide a sensible maximum size for the buffer. Don't use `Int.max`.

```swift
let body = try request.body.collect(upTo: 256*1024)
```

When you are using a request decoder from the ``Hummingbird/RequestContext`` the decoder normally needs to collate the request body into a single buffer. You can control the maximum size of this buffer by creating a `RequestContext` that overrides the ``Hummingbird/RequestContext/maxUploadSize`` variable. This defaults to 2MB.

```swift
struct MaxUploadRequestContext: RequestContext {
    init(source: Source) {
        self.coreContext = .init(source: source)
    }

    var coreContext: CoreRequestContextStorage
    /// Set maximum upload to 64KB
    var maxUploadSize: Int { 64 * 1024 }
}
```

### Process

Another form of attack is to flood a server with many connections. Hummingbird uses SwiftNIO to manage its connections and it is capable of dealing with many connections, but if each connection hits a route that requires a large amount of processing or requires work from another upstream service the attack can slow down your server, or even bring it to a halt. The best way to avoid this is to limit the number of connections your server will accept. This way you can control the load on your server.

Currently by default this is not enabled, but when configuring your Hummingbird application you can add configuration in to limit the number of connections.

```swift
// Create application that only allows 256 connections
let app = Application(
    router: router,
    configuration: .init(
        address: .hostname("127.0.0.1", port: 8080),
        availableConnectionsDelegate: .maximum(256, logger: logger)
    ),
    logger: logger
)
```

### Connections

While SwiftNIO is capable of dealing with many connections, it is still preferable you don't have more connections open than necessary. Another kind of attack is a slowloris attack where the attacker opens many connections and then drip feeds them data. With this the attacker can keep open many connections with minimal bandwidth.

Protection against this is not on by default but Hummingbird provides options to check for idle connections.

```swift
let app = Application(
    router: router,
    server: .http1(configuration: .init(idleTimeout: .seconds(30))),
    configuration: .init(address: .hostname("127.0.0.1", port: 8080)),
    logger: logger
)
```

If the full request header doesn't appear within this idle time or there is a period of time between each part of the request body greater than the idle time then the connection will be closed.

## Cross-Site Scripting

Cross-site scripting(XSS) is a common attack on websites. The [common weakness enumeration (CWE) site](https://cwe.mitre.org/top25/archive/2025/2025_cwe_top25.html) from Mitre report these as the number one most dangerous software weakness.

XSS comes in many forms, but the fundamental definition is improper neutralization of data from a untrusted source before it is placed in output such as a web page. Typically a XSS attack will run a malicious script on behalf of the victim. As the script is being run by the vicim it will have access to everything the victim has access to. Some attacks will leak or manipulate request cookies, create requests that are mistaken for valid requests from the victim and compromising confidential data.

Mitigations for this kind of attack include

- **Input validation and neutralization**

You should assume all input is malicious and either reject input with invalid characters or neutralize them. If you are using a templating engine to generate HTML. Make sure it neutralizes the `>`, `<` and `&` special charaters. For instance ``Mustache`` that comes with the Hummingbird framework will do this for you by default.

- **Content-security-policy header**

You can use the `content-security-policy` response header to control where resources are loaded from, restrict embedding of resouces, upgrade insecure requests. With this you can control where scripts are being run from, thus reducing the chance of a malicious script being run. You cannot rely on this header as your only defence against XSS attacks as they do require the user's browser to support it.

Hummingbird provides a helper object `ContentSecurityPolicy` to create your response header.

```swift
let csp: ContentSecurityPolicy = [
    .defaultSrc(.self)
    .scriptSrc(.nonce("416d1177-4d12-4e3b-b7c9-f6c409789fb8")),
    .upgradeInsecureRequests
]
response.headers[.contentSecurityPolicy] = csp.description
```

- **HTTPOnly Cookies**

Unless necessary always mark your cookies as `HTTPOnly`. This can prevent malicious scripts getting access to the user's session cookie. Although this isn't a complete solution as not all browsers support HTTP only cookies and the set-cookie header is still available when returned by a response, it does reduce the attack surface.

Hummingbird defaults all cookies to `HTTPOnly`. To further improve security you can also set cookies to only be available on secure connections and their same site policy to be strict. If you are using the ``/HummingbirdAuth/SessionStorage`` or ``/HummingbirdAuth/SessionMiddleware`` from HummingbirdAuth to setup session cookies you will need to set this up in their configuration.

```swift
let sessionMiddleware = SessionMiddleware(
    storage: persist,
    configuration: .init(
        sessionCookieParameters: .init(secure: true, sameSite: .strict)
    )
)
```

### Cross-Site Request Forgery

Cross-site request forgery (CSRF) is an attack where the victim is tricked into making an unintentional request to the web server. This is then treated as an authentic request from the client, effectively performing any operation the victim is able to perform. It can lead to exposure of confidential data, unintended code execution. If the user is an administrator or priviledged user the consequences can include gaining full control of the web application, deletion or stealing of data.

Your main defence against CSRF attacks is ensuring your server is free from XSS vulnerabilities. If this is not the case most other defences can be bypassed. But to reduce the attack surface for CSRF style attacks you can also include the following methods

- **Generate a nonce for each form**

Generate a unique nonce or CSRF token and include it as a hidden item in your form and verify the nonce on receipt of the form. Be sure the nonce generation is sufficiently random. You can find out more about this method in the [OWASP cheat sheets](https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html).

- **Separate confirmation**

Identify particularly dangerous operations and when the user performs such an operation, send a separate confirmation to ensure the user intended to perform that operation.