import Foundation
import Logging

// MARK: - Service Metrics Collector
/// Handles collection and calculation of service metrics
public class ServiceMetricsCollector {
    private let performanceMonitor: PerformanceMonitor?
    private let logger: Logger

    // Performance metrics
    private var startTime: Date?
    private var requestCount: Int = 0
    private var totalResponseTime: Double = 0.0
    private var errorCount: Int = 0

    public init(performanceMonitor: PerformanceMonitor?, logger: Logger = Logger(label: "ServiceMetricsCollector")) {
        self.performanceMonitor = performanceMonitor
        self.logger = logger
    }

    /// Set the service start time
    public func setStartTime(_ startTime: Date) {
        self.startTime = startTime
    }

    /// Record a request
    public func recordRequest(responseTime: Double) {
        requestCount += 1
        totalResponseTime += responseTime
    }

    /// Record an error
    public func recordError() {
        errorCount += 1
    }

    /// Get current metrics
    public func getMetrics() -> ServiceMetrics {
        let uptime = startTime.map { Int(Date().timeIntervalSince($0)) } ?? 0
        let averageResponseTime = requestCount > 0 ? totalResponseTime / Double(requestCount) : 0.0
        let errorRate = requestCount > 0 ? Double(errorCount) / Double(requestCount) : 0.0

        // Get real-time system metrics
        let memoryUsage = getCurrentMemoryUsage()
        let cpuUsage = getCurrentCpuUsage()

        return ServiceMetrics(
            uptimeSeconds: uptime,
            totalRequests: requestCount,
            averageResponseTime: averageResponseTime,
            errorRate: errorRate,
            memoryUsage: memoryUsage,
            cpuUsage: cpuUsage
        )
    }

    /// Record startup metrics for performance monitoring
    public func recordStartupMetrics(startupTime: TimeInterval) {
        // Record startup time metric
        performanceMonitor?.recordMetric(name: "startup_time", value: startupTime)

        // Log performance warning if startup takes too long
        if startupTime > 5.0 {
            logger.warning("Service startup took \(startupTime)s, exceeding 5s target")
        }
    }

    /// Get current memory usage in MB
    private func getCurrentMemoryUsage() -> Double {
        // Use performance monitor for accurate memory measurement
        performanceMonitor?.getCurrentMemoryUsage() ?? 25.0
    }

    /// Get current CPU usage percentage
    private func getCurrentCpuUsage() -> Double {
        // Use system APIs to get real CPU usage
        // Simplified implementation - in production, use proper system APIs
        performanceMonitor?.getCurrentCpuUsage() ?? 0.0
    }
}
