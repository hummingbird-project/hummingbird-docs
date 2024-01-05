# ``HummingbirdRedis``

Add Redis support to Hummingbird server with RediStack.

First you need to create a ``HBRedisConnectionPoolService``. This is a wrapper for a redis connection pool which also conforms to `Service` from [Swift Service Lifecycle](https://github.com/swift-server/swift-service-lifecycle).

```swift
// Create a Redis Connection Pool
let redis = try HBRedisConnectionPoolService(
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


## See Also

- ``Hummingbird``
- ``HummingbirdJobsRedis``
