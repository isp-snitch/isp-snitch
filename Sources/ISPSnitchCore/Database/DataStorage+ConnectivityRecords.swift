import Foundation
@preconcurrency import SQLite

// MARK: - DataStorage Connectivity Records Extensions
extension DataStorage {

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

        return try await decodeConnectivityRecords(from: query)
    }

    private func decodeConnectivityRecords(from query: QueryType) async throws -> [ConnectivityRecord] {
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

            let pingDataDecoded: PingData? = try decodeOptionalData(from: row[pingData], using: decoder)
            let httpDataDecoded: HttpData? = try decodeOptionalData(from: row[httpData], using: decoder)
            let dnsDataDecoded: DnsData? = try decodeOptionalData(from: row[dnsData], using: decoder)
            let speedtestDataDecoded: SpeedtestData? = try decodeOptionalData(from: row[speedtestData], using: decoder)

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

    private func decodeOptionalData<T: Codable>(from jsonString: String?, using decoder: JSONDecoder) throws -> T? {
        guard let jsonString = jsonString,
              let jsonData = jsonString.data(using: .utf8) else { return nil }
        return try decoder.decode(T.self, from: jsonData)
    }
}
