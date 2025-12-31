// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AIME",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
        .watchOS(.v26),
        .tvOS(.v26)
    ],
    products: [
        .library(
            name: "AIME",
            targets: ["AIME"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AIME",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "AIMETests",
            dependencies: ["AIME"],
            path: "Tests"
        ),
    ]
)

