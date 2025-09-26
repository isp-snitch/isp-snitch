import Foundation
@preconcurrency import SQLite

// MARK: - Schema Manager
public class SchemaManager {
    private let connection: Connection

    public init(connection: Connection) {
        self.connection = connection
    }

    public func createTables() throws {
        try createConnectivityRecordsTable()
        try createTestConfigurationsTable()
        try createSystemMetricsTable()
        try createServiceStatusTable()
        try createIndexes()
    }

    private func createConnectivityRecordsTable() throws {
        try connection.run(TableDefinitions.connectivityRecords.create(ifNotExists: true) { table in
            table.column(ConnectivityRecordColumns.id, primaryKey: true)
            table.column(ConnectivityRecordColumns.timestamp)
            table.column(ConnectivityRecordColumns.testType)
            table.column(ConnectivityRecordColumns.target)
            table.column(ConnectivityRecordColumns.latency)
            table.column(ConnectivityRecordColumns.success)
            table.column(ConnectivityRecordColumns.errorMessage)
            table.column(ConnectivityRecordColumns.errorCode)
            table.column(ConnectivityRecordColumns.networkInterface)
            table.column(ConnectivityRecordColumns.cpuUsage)
            table.column(ConnectivityRecordColumns.memoryUsage)
            table.column(ConnectivityRecordColumns.networkInterfaceStatus)
            table.column(ConnectivityRecordColumns.batteryLevel)
            table.column(ConnectivityRecordColumns.pingData)
            table.column(ConnectivityRecordColumns.httpData)
            table.column(ConnectivityRecordColumns.dnsData)
            table.column(ConnectivityRecordColumns.speedtestData)
        })
    }

    private func createTestConfigurationsTable() throws {
        try connection.run(TableDefinitions.testConfigurations.create(ifNotExists: true) { table in
            table.column(TestConfigurationColumns.id, primaryKey: true)
            table.column(TestConfigurationColumns.name)
            table.column(TestConfigurationColumns.pingTargets)
            table.column(TestConfigurationColumns.httpTargets)
            table.column(TestConfigurationColumns.dnsTargets)
            table.column(TestConfigurationColumns.testInterval)
            table.column(TestConfigurationColumns.timeout)
            table.column(TestConfigurationColumns.retryCount)
            table.column(TestConfigurationColumns.webPort)
            table.column(TestConfigurationColumns.dataRetentionDays)
            table.column(TestConfigurationColumns.enableNotifications)
            table.column(TestConfigurationColumns.enableWebInterface)
            table.column(TestConfigurationColumns.isActive)
            table.column(TestConfigurationColumns.createdAt)
            table.column(TestConfigurationColumns.updatedAt)
        })
    }

    private func createSystemMetricsTable() throws {
        try connection.run(TableDefinitions.systemMetrics.create(ifNotExists: true) { table in
            table.column(SystemMetricsColumns.id, primaryKey: true)
            table.column(SystemMetricsColumns.timestamp)
            table.column(SystemMetricsColumns.cpuUsage)
            table.column(SystemMetricsColumns.memoryUsage)
            table.column(SystemMetricsColumns.diskUsage)
            table.column(SystemMetricsColumns.networkBytesIn)
            table.column(SystemMetricsColumns.networkBytesOut)
        })
    }

    private func createServiceStatusTable() throws {
        try connection.run(TableDefinitions.serviceStatus.create(ifNotExists: true) { table in
            table.column(ServiceStatusColumns.id, primaryKey: true)
            table.column(ServiceStatusColumns.timestamp)
            table.column(ServiceStatusColumns.status)
            table.column(ServiceStatusColumns.uptime)
            table.column(ServiceStatusColumns.version)
        })
    }

    private func createIndexes() throws {
        // Connectivity records indexes
        try connection.execute("CREATE INDEX IF NOT EXISTS idx_connectivity_timestamp ON connectivity_records(timestamp)")
        try connection.execute("CREATE INDEX IF NOT EXISTS idx_connectivity_test_type ON connectivity_records(test_type)")
        try connection.execute("CREATE INDEX IF NOT EXISTS idx_connectivity_success ON connectivity_records(success)")
        try connection.execute("CREATE INDEX IF NOT EXISTS idx_connectivity_interface ON connectivity_records(network_interface)")

        // System metrics indexes
        try connection.execute("CREATE INDEX IF NOT EXISTS idx_system_metrics_timestamp ON system_metrics(timestamp)")

        // Service status indexes
        try connection.execute("CREATE INDEX IF NOT EXISTS idx_service_status_timestamp ON service_status(timestamp)")
    }
}
