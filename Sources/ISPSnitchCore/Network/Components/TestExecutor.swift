import Foundation
import Logging

// MARK: - Test Executor
/// Handles the execution of different types of network tests
public class TestExecutor {
    private let pingMonitor: PingMonitor
    private let httpMonitor: HttpMonitor
    private let dnsMonitor: DnsMonitor
    private let speedtestMonitor: SpeedtestMonitor
    private let logger: Logger

    public init(logger: Logger = Logger(label: "TestExecutor")) {
        self.pingMonitor = PingMonitor()
        self.httpMonitor = HttpMonitor()
        self.dnsMonitor = DnsMonitor()
        self.speedtestMonitor = SpeedtestMonitor()
        self.logger = logger
    }

    /// Execute a single network test
    public func executeTest(_ testType: TestType, target: String) throws -> TestResult {
        logger.info("Executing \(testType) test for target: \(target)")

        let startTime = Date()
        let result: TestResult

        do {
            switch testType {
            case .ping:
                result = try pingMonitor.executePing(target: target)
            case .http:
                result = try httpMonitor.executeHttp(target: target)
            case .dns:
                result = try dnsMonitor.executeDns(target: target)
            case .speedtest:
                result = try speedtestMonitor.executeSpeedtest(target: target)
            case .bandwidth:
                // Bandwidth test is handled by speedtest
                result = try speedtestMonitor.executeSpeedtest(target: target)
            case .latency:
                // Latency test is handled by ping
                result = try pingMonitor.executePing(target: target)
            }

            let duration = Date().timeIntervalSince(startTime)
            logger.info("\(testType) test completed in \(duration)s")

            return result
        } catch {
            logger.error("\(testType) test failed: \(error)")
            throw NetworkMonitorError.testFailed(error)
        }
    }
}
