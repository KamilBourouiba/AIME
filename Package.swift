// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AIME",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
        .tvOS(.v17)
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

