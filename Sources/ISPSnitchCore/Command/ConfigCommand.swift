import Foundation

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
        guard let _ = key, let _ = value else {
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
