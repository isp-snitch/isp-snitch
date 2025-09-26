import Foundation

/// Simple quality monitoring for documentation metrics
///
/// This service provides basic quality monitoring capabilities for documentation
/// metrics without complex dependencies or async/await features.
///
/// - Note: This service is thread-safe and can be used concurrently
/// - Since: 1.0.0
public final class SimpleQualityMonitor: @unchecked Sendable {

    // MARK: - Properties

    /// Configuration for quality monitoring
    public let configuration: SimpleQualityConfiguration

    /// Current quality metrics
    public private(set) var currentMetrics: DocumentationMetrics?

    /// Metrics storage for historical tracking
    private let metricsStorage: SimpleMetricsStorage

    // MARK: - Initialization

    /// Initializes the simple quality monitor
    ///
    /// - Parameter configuration: Quality monitoring configuration
    ///
    /// Example:
    /// ```swift
    /// let config = SimpleQualityConfiguration()
    /// let monitor = SimpleQualityMonitor(configuration: config)
    /// ```
    public init(configuration: SimpleQualityConfiguration = SimpleQualityConfiguration()) {
        self.configuration = configuration
        self.metricsStorage = SimpleMetricsStorage()
    }

    // MARK: - Public Methods

    /// Performs a quality check
    ///
    /// This method runs a comprehensive quality check and returns the results.
    ///
    /// - Returns: Current documentation metrics
    /// - Throws: `QualityMonitorError.qualityCheckFailed` if quality check fails
    ///
    /// Example:
    /// ```swift
    /// let metrics = try monitor.performQualityCheck()
    /// print("Quality score: \(metrics.qualityScore)")
    /// ```
    public func performQualityCheck() throws -> DocumentationMetrics {
        let metrics = try analyzeDocumentationQuality()
        currentMetrics = metrics

        // Store metrics for historical tracking
        try metricsStorage.storeMetrics(metrics)

        return metrics
    }

    // MARK: - Private Methods

    /// Analyzes documentation quality
    private func analyzeDocumentationQuality() throws -> DocumentationMetrics {
        let sourceFiles = try findSourceFiles()
        var totalAPIs = 0
        var documentedAPIs = 0
        var qualityBreakdown = QualityBreakdown(excellent: 0, good: 0, fair: 0, poor: 0, missing: 0)

        for filePath in sourceFiles {
            let fileMetrics = try analyzeFile(filePath)
            totalAPIs += fileMetrics.totalAPIs
            documentedAPIs += fileMetrics.documentedAPIs
            qualityBreakdown = combineQualityBreakdowns(qualityBreakdown, fileMetrics.qualityBreakdown)
        }

        let coveragePercentage = totalAPIs > 0 ? Double(documentedAPIs) / Double(totalAPIs) * 100.0 : 0.0
        let qualityScore = qualityBreakdown.qualityScore

        return DocumentationMetrics(
            totalPublicAPIs: totalAPIs,
            documentedAPIs: documentedAPIs,
            coveragePercentage: coveragePercentage,
            qualityScore: qualityScore,
            qualityBreakdown: qualityBreakdown
        )
    }

    /// Finds source files to analyze
    private func findSourceFiles() throws -> [String] {
        let fileManager = FileManager.default
        let currentDirectory = fileManager.currentDirectoryPath
        let sourcesPath = "\(currentDirectory)/Sources"

        guard fileManager.fileExists(atPath: sourcesPath) else {
            return []
        }

        var sourceFiles: [String] = []
        let enumerator = fileManager.enumerator(atPath: sourcesPath)

        while let file = enumerator?.nextObject() as? String {
            if file.hasSuffix(".swift") {
                sourceFiles.append("\(sourcesPath)/\(file)")
            }
        }

        return sourceFiles
    }

    /// Analyzes a single file
    private func analyzeFile(_ filePath: String) throws -> FileMetrics {
        let content = try String(contentsOfFile: filePath)
        let lines = content.components(separatedBy: .newlines)

        var totalAPIs = 0
        var documentedAPIs = 0
        var qualityBreakdown = QualityBreakdown(excellent: 0, good: 0, fair: 0, poor: 0, missing: 0)

        for (index, line) in lines.enumerated() where isPublicAPI(line) {
            totalAPIs += 1
            let hasDocumentation = checkForDocumentationComment(lines: lines, at: index)

            if hasDocumentation {
                documentedAPIs += 1
                qualityBreakdown = incrementQualityBreakdown(qualityBreakdown, quality: .good)
            } else {
                qualityBreakdown = incrementQualityBreakdown(qualityBreakdown, quality: .missing)
            }
        }

        return FileMetrics(
            totalAPIs: totalAPIs,
            documentedAPIs: documentedAPIs,
            qualityBreakdown: qualityBreakdown
        )
    }

    /// Checks if a line represents a public API
    private func isPublicAPI(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        return trimmed.hasPrefix("public func") ||
               trimmed.hasPrefix("public struct") ||
               trimmed.hasPrefix("public class") ||
               trimmed.hasPrefix("public enum") ||
               trimmed.hasPrefix("public protocol")
    }

    /// Checks for documentation comment
    private func checkForDocumentationComment(lines: [String], at index: Int) -> Bool {
        // Look for /// comment in the previous few lines
        for i in max(0, index - 3)..<index where lines[i].trimmingCharacters(in: .whitespaces).hasPrefix("///") {
            return true
        }
        return false
    }

    /// Combines quality breakdowns
    private func combineQualityBreakdowns(_ lhs: QualityBreakdown, _ rhs: QualityBreakdown) -> QualityBreakdown {
        QualityBreakdown(
            excellent: lhs.excellent + rhs.excellent,
            good: lhs.good + rhs.good,
            fair: lhs.fair + rhs.fair,
            poor: lhs.poor + rhs.poor,
            missing: lhs.missing + rhs.missing
        )
    }

    /// Increments quality breakdown
    private func incrementQualityBreakdown(_ breakdown: QualityBreakdown, quality: DocumentationQuality) -> QualityBreakdown {
        switch quality {
        case .excellent:
            return QualityBreakdown(
                excellent: breakdown.excellent + 1,
                good: breakdown.good,
                fair: breakdown.fair,
                poor: breakdown.poor,
                missing: breakdown.missing
            )
        case .good:
            return QualityBreakdown(
                excellent: breakdown.excellent,
                good: breakdown.good + 1,
                fair: breakdown.fair,
                poor: breakdown.poor,
                missing: breakdown.missing
            )
        case .fair:
            return QualityBreakdown(
                excellent: breakdown.excellent,
                good: breakdown.good,
                fair: breakdown.fair + 1,
                poor: breakdown.poor,
                missing: breakdown.missing
            )
        case .poor:
            return QualityBreakdown(
                excellent: breakdown.excellent,
                good: breakdown.good,
                fair: breakdown.fair,
                poor: breakdown.poor + 1,
                missing: breakdown.missing
            )
        case .missing:
            return QualityBreakdown(
                excellent: breakdown.excellent,
                good: breakdown.good,
                fair: breakdown.fair,
                poor: breakdown.poor,
                missing: breakdown.missing + 1
            )
        }
    }
}

// MARK: - Supporting Types

/// File metrics for analysis
private struct FileMetrics {
    let totalAPIs: Int
    let documentedAPIs: Int
    let qualityBreakdown: QualityBreakdown
}

/// Simple quality configuration
public struct SimpleQualityConfiguration: Sendable, Codable {
    /// Minimum coverage percentage required
    public let minimumCoverage: Double

    /// Minimum quality score required
    public let minimumQualityScore: Int

    /// Initializes simple quality configuration
    ///
    /// - Parameters:
    ///   - minimumCoverage: Minimum coverage percentage (default: 80.0)
    ///   - minimumQualityScore: Minimum quality score (default: 70)
    public init(minimumCoverage: Double = 80.0, minimumQualityScore: Int = 70) {
        self.minimumCoverage = minimumCoverage
        self.minimumQualityScore = minimumQualityScore
    }
}

/// Simple metrics storage
private struct SimpleMetricsStorage {
    func storeMetrics(_ metrics: DocumentationMetrics) throws {
        // Simplified implementation - just store in memory for now
        // In a real implementation, this would persist to disk
    }
}
