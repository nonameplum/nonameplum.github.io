// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "PlumBlog",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(
            name: "PlumBlog",
            targets: ["PlumBlog"]
        )
    ],
    dependencies: [
        .package(name: "Publish", url: "https://github.com/johnsundell/publish.git", from: "0.7.0"),
        .package(name: "SplashPublishPlugin", url: "https://github.com/johnsundell/splashpublishplugin", from: "0.1.0"),
        .package(url: "https://github.com/artrmz/ReadTimePublishPlugin", from: "0.1.1"),
    ],
    targets: [
        .target(
            name: "PlumBlog",
            dependencies: [
                "Publish",
                "SplashPublishPlugin",
                "ReadTimePublishPlugin",
            ]
        )
    ]
)
