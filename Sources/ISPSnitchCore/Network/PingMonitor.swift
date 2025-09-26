import Foundation
import Logging

// MARK: - Ping Monitor
public class PingMonitor {
    private let utilityExecutor: UtilityExecutor
    private let outputParser: OutputParser
    private let logger: Logger

    public init(logger: Logger = Logger(label: "PingMonitor")) {
        self.utilityExecutor = UtilityExecutor()
        self.outputParser = OutputParser()
        self.logger = logger
    }

    public func executePing(target: String, timeout: TimeInterval = 10.0) throws -> TestResult {
        let command = "ping -c 1 -W 1000 \(target)"
        let startTime = Date()

        do {
            let output = try utilityExecutor.executeCommand(command, timeout: timeout)
            let parsedData = try outputParser.parsePingOutput(output)
            let duration = Date().timeIntervalSince(startTime)

            return TestResult(
                testType: .ping,
                target: target,
                success: true,
                timestamp: startTime,
                duration: duration,
                data: .ping(parsedData),
                error: nil
            )
        } catch {
            logger.error("Ping test failed for \(target): \(error)")
            let duration = Date().timeIntervalSince(startTime)

            return TestResult(
                testType: .ping,
                target: target,
                success: false,
                timestamp: startTime,
                duration: duration,
                data: nil,
                error: error.localizedDescription
            )
        }
    }
}

// MARK: - HTTP Monitor
public class HttpMonitor {
    private let utilityExecutor: UtilityExecutor
    private let outputParser: OutputParser
    private let logger: Logger

    public init(logger: Logger = Logger(label: "HttpMonitor")) {
        self.utilityExecutor = UtilityExecutor()
        self.outputParser = OutputParser()
        self.logger = logger
    }

    public func executeHttp(target: String, timeout: TimeInterval = 10.0) throws -> TestResult {
        let command = "curl -w \"%{http_code}:%{time_total}:%{time_connect}:%{time_namelookup}\" -s -o /dev/null \(target)"
        let startTime = Date()

        do {
            let output = try utilityExecutor.executeCommand(command, timeout: timeout)
            let parsedData = try outputParser.parseHttpOutput(output)
            let duration = Date().timeIntervalSince(startTime)

            return TestResult(
                testType: .http,
                target: target,
                success: true,
                timestamp: startTime,
                duration: duration,
                data: .http(parsedData),
                error: nil
            )
        } catch {
            logger.error("HTTP test failed for \(target): \(error)")
            let duration = Date().timeIntervalSince(startTime)

            return TestResult(
                testType: .http,
                target: target,
                success: false,
                timestamp: startTime,
                duration: duration,
                data: nil,
                error: error.localizedDescription
            )
        }
    }
}

// MARK: - DNS Monitor
public class DnsMonitor {
    private let utilityExecutor: UtilityExecutor
    private let outputParser: OutputParser
    private let logger: Logger

    public init(logger: Logger = Logger(label: "DnsMonitor")) {
        self.utilityExecutor = UtilityExecutor()
        self.outputParser = OutputParser()
        self.logger = logger
    }

    public func executeDns(target: String, timeout: TimeInterval = 10.0) throws -> TestResult {
        let command = "dig +short +time=1 +tries=1 \(target)"
        let startTime = Date()

        do {
            let output = try utilityExecutor.executeCommand(command, timeout: timeout)
            let parsedData = try outputParser.parseDnsOutput(output)
            let duration = Date().timeIntervalSince(startTime)

            return TestResult(
                testType: .dns,
                target: target,
                success: true,
                timestamp: startTime,
                duration: duration,
                data: .dns(parsedData),
                error: nil
            )
        } catch {
            logger.error("DNS test failed for \(target): \(error)")
            let duration = Date().timeIntervalSince(startTime)

            return TestResult(
                testType: .dns,
                target: target,
                success: false,
                timestamp: startTime,
                duration: duration,
                data: nil,
                error: error.localizedDescription
            )
        }
    }
}

// MARK: - Speedtest Monitor
public class SpeedtestMonitor {
    private let utilityExecutor: UtilityExecutor
    private let outputParser: OutputParser
    private let logger: Logger

    public init(logger: Logger = Logger(label: "SpeedtestMonitor")) {
        self.utilityExecutor = UtilityExecutor()
        self.outputParser = OutputParser()
        self.logger = logger
    }

    public func executeSpeedtest(target: String, timeout: TimeInterval = 30.0) throws -> TestResult {
        let command = "speedtest-cli --simple"
        let startTime = Date()

        do {
            let output = try utilityExecutor.executeCommand(command, timeout: timeout)
            let parsedData = try outputParser.parseSpeedtestOutput(output)
            let duration = Date().timeIntervalSince(startTime)

            return TestResult(
                testType: .speedtest,
                target: target,
                success: true,
                timestamp: startTime,
                duration: duration,
                data: .speedtest(parsedData),
                error: nil
            )
        } catch {
            logger.error("Speedtest failed for \(target): \(error)")
            let duration = Date().timeIntervalSince(startTime)

            return TestResult(
                testType: .speedtest,
                target: target,
                success: false,
                timestamp: startTime,
                duration: duration,
                data: nil,
                error: error.localizedDescription
            )
        }
    }
}
