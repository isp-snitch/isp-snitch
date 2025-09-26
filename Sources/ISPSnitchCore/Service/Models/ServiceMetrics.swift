import Foundation

/// Service metrics structure
public struct ServiceMetrics: Sendable, Codable {
    public let uptimeSeconds: Int
    public let totalRequests: Int
    public let averageResponseTime: Double
    public let errorRate: Double
    public let memoryUsage: Double
    public let cpuUsage: Double

    public init(
        uptimeSeconds: Int,
        totalRequests: Int,
        averageResponseTime: Double,
        errorRate: Double,
        memoryUsage: Double,
        cpuUsage: Double
    ) {
        self.uptimeSeconds = uptimeSeconds
        self.totalRequests = totalRequests
        self.averageResponseTime = averageResponseTime
        self.errorRate = errorRate
        self.memoryUsage = memoryUsage
        self.cpuUsage = cpuUsage
    }
}
