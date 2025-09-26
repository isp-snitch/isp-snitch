@preconcurrency import Foundation
@preconcurrency import SQLite

// MARK: - Database Manager
public class DatabaseManager {
    private let connection: Connection
    private let dataStorage: DataStorage
    private let retentionManager: DataRetentionManager

    public init(databasePath: String = ":memory:") throws {
        self.connection = try Connection(databasePath)
        self.dataStorage = try DataStorage(connection: connection)
        self.retentionManager = DataRetentionManager(connection: connection)

        try setupDatabase()
    }

    private func setupDatabase() throws {
        // Create tables if they don't exist
        try dataStorage.createTables()

        // Run migrations if needed
        try Migrations.runMigrations(on: connection)
    }

    // MARK: - Public Interface

    public func insertConnectivityRecord(_ record: ConnectivityRecord) throws {
        try dataStorage.insertConnectivityRecord(record)
    }

    public func getConnectivityRecords(
        limit: Int = 100,
        offset: Int = 0,
        testType: TestType? = nil,
        success: Bool? = nil,
        since: Date? = nil
    ) throws -> [ConnectivityRecord] {
        try dataStorage.getConnectivityRecords(
            limit: limit,
            offset: offset,
            testType: testType,
            success: success,
            since: since
        )
    }

    public func insertTestConfiguration(_ configuration: TestConfiguration) throws {
        try dataStorage.insertTestConfiguration(configuration)
    }

    public func getTestConfigurations() throws -> [TestConfiguration] {
        try dataStorage.getTestConfigurations()
    }

    public func insertSystemMetrics(_ metrics: SystemMetrics) throws {
        try dataStorage.insertSystemMetrics(metrics)
    }

    public func getSystemMetrics(
        limit: Int = 100,
        since: Date? = nil
    ) throws -> [SystemMetrics] {
        try dataStorage.getSystemMetrics(limit: limit, since: since)
    }

    public func insertServiceStatus(_ status: ServiceStatus) throws {
        try dataStorage.insertServiceStatus(status)
    }

    public func getServiceStatus() throws -> ServiceStatus? {
        try dataStorage.getServiceStatus()
    }

    public func cleanup() throws {
        try retentionManager.cleanupOldData()
    }

    public func close() throws {
        // SQLite.swift Connection doesn't need explicit closing
        // The connection will be closed when the object is deallocated
    }
}

// MARK: - System Metrics
public struct SystemMetrics: Sendable, Codable, Identifiable {
    public let id: UUID
    public let timestamp: Date
    public let cpuUsage: Double
    public let memoryUsage: Double
    public let diskUsage: Double
    public let networkBytesIn: Int64
    public let networkBytesOut: Int64

    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        cpuUsage: Double,
        memoryUsage: Double,
        diskUsage: Double,
        networkBytesIn: Int64 = 0,
        networkBytesOut: Int64 = 0
    ) {
        self.id = id
        self.timestamp = timestamp
        self.cpuUsage = cpuUsage
        self.memoryUsage = memoryUsage
        self.diskUsage = diskUsage
        self.networkBytesIn = networkBytesIn
        self.networkBytesOut = networkBytesOut
    }
}

// MARK: - Service Status
public struct ServiceStatus: Sendable, Codable, Identifiable {
    public let id: UUID
    public let timestamp: Date
    public let status: String
    public let uptime: TimeInterval
    public let version: String

    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        status: String,
        uptime: TimeInterval,
        version: String
    ) {
        self.id = id
        self.timestamp = timestamp
        self.status = status
        self.uptime = uptime
        self.version = version
    }
}
