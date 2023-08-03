# ``HummingbirdRedis``

Add Redis support to Hummingbird server with RediStack.

First you need to create a ``RedisConnectionPoolGroup`` for your `EventLoopGroup`. This creates a connection pool for each `EventLoop` in your `EventLoopGroup`. When you want to send a command you ask the ``RedisConnectionPoolGroup`` for the connection pool for the `EventLoop` you are running on and then call your command.

```swift
// Initialize a Redis Connection Pool for each EventLoop
let redisConnectionPoolGroup = try RedisConnectionPoolGroup(
    configuration: .init(hostname: Self.redisHostname, port: 6379),
    eventLoopGroup: app.eventLoopGroup,
    logger: app.logger
)
// Get Redis connection
let redis = redisConnectionPoolGroup.pool(for: eventLoop)
try await redis.set("Test", to: "hello").get()
```

Alternatively you can access a Redis connection pool via `HBRequest` if you add the connection pool group to your ``HBApplication``.

```swift
try app.addRedis(
    configuration: .init(hostname: Self.redisHostname, port: 6379)
)
// Add route that returns contents of Redis INFO command
app.router.get("redis") { req in
    req.redis.send(command: "INFO").map(\.description)
}
```
## See Also

- ``Hummingbird``
