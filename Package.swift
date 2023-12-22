// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "hummingbird-docs",
    platforms: [.macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "hummingbird-docs",
            targets: ["hummingbird-docs"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, branch: "main"),
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", branch: "main"),
        .package(url: "https://github.com/hummingbird-project/hummingbird-core.git", branch: "main"),
        .package(url: "https://github.com/hummingbird-project/hummingbird-auth.git", branch: "main"),
        .package(url: "https://github.com/hummingbird-project/hummingbird-compression.git", branch: "main"),
        .package(url: "https://github.com/hummingbird-project/hummingbird-fluent.git", branch: "main"),
        .package(url: "https://github.com/hummingbird-project/hummingbird-lambda.git", branch: "1.0.0-rc.1"),
        .package(url: "https://github.com/hummingbird-project/hummingbird-mustache.git", branch: "main"),
        .package(url: "https://github.com/hummingbird-project/hummingbird-redis.git", branch: "main"),
        .package(url: "https://github.com/hummingbird-project/hummingbird-websocket.git", branch: "main"),
        .package(url: "https://github.com/apple/swift-docc-plugin", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "hummingbird-docs",
            dependencies: [
                .product(name: "HummingbirdTLS", package: "hummingbird-core"),
                .product(name: "HummingbirdHTTP2", package: "hummingbird-core"),
                .product(name: "HummingbirdFoundation", package: "hummingbird"),
                .product(name: "HummingbirdJobs", package: "hummingbird"),
                .product(name: "HummingbirdXCT", package: "hummingbird"),
                .product(name: "HummingbirdAuth", package: "hummingbird-auth"),
                .product(name: "HummingbirdCompression", package: "hummingbird-compression"),
                .product(name: "HummingbirdFluent", package: "hummingbird-fluent"),
                .product(name: "HummingbirdLambda", package: "hummingbird-lambda"),
                .product(name: "HummingbirdMustache", package: "hummingbird-mustache"),
                .product(name: "HummingbirdJobsRedis", package: "hummingbird-redis"),
                .product(name: "HummingbirdRedis", package: "hummingbird-redis"),
                .product(name: "HummingbirdWebSocket", package: "hummingbird-websocket"),
            ]),
    ]
)
