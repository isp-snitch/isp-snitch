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
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let pingDataJson = try record.pingData.map { try String(data: encoder.encode($0), encoding: .utf8) } ?? nil
        let httpDataJson = try record.httpData.map { try String(data: encoder.encode($0), encoding: .utf8) } ?? nil
        let dnsDataJson = try record.dnsData.map { try String(data: encoder.encode($0), encoding: .utf8) } ?? nil
        let speedtestDataJson = try record.speedtestData.map { try String(data: encoder.encode($0), encoding: .utf8) } ?? nil

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
        var query = connectivityRecords.select(*)

        if let testType = testType {
            query = query.filter(self.testType == testType.rawValue)
        }

        if let success = success {
            query = query.filter(self.success == success)
        }

        if let since = since {
            query = query.filter(self.timestamp >= since)
        }

        query = query.order(timestamp.desc).limit(limit, offset: offset)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        var records: [ConnectivityRecord] = []

        for row in try connection.prepare(query) {
            let systemContext = SystemContext(
                cpuUsage: row[cpuUsage],
                memoryUsage: row[memoryUsage],
                networkInterfaceStatus: row[networkInterfaceStatus],
                batteryLevel: row[batteryLevel]
            )

            let pingDataDecoded: PingData? = try {
                guard let jsonString = row[pingData],
                      let jsonData = jsonString.data(using: .utf8) else { return nil }
                return try decoder.decode(PingData.self, from: jsonData)
            }()

            let httpDataDecoded: HttpData? = try {
                guard let jsonString = row[httpData],
                      let jsonData = jsonString.data(using: .utf8) else { return nil }
                return try decoder.decode(HttpData.self, from: jsonData)
            }()

            let dnsDataDecoded: DnsData? = try {
                guard let jsonString = row[dnsData],
                      let jsonData = jsonString.data(using: .utf8) else { return nil }
                return try decoder.decode(DnsData.self, from: jsonData)
            }()

            let speedtestDataDecoded: SpeedtestData? = try {
                guard let jsonString = row[speedtestData],
                      let jsonData = jsonString.data(using: .utf8) else { return nil }
                return try decoder.decode(SpeedtestData.self, from: jsonData)
            }()

            let record = ConnectivityRecord(
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

            records.append(record)
        }

        return records
    }

    // MARK: - Test Configurations

    public func insertTestConfiguration(_ configuration: TestConfiguration) async throws {
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
        let decoder = JSONDecoder()
        var configurations: [TestConfiguration] = []

        for row in try connection.prepare(testConfigurations.select(*)) {
            let pingTargetsDecoded = try decoder.decode([String].self, from: row[pingTargets].data(using: .utf8)!)
            let httpTargetsDecoded = try decoder.decode([String].self, from: row[httpTargets].data(using: .utf8)!)
            let dnsTargetsDecoded = try decoder.decode([String].self, from: row[dnsTargets].data(using: .utf8)!)

            let configuration = TestConfiguration(
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
}
