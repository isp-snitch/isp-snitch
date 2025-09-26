import Foundation
@preconcurrency import SQLite

// MARK: - DataStorage Schema Extensions
extension DataStorage {

    // MARK: - Table Creation

    public func createTables() throws {
        try createConnectivityRecordsTable()
        try createTestConfigurationsTable()
        try createSystemMetricsTable()
        try createServiceStatusTable()
        try createIndexes()
    }

    private func createConnectivityRecordsTable() throws {
        try connection.run(connectivityRecords.create(ifNotExists: true) { table in
            table.column(id, primaryKey: true)
            table.column(timestamp)
            table.column(testType)
            table.column(target)
            table.column(latency)
            table.column(success)
            table.column(errorMessage)
            table.column(errorCode)
            table.column(networkInterface)
            table.column(cpuUsage)
            table.column(memoryUsage)
            table.column(networkInterfaceStatus)
            table.column(batteryLevel)
            table.column(pingData)
            table.column(httpData)
            table.column(dnsData)
            table.column(speedtestData)
        })
    }

    private func createTestConfigurationsTable() throws {
        try connection.run(testConfigurations.create(ifNotExists: true) { table in
            table.column(id, primaryKey: true)
            table.column(name)
            table.column(pingTargets)
            table.column(httpTargets)
            table.column(dnsTargets)
            table.column(testInterval)
            table.column(timeout)
            table.column(retryCount)
            table.column(webPort)
            table.column(dataRetentionDays)
            table.column(enableNotifications)
            table.column(enableWebInterface)
            table.column(isActive)
            table.column(createdAt)
            table.column(updatedAt)
        })
    }

    private func createSystemMetricsTable() throws {
        try connection.run(systemMetrics.create(ifNotExists: true) { table in
            table.column(id, primaryKey: true)
            table.column(timestamp)
            table.column(cpuUsage)
            table.column(memoryUsage)
            table.column(diskUsage)
            table.column(networkBytesIn)
            table.column(networkBytesOut)
        })
    }

    private func createServiceStatusTable() throws {
        try connection.run(serviceStatus.create(ifNotExists: true) { table in
            table.column(id, primaryKey: true)
            table.column(timestamp)
            table.column(status)
            table.column(uptime)
            table.column(version)
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
