import Foundation

/// Service state enumeration
public enum ServiceState: String, CaseIterable, Sendable {
    case stopped
    case starting
    case running
    case stopping
    case error
}
