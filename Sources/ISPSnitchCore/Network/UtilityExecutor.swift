import Foundation
import Logging

#if !os(macOS)
import Glibc
#endif

// MARK: - Utility Executor
public class UtilityExecutor {
    private let logger: Logger

    public init(logger: Logger = Logger(label: "UtilityExecutor")) {
        self.logger = logger
    }

    public func executeCommand(
        _ command: String,
        timeout: TimeInterval = 10.0
    ) throws -> String {
        #if os(macOS)
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", command]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        if process.terminationStatus != 0 {
            throw UtilityExecutionError(
                command: command,
                exitCode: Int(process.terminationStatus),
                output: output,
                error: "Process exited with status \(process.terminationStatus)"
            )
        }

        return output
        #else
        // Use posix_spawn on Linux
        return try executeCommandPosix(command)
        #endif
    }

    #if !os(macOS)
    private func executeCommandPosix(_ command: String) throws -> String {
        // For Linux, we'll use a simple approach with system() call
        // This is blocking, but for simple utility execution, it's acceptable.
        // For more complex scenarios, a non-blocking approach with pipes would be needed.
        let result = system(command)
        let exitCode = result >> 8

        if exitCode != 0 {
            throw UtilityExecutionError(
                command: command,
                exitCode: exitCode,
                output: "",
                error: "Command failed with exit code \(exitCode)"
            )
        }

        return ""
    }
    #endif
}

// MARK: - Utility Execution Error
public struct UtilityExecutionError: Error, Sendable {
    public let command: String
    public let exitCode: Int
    public let output: String
    public let error: String?

    public init(command: String, exitCode: Int, output: String, error: String?) {
        self.command = command
        self.exitCode = exitCode
        self.output = output
        self.error = error
    }
}
