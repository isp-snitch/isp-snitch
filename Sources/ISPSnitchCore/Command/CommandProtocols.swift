import Foundation

// MARK: - Command Pattern Protocols
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
