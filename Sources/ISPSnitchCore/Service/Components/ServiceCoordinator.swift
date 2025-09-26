import Foundation
import Logging

// MARK: - Service Coordinator
/// Coordinates all service components and manages their lifecycle
public actor ServiceCoordinator {
    private let logger: Logger
    private var databaseManager: DatabaseManager?
    private var networkMonitor: NetworkMonitor?
    private var performanceMonitor: PerformanceMonitor?

    public init(logger: Logger = Logger(label: "ServiceCoordinator")) {
        self.logger = logger
    }

    public func initializeComponents() async throws {
        logger.info("Initializing service components")

        // Initialize database manager
        self.databaseManager = try await DatabaseManager()

        // Initialize network monitor
        self.networkMonitor = NetworkMonitor()

        // Initialize performance monitor
        self.performanceMonitor = PerformanceMonitor()

        logger.info("Service components initialized successfully")
    }

    public func startComponents() async throws {
        guard let networkMonitor = networkMonitor else {
            throw ServiceError.startupFailed(NSError(
                domain: "ServiceCoordinator",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "NetworkMonitor not initialized"]
            ))
        }

        try await networkMonitor.start()
        logger.info("All components started successfully")
    }

    public func stopComponents() async {
        if let networkMonitor = networkMonitor {
            try? await networkMonitor.stop()
        }
        logger.info("All components stopped successfully")
    }

    public func getDatabaseManager() -> DatabaseManager? {
        databaseManager
    }

    public func getNetworkMonitor() -> NetworkMonitor? {
        networkMonitor
    }

    public func getPerformanceMonitor() -> PerformanceMonitor? {
        performanceMonitor
    }
}
