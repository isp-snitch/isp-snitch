import Foundation
@preconcurrency import SQLite

// MARK: - DataStorage System Metrics Extensions
extension DataStorage {

    // MARK: - System Metrics

    public func insertSystemMetrics(_ metrics: SystemMetrics) async throws {
        let insert = systemMetrics.insert(
            id <- metrics.id.uuidString,
            timestamp <- metrics.timestamp,
            cpuUsage <- metrics.cpuUsage,
            memoryUsage <- metrics.memoryUsage,
            diskUsage <- metrics.diskUsage,
            networkBytesIn <- metrics.networkBytesIn,
            networkBytesOut <- metrics.networkBytesOut
        )

        try connection.run(insert)
    }

    public func getSystemMetrics(
        limit: Int = 100,
        since: Date? = nil
    ) async throws -> [SystemMetrics] {
        var query = systemMetrics.select(*)

        if let since = since {
            query = query.filter(timestamp >= since)
        }

        query = query.order(timestamp.desc).limit(limit)

        return try await decodeSystemMetrics(from: query)
    }

    private func decodeSystemMetrics(from query: QueryType) async throws -> [SystemMetrics] {
        var metrics: [SystemMetrics] = []

        for row in try connection.prepare(query) {
            let metric = SystemMetrics(
                id: UUID(uuidString: row[id])!,
                timestamp: row[timestamp],
                cpuUsage: row[cpuUsage],
                memoryUsage: row[memoryUsage],
                diskUsage: row[diskUsage],
                networkBytesIn: row[networkBytesIn],
                networkBytesOut: row[networkBytesOut]
            )

            metrics.append(metric)
        }

        return metrics
    }
}
