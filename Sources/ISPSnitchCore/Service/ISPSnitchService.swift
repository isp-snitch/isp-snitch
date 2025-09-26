import Foundation
import Logging

/// ISP Snitch Main Service
/// 
/// This is the main service that integrates all core components
/// and provides the primary interface for the ISP Snitch application.
/// Optimized for minimal resource usage and high performance.
@MainActor
public final class ISPSnitchService: ObservableObject {
    public static let shared = ISPSnitchService()

    // Core components
    private var databaseManager: DatabaseManager?
    private let networkMonitor: NetworkMonitor
    private var webServer: Any? // Will be set when web server is available

    // Performance monitoring
    private let logger: Logger
    private var performanceMonitor: PerformanceMonitor?

    // Service state
    @Published public private(set) var isRunning = false
    @Published public private(set) var status: ServiceState = .stopped

    // Performance metrics
    private var startTime: Date?
    private var requestCount: Int = 0
    private var totalResponseTime: Double = 0.0
    private var errorCount: Int = 0

    private init() {
        // Initialize components lazily for optimal startup time
        self.databaseManager = nil as DatabaseManager?
        self.networkMonitor = NetworkMonitor()
        self.webServer = nil

        // Initialize performance monitoring
        self.logger = Logger(label: "ISPSnitchService")
        self.performanceMonitor = nil
    }

    /// Start the ISP Snitch service with optimized startup
    public func start() async throws {
        guard !isRunning else {
            throw ServiceError.alreadyRunning
        }

        let startTime = Date()
        status = .starting
        logger.info("Starting ISP Snitch service")

        do {
            // Initialize performance monitoring first
            self.performanceMonitor = PerformanceMonitor()
            await performanceMonitor?.start()

            // Initialize database with connection pooling
            self.databaseManager = try await DatabaseManager()

            // Start network monitoring with optimized intervals
            try await networkMonitor.start()

            // Start web server (placeholder for now)
            // TODO: Integrate web server when available

            self.startTime = startTime
            isRunning = true
            status = .running

            let startupTime = Date().timeIntervalSince(startTime)
            logger.info("ISP Snitch service started successfully in \(startupTime)s")

            // Record startup metrics
            await recordStartupMetrics(startupTime: startupTime)

        } catch {
            status = .error
            logger.error("Failed to start service: \(error)")
            throw ServiceError.startupFailed(error)
        }
    }

    /// Stop the ISP Snitch service
    public func stop() async throws {
        guard isRunning else {
            throw ServiceError.notRunning
        }

        status = .stopping

        do {
            // Stop network monitoring
            try await networkMonitor.stop()

            // Stop web server (placeholder for now)
            // TODO: Integrate web server when available

            isRunning = false
            status = .stopped

            print("ISP Snitch service stopped successfully")
        } catch {
            status = .error
            throw ServiceError.shutdownFailed(error)
        }
    }

    /// Restart the ISP Snitch service
    public func restart() async throws {
        try await stop()
        try await start()
    }

    /// Get current service status
    public func getStatus() -> ServiceState {
        return status
    }

    /// Get service metrics with real-time performance data
    public func getMetrics() async throws -> ServiceMetrics {
        let uptime = startTime.map { Int(Date().timeIntervalSince($0)) } ?? 0
        let averageResponseTime = requestCount > 0 ? totalResponseTime / Double(requestCount) : 0.0
        let errorRate = requestCount > 0 ? Double(errorCount) / Double(requestCount) : 0.0

        // Get real-time system metrics
        let memoryUsage = await getCurrentMemoryUsage()
        let cpuUsage = await getCurrentCpuUsage()

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
    private func recordStartupMetrics(startupTime: TimeInterval) async {
        // Record startup time metric
        await performanceMonitor?.recordMetric(name: "startup_time", value: startupTime)

        // Log performance warning if startup takes too long
        if startupTime > 5.0 {
            logger.warning("Service startup took \(startupTime)s, exceeding 5s target")
        }
    }

    /// Get current memory usage in MB
    private func getCurrentMemoryUsage() async -> Double {
        // Use performance monitor for accurate memory measurement
        return await performanceMonitor?.getCurrentMemoryUsage() ?? 25.0
    }

    /// Get current CPU usage percentage
    private func getCurrentCpuUsage() async -> Double {
        // Use system APIs to get real CPU usage
        // Simplified implementation - in production, use proper system APIs
        return await performanceMonitor?.getCurrentCpuUsage() ?? 0.0
    }
}

/// Service state enumeration
public enum ServiceState: String, CaseIterable, Sendable {
    case stopped
    case starting
    case running
    case stopping
    case error
}

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

/// Service error enumeration
public enum ServiceError: Error, Sendable {
    case alreadyRunning
    case notRunning
    case startupFailed(Error)
    case shutdownFailed(Error)
    case configurationError(String)
    case databaseError(String)
    case networkError(String)

    public var localizedDescription: String {
        switch self {
        case .alreadyRunning:
            return "Service is already running"
        case .notRunning:
            return "Service is not running"
        case .startupFailed(let error):
            return "Failed to start service: \(error.localizedDescription)"
        case .shutdownFailed(let error):
            return "Failed to stop service: \(error.localizedDescription)"
        case .configurationError(let message):
            return "Configuration error: \(message)"
        case .databaseError(let message):
            return "Database error: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}
