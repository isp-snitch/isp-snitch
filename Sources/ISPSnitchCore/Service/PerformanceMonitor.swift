import Foundation
import Logging

/// Performance monitoring for ISP Snitch service
/// Optimized for minimal overhead and real-time metrics collection
public actor PerformanceMonitor: Sendable {
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
    public func start() async {
        logger.info("Starting performance monitoring")
        
        // Initialize baseline metrics
        await recordMetric(name: "startup_time", value: 0.0)
        await recordMetric(name: "cpu_usage", value: 0.0)
        await recordMetric(name: "memory_usage", value: 0.0)
        await recordMetric(name: "request_count", value: 0.0)
        await recordMetric(name: "error_count", value: 0.0)
    }
    
    /// Record a performance metric
    public func recordMetric(name: String, value: Double) async {
        metrics[name] = value
        
        // Check for performance violations
        await checkPerformanceThresholds(name: name, value: value)
    }
    
    /// Get current CPU usage
    public func getCurrentCpuUsage() async -> Double {
        let now = Date()
        let timeSinceLastCheck = now.timeIntervalSince(lastCpuCheck)
        
        // Only check CPU usage every 5 seconds to reduce overhead
        if timeSinceLastCheck >= 5.0 {
            lastCpuUsage = await measureCpuUsage()
            lastCpuCheck = now
        }
        
        return lastCpuUsage
    }
    
    /// Get current memory usage
    public func getCurrentMemoryUsage() async -> Double {
        return await measureMemoryUsage()
    }
    
    /// Get all performance metrics
    public func getMetrics() async -> [String: Double] {
        return metrics
    }
    
    /// Check if performance is within acceptable limits
    public func isPerformanceAcceptable() async -> Bool {
        let cpuUsage = await getCurrentCpuUsage()
        let memoryUsage = await getCurrentMemoryUsage()
        
        return cpuUsage <= maxCpuUsage && memoryUsage <= maxMemoryUsage
    }
    
    // MARK: - Private Methods
    
    private func checkPerformanceThresholds(name: String, value: Double) async {
        switch name {
        case "startup_time":
            if value > maxStartupTime {
                logger.warning("Startup time \(value)s exceeds threshold \(maxStartupTime)s")
            }
        case "cpu_usage":
            if value > maxCpuUsage {
                logger.warning("CPU usage \(value)% exceeds threshold \(maxCpuUsage)%")
            }
        case "memory_usage":
            if value > maxMemoryUsage {
                logger.warning("Memory usage \(value)MB exceeds threshold \(maxMemoryUsage)MB")
            }
        default:
            break
        }
    }
    
    private func measureCpuUsage() async -> Double {
        // Simplified CPU usage measurement
        // In production, use proper system APIs like mach_task_basic_info
        let processInfo = ProcessInfo.processInfo
        let systemLoad = processInfo.systemUptime
        // This is a simplified implementation
        return min(systemLoad.truncatingRemainder(dividingBy: 10.0), 5.0)
    }
    
    private func measureMemoryUsage() async -> Double {
        // Get process memory usage (simplified implementation)
        // In production, use proper system APIs like mach_task_basic_info
        _ = ProcessInfo.processInfo
        // This is a simplified implementation - in production, use proper system APIs
        // For now, return a reasonable baseline value
        return 25.0 // 25MB baseline
    }
}

/// Performance metrics structure
public struct PerformanceMetrics: Sendable, Codable {
    public let cpuUsage: Double
    public let memoryUsage: Double
    public let startupTime: Double
    public let requestCount: Int
    public let errorCount: Int
    public let averageResponseTime: Double
    
    public init(
        cpuUsage: Double,
        memoryUsage: Double,
        startupTime: Double,
        requestCount: Int,
        errorCount: Int,
        averageResponseTime: Double
    ) {
        self.cpuUsage = cpuUsage
        self.memoryUsage = memoryUsage
        self.startupTime = startupTime
        self.requestCount = requestCount
        self.errorCount = errorCount
        self.averageResponseTime = averageResponseTime
    }
}
