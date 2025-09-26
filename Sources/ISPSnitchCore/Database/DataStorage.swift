import Foundation
@preconcurrency import SQLite

// MARK: - Data Storage Facade
public actor DataStorage {
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
    public func createTables() async throws {
        try await schemaManager.createTables()
    }

    // MARK: - Connectivity Records
    public func insertConnectivityRecord(_ record: ConnectivityRecord) async throws {
        try await connectivityRecordRepository.insert(record)
    }

    public func getConnectivityRecords(
        limit: Int = 100,
        offset: Int = 0,
        testType: TestType? = nil,
        success: Bool? = nil,
        since: Date? = nil
    ) async throws -> [ConnectivityRecord] {
        return try await connectivityRecordRepository.getRecords(
            limit: limit,
            offset: offset,
            testType: testType,
            success: success,
            since: since
        )
    }

    // MARK: - Test Configurations
    public func insertTestConfiguration(_ configuration: TestConfiguration) async throws {
        try await testConfigurationRepository.insert(configuration)
    }

    public func getTestConfigurations() async throws -> [TestConfiguration] {
        return try await testConfigurationRepository.getAll()
    }

    // MARK: - System Metrics
    public func insertSystemMetrics(_ metrics: SystemMetrics) async throws {
        try await systemMetricsRepository.insert(metrics)
    }

    public func getSystemMetrics(
        limit: Int = 100,
        since: Date? = nil
    ) async throws -> [SystemMetrics] {
        return try await systemMetricsRepository.getMetrics(limit: limit, since: since)
    }

    // MARK: - Service Status
    public func insertServiceStatus(_ status: ServiceStatus) async throws {
        try await serviceStatusRepository.insert(status)
    }

    public func getServiceStatus() async throws -> ServiceStatus? {
        return try await serviceStatusRepository.getLatest()
    }
}
