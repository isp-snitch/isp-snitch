import Foundation
@preconcurrency import SQLite

// MARK: - Data Storage
public actor DataStorage {
    private let connection: Connection

    // Tables
    private let connectivityRecords = Table("connectivity_records")
    private let testConfigurations = Table("test_configurations")
    private let systemMetrics = Table("system_metrics")
    private let serviceStatus = Table("service_status")

    // Connectivity Records columns
    private let id = Expression<String>("id")
    private let timestamp = Expression<Date>("timestamp")
    private let testType = Expression<String>("test_type")
    private let target = Expression<String>("target")
    private let latency = Expression<Double?>("latency")
    private let success = Expression<Bool>("success")
    private let errorMessage = Expression<String?>("error_message")
    private let errorCode = Expression<Int?>("error_code")
    private let networkInterface = Expression<String>("network_interface")

    // System Context columns
    private let cpuUsage = Expression<Double>("cpu_usage")
    private let memoryUsage = Expression<Double>("memory_usage")
    private let networkInterfaceStatus = Expression<String>("network_interface_status")
    private let batteryLevel = Expression<Double?>("battery_level")

    // Test-specific data columns
    private let pingData = Expression<String?>("ping_data")
    private let httpData = Expression<String?>("http_data")
    private let dnsData = Expression<String?>("dns_data")
    private let speedtestData = Expression<String?>("speedtest_data")

    // Test Configuration columns
    private let name = Expression<String>("name")
    private let pingTargets = Expression<String>("ping_targets")
    private let httpTargets = Expression<String>("http_targets")
    private let dnsTargets = Expression<String>("dns_targets")
    private let testInterval = Expression<Double>("test_interval")
    private let timeout = Expression<Double>("timeout")
    private let retryCount = Expression<Int>("retry_count")
    private let webPort = Expression<Int>("web_port")
    private let dataRetentionDays = Expression<Int>("data_retention_days")
    private let enableNotifications = Expression<Bool>("enable_notifications")
    private let enableWebInterface = Expression<Bool>("enable_web_interface")
    private let isActive = Expression<Bool>("is_active")
    private let createdAt = Expression<Date>("created_at")
    private let updatedAt = Expression<Date>("updated_at")

    // System Metrics columns
    private let diskUsage = Expression<Double>("disk_usage")
    private let networkBytesIn = Expression<Int64>("network_bytes_in")
    private let networkBytesOut = Expression<Int64>("network_bytes_out")

    // Service Status columns
    private let status = Expression<String>("status")
    private let uptime = Expression<Double>("uptime")
    private let version = Expression<String>("version")

    public init(connection: Connection) throws {
        self.connection = connection
    }

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

    // MARK: - Connectivity Records

    public func insertConnectivityRecord(_ record: ConnectivityRecord) async throws {
        let pingDataJson = try encodeTestData(record.pingData)
        let httpDataJson = try encodeTestData(record.httpData)
        let dnsDataJson = try encodeTestData(record.dnsData)
        let speedtestDataJson = try encodeTestData(record.speedtestData)

        let insert = connectivityRecords.insert(
            id <- record.id.uuidString,
            timestamp <- record.timestamp,
            testType <- record.testType.rawValue,
            target <- record.target,
            latency <- record.latency,
            success <- record.success,
            errorMessage <- record.errorMessage,
            errorCode <- record.errorCode,
            networkInterface <- record.networkInterface,
            cpuUsage <- record.systemContext.cpuUsage,
            memoryUsage <- record.systemContext.memoryUsage,
            networkInterfaceStatus <- record.systemContext.networkInterfaceStatus,
            batteryLevel <- record.systemContext.batteryLevel,
            pingData <- pingDataJson,
            httpData <- httpDataJson,
            dnsData <- dnsDataJson,
            speedtestData <- speedtestDataJson
        )

        try connection.run(insert)
    }

    public func getConnectivityRecords(
        limit: Int = 100,
        offset: Int = 0,
        testType: TestType? = nil,
        success: Bool? = nil,
        since: Date? = nil
    ) async throws -> [ConnectivityRecord] {
        let query = buildConnectivityQuery(testType: testType, success: success, since: since)
            .limit(limit, offset: offset)

        var records: [ConnectivityRecord] = []
        for row in try connection.prepare(query) {
            let record = try createConnectivityRecord(from: row)
            records.append(record)
        }

        return records
    }

    // MARK: - Test Configurations

    public func insertTestConfiguration(_ configuration: TestConfiguration) async throws {
        let pingTargetsJson = try encodeTargets(configuration.pingTargets)
        let httpTargetsJson = try encodeTargets(configuration.httpTargets)
        let dnsTargetsJson = try encodeTargets(configuration.dnsTargets)

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
        var configurations: [TestConfiguration] = []

        for row in try connection.prepare(testConfigurations.select(*)) {
            let configuration = try createTestConfiguration(from: row)
            configurations.append(configuration)
        }

        return configurations
    }

    // MARK: - System Metrics

    public func insertSystemMetrics(_ metrics: SystemMetrics) async throws {
        let insert = systemMetrics.insert(
            id <- metrics.id.uuidString,
            timestamp <- metrics.timestamp,
            cpuUsage <- metrics.cpuUsage,
            memoryUsage <- metrics.memoryUsage,
            diskUsage <- metrics.diskUsage,
            networkBytesIn <- metrics.networkBytesIn,
            networkBytesOut <- metrics.networkBytesOut
        )

        try connection.run(insert)
    }

    public func getSystemMetrics(
        limit: Int = 100,
        since: Date? = nil
    ) async throws -> [SystemMetrics] {
        var query = systemMetrics.select(*)

        if let since = since {
            query = query.filter(timestamp >= since)
        }

        query = query.order(timestamp.desc).limit(limit)

        var metrics: [SystemMetrics] = []

        for row in try connection.prepare(query) {
            let metric = SystemMetrics(
                id: UUID(uuidString: row[id])!,
                timestamp: row[timestamp],
                cpuUsage: row[cpuUsage],
                memoryUsage: row[memoryUsage],
                diskUsage: row[diskUsage],
                networkBytesIn: row[networkBytesIn],
                networkBytesOut: row[networkBytesOut]
            )

            metrics.append(metric)
        }

        return metrics
    }

    // MARK: - Service Status

    public func insertServiceStatus(_ status: ServiceStatus) async throws {
        let insert = serviceStatus.insert(
            id <- status.id.uuidString,
            timestamp <- status.timestamp,
            self.status <- status.status,
            uptime <- status.uptime,
            version <- status.version
        )

        try connection.run(insert)
    }

    public func getServiceStatus() async throws -> ServiceStatus? {
        guard let row = try connection.pluck(serviceStatus.select(*).order(timestamp.desc)) else {
            return nil
        }

        return ServiceStatus(
            id: UUID(uuidString: row[id])!,
            timestamp: row[timestamp],
            status: row[status],
            uptime: row[uptime],
            version: row[version]
        )
    }
    
    // MARK: - Helper Functions
    
    private func encodeTestData<T: Codable>(_ data: T?) throws -> String? {
        guard let data = data else { return nil }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try String(data: encoder.encode(data), encoding: .utf8)
    }
    
    private func decodeTestData<T: Codable>(_ jsonString: String?, as type: T.Type) throws -> T? {
        guard let jsonString = jsonString,
              let jsonData = jsonString.data(using: .utf8) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(type, from: jsonData)
    }
    
    private func buildConnectivityQuery(
        testType: TestType?,
        success: Bool?,
        since: Date?
    ) -> QueryType {
        var query = connectivityRecords.select(*)
        
        if let testType = testType {
            query = query.filter(self.testType == testType.rawValue)
        }
        
        if let success = success {
            query = query.filter(self.success == success)
        }
        
        if let since = since {
            query = query.filter(timestamp >= since)
        }
        
        return query.order(timestamp.desc)
    }
    
    private func createSystemContext(from row: Row) -> SystemContext {
        return SystemContext(
            cpuUsage: row[cpuUsage],
            memoryUsage: row[memoryUsage],
            networkInterfaceStatus: row[networkInterfaceStatus],
            batteryLevel: row[batteryLevel]
        )
    }
    
    private func createConnectivityRecord(from row: Row) throws -> ConnectivityRecord {
        let systemContext = createSystemContext(from: row)
        
        let pingDataDecoded = try decodeTestData(row[pingData], as: PingData.self)
        let httpDataDecoded = try decodeTestData(row[httpData], as: HttpData.self)
        let dnsDataDecoded = try decodeTestData(row[dnsData], as: DnsData.self)
        let speedtestDataDecoded = try decodeTestData(row[speedtestData], as: SpeedtestData.self)
        
        return ConnectivityRecord(
            id: UUID(uuidString: row[id])!,
            timestamp: row[timestamp],
            testType: TestType(rawValue: row[self.testType])!,
            target: row[target],
            latency: row[latency],
            success: row[self.success],
            errorMessage: row[errorMessage],
            errorCode: row[errorCode],
            networkInterface: row[networkInterface],
            systemContext: systemContext,
            pingData: pingDataDecoded,
            httpData: httpDataDecoded,
            dnsData: dnsDataDecoded,
            speedtestData: speedtestDataDecoded
        )
    }
    
    private func encodeTargets(_ targets: [String]) throws -> String {
        let encoder = JSONEncoder()
        return try String(data: encoder.encode(targets), encoding: .utf8)!
    }
    
    private func decodeTargets(_ jsonString: String) throws -> [String] {
        let decoder = JSONDecoder()
        return try decoder.decode([String].self, from: jsonString.data(using: .utf8)!)
    }
    
    private func createTestConfiguration(from row: Row) throws -> TestConfiguration {
        let pingTargetsDecoded = try decodeTargets(row[pingTargets])
        let httpTargetsDecoded = try decodeTargets(row[httpTargets])
        let dnsTargetsDecoded = try decodeTargets(row[dnsTargets])
        
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
