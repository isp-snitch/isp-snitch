import Foundation

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
