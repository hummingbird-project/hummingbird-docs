# Persistent data

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

How to persist data between requests to your server.

## Overview

If you are looking to store data between requests then the Hummingbird `persist` framework provides a key/value store. Each key is a string and the value can be any object that conforms to `Codable`. 

## Setup

At setup you need to choose your persist driver. Below we are using the in memory storage driver. 

```swift
let persist = MemoryPersistDriver()
```

The persist drivers conform to `Service` from Swift Service Lifecycle and should either to added to the ``Application`` serivce group using ``Application/addServices(_:)`` or added to an external managed `ServiceGroup`.

```swift
var app = Application(router: myRouter)
app.addServices(persist)
```

## Usage

To create a new entry you can call `create`
```swift
try await persist.create(key: "mykey", value: MyValue)
```
If there is an entry for the key already then a `PersistError.duplicate` error will be thrown.

If you are not concerned about overwriting a previous key/value pair you can use 
```swift
try await persist.set(key: "mykey", value: MyValue)
```

Both `create` and `set` have an `expires` parameter. With this parameter you can make a key/value pair expire after a certain time period. eg
```swift
try await persist.set(key: "sessionID", value: MyValue, expires: .hours(1))
```

To access values in the `persist` key/value store you use 
```swift
let value = try await persist.get(key: "mykey", as: MyValueType.self)
```

This returns the value associated with the key or `nil` if that value doesn't exist.
If the value is not of the expected type, this will throw ``PersistError/invalidConversion``.

And finally if you want to delete a key you can use
```swift
try await persist.remove(key: "mykey")
```

## Drivers

The `persist` framework defines an API for storing key/value pairs. You also need a driver for the framework. When configuring your application if you want to use `persist` you have to add it to the application and indicate what driver you are going to use. `Hummingbird` comes with a memory based driver which will store these values in the memory of your server. 
```swift
let persist = MemoryPersistDriver()
```
If you use the memory based driver the key/value pairs you store will be lost if your server goes down, also you will not be able to share values between server processes. 

### Redis

You can use Redis to store the `persists` key/value pairs with the `HummingbirdRedis` library. You would setup `persist` to use Redis as follows. To use the Redis driver you need to have setup Redis with Hummingbird as well.
```swift
let redis = RedisConnectionPoolService(
    .init(hostname: redisHostname, port: 6379), 
    logger: Logger(label: "Redis")
)
let persist = RedisPersistDriver(redisConnectionPoolService: redis)
```

### Fluent

``HummingbirdFluent`` also contains a `persist` driver for the storing the key/value pairs in a database. To setup the Fluent driver you need to have setup Fluent first. The first time you run with the fluent driver you should ensure you call `fluent.migrate()` after creating the ``HummingbirdFluent/FluentPersistDriver`` call has been made.
```swift
let fluent = Fluent(logger: Logger(label: "Fluent"))
fluent.databases.use(...)
let persist = await FluentPersistDriver(fluent: fluent)
// run migrations
if shouldMigrate {
    try await fluent.migrate()
}
```

## Topics

### Reference

- ``PersistDriver``
- ``PersistError``
- ``MemoryPersistDriver``
- ``HummingbirdFluent/FluentPersistDriver``
- ``HummingbirdPostgres/PostgresPersistDriver``
- ``HummingbirdRedis/RedisPersistDriver``

