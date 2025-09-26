import Foundation

/// Documentation quality levels
///
/// This enumeration represents different levels of documentation quality
/// for assessment and monitoring purposes.
///
/// - Note: This enum is thread-safe and can be used concurrently
/// - Since: 1.0.0
public enum DocumentationQuality: String, Sendable, Codable, CaseIterable {
    case excellent
    case good
    case fair
    case poor
    case missing

    /// Quality score for this level
    public var score: Int {
        switch self {
        case .excellent: return 100
        case .good: return 80
        case .fair: return 60
        case .poor: return 40
        case .missing: return 0
        }
    }

    /// Description of the quality level
    public var description: String {
        switch self {
        case .excellent: return "Excellent documentation quality"
        case .good: return "Good documentation quality"
        case .fair: return "Fair documentation quality"
        case .poor: return "Poor documentation quality"
        case .missing: return "Missing documentation"
        }
    }
}
