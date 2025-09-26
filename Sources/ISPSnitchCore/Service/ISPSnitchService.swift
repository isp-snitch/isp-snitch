import Foundation
import Logging

/// ISP Snitch Main Service
///
/// This is the main service that integrates all core components
/// and provides the primary interface for the ISP Snitch application.
/// Optimized for minimal resource usage and high performance.
public final class ISPSnitchService {
    public static let shared = ISPSnitchService()

    // Core components
    private var databaseManager: DatabaseManager?
    private let networkMonitor: NetworkMonitor
    private var webServer: Any? // Will be set when web server is available

    // Service management
    private let lifecycleManager: ServiceLifecycleManager
    private let metricsCollector: ServiceMetricsCollector
    private let logger: Logger

    // Performance monitoring
    private var performanceMonitor: PerformanceMonitor?

    public init() {
        // Initialize components lazily for optimal startup time
        self.databaseManager = nil as DatabaseManager?
        self.networkMonitor = NetworkMonitor()
        self.webServer = nil

        // Initialize performance monitoring
        self.logger = Logger(label: "ISPSnitchService")
        self.performanceMonitor = nil

        // Initialize service management components
        self.metricsCollector = ServiceMetricsCollector(performanceMonitor: nil, logger: logger)
        self.lifecycleManager = ServiceLifecycleManager(
            networkMonitor: networkMonitor,
            performanceMonitor: nil,
            metricsCollector: metricsCollector,
            logger: logger
        )
    }

    /// Start the ISP Snitch service with optimized startup
    public func start() throws {
        // Initialize performance monitoring first
        self.performanceMonitor = PerformanceMonitor()
        performanceMonitor?.start()

        // Initialize database with connection pooling
        self.databaseManager = try DatabaseManager()

        // Update metrics collector with performance monitor
        let updatedMetricsCollector = ServiceMetricsCollector(performanceMonitor: performanceMonitor, logger: logger)
        let updatedLifecycleManager = ServiceLifecycleManager(
            networkMonitor: networkMonitor,
            performanceMonitor: performanceMonitor,
            metricsCollector: updatedMetricsCollector,
            logger: logger
        )

        // Start the service
        try updatedLifecycleManager.start()
    }

    /// Stop the ISP Snitch service
    public func stop() throws {
        try lifecycleManager.stop()
    }

    /// Restart the ISP Snitch service
    public func restart() throws {
        try lifecycleManager.restart()
    }

    /// Get current service status
    public func getStatus() -> ServiceState {
        lifecycleManager.getStatus()
    }

    /// Get service metrics with real-time performance data
    public func getMetrics() -> ServiceMetrics {
        metricsCollector.getMetrics()
    }

    /// Check if service is running
    public var isRunning: Bool {
        lifecycleManager.isServiceRunning()
    }
}
