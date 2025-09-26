import Foundation
import ArgumentParser
import ISPSnitchCore

// MARK: - Status Command
struct StatusCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "status",
        abstract: "Show service status and current connectivity information"
    )

    @Option(name: .shortAndLong, help: "Output format (text, json, csv)")
    var format: String = "text"

    @Flag(name: .long, help: "Show live updates (refresh every 5 seconds)")
    var live: Bool = false

    @Flag(name: .long, help: "Enable verbose output")
    var verbose: Bool = false

    func run() throws {
        // TODO: Implement status command
        // This will integrate with the core service to get real status
        print("Status command - implementation in progress")
    }
}
