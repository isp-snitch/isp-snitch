import Foundation
@preconcurrency import SQLite

// MARK: - SQLite Data Repository System Metrics Extensions
extension SQLiteDataRepository {

    public func insertSystemMetrics(_ metrics: SystemMetrics) async throws {
        let systemMetrics = Table("system_metrics")
        let id = Expression<String>("id")
        let timestamp = Expression<Date>("timestamp")
        let cpuUsage = Expression<Double>("cpu_usage")
        let memoryUsage = Expression<Double>("memory_usage")
        let diskUsage = Expression<Double>("disk_usage")
        let networkBytesIn = Expression<Int64>("network_bytes_in")
        let networkBytesOut = Expression<Int64>("network_bytes_out")

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
        let systemMetrics = Table("system_metrics")
        let id = Expression<String>("id")
        let timestamp = Expression<Date>("timestamp")
        let cpuUsage = Expression<Double>("cpu_usage")
        let memoryUsage = Expression<Double>("memory_usage")
        let diskUsage = Expression<Double>("disk_usage")
        let networkBytesIn = Expression<Int64>("network_bytes_in")
        let networkBytesOut = Expression<Int64>("network_bytes_out")

        var query = systemMetrics.select(*)

        if let since = since {
            query = query.filter(timestamp >= since)
        }

        query = query.order(timestamp.desc).limit(limit)

        return try await decodeSystemMetrics(from: query)
    }

    private func decodeSystemMetrics(from query: QueryType) async throws -> [SystemMetrics] {
        let id = Expression<String>("id")
        let timestamp = Expression<Date>("timestamp")
        let cpuUsage = Expression<Double>("cpu_usage")
        let memoryUsage = Expression<Double>("memory_usage")
        let diskUsage = Expression<Double>("disk_usage")
        let networkBytesIn = Expression<Int64>("network_bytes_in")
        let networkBytesOut = Expression<Int64>("network_bytes_out")

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
