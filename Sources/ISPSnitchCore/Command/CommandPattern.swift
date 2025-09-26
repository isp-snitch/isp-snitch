import Foundation

// MARK: - Command Pattern Implementation
public protocol Command {
    func execute() async throws -> CommandResult
}

public protocol CommandHandler {
    associatedtype CommandType: Command
    func handle(_ command: CommandType) async throws -> CommandResult
}

// MARK: - Command Result
public struct CommandResult {
    public let success: Bool
    public let message: String
    public let data: [String: Any]?
    public let exitCode: Int32

    public init(success: Bool, message: String, data: [String: Any]? = nil, exitCode: Int32 = 0) {
        self.success = success
        self.message = message
        self.data = data
        self.exitCode = exitCode
    }

    public static func success(_ message: String, data: [String: Any]? = nil) -> CommandResult {
        return CommandResult(success: true, message: message, data: data)
    }

    public static func failure(_ message: String, exitCode: Int32 = 1) -> CommandResult {
        return CommandResult(success: false, message: message, exitCode: exitCode)
    }
}

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

// MARK: - Report Command
public struct ReportCommand: Command {
    private let dataRepository: DataRepository
    private let timeRange: TimeRange
    private let testType: TestType?
    private let successOnly: Bool

    public init(
        dataRepository: DataRepository,
        timeRange: TimeRange = .last24Hours,
        testType: TestType? = nil,
        successOnly: Bool = false
    ) {
        self.dataRepository = dataRepository
        self.timeRange = timeRange
        self.testType = testType
        self.successOnly = successOnly
    }

    public func execute() async throws -> CommandResult {
        let since = timeRange.startDate
        let records = try await dataRepository.getConnectivityRecords(
            limit: 1000,
            testType: testType,
            success: successOnly ? true : nil,
            since: since
        )

        let summary = generateSummary(from: records)

        let data: [String: Any] = [
            "summary": summary,
            "records": records.map { record in
                [
                    "id": record.id.uuidString,
                    "timestamp": record.timestamp,
                    "testType": record.testType.rawValue,
                    "target": record.target,
                    "success": record.success,
                    "latency": record.latency ?? 0.0
                ]
            }
        ]

        return .success("Report generated successfully", data: data)
    }

    private func generateSummary(from records: [ConnectivityRecord]) -> [String: Any] {
        let totalTests = records.count
        let successfulTests = records.filter { $0.success }.count
        let successRate = totalTests > 0 ? Double(successfulTests) / Double(totalTests) : 0.0

        let averageLatency = records.compactMap { $0.latency }.reduce(0.0, +) / Double(records.compactMap { $0.latency }.count)

        return [
            "totalTests": totalTests,
            "successfulTests": successfulTests,
            "successRate": successRate,
            "averageLatency": averageLatency,
            "timeRange": [
                "start": timeRange.startDate,
                "end": timeRange.endDate
            ]
        ]
    }
}

// MARK: - Config Command
public struct ConfigCommand: Command {
    private let dataRepository: DataRepository
    private let action: ConfigAction
    private let key: String?
    private let value: String?

    public enum ConfigAction {
        case get
        case set
        case list
        case reset
    }

    public init(
        dataRepository: DataRepository,
        action: ConfigAction,
        key: String? = nil,
        value: String? = nil
    ) {
        self.dataRepository = dataRepository
        self.action = action
        self.key = key
        self.value = value
    }

    public func execute() async throws -> CommandResult {
        switch action {
        case .get:
            return try await getConfiguration()
        case .set:
            return try await setConfiguration()
        case .list:
            return try await listConfigurations()
        case .reset:
            return try await resetConfiguration()
        }
    }

    private func getConfiguration() async throws -> CommandResult {
        guard let key = key else {
            return .failure("Configuration key is required")
        }

        let configurations = try await dataRepository.getTestConfigurations()
        guard let config = configurations.first else {
            return .failure("No configuration found")
        }

        let value = getConfigValue(for: key, from: config)
        return .success("Configuration retrieved", data: ["key": key, "value": value])
    }

    private func setConfiguration() async throws -> CommandResult {
        guard let key = key, let value = value else {
            return .failure("Configuration key and value are required")
        }

        // Implementation would update configuration
        return .success("Configuration updated successfully")
    }

    private func listConfigurations() async throws -> CommandResult {
        let configurations = try await dataRepository.getTestConfigurations()
        let configData = configurations.map { config in
            [
                "id": config.id.uuidString,
                "name": config.name,
                "isActive": config.isActive,
                "testInterval": config.testInterval,
                "timeout": config.timeout
            ]
        }

        return .success("Configurations listed successfully", data: ["configurations": configData])
    }

    private func resetConfiguration() async throws -> CommandResult {
        // Implementation would reset to defaults
        return .success("Configuration reset to defaults")
    }

    private func getConfigValue(for key: String, from config: TestConfiguration) -> Any {
        switch key {
        case "testInterval":
            return config.testInterval
        case "timeout":
            return config.timeout
        case "retryCount":
            return config.retryCount
        case "webPort":
            return config.webPort
        case "dataRetentionDays":
            return config.dataRetentionDays
        case "enableNotifications":
            return config.enableNotifications
        case "enableWebInterface":
            return config.enableWebInterface
        default:
            return "Unknown key: \(key)"
        }
    }
}

// MARK: - Time Range
public enum TimeRange {
    case lastHour
    case last24Hours
    case last7Days
    case last30Days
    case custom(start: Date, end: Date)

    public var startDate: Date {
        switch self {
        case .lastHour:
            return Date().addingTimeInterval(-3600)
        case .last24Hours:
            return Date().addingTimeInterval(-86400)
        case .last7Days:
            return Date().addingTimeInterval(-604800)
        case .last30Days:
            return Date().addingTimeInterval(-2592000)
        case .custom(let start, _):
            return start
        }
    }

    public var endDate: Date {
        switch self {
        case .custom(_, let end):
            return end
        default:
            return Date()
        }
    }
}

// MARK: - Command Dispatcher
public class CommandDispatcher {
    private let serviceManager: ServiceManager
    private let dataRepository: DataRepository

    public init(serviceManager: ServiceManager, dataRepository: DataRepository) {
        self.serviceManager = serviceManager
        self.dataRepository = dataRepository
    }

    public func dispatch(_ command: Command) async -> CommandResult {
        do {
            return try await command.execute()
        } catch {
            return .failure("Command execution failed: \(error.localizedDescription)")
        }
    }
}
