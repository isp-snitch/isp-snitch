import Foundation

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
