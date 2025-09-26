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
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", command]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        try process.run()

        // Wait for completion with timeout
        let result = await withTaskGroup(of: ProcessResult.self) { group in
            group.addTask {
                await self.waitForProcess(process)
            }

            group.addTask {
                do {
                    try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                    process.terminate()
                    return ProcessResult(output: "", exitCode: -1, error: "Timeout")
                } catch {
                    return ProcessResult(output: "", exitCode: -1, error: "Timeout")
                }
            }

            var firstResult: ProcessResult?
            for await result in group {
                firstResult = result
                break
            }
            return firstResult ?? ProcessResult(output: "", exitCode: -1, error: "Unknown error")
        }

        if result.exitCode != 0 {
            throw UtilityExecutionError(
                command: command,
                exitCode: result.exitCode,
                output: result.output,
                error: result.error
            )
        }

        return result.output
    }

    private func waitForProcess(_ process: Process) async -> ProcessResult {
        process.waitUntilExit()

        guard let data = process.standardOutput as? Pipe else {
            return ProcessResult(output: "", exitCode: -1, error: "Invalid pipe")
        }
        let outputData = data.fileHandleForReading.readDataToEndOfFile()
        let output = String(bytes: outputData, encoding: .utf8) ?? ""

        return ProcessResult(
            output: output,
            exitCode: Int(process.terminationStatus),
            error: process.terminationReason == .uncaughtSignal ? "Process terminated by signal" : nil
        )
    }
}

// MARK: - Process Result
private struct ProcessResult: Sendable {
    let output: String
    let exitCode: Int
    let error: String?
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
