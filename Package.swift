// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "PlumBlog",
    platforms: [.macOS(.v12)],
    products: [
        .executable(
            name: "PlumBlog",
            targets: ["PlumBlog"]
        )
    ],
    dependencies: [
        .package(name: "Publish", url: "https://github.com/johnsundell/publish.git", from: "0.9.0"),
        .package(name: "SplashPublishPlugin", url: "https://github.com/johnsundell/splashpublishplugin", from: "0.2.0"),
        .package(path: "./ReadTimePublishPlugin")
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
