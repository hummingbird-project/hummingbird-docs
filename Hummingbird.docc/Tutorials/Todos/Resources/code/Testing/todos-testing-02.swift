// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HummingbirdTodos",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", branch: "2.x.x"),
    ],
    targets: [
        .executableTarget(
            name: "HummingbirdTodos",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Hummingbird", package: "hummingbird"),
                .product(name: "HummingbirdFoundation", package: "hummingbird"),
            ]
        ),
        .testTarget(
            name: "HummingbirdTodosTests",
            dependencies: [
                "HummingbirdTodos",
                .product(name: "Hummingbird", package: "hummingbird"),
                .product(name: "HummingbirdXCT", package: "hummingbird"),
            ]
        )
    ]
)
