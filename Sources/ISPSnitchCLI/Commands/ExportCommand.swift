import Foundation
import ArgumentParser
import ISPSnitchCore

// MARK: - Export Command
struct ExportCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "export",
        abstract: "Export connectivity data"
    )

    @Option(name: .shortAndLong, help: "Output format (json, csv)")
    var format: String = "json"

    @Option(name: .shortAndLong, help: "Output file path")
    var output: String

    @Option(name: .shortAndLong, help: "Time period for export (1h, 24h, 7d, 30d)")
    var period: String = "24h"

    func run() throws {
        // TODO: Implement export command
        print("Export command - implementation in progress")
    }
}
