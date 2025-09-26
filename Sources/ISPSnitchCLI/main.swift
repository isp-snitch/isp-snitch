import Foundation
import ArgumentParser
import ISPSnitchCore

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
            ServiceCommand.self,
            SimpleQualityCommand.self
        ]
    )
}

// Main entry point
ISPSnitchCLI.main()
