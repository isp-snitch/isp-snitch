import Foundation
import ArgumentParser
import ISPSnitchCore

/// Simple quality monitoring command for documentation metrics
///
/// This command provides basic quality monitoring capabilities for
/// documentation metrics without complex dependencies.
///
/// - Note: This command is thread-safe and can be used concurrently
/// - Since: 1.0.0
public struct SimpleQualityCommand: ParsableCommand {

    // MARK: - Command Configuration

    public static let configuration = CommandConfiguration(
        commandName: "quality",
        abstract: "Monitor documentation quality metrics",
        subcommands: [CheckCommand.self]
    )

    public init() {}

    public func run() throws {
        print("Quality monitoring command")
        print("Available subcommands: check")
    }
}

// MARK: - Check Subcommand

/// Check documentation quality
public struct CheckCommand: ParsableCommand {

    public static let configuration = CommandConfiguration(
        commandName: "check",
        abstract: "Check current documentation quality"
    )

    @Option(name: .shortAndLong, help: "Output format (json, text)")
    public var format: OutputFormat = .text

    public init() {}

    public func run() throws {
        let monitor = SimpleQualityMonitor()
        let metrics = try monitor.performQualityCheck()
        outputMetrics(metrics)
    }

    private func outputMetrics(_ metrics: DocumentationMetrics) {
        switch format {
        case .json:
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            if let data = try? encoder.encode(metrics),
               let json = String(data: data, encoding: .utf8) {
                print(json)
            }
        case .text:
            print(formatAsTable(metrics))
        }
    }

    private func formatAsTable(_ metrics: DocumentationMetrics) -> String {
        """
        ┌─────────────────────────────────────────────────────────────┐
        │                    Quality Metrics                        │
        ├─────────────────────────────────────────────────────────────┤
        │ Total APIs: \(String(format: "%6d", metrics.totalPublicAPIs))                                    │
        │ Documented: \(String(format: "%6d", metrics.documentedAPIs))                                  │
        │ Coverage: \(String(format: "%6.1f%%", metrics.coveragePercentage))                                  │
        │ Quality Score: \(String(format: "%6d", metrics.qualityScore))                              │
        └─────────────────────────────────────────────────────────────┘
        """
    }
}

// MARK: - Output Format

public enum OutputFormat: String, CaseIterable, Sendable, Codable, ExpressibleByArgument {
    case json
    case text
}
