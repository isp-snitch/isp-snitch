import Foundation

/// Documentation metrics for quality assessment
///
/// This struct provides comprehensive metrics for documentation
/// quality assessment and monitoring purposes.
///
/// - Note: This struct is thread-safe and can be used concurrently
/// - Since: 1.0.0
public struct DocumentationMetrics: Sendable, Codable {
    /// Total number of public APIs
    public let totalPublicAPIs: Int

    /// Number of documented APIs
    public let documentedAPIs: Int

    /// Coverage percentage
    public let coveragePercentage: Double

    /// Quality score (0-100)
    public let qualityScore: Int

    /// Quality breakdown by category
    public let qualityBreakdown: QualityBreakdown

    /// Timestamp of the metrics
    public let timestamp: Date

    /// Initializes documentation metrics
    ///
    /// - Parameters:
    ///   - totalPublicAPIs: Total number of public APIs
    ///   - documentedAPIs: Number of documented APIs
    ///   - coveragePercentage: Coverage percentage
    ///   - qualityScore: Quality score (0-100)
    ///   - qualityBreakdown: Quality breakdown by category
    ///   - timestamp: Timestamp of the metrics
    public init(
        totalPublicAPIs: Int,
        documentedAPIs: Int,
        coveragePercentage: Double,
        qualityScore: Int,
        qualityBreakdown: QualityBreakdown,
        timestamp: Date = Date()
    ) {
        self.totalPublicAPIs = totalPublicAPIs
        self.documentedAPIs = documentedAPIs
        self.coveragePercentage = coveragePercentage
        self.qualityScore = qualityScore
        self.qualityBreakdown = qualityBreakdown
        self.timestamp = timestamp
    }

    /// Whether the quality meets standards
    public var meetsStandards: Bool {
        coveragePercentage >= 80.0 && qualityScore >= 70
    }

    /// Quality status description
    public var status: String {
        if meetsStandards {
            return "✅ Quality standards met"
        } else {
            return "⚠️ Quality standards not met"
        }
    }

    /// Summary of metrics
    public var summary: String {
        """
        Documentation Metrics:
        - Total APIs: \(totalPublicAPIs)
        - Documented: \(documentedAPIs)
        - Coverage: \(String(format: "%.1f", coveragePercentage))%
        - Quality Score: \(qualityScore)
        - Status: \(status)
        """
    }
}

// MARK: - Extensions

extension DocumentationMetrics: Equatable {
    public static func == (lhs: DocumentationMetrics, rhs: DocumentationMetrics) -> Bool {
        lhs.totalPublicAPIs == rhs.totalPublicAPIs &&
        lhs.documentedAPIs == rhs.documentedAPIs &&
        lhs.coveragePercentage == rhs.coveragePercentage &&
        lhs.qualityScore == rhs.qualityScore &&
        lhs.qualityBreakdown == rhs.qualityBreakdown
    }
}

extension DocumentationMetrics: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(totalPublicAPIs)
        hasher.combine(documentedAPIs)
        hasher.combine(coveragePercentage)
        hasher.combine(qualityScore)
        hasher.combine(qualityBreakdown)
    }
}
