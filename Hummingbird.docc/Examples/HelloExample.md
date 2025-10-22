# Hello Example

Example demonstaritng how to setup and start up a server

> The source code for this example can be found [here](https://github.com/hummingbird-project/hummingbird-examples/tree/main/hello).

This example responds with word "Hello".

To begin using Hummingbird, set up a new project using the [starter template](https://github.com/hummingbird-project/template). This template includes everything you need to create and deploy a basic Hummingbird app.

Run the template:
```
curl -L https://raw.githubusercontent.com/hummingbird-project/template/main/scripts/download.sh | bash

```
Start the server:
```
swift run App
```

Test the server:
```
curl localhost:8080
```

## Walkthrough

The example has three important files
- [`Package.swift`](https://github.com/hummingbird-project/hummingbird-examples/blob/main/hello/Package.swift): A manifest file is used by Swift Package Manager to define your project's dependencies, targets, supported platforms, and other build settings.
- [`app.swift`](https://github.com/hummingbird-project/hummingbird-examples/blob/main/hello/Sources/App/app.swift): Contains your Command Line arguments and the entrypoint for your app.
- [`Application+build.swift`](https://github.com/hummingbird-project/hummingbird-examples/blob/main/hello/Sources/App/Application%2Bbuild.swift): Contains the configuration of the appliction, routes, middleware, and services.

### Arguments
Defines a command-line option named hostname, accessible via both short (-h) and long (--hostname) flags.

```swift
@Option(name: .shortAndLong)
var hostname: String = "127.0.0.1"
```

- The default value is "127.0.0.1", which refers to the local loopback address — meaning the server will bind to the local machine unless overridden.

- It can be customized this by passing a different IP or hostname when launching the app.

Defines a command-line option named port, also accessible via short (-p) and long (--port) flags.

```swift
@Option(name: .shortAndLong)
var port: Int = 8080
```
- The default value is 8080, a common alternative to port 80 for HTTP servers.

- It can be overriden this to run the server on a different port.

### Route
The router directs requests to their handlers based on the contents of their path.
Example contains a simple route which returns “Hello” in the body of the response.
```swift
router.get("/") { _, _ in
    return "Hello"
}
```
- This defines a route that responds to HTTP GET requests.
- `"/"` is the root path of the server.
