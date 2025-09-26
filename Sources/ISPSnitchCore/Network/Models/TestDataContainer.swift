import Foundation

// MARK: - Test Data Protocol
public protocol TestData: Sendable, Codable {
    var testType: TestType { get }
}

// MARK: - Test Data Container
public enum TestDataContainer: Sendable, Codable {
    case ping(PingData)
    case http(HttpData)
    case dns(DnsData)
    case speedtest(SpeedtestData)

    public var testType: TestType {
        switch self {
        case .ping: return .ping
        case .http: return .http
        case .dns: return .dns
        case .speedtest: return .speedtest
        }
    }
}
