import Foundation
import Logging

// MARK: - Test Strategy Protocol
public protocol TestStrategy {
    func executeTest(target: String, timeout: TimeInterval) async throws -> TestResult
    var testType: TestType { get }
}

// MARK: - Ping Test Strategy
public struct PingTestStrategy: TestStrategy {
    private let pingMonitor: PingMonitor
    private let logger: Logger

    public let testType: TestType = .ping

    public init(logger: Logger = Logger(label: "PingTestStrategy")) {
        self.pingMonitor = PingMonitor()
        self.logger = logger
    }

    public func executeTest(target: String, timeout: TimeInterval) async throws -> TestResult {
        try await pingMonitor.executePing(target: target, timeout: timeout)
    }
}

// MARK: - HTTP Test Strategy
public struct HttpTestStrategy: TestStrategy {
    private let httpMonitor: HttpMonitor
    private let logger: Logger

    public let testType: TestType = .http

    public init(logger: Logger = Logger(label: "HttpTestStrategy")) {
        self.httpMonitor = HttpMonitor()
        self.logger = logger
    }

    public func executeTest(target: String, timeout: TimeInterval) async throws -> TestResult {
        try await httpMonitor.executeHttp(target: target, timeout: timeout)
    }
}

// MARK: - DNS Test Strategy
public struct DnsTestStrategy: TestStrategy {
    private let dnsMonitor: DnsMonitor
    private let logger: Logger

    public let testType: TestType = .dns

    public init(logger: Logger = Logger(label: "DnsTestStrategy")) {
        self.dnsMonitor = DnsMonitor()
        self.logger = logger
    }

    public func executeTest(target: String, timeout: TimeInterval) async throws -> TestResult {
        try await dnsMonitor.executeDns(target: target, timeout: timeout)
    }
}

// MARK: - Speedtest Strategy
public struct SpeedtestStrategy: TestStrategy {
    private let speedtestMonitor: SpeedtestMonitor
    private let logger: Logger

    public let testType: TestType = .speedtest

    public init(logger: Logger = Logger(label: "SpeedtestStrategy")) {
        self.speedtestMonitor = SpeedtestMonitor()
        self.logger = logger
    }

    public func executeTest(target: String, timeout: TimeInterval) async throws -> TestResult {
        try await speedtestMonitor.executeSpeedtest(target: target, timeout: timeout)
    }
}

// MARK: - Test Strategy Factory
public struct TestStrategyFactory {
    public static func createStrategy(for testType: TestType, logger: Logger = Logger(label: "TestStrategyFactory")) -> TestStrategy {
        switch testType {
        case .ping:
            return PingTestStrategy(logger: logger)
        case .http:
            return HttpTestStrategy(logger: logger)
        case .dns:
            return DnsTestStrategy(logger: logger)
        case .speedtest:
            return SpeedtestStrategy(logger: logger)
        case .bandwidth:
            return SpeedtestStrategy(logger: logger) // Use speedtest for bandwidth
        case .latency:
            return PingTestStrategy(logger: logger) // Use ping for latency
        }
    }
}
