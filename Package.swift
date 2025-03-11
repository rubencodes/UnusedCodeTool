// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UnusedCodeTool",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "unused-code-tool",
            dependencies: ["Core"],
            path: "Sources/Main"
        ),
        .target(
            name: "Core",
            dependencies: []
        ),
    ]
)
