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
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", branch: "main"),
        .package(url: "https://github.com/hummingbird-project/hummingbird-core.git", from: "1.0.0-alpha.1"),
        .package(url: "https://github.com/hummingbird-project/hummingbird-auth.git", from: "1.0.0-alpha.1"),
        .package(url: "https://github.com/hummingbird-project/hummingbird-compression.git", from: "1.0.0-alpha.1"),
        .package(url: "https://github.com/hummingbird-project/hummingbird-lambda.git", from: "1.0.0-alpha.1"),
        .package(url: "https://github.com/hummingbird-project/hummingbird-mustache.git", from: "1.0.0"),
        .package(url: "https://github.com/hummingbird-project/hummingbird-websocket.git", from: "1.0.0-alpha.1"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
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
                .product(name: "HummingbirdLambda", package: "hummingbird-lambda"),
                .product(name: "HummingbirdMustache", package: "hummingbird-mustache"),
                .product(name: "HummingbirdWebSocket", package: "hummingbird-websocket"),
            ]),
    ]
)
