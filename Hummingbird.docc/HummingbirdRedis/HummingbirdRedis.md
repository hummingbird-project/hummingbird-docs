# ``HummingbirdRedis``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Add Redis support to Hummingbird server with RediStack.

## Overview

Adds Redis support to Hummingbird via [RediStack](https://github.com/swift-server/RediStack) and manage the lifecycle of your Redis connection pool. Also provides a Redis based driver for the persist framework.

```swift
let redis = try RedisConnectionPoolService(
    .init(hostname: Self.redisHostname, port: 6379),
    logger: Logger(label: "Redis")
)
// add router with one route to return Redis info
let router = Router()
router.get("redis") { _, _ in
    try await redis.send(command: "INFO").map(\.description).get()
}
var app = Application(router: router)
// add Redis connection pool as a service to manage its lifecycle
app.addServices(redis)
try await app.runService()
```

## Storage

HummingbirdRedis provides a driver for the persist framework to store key, value pairs between requests.

```swift
let redis = try RedisConnectionPoolService(
    .init(hostname: Self.redisHostname, port: 6379),
    logger: Logger(label: "Redis")
)
let persist = RedisPersistDriver(redisConnectionPoolService: redis)
let router = Router()
// return value from redis database
router.get("{id}") { request, context -> String? in
    let id = try context.parameters.require("id")
    try await persist.get(key: id, as: String.self)
}
// set value in redis database
router.put("{id}") { request, context -> String? in
    let id = try context.parameters.require("id")
    let value = try request.uri.queryParameters.require("value")
    try await persist.set(key: id, value: value)
}
var app = Application(router: router)
// add Redis connection pool and persist driver as services to manage their lifecycle
app.addServices(redis, persist)
try await app.runService()
```


## Topics

### Connection Pool

- ``RedisConnectionPoolService``
- ``RedisConfiguration``

### Storage

- ``RedisPersistDriver``

## See Also

- ``JobsRedis``