import Foundation

// MARK: - Service Factory
public class ServiceFactory {
    private let configuration: ServiceConfiguration

    public init(configuration: ServiceConfiguration) {
        self.configuration = configuration
    }

    // MARK: - Factory Methods
    public func createDataRepository() throws -> DataRepository {
        let connection = try Connection(configuration.databasePath)
        return SQLiteDataRepository(connection: connection)
    }

    public func createNetworkMonitor() -> NetworkMonitorProtocol {
        return NetworkMonitor(
            pingTargets: configuration.pingTargets,
            httpTargets: configuration.httpTargets,
            dnsTargets: configuration.dnsTargets,
            testInterval: configuration.testInterval,
            timeout: configuration.timeout
        )
    }

    public func createPerformanceMonitor() -> PerformanceMonitorProtocol {
        return PerformanceMonitor()
    }

    public func createISPSnitchService() throws -> ISPSnitchServiceProtocol {
        let dataRepository = try createDataRepository()
        let networkMonitor = createNetworkMonitor()
        let performanceMonitor = createPerformanceMonitor()

        return ISPSnitchService(
            dataRepository: dataRepository,
            networkMonitor: networkMonitor,
            performanceMonitor: performanceMonitor
        )
    }
}

// MARK: - Service Configuration
public struct ServiceConfiguration {
    public let databasePath: String
    public let pingTargets: [String]
    public let httpTargets: [String]
    public let dnsTargets: [String]
    public let testInterval: TimeInterval
    public let timeout: TimeInterval
    public let webPort: Int
    public let dataRetentionDays: Int
    public let enableNotifications: Bool
    public let enableWebInterface: Bool

    public init(
        databasePath: String = "/var/lib/isp-snitch/isp-snitch.db",
        pingTargets: [String] = ["8.8.8.8", "1.1.1.1"],
        httpTargets: [String] = ["https://google.com", "https://cloudflare.com"],
        dnsTargets: [String] = ["google.com", "cloudflare.com"],
        testInterval: TimeInterval = 60.0,
        timeout: TimeInterval = 10.0,
        webPort: Int = 8080,
        dataRetentionDays: Int = 30,
        enableNotifications: Bool = true,
        enableWebInterface: Bool = true
    ) {
        self.databasePath = databasePath
        self.pingTargets = pingTargets
        self.httpTargets = httpTargets
        self.dnsTargets = dnsTargets
        self.testInterval = testInterval
        self.timeout = timeout
        self.webPort = webPort
        self.dataRetentionDays = dataRetentionDays
        self.enableNotifications = enableNotifications
        self.enableWebInterface = enableWebInterface
    }
}

// MARK: - Configuration Builder
public class ServiceConfigurationBuilder {
    private var databasePath: String = "/var/lib/isp-snitch/isp-snitch.db"
    private var pingTargets: [String] = ["8.8.8.8", "1.1.1.1"]
    private var httpTargets: [String] = ["https://google.com", "https://cloudflare.com"]
    private var dnsTargets: [String] = ["google.com", "cloudflare.com"]
    private var testInterval: TimeInterval = 60.0
    private var timeout: TimeInterval = 10.0
    private var webPort: Int = 8080
    private var dataRetentionDays: Int = 30
    private var enableNotifications: Bool = true
    private var enableWebInterface: Bool = true

    public init() {}

    public func withDatabasePath(_ path: String) -> ServiceConfigurationBuilder {
        self.databasePath = path
        return self
    }

    public func withPingTargets(_ targets: [String]) -> ServiceConfigurationBuilder {
        self.pingTargets = targets
        return self
    }

    public func withHttpTargets(_ targets: [String]) -> ServiceConfigurationBuilder {
        self.httpTargets = targets
        return self
    }

    public func withDnsTargets(_ targets: [String]) -> ServiceConfigurationBuilder {
        self.dnsTargets = targets
        return self
    }

    public func withTestInterval(_ interval: TimeInterval) -> ServiceConfigurationBuilder {
        self.testInterval = interval
        return self
    }

    public func withTimeout(_ timeout: TimeInterval) -> ServiceConfigurationBuilder {
        self.timeout = timeout
        return self
    }

    public func withWebPort(_ port: Int) -> ServiceConfigurationBuilder {
        self.webPort = port
        return self
    }

    public func withDataRetentionDays(_ days: Int) -> ServiceConfigurationBuilder {
        self.dataRetentionDays = days
        return self
    }

    public func withNotifications(_ enabled: Bool) -> ServiceConfigurationBuilder {
        self.enableNotifications = enabled
        return self
    }

    public func withWebInterface(_ enabled: Bool) -> ServiceConfigurationBuilder {
        self.enableWebInterface = enabled
        return self
    }

    public func build() -> ServiceConfiguration {
        return ServiceConfiguration(
            databasePath: databasePath,
            pingTargets: pingTargets,
            httpTargets: httpTargets,
            dnsTargets: dnsTargets,
            testInterval: testInterval,
            timeout: timeout,
            webPort: webPort,
            dataRetentionDays: dataRetentionDays,
            enableNotifications: enableNotifications,
            enableWebInterface: enableWebInterface
        )
    }
}
