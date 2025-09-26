import Foundation
@preconcurrency import SQLite

// MARK: - Test Configuration Repository
public actor TestConfigurationRepository {
    private let connection: Connection

    public init(connection: Connection) {
        self.connection = connection
    }

    public func insert(_ configuration: TestConfiguration) async throws {
        let pingTargetsJson = JSONSerializer.encodeTargets(configuration.pingTargets)
        let httpTargetsJson = JSONSerializer.encodeTargets(configuration.httpTargets)
        let dnsTargetsJson = JSONSerializer.encodeTargets(configuration.dnsTargets)

        let insert = TableDefinitions.testConfigurations.insert(
            TestConfigurationColumns.id <- configuration.id.uuidString,
            TestConfigurationColumns.name <- configuration.name,
            TestConfigurationColumns.pingTargets <- pingTargetsJson,
            TestConfigurationColumns.httpTargets <- httpTargetsJson,
            TestConfigurationColumns.dnsTargets <- dnsTargetsJson,
            TestConfigurationColumns.testInterval <- configuration.testInterval,
            TestConfigurationColumns.timeout <- configuration.timeout,
            TestConfigurationColumns.retryCount <- configuration.retryCount,
            TestConfigurationColumns.webPort <- configuration.webPort,
            TestConfigurationColumns.dataRetentionDays <- configuration.dataRetentionDays,
            TestConfigurationColumns.enableNotifications <- configuration.enableNotifications,
            TestConfigurationColumns.enableWebInterface <- configuration.enableWebInterface,
            TestConfigurationColumns.isActive <- configuration.isActive,
            TestConfigurationColumns.createdAt <- configuration.createdAt,
            TestConfigurationColumns.updatedAt <- configuration.updatedAt
        )

        try connection.run(insert)
    }

    public func getAll() async throws -> [TestConfiguration] {
        var configurations: [TestConfiguration] = []

        for row in try connection.prepare(TableDefinitions.testConfigurations.select(*)) {
            let configuration = try createConfiguration(from: row)
            configurations.append(configuration)
        }

        return configurations
    }

    private func createConfiguration(from row: Row) throws -> TestConfiguration {
        // Safe JSON parsing
        let pingTargets = JSONSerializer.decodeTargets(row[TestConfigurationColumns.pingTargets])
        let httpTargets = JSONSerializer.decodeTargets(row[TestConfigurationColumns.httpTargets])
        let dnsTargets = JSONSerializer.decodeTargets(row[TestConfigurationColumns.dnsTargets])

        // Safe UUID parsing
        guard let id = SafeParsers.parseUUID(from: row[TestConfigurationColumns.id]) else {
            throw RepositoryError.invalidData("Invalid UUID in test configuration")
        }

        return TestConfiguration(
            id: id,
            name: row[TestConfigurationColumns.name],
            pingTargets: pingTargets,
            httpTargets: httpTargets,
            dnsTargets: dnsTargets,
            testInterval: row[TestConfigurationColumns.testInterval],
            timeout: row[TestConfigurationColumns.timeout],
            retryCount: row[TestConfigurationColumns.retryCount],
            webPort: row[TestConfigurationColumns.webPort],
            dataRetentionDays: row[TestConfigurationColumns.dataRetentionDays],
            enableNotifications: row[TestConfigurationColumns.enableNotifications],
            enableWebInterface: row[TestConfigurationColumns.enableWebInterface],
            isActive: row[TestConfigurationColumns.isActive]
        )
    }
}
