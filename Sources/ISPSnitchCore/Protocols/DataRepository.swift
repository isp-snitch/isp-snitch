import Foundation

// MARK: - Repository Protocol
public protocol DataRepository {
    func insertConnectivityRecord(_ record: ConnectivityRecord) async throws
    func getConnectivityRecords(
        limit: Int,
        offset: Int,
        testType: TestType?,
        success: Bool?,
        since: Date?
    ) async throws -> [ConnectivityRecord]

    func insertTestConfiguration(_ configuration: TestConfiguration) async throws
    func getTestConfigurations() async throws -> [TestConfiguration]

    func insertSystemMetrics(_ metrics: SystemMetrics) async throws
    func getSystemMetrics(limit: Int, since: Date?) async throws -> [SystemMetrics]

    func insertServiceStatus(_ status: ServiceStatus) async throws
    func getServiceStatus() async throws -> ServiceStatus?
}

// MARK: - Database Protocol
public protocol DatabaseProtocol {
    func createTables() async throws
    func runMigrations() async throws
}

// MARK: - Network Monitor Protocol
public protocol NetworkMonitorProtocol {
    func start() async throws
    func stop() async throws
    func isRunning() async -> Bool
}

// MARK: - Performance Monitor Protocol
public protocol PerformanceMonitorProtocol {
    func start() async throws
    func stop() async throws
    func getMetrics() async -> SystemMetrics
}

// MARK: - Service Protocol
public protocol ISPSnitchServiceProtocol {
    func start() async throws
    func stop() async throws
    func getStatus() async -> ServiceStatus
    func getMetrics() async -> SystemMetrics
}
