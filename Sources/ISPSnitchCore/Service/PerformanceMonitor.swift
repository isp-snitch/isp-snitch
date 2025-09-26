import Foundation
import Logging

/// Performance monitoring for ISP Snitch service
/// Optimized for minimal overhead and real-time metrics collection
public class PerformanceMonitor {
    private let logger: Logger
    private var metrics: [String: Double] = [:]
    private var startTime: Date
    private var lastCpuCheck: Date = Date()
    private var lastCpuUsage: Double = 0.0

    // Performance thresholds
    private let maxCpuUsage: Double = 5.0 // 5% max CPU
    private let maxMemoryUsage: Double = 100.0 // 100MB max memory
    private let maxStartupTime: Double = 5.0 // 5 seconds max startup

    public init(logger: Logger = Logger(label: "PerformanceMonitor")) {
        self.logger = logger
        self.startTime = Date()
    }

    /// Start performance monitoring
    public func start() {
        logger.info("Starting performance monitoring")

        // Initialize baseline metrics
        recordMetric(name: "startup_time", value: 0.0)
        recordMetric(name: "cpu_usage", value: 0.0)
        recordMetric(name: "memory_usage", value: 0.0)
        recordMetric(name: "request_count", value: 0.0)
        recordMetric(name: "error_count", value: 0.0)
    }

    /// Record a performance metric
    public func recordMetric(name: String, value: Double) {
        metrics[name] = value

        // Check for performance violations
        checkPerformanceThresholds(name: name, value: value)
    }

    /// Get current CPU usage
    public func getCurrentCpuUsage() -> Double {
        let now = Date()
        let timeSinceLastCheck = now.timeIntervalSince(lastCpuCheck)

        // Only check CPU usage every 5 seconds to reduce overhead
        if timeSinceLastCheck >= 5.0 {
            lastCpuUsage = measureCpuUsage()
            lastCpuCheck = now
        }

        return lastCpuUsage
    }

    /// Get current memory usage in MB
    public func getCurrentMemoryUsage() -> Double {
        measureMemoryUsage()
    }

    /// Get all performance metrics
    public func getMetrics() -> [String: Double] {
        metrics
    }

    /// Check if performance is within acceptable limits
    public func isPerformanceAcceptable() -> Bool {
        let cpuUsage = getCurrentCpuUsage()
        let memoryUsage = getCurrentMemoryUsage()

        return cpuUsage <= maxCpuUsage && memoryUsage <= maxMemoryUsage
    }

    /// Get performance summary
    public func getPerformanceSummary() -> PerformanceSummary {
        let uptime = Date().timeIntervalSince(startTime)
        let cpuUsage = getCurrentCpuUsage()
        let memoryUsage = getCurrentMemoryUsage()
        let requestCount = metrics["request_count"] ?? 0.0
        let errorCount = metrics["error_count"] ?? 0.0
        let errorRate = requestCount > 0 ? (errorCount / requestCount) * 100.0 : 0.0

        return PerformanceSummary(
            uptime: uptime,
            cpuUsage: cpuUsage,
            memoryUsage: memoryUsage,
            requestCount: Int(requestCount),
            errorCount: Int(errorCount),
            errorRate: errorRate,
            isAcceptable: isPerformanceAcceptable()
        )
    }

    // MARK: - Private Methods

    private func checkPerformanceThresholds(name: String, value: Double) {
        switch name {
        case "cpu_usage":
            if value > maxCpuUsage {
                logger.warning("High CPU usage detected: \(value)% (threshold: \(maxCpuUsage)%)")
            }
        case "memory_usage":
            if value > maxMemoryUsage {
                logger.warning("High memory usage detected: \(value)MB (threshold: \(maxMemoryUsage)MB)")
            }
        case "startup_time":
            if value > maxStartupTime {
                logger.warning("Slow startup detected: \(value)s (threshold: \(maxStartupTime)s)")
            }
        default:
            break
        }
    }

    private func measureCpuUsage() -> Double {
        // Simplified CPU measurement - in production, use proper system APIs
        // For now, return a baseline value
        0.5 // 0.5% CPU usage
    }

    private func measureMemoryUsage() -> Double {
        // Simplified memory measurement - in production, use proper system APIs
        // For now, return a baseline value
        25.0 // 25MB memory usage
    }
}

/// Performance summary structure
public struct PerformanceSummary: Sendable, Codable {
    public let uptime: TimeInterval
    public let cpuUsage: Double
    public let memoryUsage: Double
    public let requestCount: Int
    public let errorCount: Int
    public let errorRate: Double
    public let isAcceptable: Bool

    public init(
        uptime: TimeInterval,
        cpuUsage: Double,
        memoryUsage: Double,
        requestCount: Int,
        errorCount: Int,
        errorRate: Double,
        isAcceptable: Bool
    ) {
        self.uptime = uptime
        self.cpuUsage = cpuUsage
        self.memoryUsage = memoryUsage
        self.requestCount = requestCount
        self.errorCount = errorCount
        self.errorRate = errorRate
        self.isAcceptable = isAcceptable
    }
}
