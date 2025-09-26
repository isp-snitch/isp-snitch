import Foundation
@preconcurrency import SQLite

// MARK: - Service Status Repository
public actor ServiceStatusRepository {
    private let connection: Connection

    public init(connection: Connection) {
        self.connection = connection
    }

    public func insert(_ status: ServiceStatus) async throws {
        let insert = TableDefinitions.serviceStatus.insert(
            ServiceStatusColumns.id <- status.id.uuidString,
            ServiceStatusColumns.timestamp <- status.timestamp,
            ServiceStatusColumns.status <- status.status,
            ServiceStatusColumns.uptime <- status.uptime,
            ServiceStatusColumns.version <- status.version
        )

        try connection.run(insert)
    }

    public func getLatest() async throws -> ServiceStatus? {
        guard let row = try connection.pluck(TableDefinitions.serviceStatus.select(*).order(ServiceStatusColumns.timestamp.desc)) else {
            return nil
        }

        // Safe UUID parsing
        guard let id = UUID(uuidString: row[ServiceStatusColumns.id]) else {
            throw RepositoryError.invalidData("Invalid UUID in service status")
        }

        return ServiceStatus(
            id: id,
            timestamp: row[ServiceStatusColumns.timestamp],
            status: row[ServiceStatusColumns.status],
            uptime: row[ServiceStatusColumns.uptime],
            version: row[ServiceStatusColumns.version]
        )
    }
}
