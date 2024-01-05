# Logging, Metrics and Tracing

Considered the three pillars of observability, logging, metrics and tracing provide different ways of viewing how your application is working. 

## Overview

Apple has developed packages for each of the observability systems ([swift-log](https://github.com/apple/swift-log), [swift-metrics](https://github.com/apple/swift-metrics), [swift-distributed-tracing](https://github.com/apple/swift-distributed-tracing)). They provide a consistent API while not defining how the backend is implemented. With these it is possible to add observability to your own libraries without commiting to a certain implementation of each system.

Hummingbird has middleware for each of these systems. As these are provided as middleware you can add these to your application as and when you need them.

## Logging

Logs provides a record of discrete events over time. Each event has a timestamp, description and an array of metadata. Hummingbird automatically does some logging of events. You can control the fidelity of your logging by setting the application log level eg

```swift
application.logger.logLevel = .debug
```

If you want a record of every request to the server you can add the ``HBLogRequestsMiddleware`` middleware. You can control at what `logLevel` the request logging will occur and whether it includes information about each requests headers. eg

```swift
application.middleware.add(HBLogRequestsMiddleware(.info, includeHeaders: false))
```

If you would like to add your own logging, or implement your own logging backend you can find out more [here](https://swiftpackageindex.com/apple/swift-log/main/documentation/logging). A complete list of logging implementations can be found [here](https://github.com/apple/swift-log#selecting-a-logging-backend-implementation-applications-only).

## Metrics

Metrics provides an overview of how your application is working over time. It allows you to create visualisations of the state of your application. 

The middleware ``HBMetricsMiddleware`` will record how many requests are being made to each route, how long they took and how many failed. To add recording of these metrics to your Hummingbird application you need to add this middleware and bootstrap your chosen metrics backend. Below is an example setting up recording metrics with Prometheus, using the package [SwiftPrometheus](https://github.com/swift-server-community/SwiftPrometheus).

```swift
import Metrics
import Prometheus

// Bootstrap Prometheus
let prometheus = PrometheusClient()
MetricsSystem.bootstrap(PrometheusMetricsFactory(client: prometheus))

// Add metrics middleware
application.middleware.add(HBMetricsMiddleware())
```

If you would like to record your own metrics, or implement your own metrics backed you can find out more [here](https://swiftpackageindex.com/apple/swift-metrics/main/documentation/coremetrics). A list of metrics backend implementations can be found [here](https://github.com/apple/swift-metrics#selecting-a-metrics-backend-implementation-applications-only).

## Tracing

Tracing is used to understand how data flows through an application's various services. 

The middleware ``HBTracingMiddleware`` will record spans for each request made to your application and attach the relevant metadata about request and responses. To add tracing to your Hummingbird application you need to add this middleware and bootstrap your chosen tracing backend. Below is an example setting up tracing using the Open Telemetry package [swift-otel](https://github.com/slashmo/swift-otel).

```swift
import OpenTelemetry
import Tracing

// Bootstrap Open Telemetry
let otel = OTel(serviceName: "example", eventLoopGroup: application.eventLoopGroup)
try otel.start().wait()
InstrumentationSystem.bootstrap(otel.tracer())

// Add tracing middleware
application.middleware.add(HBTracingMiddleware(recordingHeaders: ["content-type", "content-length"]))
```

The Swift implementation of tracing relies on task local variables to propagate the tracing context down the callstack. The internals of Hummingbird are EventLoop based so task local variables may not be propagated correctly. Instead we use an ``HBRequest`` extension to propagate the context. When you move between async and EventLoopFuture based functions it will move the context between task local variables and the ``HBRequest`` extension.

There are different APIs for setting up spans and setting the tracing context when in async or EventLoopFuture based functions. To set the tracing context in an async function use `ServiceContext.withValue` while in an EventLoop based middleware use `HBRequest.withServiceContext`. To setup a new span in an async function use `InstrumentationSystem.tracer.withSpan` while in an EventLoop based middleware use `HBRequest.withSpan`. If you want the tracing context to propagate to the services you are using from your route handlers then these need to be Swift concurrency based.

If you would like to find out more about tracing, or implement your own tracing backend you can find out more [here](https://swiftpackageindex.com/apple/swift-distributed-tracing/main/documentation/tracing).

## Topics

### Reference

- ``HBLogRequestsMiddleware``
- ``HBMetricsMiddleware``
- ``HBTracingMiddleware``
