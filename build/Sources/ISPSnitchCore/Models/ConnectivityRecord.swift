import Foundation

// MARK: - Connectivity Record
public struct ConnectivityRecord: Sendable, Codable, Identifiable {
    public let id: UUID
    public let timestamp: Date
    public let testType: TestType
    public let target: String
    public let latency: TimeInterval?
    public let success: Bool
    public let errorMessage: String?
    public let errorCode: Int?  // Utility exit code
    public let networkInterface: String
    public let systemContext: SystemContext

    // Test-specific data based on actual utility outputs
    public let pingData: PingData?
    public let httpData: HttpData?
    public let dnsData: DnsData?
    public let speedtestData: SpeedtestData?

    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        testType: TestType,
        target: String,
        latency: TimeInterval? = nil,
        success: Bool,
        errorMessage: String? = nil,
        errorCode: Int? = nil,
        networkInterface: String,
        systemContext: SystemContext,
        pingData: PingData? = nil,
        httpData: HttpData? = nil,
        dnsData: DnsData? = nil,
        speedtestData: SpeedtestData? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.testType = testType
        self.target = target
        self.latency = latency
        self.success = success
        self.errorMessage = errorMessage
        self.errorCode = errorCode
        self.networkInterface = networkInterface
        self.systemContext = systemContext
        self.pingData = pingData
        self.httpData = httpData
        self.dnsData = dnsData
        self.speedtestData = speedtestData
    }
}

// MARK: - Test Types
public enum TestType: String, CaseIterable, Codable, Sendable {
    case ping = "ping"
    case http = "http"
    case dns = "dns"
    case bandwidth = "bandwidth"
    case latency = "latency"

    public var displayName: String {
        switch self {
        case .ping: return "Ping Test"
        case .http: return "HTTP Test"
        case .dns: return "DNS Test"
        case .bandwidth: return "Bandwidth Test"
        case .latency: return "Latency Test"
        }
    }

    public var defaultTargets: [String] {
        switch self {
        case .ping: return ["8.8.8.8", "1.1.1.1"]
        case .http: return ["https://google.com", "https://cloudflare.com"]
        case .dns: return ["google.com", "cloudflare.com"]
        case .bandwidth: return ["speedtest.net"]
        case .latency: return ["8.8.8.8", "1.1.1.1"]
        }
    }
}

// MARK: - System Context
public struct SystemContext: Sendable, Codable {
    public let cpuUsage: Double
    public let memoryUsage: Double
    public let networkInterfaceStatus: String
    public let batteryLevel: Double?

    public init(
        cpuUsage: Double,
        memoryUsage: Double,
        networkInterfaceStatus: String,
        batteryLevel: Double? = nil
    ) {
        self.cpuUsage = cpuUsage
        self.memoryUsage = memoryUsage
        self.networkInterfaceStatus = networkInterfaceStatus
        self.batteryLevel = batteryLevel
    }
}

// MARK: - Test-Specific Data Structures
public struct PingData: Sendable, Codable {
    public let latency: TimeInterval
    public let packetLoss: Double
    public let ttl: Int?
    public let statistics: PingStatistics?

    public init(
        latency: TimeInterval,
        packetLoss: Double,
        ttl: Int? = nil,
        statistics: PingStatistics? = nil
    ) {
        self.latency = latency
        self.packetLoss = packetLoss
        self.ttl = ttl
        self.statistics = statistics
    }
}

public struct PingStatistics: Sendable, Codable {
    public let minLatency: TimeInterval
    public let avgLatency: TimeInterval
    public let maxLatency: TimeInterval
    public let stdDev: TimeInterval
    public let packetsTransmitted: Int
    public let packetsReceived: Int

    public init(
        minLatency: TimeInterval,
        avgLatency: TimeInterval,
        maxLatency: TimeInterval,
        stdDev: TimeInterval,
        packetsTransmitted: Int,
        packetsReceived: Int
    ) {
        self.minLatency = minLatency
        self.avgLatency = avgLatency
        self.maxLatency = maxLatency
        self.stdDev = stdDev
        self.packetsTransmitted = packetsTransmitted
        self.packetsReceived = packetsReceived
    }
}

public struct HttpData: Sendable, Codable {
    public let httpCode: Int
    public let totalTime: TimeInterval
    public let connectTime: TimeInterval
    public let dnsTime: TimeInterval
    public let downloadSize: Int
    public let downloadSpeed: Double

    public init(
        httpCode: Int,
        totalTime: TimeInterval,
        connectTime: TimeInterval,
        dnsTime: TimeInterval,
        downloadSize: Int,
        downloadSpeed: Double
    ) {
        self.httpCode = httpCode
        self.totalTime = totalTime
        self.connectTime = connectTime
        self.dnsTime = dnsTime
        self.downloadSize = downloadSize
        self.downloadSpeed = downloadSpeed
    }
}

public struct DnsData: Sendable, Codable {
    public let queryTime: TimeInterval
    public let status: String
    public let answerCount: Int
    public let server: String
    public let answers: [String]

    public init(
        queryTime: TimeInterval,
        status: String,
        answerCount: Int,
        server: String,
        answers: [String]
    ) {
        self.queryTime = queryTime
        self.status = status
        self.answerCount = answerCount
        self.server = server
        self.answers = answers
    }
}

public struct SpeedtestData: Sendable, Codable {
    public let ping: TimeInterval
    public let downloadSpeed: Double  // Mbit/s
    public let uploadSpeed: Double    // Mbit/s

    public init(
        ping: TimeInterval,
        downloadSpeed: Double,
        uploadSpeed: Double
    ) {
        self.ping = ping
        self.downloadSpeed = downloadSpeed
        self.uploadSpeed = uploadSpeed
    }
}

// MARK: - Test Configuration
public struct TestConfiguration: Sendable, Codable, Identifiable {
    public let id: UUID
    public let name: String
    public let pingTargets: [String]
    public let httpTargets: [String]
    public let dnsTargets: [String]
    public let testInterval: TimeInterval
    public let timeout: TimeInterval
    public let retryCount: Int
    public let webPort: Int
    public let dataRetentionDays: Int
    public let enableNotifications: Bool
    public let enableWebInterface: Bool
    public let isActive: Bool
    public let createdAt: Date
    public let updatedAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        pingTargets: [String] = TestType.ping.defaultTargets,
        httpTargets: [String] = TestType.http.defaultTargets,
        dnsTargets: [String] = TestType.dns.defaultTargets,
        testInterval: TimeInterval = 30.0,
        timeout: TimeInterval = 10.0,
        retryCount: Int = 3,
        webPort: Int = 8080,
        dataRetentionDays: Int = 30,
        enableNotifications: Bool = true,
        enableWebInterface: Bool = true,
        isActive: Bool = true
    ) {
        self.id = id
        self.name = name
        self.pingTargets = pingTargets
        self.httpTargets = httpTargets
        self.dnsTargets = dnsTargets
        self.testInterval = testInterval
        self.timeout = timeout
        self.retryCount = retryCount
        self.webPort = webPort
        self.dataRetentionDays = dataRetentionDays
        self.enableNotifications = enableNotifications
        self.enableWebInterface = enableWebInterface
        self.isActive = isActive
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
