import Foundation

/// Performance metrics for documentation generation
///
/// This model represents performance metrics collected during documentation
/// generation and validation processes.
///
/// - Note: This model is thread-safe and can be used concurrently
/// - Since: 1.0.0
public struct DocumentationPerformanceMetrics: Sendable, Codable {

    // MARK: - Properties

    /// Time taken to generate documentation in seconds
    public let generationTime: TimeInterval

    /// Memory usage during generation in MB
    public let memoryUsage: Int

    /// CPU usage during generation as percentage
    public let cpuUsage: Double

    /// Number of files processed
    public let fileCount: Int

    /// Number of APIs processed
    public let apiCount: Int

    /// Size of generated output in MB
    public let outputSize: Int

    /// Timestamp when metrics were collected
    public let timestamp: Date

    // MARK: - Initialization

    /// Initializes performance metrics
    ///
    /// - Parameters:
    ///   - generationTime: Time taken to generate documentation
    ///   - memoryUsage: Memory usage in MB
    ///   - cpuUsage: CPU usage percentage
    ///   - fileCount: Number of files processed
    ///   - apiCount: Number of APIs processed
    ///   - outputSize: Output size in MB
    ///   - timestamp: Collection timestamp
    ///
    /// Example:
    /// ```swift
    /// let metrics = DocumentationPerformanceMetrics(
    ///     generationTime: 2.5,
    ///     memoryUsage: 45,
    ///     cpuUsage: 25.0,
    ///     fileCount: 50,
    ///     apiCount: 200,
    ///     outputSize: 5,
    ///     timestamp: Date()
    /// )
    /// ```
    public init(
        generationTime: TimeInterval,
        memoryUsage: Int,
        cpuUsage: Double,
        fileCount: Int,
        apiCount: Int,
        outputSize: Int,
        timestamp: Date = Date()
    ) {
        self.generationTime = generationTime
        self.memoryUsage = memoryUsage
        self.cpuUsage = cpuUsage
        self.fileCount = fileCount
        self.apiCount = apiCount
        self.outputSize = outputSize
        self.timestamp = timestamp
    }

    // MARK: - Computed Properties

    /// Whether performance is within acceptable limits
    public var isAcceptable: Bool {
        generationTime <= 30.0 && memoryUsage <= 100 && cpuUsage <= 50.0
    }

    /// Performance status description
    public var status: String {
        if isAcceptable {
            return "✅ Performance within limits"
        } else {
            return "⚠️ Performance exceeds limits"
        }
    }

    /// Summary of performance metrics
    public var summary: String {
        """
        Performance Metrics:
        - Generation Time: \(String(format: "%.1f", generationTime))s
        - Memory Usage: \(memoryUsage)MB
        - CPU Usage: \(String(format: "%.1f", cpuUsage))%
        - Files Processed: \(fileCount)
        - APIs Processed: \(apiCount)
        - Output Size: \(outputSize)MB
        - Status: \(status)
        """
    }
}

// MARK: - Extensions

extension DocumentationPerformanceMetrics: Equatable {
    public static func == (lhs: DocumentationPerformanceMetrics, rhs: DocumentationPerformanceMetrics) -> Bool {
        lhs.generationTime == rhs.generationTime &&
        lhs.memoryUsage == rhs.memoryUsage &&
        lhs.cpuUsage == rhs.cpuUsage &&
        lhs.fileCount == rhs.fileCount &&
        lhs.apiCount == rhs.apiCount &&
        lhs.outputSize == rhs.outputSize
    }
}

extension DocumentationPerformanceMetrics: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(generationTime)
        hasher.combine(memoryUsage)
        hasher.combine(cpuUsage)
        hasher.combine(fileCount)
        hasher.combine(apiCount)
        hasher.combine(outputSize)
    }
}
