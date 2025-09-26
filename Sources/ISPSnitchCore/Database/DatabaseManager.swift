@preconcurrency import Foundation
@preconcurrency import SQLite

// MARK: - Database Manager
public actor DatabaseManager {
    private let connection: Connection
    private let dataStorage: DataStorage
    private let retentionManager: DataRetentionManager

    public init(databasePath: String = ":memory:") async throws {
        self.connection = try Connection(databasePath)
        self.dataStorage = try DataStorage(connection: connection)
        self.retentionManager = DataRetentionManager(connection: connection)

        try await setupDatabase()
    }

    private func setupDatabase() async throws {
        // Create tables if they don't exist
        try await dataStorage.createTables()

        // Run migrations if needed
        try Migrations.runMigrations(on: connection)
    }

    // MARK: - Public Interface

    public func insertConnectivityRecord(_ record: ConnectivityRecord) async throws {
        try await dataStorage.insertConnectivityRecord(record)
    }

    public func getConnectivityRecords(
        limit: Int = 100,
        offset: Int = 0,
        testType: TestType? = nil,
        success: Bool? = nil,
        since: Date? = nil
    ) async throws -> [ConnectivityRecord] {
        try await dataStorage.getConnectivityRecords(
            limit: limit,
            offset: offset,
            testType: testType,
            success: success,
            since: since
        )
    }

    public func insertTestConfiguration(_ configuration: TestConfiguration) async throws {
        try await dataStorage.insertTestConfiguration(configuration)
    }

    public func getTestConfigurations() async throws -> [TestConfiguration] {
        try await dataStorage.getTestConfigurations()
    }

    public func insertSystemMetrics(_ metrics: SystemMetrics) async throws {
        try await dataStorage.insertSystemMetrics(metrics)
    }

    public func getSystemMetrics(
        limit: Int = 100,
        since: Date? = nil
    ) async throws -> [SystemMetrics] {
        try await dataStorage.getSystemMetrics(limit: limit, since: since)
    }

    public func insertServiceStatus(_ status: ServiceStatus) async throws {
        try await dataStorage.insertServiceStatus(status)
    }

    public func getServiceStatus() async throws -> ServiceStatus? {
        try await dataStorage.getServiceStatus()
    }

    public func cleanup() async throws {
        try await retentionManager.cleanupOldData()
    }

    public func close() async throws {
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
