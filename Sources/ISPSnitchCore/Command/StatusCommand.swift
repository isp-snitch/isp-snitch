import Foundation

// MARK: - Status Command
public struct StatusCommand: Command {
    private let serviceManager: ServiceManager

    public init(serviceManager: ServiceManager) {
        self.serviceManager = serviceManager
    }

    public func execute() async throws -> CommandResult {
        let status = await serviceManager.getServiceStatus()
        let metrics = await serviceManager.getServiceMetrics()

        let data: [String: Any] = [
            "status": status.status,
            "uptime": status.uptime,
            "version": status.version,
            "timestamp": status.timestamp,
            "metrics": [
                "cpuUsage": metrics.cpuUsage,
                "memoryUsage": metrics.memoryUsage,
                "diskUsage": metrics.diskUsage
            ]
        ]

        return .success("Service status retrieved successfully", data: data)
    }
}
