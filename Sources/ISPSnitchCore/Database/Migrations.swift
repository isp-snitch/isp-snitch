import Foundation
@preconcurrency import SQLite

// MARK: - Migration System
public struct Migrations {
    private static let migrations = Table("migrations")
    private static let migrationVersion = Expression<Int>(value: "version")
    private static let migrationName = Expression<String>(value: "name")
    private static let migrationTimestamp = Expression<Date>(value: "timestamp")

    public static func runMigrations(on connection: Connection) throws {
        try createMigrationsTable(on: connection)
        let currentVersion = try getCurrentVersion(on: connection)

        // List of all migrations in order
        let allMigrations: [(Int, String, (Connection) throws -> Void)] = [
            (1, "Initial schema", migration001_InitialSchema),
            (2, "Add indexes", migration002_AddIndexes),
            (3, "Add service status table", migration003_AddServiceStatusTable)
        ]

        // Run migrations that haven't been applied yet
        for (version, name, migration) in allMigrations where version > currentVersion {
            try migration(connection)
            try recordMigration(on: connection, version: version, name: name)
            print("Applied migration \(version): \(name)")
        }
    }

    private static func createMigrationsTable(on connection: Connection) throws {
        try connection.run(migrations.create(ifNotExists: true) { table in
            table.column(migrationVersion, primaryKey: true)
            table.column(migrationName)
            table.column(migrationTimestamp)
        })
    }

    private static func getCurrentVersion(on connection: Connection) throws -> Int {
        guard let row = try connection.pluck(migrations.select(migrationVersion.max)) else {
            return 0
        }

        return row[migrationVersion.max] ?? 0
    }

    private static func recordMigration(on connection: Connection, version: Int, name: String) throws {
        let insert = migrations.insert(
            migrationVersion <- version,
            migrationName <- name,
            migrationTimestamp <- Date()
        )

        try connection.run(insert)
    }

    // MARK: - Individual Migrations

    private static func migration001_InitialSchema(_ connection: Connection) throws {
        // This migration is handled by the DataStorage.createTables() method
        // We just record it as applied
    }

    private static func migration002_AddIndexes(_ connection: Connection) throws {
        // Additional indexes for performance
        let connectivityRecords = Table("connectivity_records")
        let systemMetrics = Table("system_metrics")

        let timestamp = Expression<Date>(value: "timestamp")
        let testType = Expression<String>(value: "test_type")
        let success = Expression<Bool>(value: "success")
        let networkInterface = Expression<String>(value: "network_interface")

        // Add composite indexes for common queries
        try connection.execute("CREATE INDEX IF NOT EXISTS idx_connectivity_test_type_timestamp ON connectivity_records(test_type, timestamp)")
        try connection.execute("CREATE INDEX IF NOT EXISTS idx_connectivity_success_timestamp ON connectivity_records(success, timestamp)")
        try connection.execute("CREATE INDEX IF NOT EXISTS idx_connectivity_interface_timestamp ON connectivity_records(network_interface, timestamp)")

        // Add index for system metrics timestamp queries
        try connection.execute("CREATE INDEX IF NOT EXISTS idx_system_metrics_timestamp ON system_metrics(timestamp)")
    }

    private static func migration003_AddServiceStatusTable(_ connection: Connection) throws {
        let serviceStatus = Table("service_status")

        let id = Expression<String>(value: "id")
        let timestamp = Expression<Date>(value: "timestamp")
        let status = Expression<String>(value: "status")
        let uptime = Expression<Double>(value: "uptime")
        let version = Expression<String>(value: "version")

        try connection.run(serviceStatus.create(ifNotExists: true) { table in
            table.column(id, primaryKey: true)
            table.column(timestamp)
            table.column(status)
            table.column(uptime)
            table.column(version)
        })

        // Add index for timestamp queries
        try connection.execute("CREATE INDEX IF NOT EXISTS idx_service_status_timestamp ON service_status(timestamp)")
    }
}
