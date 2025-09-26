import Foundation
import Logging

// MARK: - Ping Monitor
public actor PingMonitor {
    private let utilityExecutor: UtilityExecutor
    private let outputParser: OutputParser
    private let logger: Logger

    public init(logger: Logger = Logger(label: "PingMonitor")) {
        self.utilityExecutor = UtilityExecutor()
        self.outputParser = OutputParser()
        self.logger = logger
    }

    public func executePing(target: String, timeout: TimeInterval = 10.0) async throws -> TestResult {
        let command = "ping -c 1 -W 1000 \(target)"

        do {
            let output = try await utilityExecutor.executeCommand(command, timeout: timeout)
            let parsedData = try outputParser.parsePingOutput(output)

            return TestResult(
                success: true,
                pingData: parsedData
            )
        } catch {
            logger.error("Ping test failed for \(target): \(error)")

            return TestResult(
                success: false,
                errorMessage: error.localizedDescription,
                errorCode: (error as? UtilityExecutionError)?.exitCode
            )
        }
    }
}

// MARK: - HTTP Monitor
public actor HttpMonitor {
    private let utilityExecutor: UtilityExecutor
    private let outputParser: OutputParser
    private let logger: Logger

    public init(logger: Logger = Logger(label: "HttpMonitor")) {
        self.utilityExecutor = UtilityExecutor()
        self.outputParser = OutputParser()
        self.logger = logger
    }

    public func executeHttp(target: String, timeout: TimeInterval = 10.0) async throws -> TestResult {
        let command = "curl -w \"%{http_code}:%{time_total}:%{time_connect}:%{time_namelookup}\" -s -o /dev/null \(target)"

        do {
            let output = try await utilityExecutor.executeCommand(command, timeout: timeout)
            let parsedData = try outputParser.parseHttpOutput(output)

            return TestResult(
                success: true,
                httpData: parsedData
            )
        } catch {
            logger.error("HTTP test failed for \(target): \(error)")

            return TestResult(
                success: false,
                errorMessage: error.localizedDescription,
                errorCode: (error as? UtilityExecutionError)?.exitCode
            )
        }
    }
}

// MARK: - DNS Monitor
public actor DnsMonitor {
    private let utilityExecutor: UtilityExecutor
    private let outputParser: OutputParser
    private let logger: Logger

    public init(logger: Logger = Logger(label: "DnsMonitor")) {
        self.utilityExecutor = UtilityExecutor()
        self.outputParser = OutputParser()
        self.logger = logger
    }

    public func executeDns(target: String, timeout: TimeInterval = 10.0) async throws -> TestResult {
        let command = "dig +short +time=1 +tries=1 \(target)"

        do {
            let output = try await utilityExecutor.executeCommand(command, timeout: timeout)
            let parsedData = try outputParser.parseDnsOutput(output)

            return TestResult(
                success: true,
                dnsData: parsedData
            )
        } catch {
            logger.error("DNS test failed for \(target): \(error)")

            return TestResult(
                success: false,
                errorMessage: error.localizedDescription,
                errorCode: (error as? UtilityExecutionError)?.exitCode
            )
        }
    }
}

// MARK: - Speedtest Monitor
public actor SpeedtestMonitor {
    private let utilityExecutor: UtilityExecutor
    private let outputParser: OutputParser
    private let logger: Logger

    public init(logger: Logger = Logger(label: "SpeedtestMonitor")) {
        self.utilityExecutor = UtilityExecutor()
        self.outputParser = OutputParser()
        self.logger = logger
    }

    public func executeSpeedtest(target: String, timeout: TimeInterval = 30.0) async throws -> TestResult {
        let command = "speedtest-cli --simple"

        do {
            let output = try await utilityExecutor.executeCommand(command, timeout: timeout)
            let parsedData = try outputParser.parseSpeedtestOutput(output)

            return TestResult(
                success: true,
                speedtestData: parsedData
            )
        } catch {
            logger.error("Speedtest failed for \(target): \(error)")

            return TestResult(
                success: false,
                errorMessage: error.localizedDescription,
                errorCode: (error as? UtilityExecutionError)?.exitCode
            )
        }
    }
}
