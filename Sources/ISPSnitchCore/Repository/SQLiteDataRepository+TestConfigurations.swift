import Foundation
@preconcurrency import SQLite

// MARK: - SQLite Data Repository Test Configurations Extensions
extension SQLiteDataRepository {

    public func insertTestConfiguration(_ configuration: TestConfiguration) async throws {
        let testConfigurations = Table("test_configurations")
        let id = Expression<String>("id")
        let name = Expression<String>("name")
        let pingTargets = Expression<String>("ping_targets")
        let httpTargets = Expression<String>("http_targets")
        let dnsTargets = Expression<String>("dns_targets")
        let testInterval = Expression<Double>("test_interval")
        let timeout = Expression<Double>("timeout")
        let retryCount = Expression<Int>("retry_count")
        let webPort = Expression<Int>("web_port")
        let dataRetentionDays = Expression<Int>("data_retention_days")
        let enableNotifications = Expression<Bool>("enable_notifications")
        let enableWebInterface = Expression<Bool>("enable_web_interface")
        let isActive = Expression<Bool>("is_active")
        let createdAt = Expression<Date>("created_at")
        let updatedAt = Expression<Date>("updated_at")

        let encoder = JSONEncoder()

        let pingTargetsJson = try String(data: encoder.encode(configuration.pingTargets), encoding: .utf8)!
        let httpTargetsJson = try String(data: encoder.encode(configuration.httpTargets), encoding: .utf8)!
        let dnsTargetsJson = try String(data: encoder.encode(configuration.dnsTargets), encoding: .utf8)!

        let insert = testConfigurations.insert(
            id <- configuration.id.uuidString,
            name <- configuration.name,
            pingTargets <- pingTargetsJson,
            httpTargets <- httpTargetsJson,
            dnsTargets <- dnsTargetsJson,
            testInterval <- configuration.testInterval,
            timeout <- configuration.timeout,
            retryCount <- configuration.retryCount,
            webPort <- configuration.webPort,
            dataRetentionDays <- configuration.dataRetentionDays,
            enableNotifications <- configuration.enableNotifications,
            enableWebInterface <- configuration.enableWebInterface,
            isActive <- configuration.isActive,
            createdAt <- configuration.createdAt,
            updatedAt <- configuration.updatedAt
        )

        try connection.run(insert)
    }

    public func getTestConfigurations() async throws -> [TestConfiguration] {
        let testConfigurations = Table("test_configurations")
        let id = Expression<String>("id")
        let name = Expression<String>("name")
        let pingTargets = Expression<String>("ping_targets")
        let httpTargets = Expression<String>("http_targets")
        let dnsTargets = Expression<String>("dns_targets")
        let testInterval = Expression<Double>("test_interval")
        let timeout = Expression<Double>("timeout")
        let retryCount = Expression<Int>("retry_count")
        let webPort = Expression<Int>("web_port")
        let dataRetentionDays = Expression<Int>("data_retention_days")
        let enableNotifications = Expression<Bool>("enable_notifications")
        let enableWebInterface = Expression<Bool>("enable_web_interface")
        let isActive = Expression<Bool>("is_active")

        let decoder = JSONDecoder()
        var configurations: [TestConfiguration] = []

        for row in try connection.prepare(testConfigurations.select(*)) {
            let configuration = try decodeTestConfiguration(from: row, using: decoder)
            configurations.append(configuration)
        }

        return configurations
    }

    private func decodeTestConfiguration(from row: Row, using decoder: JSONDecoder) throws -> TestConfiguration {
        let pingTargets = Expression<String>("ping_targets")
        let httpTargets = Expression<String>("http_targets")
        let dnsTargets = Expression<String>("dns_targets")
        let id = Expression<String>("id")
        let name = Expression<String>("name")
        let testInterval = Expression<Double>("test_interval")
        let timeout = Expression<Double>("timeout")
        let retryCount = Expression<Int>("retry_count")
        let webPort = Expression<Int>("web_port")
        let dataRetentionDays = Expression<Int>("data_retention_days")
        let enableNotifications = Expression<Bool>("enable_notifications")
        let enableWebInterface = Expression<Bool>("enable_web_interface")
        let isActive = Expression<Bool>("is_active")

        let pingTargetsDecoded = try decoder.decode([String].self, from: row[pingTargets].data(using: .utf8)!)
        let httpTargetsDecoded = try decoder.decode([String].self, from: row[httpTargets].data(using: .utf8)!)
        let dnsTargetsDecoded = try decoder.decode([String].self, from: row[dnsTargets].data(using: .utf8)!)

        return TestConfiguration(
            id: UUID(uuidString: row[id])!,
            name: row[name],
            pingTargets: pingTargetsDecoded,
            httpTargets: httpTargetsDecoded,
            dnsTargets: dnsTargetsDecoded,
            testInterval: row[testInterval],
            timeout: row[timeout],
            retryCount: row[retryCount],
            webPort: row[webPort],
            dataRetentionDays: row[dataRetentionDays],
            enableNotifications: row[enableNotifications],
            enableWebInterface: row[enableWebInterface],
            isActive: row[isActive]
        )
    }
}
