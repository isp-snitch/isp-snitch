import Foundation
import Logging

// MARK: - Test Scheduler
/// Handles test scheduling and timing logic
public class TestScheduler {
    private let logger: Logger
    private let minTestInterval: TimeInterval = 30.0 // Minimum 30 seconds between tests
    private var lastTestTime: [TestType: Date] = [:]

    public init(logger: Logger = Logger(label: "TestScheduler")) {
        self.logger = logger
    }

    /// Check if a test should be performed based on timing
    public func shouldPerformTest(_ testType: TestType) -> Bool {
        if let lastTime = lastTestTime[testType] {
            return Date().timeIntervalSince(lastTime) >= minTestInterval
        }
        return true
    }

    /// Record that a test was performed
    public func recordTestPerformed(_ testType: TestType) {
        lastTestTime[testType] = Date()
    }

    /// Check if enough time has passed since last test
    public func canPerformTest(_ testType: TestType) -> Bool {
        if let lastTime = lastTestTime[testType],
           Date().timeIntervalSince(lastTime) < minTestInterval {
            logger.debug("Skipping \(testType) test - too soon since last test")
            return false
        }
        return true
    }

    /// Get the last test times
    public func getLastTestTimes() -> [TestType: Date] {
        lastTestTime
    }

    /// Get the minimum test interval
    public func getMinTestInterval() -> TimeInterval {
        minTestInterval
    }
}
