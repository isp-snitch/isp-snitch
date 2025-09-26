import Foundation

// MARK: - Network Monitor Error
public enum NetworkMonitorError: Error, Sendable {
    case notRunning
    case testTooSoon
    case testFailed(Error)
    case invalidTarget(String)
    case timeout(String)

    public var localizedDescription: String {
        switch self {
        case .notRunning:
            return "Network monitor is not running"
        case .testTooSoon:
            return "Test cannot be performed yet - minimum interval not reached"
        case .testFailed(let error):
            return "Test failed: \(error.localizedDescription)"
        case .invalidTarget(let target):
            return "Invalid target: \(target)"
        case .timeout(let message):
            return "Test timed out: \(message)"
        }
    }
}
