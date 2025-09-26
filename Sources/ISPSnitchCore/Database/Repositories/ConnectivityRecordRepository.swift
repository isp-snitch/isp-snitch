import Foundation
@preconcurrency import SQLite

// MARK: - Repository Error
public enum RepositoryError: Error, Sendable {
    case invalidData(String)
    case databaseError(String)
}

// MARK: - Connectivity Record Repository
public actor ConnectivityRecordRepository {
    private let connection: Connection

    public init(connection: Connection) {
        self.connection = connection
    }

    public func insert(_ record: ConnectivityRecord) async throws {
        let pingDataJson = JSONSerializer.encode(record.pingData)
        let httpDataJson = JSONSerializer.encode(record.httpData)
        let dnsDataJson = JSONSerializer.encode(record.dnsData)
        let speedtestDataJson = JSONSerializer.encode(record.speedtestData)

        let insert = TableDefinitions.connectivityRecords.insert(
            ConnectivityRecordColumns.id <- record.id.uuidString,
            ConnectivityRecordColumns.timestamp <- record.timestamp,
            ConnectivityRecordColumns.testType <- record.testType.rawValue,
            ConnectivityRecordColumns.target <- record.target,
            ConnectivityRecordColumns.latency <- record.latency,
            ConnectivityRecordColumns.success <- record.success,
            ConnectivityRecordColumns.errorMessage <- record.errorMessage,
            ConnectivityRecordColumns.errorCode <- record.errorCode,
            ConnectivityRecordColumns.networkInterface <- record.networkInterface,
            ConnectivityRecordColumns.cpuUsage <- record.systemContext.cpuUsage,
            ConnectivityRecordColumns.memoryUsage <- record.systemContext.memoryUsage,
            ConnectivityRecordColumns.networkInterfaceStatus <- record.systemContext.networkInterfaceStatus,
            ConnectivityRecordColumns.batteryLevel <- record.systemContext.batteryLevel,
            ConnectivityRecordColumns.pingData <- pingDataJson,
            ConnectivityRecordColumns.httpData <- httpDataJson,
            ConnectivityRecordColumns.dnsData <- dnsDataJson,
            ConnectivityRecordColumns.speedtestData <- speedtestDataJson
        )

        try connection.run(insert)
    }

    public func getRecords(
        limit: Int = 100,
        offset: Int = 0,
        testType: TestType? = nil,
        success: Bool? = nil,
        since: Date? = nil
    ) async throws -> [ConnectivityRecord] {
        let query = buildQuery(testType: testType, success: success, since: since)
            .limit(limit, offset: offset)

        var records: [ConnectivityRecord] = []
        for row in try connection.prepare(query) {
            let record = try createRecord(from: row)
            records.append(record)
        }

        return records
    }

    private func buildQuery(
        testType: TestType?,
        success: Bool?,
        since: Date?
    ) -> QueryType {
        var query = TableDefinitions.connectivityRecords.select(*)

        if let testType = testType {
            query = query.filter(ConnectivityRecordColumns.testType == testType.rawValue)
        }

        if let success = success {
            query = query.filter(ConnectivityRecordColumns.success == success)
        }

        if let since = since {
            query = query.filter(ConnectivityRecordColumns.timestamp >= since)
        }

        return query.order(ConnectivityRecordColumns.timestamp.desc)
    }

    private func createRecord(from row: Row) throws -> ConnectivityRecord {
        let systemContext = SystemContext(
            cpuUsage: row[ConnectivityRecordColumns.cpuUsage],
            memoryUsage: row[ConnectivityRecordColumns.memoryUsage],
            networkInterfaceStatus: row[ConnectivityRecordColumns.networkInterfaceStatus],
            batteryLevel: row[ConnectivityRecordColumns.batteryLevel]
        )

        // Safe JSON parsing
        let pingData = JSONSerializer.decode(row[ConnectivityRecordColumns.pingData], as: PingData.self)
        let httpData = JSONSerializer.decode(row[ConnectivityRecordColumns.httpData], as: HttpData.self)
        let dnsData = JSONSerializer.decode(row[ConnectivityRecordColumns.dnsData], as: DnsData.self)
        let speedtestData = JSONSerializer.decode(row[ConnectivityRecordColumns.speedtestData], as: SpeedtestData.self)

        // Safe UUID parsing
        guard let id = UUID(uuidString: row[ConnectivityRecordColumns.id]) else {
            throw RepositoryError.invalidData("Invalid UUID in connectivity record")
        }

        // Safe enum parsing
        guard let testType = TestType(rawValue: row[ConnectivityRecordColumns.testType]) else {
            throw RepositoryError.invalidData("Invalid test type: \(row[ConnectivityRecordColumns.testType])")
        }

        return ConnectivityRecord(
            id: id,
            timestamp: row[ConnectivityRecordColumns.timestamp],
            testType: testType,
            target: row[ConnectivityRecordColumns.target],
            latency: row[ConnectivityRecordColumns.latency],
            success: row[ConnectivityRecordColumns.success],
            errorMessage: row[ConnectivityRecordColumns.errorMessage],
            errorCode: row[ConnectivityRecordColumns.errorCode],
            networkInterface: row[ConnectivityRecordColumns.networkInterface],
            systemContext: systemContext,
            pingData: pingData,
            httpData: httpData,
            dnsData: dnsData,
            speedtestData: speedtestData
        )
    }
}
