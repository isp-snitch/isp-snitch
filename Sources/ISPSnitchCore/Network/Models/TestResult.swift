import Foundation

// MARK: - Test Result
public struct TestResult: Sendable, Codable {
    public let testType: TestType
    public let target: String
    public let success: Bool
    public let timestamp: Date
    public let duration: TimeInterval
    public let data: TestDataContainer?
    public let error: String?

    public init(
        testType: TestType,
        target: String,
        success: Bool,
        timestamp: Date,
        duration: TimeInterval,
        data: TestDataContainer?,
        error: String?
    ) {
        self.testType = testType
        self.target = target
        self.success = success
        self.timestamp = timestamp
        self.duration = duration
        self.data = data
        self.error = error
    }
}
