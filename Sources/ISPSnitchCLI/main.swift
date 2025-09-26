import Foundation
import ArgumentParser
import ISPSnitchCore

/// ISP Snitch CLI Interface
///
/// Command-line interface for the ISP Snitch network monitoring application.
struct ISPSnitchCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "isp-snitch",
        abstract: "A lightweight ISP service monitor for macOS",
        version: ISPSnitchCore.version,
        subcommands: [
            StatusCommand.self,
            ReportCommand.self,
            ConfigCommand.self,
            ExportCommand.self,
            ServiceCommand.self
        ]
    )
}

// Main entry point
@main
struct Main {
    static func main() {
        ISPSnitchCLI.main()
    }
}
