// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "hummingbird-docs",
    platforms: [.macOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "HummingbirdDocs",
            targets: ["HummingbirdDocs"]),
    ],
    dependencies: [
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0-rc.1"),
        .package(url: "https://github.com/hummingbird-project/hummingbird-auth.git", from: "2.0.0-beta.3"),
        .package(url: "https://github.com/hummingbird-project/hummingbird-compression.git", from: "2.0.0-alpha.2"),
        .package(url: "https://github.com/hummingbird-project/hummingbird-fluent.git", from: "2.0.0-beta.2"),
        .package(url: "https://github.com/hummingbird-project/swift-jobs.git", from: "1.0.0-beta.1"),
        .package(url: "https://github.com/hummingbird-project/swift-jobs-redis.git", from: "1.0.0-beta.2"),
        .package(url: "https://github.com/hummingbird-project/hummingbird-lambda.git", from: "2.0.0-beta.6"),
        .package(url: "https://github.com/hummingbird-project/swift-mustache.git", from: "2.0.0-beta.1"),
        .package(url: "https://github.com/hummingbird-project/hummingbird-postgres.git", from: "0.2.0"),
        .package(url: "https://github.com/hummingbird-project/hummingbird-redis.git", from: "2.0.0-beta.2"),
        .package(url: "https://github.com/hummingbird-project/hummingbird-websocket.git", from: "2.0.0-beta.5"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "HummingbirdDocs",
            dependencies: [
                .product(name: "HummingbirdTLS", package: "hummingbird"),
                .product(name: "HummingbirdHTTP2", package: "hummingbird"),
                .product(name: "HummingbirdRouter", package: "hummingbird"),
                .product(name: "HummingbirdTesting", package: "hummingbird"),
                .product(name: "HummingbirdAuth", package: "hummingbird-auth"),
                .product(name: "HummingbirdCompression", package: "hummingbird-compression"),
                .product(name: "HummingbirdFluent", package: "hummingbird-fluent"),
                .product(name: "Jobs", package: "swift-jobs"),
                .product(name: "JobsRedis", package: "swift-jobs-redis"),
                .product(name: "HummingbirdLambda", package: "hummingbird-lambda"),
                .product(name: "HummingbirdLambdaTesting", package: "hummingbird-lambda"),
                .product(name: "Mustache", package: "swift-mustache"),
                .product(name: "HummingbirdPostgres", package: "hummingbird-postgres"),
                .product(name: "JobsPostgres", package: "hummingbird-postgres"),
                .product(name: "HummingbirdRedis", package: "hummingbird-redis"),
                .product(name: "HummingbirdWebSocket", package: "hummingbird-websocket"),
                .product(name: "HummingbirdWSClient", package: "hummingbird-websocket"),
                .product(name: "HummingbirdWSCompression", package: "hummingbird-websocket"),
            ]),
    ]
)
