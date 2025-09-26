// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ISPSnitch",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "isp-snitch", targets: ["ISPSnitchCLI"]),
        .library(name: "ISPSnitchCore", targets: ["ISPSnitchCore"]),
        .library(name: "ISPSnitchWeb", targets: ["ISPSnitchWeb"])
    ],
    dependencies: [
        // SwiftNIO for HTTP server and networking
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "2.25.0"),
        .package(url: "https://github.com/apple/swift-nio-http2.git", from: "1.25.0"),

        // SQLite.swift for database operations
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.15.0"),

        // ArgumentParser for CLI interface
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),

        // Swift Metrics for monitoring
        .package(url: "https://github.com/apple/swift-metrics.git", from: "2.4.0"),

        // Swift Log for logging
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0")
    ],
    targets: [
        // Core library with data models and business logic
        .target(
            name: "ISPSnitchCore",
            dependencies: [
                .product(name: "SQLite", package: "SQLite.swift"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Metrics", package: "swift-metrics")
            ]
        ),

        // CLI interface
        .executableTarget(
            name: "ISPSnitchCLI",
            dependencies: [
                "ISPSnitchCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),

        // Web interface
        .target(
            name: "ISPSnitchWeb",
            dependencies: [
                "ISPSnitchCore",
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "NIOHTTP2", package: "swift-nio-http2"),
                .product(name: "NIOSSL", package: "swift-nio-ssl"),
                .product(name: "NIOFoundationCompat", package: "swift-nio")
            ]
        ),

        // Test suite
        .testTarget(
            name: "ISPSnitchTests",
            dependencies: [
                "ISPSnitchCore",
                "ISPSnitchCLI",
                "ISPSnitchWeb"
            ]
        )
    ]
)
