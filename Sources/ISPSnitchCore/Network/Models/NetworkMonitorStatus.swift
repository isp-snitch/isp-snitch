@preconcurrency import Foundation

// MARK: - Network Monitor Status
public struct NetworkMonitorStatus: Sendable, Codable {
    public let isMonitoring: Bool
    public let lastTestTimes: [TestType: Date]
    public let monitoringInterval: TimeInterval
    public let minTestInterval: TimeInterval

    public init(
        isMonitoring: Bool,
        lastTestTimes: [TestType: Date],
        monitoringInterval: TimeInterval,
        minTestInterval: TimeInterval
    ) {
        self.isMonitoring = isMonitoring
        self.lastTestTimes = lastTestTimes
        self.monitoringInterval = monitoringInterval
        self.minTestInterval = minTestInterval
    }
}
