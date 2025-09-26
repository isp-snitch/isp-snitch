import Foundation
@preconcurrency import SQLite

// MARK: - System Metrics Repository
public class SystemMetricsRepository {
    private let connection: Connection

    public init(connection: Connection) {
        self.connection = connection
    }

    public func insert(_ metrics: SystemMetrics) throws {
        let insert = TableDefinitions.systemMetrics.insert(
            SystemMetricsColumns.id <- metrics.id.uuidString,
            SystemMetricsColumns.timestamp <- metrics.timestamp,
            SystemMetricsColumns.cpuUsage <- metrics.cpuUsage,
            SystemMetricsColumns.memoryUsage <- metrics.memoryUsage,
            SystemMetricsColumns.diskUsage <- metrics.diskUsage,
            SystemMetricsColumns.networkBytesIn <- metrics.networkBytesIn,
            SystemMetricsColumns.networkBytesOut <- metrics.networkBytesOut
        )

        try connection.run(insert)
    }

    public func getMetrics(
        limit: Int = 100,
        since: Date? = nil
    ) throws -> [SystemMetrics] {
        var query = TableDefinitions.systemMetrics.select(*)

        if let since = since {
            query = query.filter(SystemMetricsColumns.timestamp >= since)
        }

        query = query.order(SystemMetricsColumns.timestamp.desc).limit(limit)

        var metrics: [SystemMetrics] = []

        for row in try connection.prepare(query) {
            // Safe UUID parsing
            guard let id = UUID(uuidString: row[SystemMetricsColumns.id]) else {
                throw RepositoryError.invalidData("Invalid UUID in system metrics")
            }

            let metric = SystemMetrics(
                id: id,
                timestamp: row[SystemMetricsColumns.timestamp],
                cpuUsage: row[SystemMetricsColumns.cpuUsage],
                memoryUsage: row[SystemMetricsColumns.memoryUsage],
                diskUsage: row[SystemMetricsColumns.diskUsage],
                networkBytesIn: row[SystemMetricsColumns.networkBytesIn],
                networkBytesOut: row[SystemMetricsColumns.networkBytesOut]
            )

            metrics.append(metric)
        }

        return metrics
    }
}
