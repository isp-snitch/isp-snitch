import Foundation
@preconcurrency import SQLite

// MARK: - SQLite Data Repository Service Status Extensions
extension SQLiteDataRepository {

    public func insertServiceStatus(_ status: ServiceStatus) async throws {
        let serviceStatus = Table("service_status")
        let id = Expression<String>("id")
        let timestamp = Expression<Date>("timestamp")
        let statusExpr = Expression<String>("status")
        let uptime = Expression<Double>("uptime")
        let version = Expression<String>("version")

        let insert = serviceStatus.insert(
            id <- status.id.uuidString,
            timestamp <- status.timestamp,
            statusExpr <- status.status,
            uptime <- status.uptime,
            version <- status.version
        )

        try connection.run(insert)
    }

    public func getServiceStatus() async throws -> ServiceStatus? {
        let serviceStatus = Table("service_status")
        let id = Expression<String>("id")
        let timestamp = Expression<Date>("timestamp")
        let status = Expression<String>("status")
        let uptime = Expression<Double>("uptime")
        let version = Expression<String>("version")

        guard let row = try connection.pluck(serviceStatus.select(*).order(timestamp.desc)) else {
            return nil
        }

        return ServiceStatus(
            id: UUID(uuidString: row[id])!,
            timestamp: row[timestamp],
            status: row[status],
            uptime: row[uptime],
            version: row[version]
        )
    }
}
