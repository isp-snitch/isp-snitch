import Foundation
import Logging

// MARK: - Service Lifecycle Manager
/// Handles service startup, shutdown, and state management
public class ServiceLifecycleManager {
    private let networkMonitor: NetworkMonitor
    private let performanceMonitor: PerformanceMonitor?
    private let metricsCollector: ServiceMetricsCollector
    private let logger: Logger

    // Service state
    private var isRunning = false
    private var status: ServiceState = .stopped

    public init(
        networkMonitor: NetworkMonitor,
        performanceMonitor: PerformanceMonitor?,
        metricsCollector: ServiceMetricsCollector,
        logger: Logger = Logger(label: "ServiceLifecycleManager")
    ) {
        self.networkMonitor = networkMonitor
        self.performanceMonitor = performanceMonitor
        self.metricsCollector = metricsCollector
        self.logger = logger
    }

    /// Start the service
    public func start() throws {
        guard !isRunning else {
            throw ServiceError.alreadyRunning
        }

        let startTime = Date()
        status = .starting
        logger.info("Starting ISP Snitch service")

        do {
            // Initialize performance monitoring first
            performanceMonitor?.start()

            // Start network monitoring with optimized intervals
            try networkMonitor.start()

            // Start web server (placeholder for now)
            // TODO: Integrate web server when available

            metricsCollector.setStartTime(startTime)
            isRunning = true
            status = .running

            let startupTime = Date().timeIntervalSince(startTime)
            logger.info("ISP Snitch service started successfully in \(startupTime)s")

            // Record startup metrics
            metricsCollector.recordStartupMetrics(startupTime: startupTime)

        } catch {
            status = .error
            logger.error("Failed to start service: \(error)")
            throw ServiceError.startupFailed(error)
        }
    }

    /// Stop the service
    public func stop() throws {
        guard isRunning else {
            throw ServiceError.notRunning
        }

        status = .stopping

        do {
            // Stop network monitoring
            try networkMonitor.stop()

            // Stop web server (placeholder for now)
            // TODO: Integrate web server when available

            isRunning = false
            status = .stopped

            logger.info("ISP Snitch service stopped successfully")
        } catch {
            status = .error
            throw ServiceError.shutdownFailed(error)
        }
    }

    /// Restart the service
    public func restart() throws {
        try stop()
        try start()
    }

    /// Get current service status
    public func getStatus() -> ServiceState {
        status
    }

    /// Check if service is running
    public func isServiceRunning() -> Bool {
        isRunning
    }
}
