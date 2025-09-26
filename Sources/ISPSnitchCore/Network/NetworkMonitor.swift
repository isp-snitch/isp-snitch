import Foundation
import Logging

// MARK: - Network Monitor
/// Optimized network monitoring with minimal resource usage
public class NetworkMonitor {
    private let testExecutor: TestExecutor
    private let testScheduler: TestScheduler
    private let logger: Logger

    // Performance optimization
    private var isMonitoring = false
    private let monitoringInterval: TimeInterval = 60.0 // 1 minute default

    public init(logger: Logger = Logger(label: "NetworkMonitor")) {
        self.testExecutor = TestExecutor(logger: logger)
        self.testScheduler = TestScheduler(logger: logger)
        self.logger = logger
    }

    // MARK: - Public Interface

    public func start() throws {
        guard !isMonitoring else {
            logger.info("Network monitor already running")
            return
        }

        logger.info("Starting network monitor with optimized intervals")
        isMonitoring = true

        logger.info("Network monitor started successfully")
    }

    public func stop() throws {
        guard isMonitoring else {
            logger.info("Network monitor not running")
            return
        }

        logger.info("Stopping network monitor")
        isMonitoring = false

        logger.info("Network monitor stopped successfully")
    }

    /// Execute a single network test
    public func executeTest(_ testType: TestType, target: String) throws -> TestResult {
        guard isMonitoring else {
            throw NetworkMonitorError.notRunning
        }

        // Check if enough time has passed since last test
        guard testScheduler.canPerformTest(testType) else {
            throw NetworkMonitorError.testTooSoon
        }

        let result = try testExecutor.executeTest(testType, target: target)

        // Record that the test was performed
        testScheduler.recordTestPerformed(testType)

        return result
    }

    /// Check if a test should be performed based on timing
    public func shouldPerformTest(_ testType: TestType) -> Bool {
        guard isMonitoring else { return false }
        return testScheduler.shouldPerformTest(testType)
    }

    /// Get current monitoring status
    public func getStatus() -> NetworkMonitorStatus {
        NetworkMonitorStatus(
            isMonitoring: isMonitoring,
            lastTestTimes: testScheduler.getLastTestTimes(),
            monitoringInterval: monitoringInterval,
            minTestInterval: testScheduler.getMinTestInterval()
        )
    }
}
