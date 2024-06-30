# ``HummingbirdRedis/RedisConnectionPoolService``

## Overview

`RedisConnectionPoolService` is a wrapper for a redis connection pool which also conforms to `Service` from [Swift Service Lifecycle](https://github.com/swift-server/swift-service-lifecycle).

```swift
// Create a Redis Connection Pool
let redis = try RedisConnectionPoolService(
    .init(
        hostname: Self.redisHostname, 
        port: 6379,
        pool: .init(maximumConnectionCount: 32)
    ),
    logger: Logger(label: "Redis")
)
// Call Redis function. Currently there are no async/await versions 
// of the functions so have to call `get` to await for EventLoopFuture result
try await redis.set("Test", to: "hello").get()
```

## Service Lifecycle

Given `RedisConnectionPoolService` conforms to `Service` you can have its lifecycle managed by either adding it to the Hummingbird `ServiceGroup` using ``/Hummingbird/Application/addServices(_:)`` from ``/Hummingbird/Application`` or adding it to an independently managed `ServiceGroup`.
