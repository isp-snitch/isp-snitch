// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ISPSnitch",
    products: [
        .executable(name: "isp-snitch", targets: ["ISPSnitchCLI"]),
        .library(name: "ISPSnitchCore", targets: ["ISPSnitchCore"])
        // .library(name: "ISPSnitchWeb", targets: ["ISPSnitchWeb"]) - disabled due to SwiftNIO compatibility issues
    ],
    dependencies: [
        // SQLite.swift for database operations
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.14.0"),

        // ArgumentParser for CLI interface
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),

        // Swift Log for logging
        .package(url: "https://github.com/apple/swift-log.git", from: "1.4.0")
    ],
    targets: [
        // Core library with data models and business logic
        .target(
            name: "ISPSnitchCore",
            dependencies: [
                .product(name: "SQLite", package: "SQLite.swift"),
                .product(name: "Logging", package: "swift-log")
            ],
            resources: [
                .process("Database/Schema.sql")  // Include schema documentation as resource
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

        // Web interface (disabled due to SwiftNIO compatibility issues)
        // .target(
        //     name: "ISPSnitchWeb",
        //     dependencies: [
        //         "ISPSnitchCore",
        //         .product(name: "NIO", package: "swift-nio"),
        //         .product(name: "NIOHTTP1", package: "swift-nio"),
        //         .product(name: "NIOHTTP2", package: "swift-nio-http2"),
        //         .product(name: "NIOSSL", package: "swift-nio-ssl"),
        //         .product(name: "NIOFoundationCompat", package: "swift-nio")
        //     ]
        // ),

        // Test suite
        .testTarget(
            name: "ISPSnitchTests",
            dependencies: [
                "ISPSnitchCore",
                "ISPSnitchCLI"
                // "ISPSnitchWeb" - disabled due to SwiftNIO compatibility issues
            ]
        )
    ]
)
