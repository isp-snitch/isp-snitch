import Foundation

// MARK: - Clean ISPSnitch Service Implementation
public class CleanISPSnitchService: ISPSnitchServiceProtocol {
    private let dataRepository: DataRepository
    private let networkMonitor: NetworkMonitorProtocol
    private let performanceMonitor: PerformanceMonitorProtocol
    private let logger: Logger

    private var isRunning: Bool = false
    private var startTime: Date?

    public init(
        dataRepository: DataRepository,
        networkMonitor: NetworkMonitorProtocol,
        performanceMonitor: PerformanceMonitorProtocol,
        logger: Logger = Logger(label: "ISPSnitchService")
    ) {
        self.dataRepository = dataRepository
        self.networkMonitor = networkMonitor
        self.performanceMonitor = performanceMonitor
        self.logger = logger
    }

    // MARK: - ISPSnitchServiceProtocol Implementation
    public func start() async throws {
        guard !isRunning else {
            logger.info("Service is already running")
            return
        }

        logger.info("Starting ISP Snitch service")

        do {
            try await performanceMonitor.start()
            try await networkMonitor.start()

            isRunning = true
            startTime = Date()

            // Record service start
            let serviceStatus = ServiceStatus(
                id: UUID(),
                timestamp: Date(),
                status: "running",
                uptime: 0.0,
                version: "1.0.0"
            )

            try await dataRepository.insertServiceStatus(serviceStatus)

            logger.info("ISP Snitch service started successfully")
        } catch {
            logger.error("Failed to start service: \(error)")
            throw ServiceError.startupFailed(error)
        }
    }

    public func stop() async throws {
        guard isRunning else {
            logger.info("Service is not running")
            return
        }

        logger.info("Stopping ISP Snitch service")

        do {
            try await networkMonitor.stop()
            try await performanceMonitor.stop()

            isRunning = false

            // Record service stop
            let serviceStatus = ServiceStatus(
                id: UUID(),
                timestamp: Date(),
                status: "stopped",
                uptime: startTime?.timeIntervalSinceNow.magnitude ?? 0.0,
                version: "1.0.0"
            )

            try await dataRepository.insertServiceStatus(serviceStatus)

            logger.info("ISP Snitch service stopped successfully")
        } catch {
            logger.error("Failed to stop service: \(error)")
            throw ServiceError.shutdownFailed(error)
        }
    }

    public func getStatus() async -> ServiceStatus {
        let uptime = startTime?.timeIntervalSinceNow.magnitude ?? 0.0
        let status = isRunning ? "running" : "stopped"

        return ServiceStatus(
            id: UUID(),
            timestamp: Date(),
            status: status,
            uptime: uptime,
            version: "1.0.0"
        )
    }

    public func getMetrics() async -> SystemMetrics {
        return await performanceMonitor.getMetrics()
    }
}

// MARK: - Service Error Types
public enum ServiceError: Error, LocalizedError {
    case startupFailed(Error)
    case shutdownFailed(Error)
    case notRunning
    case alreadyRunning

    public var errorDescription: String? {
        switch self {
        case .startupFailed(let error):
            return "Failed to start service: \(error.localizedDescription)"
        case .shutdownFailed(let error):
            return "Failed to stop service: \(error.localizedDescription)"
        case .notRunning:
            return "Service is not running"
        case .alreadyRunning:
            return "Service is already running"
        }
    }
}

// MARK: - Service Manager
public class ServiceManager {
    private let service: ISPSnitchServiceProtocol
    private let logger: Logger

    public init(service: ISPSnitchServiceProtocol, logger: Logger = Logger(label: "ServiceManager")) {
        self.service = service
        self.logger = logger
    }

    public func startService() async -> Result<Void, Error> {
        do {
            try await service.start()
            logger.info("Service started successfully")
            return .success(())
        } catch {
            logger.error("Failed to start service: \(error)")
            return .failure(error)
        }
    }

    public func stopService() async -> Result<Void, Error> {
        do {
            try await service.stop()
            logger.info("Service stopped successfully")
            return .success(())
        } catch {
            logger.error("Failed to stop service: \(error)")
            return .failure(error)
        }
    }

    public func getServiceStatus() async -> ServiceStatus {
        return await service.getStatus()
    }

    public func getServiceMetrics() async -> SystemMetrics {
        return await service.getMetrics()
    }
}
