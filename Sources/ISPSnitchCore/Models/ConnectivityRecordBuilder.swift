import Foundation

// MARK: - Connectivity Record Builder
public struct ConnectivityRecordBuilder {
    private var id: UUID = UUID()
    private var timestamp: Date = Date()
    private var testType: TestType?
    private var target: String?
    private var latency: TimeInterval?
    private var success: Bool = false
    private var errorMessage: String?
    private var errorCode: Int?
    private var networkInterface: String?
    private var systemContext: SystemContext?
    private var pingData: PingData?
    private var httpData: HttpData?
    private var dnsData: DnsData?
    private var speedtestData: SpeedtestData?

    public init() {}

    public func withId(_ id: UUID) -> ConnectivityRecordBuilder {
        var builder = self
        builder.id = id
        return builder
    }

    public func withTimestamp(_ timestamp: Date) -> ConnectivityRecordBuilder {
        var builder = self
        builder.timestamp = timestamp
        return builder
    }

    public func withTestType(_ testType: TestType) -> ConnectivityRecordBuilder {
        var builder = self
        builder.testType = testType
        return builder
    }

    public func withTarget(_ target: String) -> ConnectivityRecordBuilder {
        var builder = self
        builder.target = target
        return builder
    }

    public func withLatency(_ latency: TimeInterval?) -> ConnectivityRecordBuilder {
        var builder = self
        builder.latency = latency
        return builder
    }

    public func withSuccess(_ success: Bool) -> ConnectivityRecordBuilder {
        var builder = self
        builder.success = success
        return builder
    }

    public func withErrorMessage(_ errorMessage: String?) -> ConnectivityRecordBuilder {
        var builder = self
        builder.errorMessage = errorMessage
        return builder
    }

    public func withErrorCode(_ errorCode: Int?) -> ConnectivityRecordBuilder {
        var builder = self
        builder.errorCode = errorCode
        return builder
    }

    public func withNetworkInterface(_ networkInterface: String) -> ConnectivityRecordBuilder {
        var builder = self
        builder.networkInterface = networkInterface
        return builder
    }

    public func withSystemContext(_ systemContext: SystemContext) -> ConnectivityRecordBuilder {
        var builder = self
        builder.systemContext = systemContext
        return builder
    }

    public func withPingData(_ pingData: PingData?) -> ConnectivityRecordBuilder {
        var builder = self
        builder.pingData = pingData
        return builder
    }

    public func withHttpData(_ httpData: HttpData?) -> ConnectivityRecordBuilder {
        var builder = self
        builder.httpData = httpData
        return builder
    }

    public func withDnsData(_ dnsData: DnsData?) -> ConnectivityRecordBuilder {
        var builder = self
        builder.dnsData = dnsData
        return builder
    }

    public func withSpeedtestData(_ speedtestData: SpeedtestData?) -> ConnectivityRecordBuilder {
        var builder = self
        builder.speedtestData = speedtestData
        return builder
    }

    public func build() throws -> ConnectivityRecord {
        guard let testType = testType else {
            throw BuilderError.missingRequiredField("testType")
        }
        guard let target = target else {
            throw BuilderError.missingRequiredField("target")
        }
        guard let networkInterface = networkInterface else {
            throw BuilderError.missingRequiredField("networkInterface")
        }
        guard let systemContext = systemContext else {
            throw BuilderError.missingRequiredField("systemContext")
        }

        return ConnectivityRecord(
            id: id,
            timestamp: timestamp,
            testType: testType,
            target: target,
            latency: latency,
            success: success,
            errorMessage: errorMessage,
            errorCode: errorCode,
            networkInterface: networkInterface,
            systemContext: systemContext,
            pingData: pingData,
            httpData: httpData,
            dnsData: dnsData,
            speedtestData: speedtestData
        )
    }
}

// MARK: - Builder Error
public enum BuilderError: Error {
    case missingRequiredField(String)
}
