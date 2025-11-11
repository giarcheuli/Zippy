// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Zippy",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "Zippy",
            targets: ["Zippy"])
    ],
    dependencies: [
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.0")
    ],
    targets: [
        .executableTarget(
            name: "Zippy",
            dependencies: [
                .product(name: "ZIPFoundation", package: "ZIPFoundation")
            ],
            path: "Sources",
            resources: [
                .process("Resources")
            ]),
        .testTarget(
            name: "ZippyTests",
            dependencies: ["Zippy"])
    ]
)
