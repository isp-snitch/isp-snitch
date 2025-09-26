import Foundation

// MARK: - Builder Pattern for ConnectivityRecord
public class ConnectivityRecordBuilder {
    private var id: UUID = UUID()
    private var timestamp: Date = Date()
    private var testType: TestType = .ping
    private var target: String = ""
    private var latency: Double?
    private var success: Bool = false
    private var errorMessage: String?
    private var errorCode: Int?
    private var networkInterface: String = "en0"
    private var systemContext: SystemContext = SystemContext(
        cpuUsage: 0.0,
        memoryUsage: 0.0,
        networkInterfaceStatus: "active",
        batteryLevel: nil
    )
    private var pingData: PingData?
    private var httpData: HttpData?
    private var dnsData: DnsData?
    private var speedtestData: SpeedtestData?

    public init() {}

    // MARK: - Builder Methods
    public func withId(_ id: UUID) -> ConnectivityRecordBuilder {
        self.id = id
        return self
    }

    public func withTimestamp(_ timestamp: Date) -> ConnectivityRecordBuilder {
        self.timestamp = timestamp
        return self
    }

    public func withTestType(_ testType: TestType) -> ConnectivityRecordBuilder {
        self.testType = testType
        return self
    }

    public func withTarget(_ target: String) -> ConnectivityRecordBuilder {
        self.target = target
        return self
    }

    public func withLatency(_ latency: Double?) -> ConnectivityRecordBuilder {
        self.latency = latency
        return self
    }

    public func withSuccess(_ success: Bool) -> ConnectivityRecordBuilder {
        self.success = success
        return self
    }

    public func withErrorMessage(_ errorMessage: String?) -> ConnectivityRecordBuilder {
        self.errorMessage = errorMessage
        return self
    }

    public func withErrorCode(_ errorCode: Int?) -> ConnectivityRecordBuilder {
        self.errorCode = errorCode
        return self
    }

    public func withNetworkInterface(_ networkInterface: String) -> ConnectivityRecordBuilder {
        self.networkInterface = networkInterface
        return self
    }

    public func withSystemContext(_ systemContext: SystemContext) -> ConnectivityRecordBuilder {
        self.systemContext = systemContext
        return self
    }

    public func withPingData(_ pingData: PingData?) -> ConnectivityRecordBuilder {
        self.pingData = pingData
        return self
    }

    public func withHttpData(_ httpData: HttpData?) -> ConnectivityRecordBuilder {
        self.httpData = httpData
        return self
    }

    public func withDnsData(_ dnsData: DnsData?) -> ConnectivityRecordBuilder {
        self.dnsData = dnsData
        return self
    }

    public func withSpeedtestData(_ speedtestData: SpeedtestData?) -> ConnectivityRecordBuilder {
        self.speedtestData = speedtestData
        return self
    }

    // MARK: - Convenience Methods
    public func asPingTest(target: String, latency: Double? = nil, success: Bool = true) -> ConnectivityRecordBuilder {
        return self
            .withTestType(.ping)
            .withTarget(target)
            .withLatency(latency)
            .withSuccess(success)
    }

    public func asHttpTest(target: String, latency: Double? = nil, success: Bool = true) -> ConnectivityRecordBuilder {
        return self
            .withTestType(.http)
            .withTarget(target)
            .withLatency(latency)
            .withSuccess(success)
    }

    public func asDnsTest(target: String, success: Bool = true) -> ConnectivityRecordBuilder {
        return self
            .withTestType(.dns)
            .withTarget(target)
            .withSuccess(success)
    }

    public func asSpeedtestTest(target: String, success: Bool = true) -> ConnectivityRecordBuilder {
        return self
            .withTestType(.speedtest)
            .withTarget(target)
            .withSuccess(success)
    }

    public func withFailure(error: String, code: Int? = nil) -> ConnectivityRecordBuilder {
        return self
            .withSuccess(false)
            .withErrorMessage(error)
            .withErrorCode(code)
    }

    // MARK: - Build Method
    public func build() -> ConnectivityRecord {
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

// MARK: - Factory Methods
public extension ConnectivityRecordBuilder {
    static func pingTest(target: String, latency: Double? = nil, success: Bool = true) -> ConnectivityRecordBuilder {
        return ConnectivityRecordBuilder()
            .asPingTest(target: target, latency: latency, success: success)
    }

    static func httpTest(target: String, latency: Double? = nil, success: Bool = true) -> ConnectivityRecordBuilder {
        return ConnectivityRecordBuilder()
            .asHttpTest(target: target, latency: latency, success: success)
    }

    static func dnsTest(target: String, success: Bool = true) -> ConnectivityRecordBuilder {
        return ConnectivityRecordBuilder()
            .asDnsTest(target: target, success: success)
    }

    static func speedtestTest(target: String, success: Bool = true) -> ConnectivityRecordBuilder {
        return ConnectivityRecordBuilder()
            .asSpeedtestTest(target: target, success: success)
    }
}
