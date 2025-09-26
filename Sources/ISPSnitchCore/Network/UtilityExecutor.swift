import Foundation
import Logging

// MARK: - Utility Executor
public actor UtilityExecutor {
    private let logger: Logger

    public init(logger: Logger = Logger(label: "UtilityExecutor")) {
        self.logger = logger
    }

    public func executeCommand(
        _ command: String,
        timeout: TimeInterval = 10.0
    ) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            Task {
                do {
                    let result = try await executeCommandAsync(command, timeout: timeout)
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func executeCommandAsync(
        _ command: String,
        timeout: TimeInterval
    ) async throws -> String {
        let task = Task {
            try await executeCommandSync(command)
        }

        let timeoutTask = Task {
            try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
            task.cancel()
        }

        do {
            let result = try await task.value
            timeoutTask.cancel()
            return result
        } catch {
            timeoutTask.cancel()
            if task.isCancelled {
                throw UtilityExecutionError(
                    command: command,
                    exitCode: -1,
                    output: "",
                    error: "Command timed out after \(timeout) seconds"
                )
            }
            throw error
        }
    }

    private func executeCommandSync(_ command: String) async throws -> String {
        #if os(macOS)
        // Use Process on macOS
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", command]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        try process.run()
        process.waitUntilExit()

        // Get output
        let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(bytes: outputData, encoding: .utf8) ?? ""

        // Check exit status
        let exitCode = process.terminationStatus
        if exitCode != 0 {
            let errorMessage = process.terminationReason == .uncaughtSignal ? "Process terminated by signal" : nil
            throw UtilityExecutionError(
                command: command,
                exitCode: Int(exitCode),
                output: output,
                error: errorMessage
            )
        }

        return output
        #else
        // Use posix_spawn on Linux
        return try await executeCommandPosix(command)
        #endif
    }

    #if !os(macOS)
    private func executeCommandPosix(_ command: String) async throws -> String {
        // For Linux, we'll use a simple approach with system() call
        // This is a simplified implementation - in production you'd want to use posix_spawn
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
