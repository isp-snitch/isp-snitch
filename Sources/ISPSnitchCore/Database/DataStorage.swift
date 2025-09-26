import Foundation
@preconcurrency import SQLite

// MARK: - Data Storage Facade
public class DataStorage {
    private let connection: Connection
    private let schemaManager: SchemaManager
    private let connectivityRecordRepository: ConnectivityRecordRepository
    private let testConfigurationRepository: TestConfigurationRepository
    private let systemMetricsRepository: SystemMetricsRepository
    private let serviceStatusRepository: ServiceStatusRepository

    public init(connection: Connection) throws {
        self.connection = connection
        self.schemaManager = SchemaManager(connection: connection)
        self.connectivityRecordRepository = ConnectivityRecordRepository(connection: connection)
        self.testConfigurationRepository = TestConfigurationRepository(connection: connection)
        self.systemMetricsRepository = SystemMetricsRepository(connection: connection)
        self.serviceStatusRepository = ServiceStatusRepository(connection: connection)
    }

    // MARK: - Table Creation
    public func createTables() throws {
        try schemaManager.createTables()
    }

    // MARK: - Connectivity Records
    public func insertConnectivityRecord(_ record: ConnectivityRecord) throws {
        try connectivityRecordRepository.insert(record)
    }

    public func getConnectivityRecords(
        limit: Int = 100,
        offset: Int = 0,
        testType: TestType? = nil,
        success: Bool? = nil,
        since: Date? = nil
    ) throws -> [ConnectivityRecord] {
        try connectivityRecordRepository.getRecords(
            limit: limit,
            offset: offset,
            testType: testType,
            success: success,
            since: since
        )
    }

    // MARK: - Test Configurations
    public func insertTestConfiguration(_ configuration: TestConfiguration) throws {
        try testConfigurationRepository.insert(configuration)
    }

    public func getTestConfigurations() throws -> [TestConfiguration] {
        try testConfigurationRepository.getAll()
    }

    // MARK: - System Metrics
    public func insertSystemMetrics(_ metrics: SystemMetrics) throws {
        try systemMetricsRepository.insert(metrics)
    }

    public func getSystemMetrics(
        limit: Int = 100,
        since: Date? = nil
    ) throws -> [SystemMetrics] {
        try systemMetricsRepository.getMetrics(limit: limit, since: since)
    }

    // MARK: - Service Status
    public func insertServiceStatus(_ status: ServiceStatus) throws {
        try serviceStatusRepository.insert(status)
    }

    public func getServiceStatus() throws -> ServiceStatus? {
        try serviceStatusRepository.getLatest()
    }
}
