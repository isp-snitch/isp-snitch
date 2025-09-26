import Foundation

/// Quality breakdown for documentation metrics
///
/// This struct provides a detailed breakdown of quality metrics
/// for documentation assessment and monitoring purposes.
///
/// - Note: This struct is thread-safe and can be used concurrently
/// - Since: 1.0.0
public struct QualityBreakdown: Sendable, Codable {
    /// Number of APIs with excellent documentation
    public let excellent: Int

    /// Number of APIs with good documentation
    public let good: Int

    /// Number of APIs with fair documentation
    public let fair: Int

    /// Number of APIs with poor documentation
    public let poor: Int

    /// Number of APIs with missing documentation
    public let missing: Int

    /// Initializes quality breakdown
    ///
    /// - Parameters:
    ///   - excellent: Number of APIs with excellent documentation
    ///   - good: Number of APIs with good documentation
    ///   - fair: Number of APIs with fair documentation
    ///   - poor: Number of APIs with poor documentation
    ///   - missing: Number of APIs with missing documentation
    public init(excellent: Int, good: Int, fair: Int, poor: Int, missing: Int) {
        self.excellent = excellent
        self.good = good
        self.fair = fair
        self.poor = poor
        self.missing = missing
    }

    /// Total number of APIs
    public var total: Int {
        excellent + good + fair + poor + missing
    }

    /// Quality score (0-100)
    public var qualityScore: Int {
        let total = self.total
        guard total > 0 else { return 0 }

        let weightedScore = (excellent * 100 + good * 80 + fair * 60 + poor * 40 + missing * 0)
        return weightedScore / total
    }

    /// Coverage percentage
    public var coveragePercentage: Double {
        let total = self.total
        guard total > 0 else { return 0.0 }

        let documented = excellent + good + fair + poor
        return Double(documented) / Double(total) * 100.0
    }
}

// MARK: - Extensions

extension QualityBreakdown: Equatable {
    public static func == (lhs: QualityBreakdown, rhs: QualityBreakdown) -> Bool {
        lhs.excellent == rhs.excellent &&
        lhs.good == rhs.good &&
        lhs.fair == rhs.fair &&
        lhs.poor == rhs.poor &&
        lhs.missing == rhs.missing
    }
}

extension QualityBreakdown: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(excellent)
        hasher.combine(good)
        hasher.combine(fair)
        hasher.combine(poor)
        hasher.combine(missing)
    }
}
