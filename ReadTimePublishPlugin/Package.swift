// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReadTimePublishPlugin",
    platforms: [.macOS(.v12)],
    products: [
        .library(
            name: "ReadTimePublishPlugin",
            targets: ["ReadTimePublishPlugin"]),
    ],
    dependencies: [
        .package(url: "https://github.com/johnsundell/publish.git", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: "ReadTimePublishPlugin",
            dependencies: [
                .product(name: "Publish", package: "publish")
            ]),
        .testTarget(
            name: "ReadTimePublishPluginTests",
            dependencies: ["ReadTimePublishPlugin"]),
    ]
)
