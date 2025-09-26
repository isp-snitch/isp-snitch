import Foundation

// MARK: - Report Command
public struct ReportCommand: Command {
    private let dataRepository: DataRepository
    private let timeRange: TimeRange
    private let testType: TestType?
    private let successOnly: Bool

    public init(
        dataRepository: DataRepository,
        timeRange: TimeRange = .last24Hours,
        testType: TestType? = nil,
        successOnly: Bool = false
    ) {
        self.dataRepository = dataRepository
        self.timeRange = timeRange
        self.testType = testType
        self.successOnly = successOnly
    }

    public func execute() async throws -> CommandResult {
        let since = timeRange.startDate
        let records = try await dataRepository.getConnectivityRecords(
            limit: 1000,
            offset: 0,
            testType: testType,
            success: successOnly ? true : nil,
            since: since
        )

        let summary = generateSummary(from: records)

        let data: [String: Any] = [
            "summary": summary,
            "records": records.map { record in
                [
                    "id": record.id.uuidString,
                    "timestamp": record.timestamp,
                    "testType": record.testType.rawValue,
                    "target": record.target,
                    "success": record.success,
                    "latency": record.latency ?? 0.0
                ]
            }
        ]

        return .success("Report generated successfully", data: data)
    }

    private func generateSummary(from records: [ConnectivityRecord]) -> [String: Any] {
        let totalTests = records.count
        let successfulTests = records.filter { $0.success }.count
        let successRate = totalTests > 0 ? Double(successfulTests) / Double(totalTests) : 0.0

        let averageLatency = records.compactMap { $0.latency }.reduce(0.0, +) / Double(records.compactMap { $0.latency }.count)

        return [
            "totalTests": totalTests,
            "successfulTests": successfulTests,
            "successRate": successRate,
            "averageLatency": averageLatency,
            "timeRange": [
                "start": timeRange.startDate,
                "end": timeRange.endDate
            ]
        ]
    }
}
