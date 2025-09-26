import Foundation

/// ISP Snitch Main Service
/// 
/// This is the main service that integrates all core components
/// and provides the primary interface for the ISP Snitch application.
@MainActor
public final class ISPSnitchService: ObservableObject {
    public static let shared = ISPSnitchService()

    // Core components
    private var databaseManager: DatabaseManager?
    private let networkMonitor: NetworkMonitor
    private var webServer: Any? // Will be set when web server is available

    // Service state
    @Published public private(set) var isRunning = false
    @Published public private(set) var status: ServiceState = .stopped

    private init() {
        // Initialize components lazily
        self.databaseManager = nil as DatabaseManager?
        self.networkMonitor = NetworkMonitor()
        self.webServer = nil
    }

    /// Start the ISP Snitch service
    public func start() async throws {
        guard !isRunning else {
            throw ServiceError.alreadyRunning
        }

        status = .starting

        do {
            // Initialize database
            self.databaseManager = try await DatabaseManager()

            // Start network monitoring
            try await networkMonitor.start()

            // Start web server (placeholder for now)
            // TODO: Integrate web server when available

            isRunning = true
            status = .running

            print("ISP Snitch service started successfully")
        } catch {
            status = .error
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

    /// Get service metrics
    public func getMetrics() async throws -> ServiceMetrics {
        // TODO: Implement real metrics collection
        return ServiceMetrics(
            uptimeSeconds: 0,
            totalRequests: 0,
            averageResponseTime: 0.0,
            errorRate: 0.0,
            memoryUsage: 0.0,
            cpuUsage: 0.0
        )
    }
}

/// Service state enumeration
public enum ServiceState: String, CaseIterable, Sendable {
    case stopped = "stopped"
    case starting = "starting"
    case running = "running"
    case stopping = "stopping"
    case error = "error"
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
