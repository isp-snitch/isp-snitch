import Foundation
@preconcurrency import SQLite

// MARK: - DataStorage Service Status Extensions
extension DataStorage {

    // MARK: - Service Status

    public func insertServiceStatus(_ status: ServiceStatus) async throws {
        let insert = serviceStatus.insert(
            id <- status.id.uuidString,
            timestamp <- status.timestamp,
            self.status <- status.status,
            uptime <- status.uptime,
            version <- status.version
        )

        try connection.run(insert)
    }

    public func getServiceStatus() async throws -> ServiceStatus? {
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
