import Foundation
import Logging
import Metrics

// MARK: - Network Monitor
/// Optimized network monitoring with minimal resource usage
public actor NetworkMonitor {
    private let pingMonitor: PingMonitor
    private let httpMonitor: HttpMonitor
    private let dnsMonitor: DnsMonitor
    private let speedtestMonitor: SpeedtestMonitor
    private let utilityExecutor: UtilityExecutor
    private let outputParser: OutputParser
    private let logger: Logger

    // Performance optimization
    private var isMonitoring = false
    private var monitoringTask: Task<Void, Never>?
    private let monitoringInterval: TimeInterval = 60.0 // 1 minute default
    private var lastTestTime: [TestType: Date] = [:]
    private let minTestInterval: TimeInterval = 30.0 // Minimum 30 seconds between tests

    public init(logger: Logger = Logger(label: "NetworkMonitor")) {
        self.pingMonitor = PingMonitor()
        self.httpMonitor = HttpMonitor()
        self.dnsMonitor = DnsMonitor()
        self.speedtestMonitor = SpeedtestMonitor()
        self.utilityExecutor = UtilityExecutor()
        self.outputParser = OutputParser()
        self.logger = logger
    }

    // MARK: - Public Interface

    public func start() async throws {
        guard !isMonitoring else {
            logger.info("Network monitor already running")
            return
        }

        logger.info("Starting network monitor with optimized intervals")
        isMonitoring = true

        // Start background monitoring task
        monitoringTask = Task {
            await startBackgroundMonitoring()
        }

        logger.info("Network monitor started successfully")
    }

    public func stop() async throws {
        guard isMonitoring else {
            logger.info("Network monitor not running")
            return
        }

        logger.info("Stopping network monitor")
        isMonitoring = false

        // Cancel background monitoring task
        monitoringTask?.cancel()
        monitoringTask = nil

        logger.info("Network monitor stopped successfully")
    }

    public func performConnectivityTest(
        testType: TestType,
        target: String,
        timeout: TimeInterval = 10.0
    ) async throws -> ConnectivityRecord {
        // Check if we should skip this test based on recent activity
        if await shouldSkipTest(testType: testType) {
            logger.debug("Skipping \(testType.rawValue) test - too recent")
            throw NetworkError.testTooRecent
        }

        let startTime = Date()

        do {
            let result = try await executeTest(testType: testType, target: target, timeout: timeout)
            let endTime = Date()
            let latency = endTime.timeIntervalSince(startTime)

            // Update last test time
            lastTestTime[testType] = startTime

            // Log performance metrics
            logger.debug("\(testType.rawValue) test completed in \(latency)s")

            return ConnectivityRecord(
                testType: testType,
                target: target,
                latency: latency,
                success: result.success,
                errorMessage: result.errorMessage,
                errorCode: result.errorCode,
                networkInterface: await getCurrentNetworkInterface(),
                systemContext: await getSystemContext(),
                pingData: result.pingData,
                httpData: result.httpData,
                dnsData: result.dnsData,
                speedtestData: result.speedtestData
            )
        } catch {
            logger.error("Connectivity test failed for \(testType.rawValue) to \(target): \(error)")

            return ConnectivityRecord(
                testType: testType,
                target: target,
                latency: nil,
                success: false,
                errorMessage: error.localizedDescription,
                errorCode: nil,
                networkInterface: await getCurrentNetworkInterface(),
                systemContext: await getSystemContext()
            )
        }
    }

    // MARK: - Private Methods

    private func executeTest(
        testType: TestType,
        target: String,
        timeout: TimeInterval
    ) async throws -> TestResult {
        switch testType {
        case .ping:
            return try await pingMonitor.executePing(target: target, timeout: timeout)
        case .http:
            return try await httpMonitor.executeHttp(target: target, timeout: timeout)
        case .dns:
            return try await dnsMonitor.executeDns(target: target, timeout: timeout)
        case .bandwidth:
            return try await speedtestMonitor.executeSpeedtest(target: target, timeout: timeout)
        case .latency:
            return try await pingMonitor.executePing(target: target, timeout: timeout)
        }
    }

    private func getCurrentNetworkInterface() async -> String {
        // Get the current active network interface
        // This is a simplified implementation
        return "en0" // Default to en0, should be dynamically detected
    }

    private func getSystemContext() async -> SystemContext {
        // Get current system metrics
        let cpuUsage = await getCpuUsage()
        let memoryUsage = await getMemoryUsage()
        let networkInterfaceStatus = "active" // Should be dynamically detected
        let batteryLevel = await getBatteryLevel()

        return SystemContext(
            cpuUsage: cpuUsage,
            memoryUsage: memoryUsage,
            networkInterfaceStatus: networkInterfaceStatus,
            batteryLevel: batteryLevel
        )
    }

    private func getCpuUsage() async -> Double {
        // Simplified CPU usage detection
        // In a real implementation, this would use system APIs
        return 0.5
    }

    private func getMemoryUsage() async -> Double {
        // Simplified memory usage detection
        // In a real implementation, this would use system APIs
        return 42.0
    }

    private func getBatteryLevel() async -> Double? {
        // Simplified battery level detection
        // In a real implementation, this would use system APIs
        return 85.0
    }

    /// Start background monitoring with optimized intervals
    private func startBackgroundMonitoring() async {
        logger.info("Starting background monitoring with \(monitoringInterval)s interval")

        while isMonitoring {
            do {
                // Perform periodic connectivity tests
                try await performPeriodicTests()

                // Wait for next monitoring cycle
                try await Task.sleep(nanoseconds: UInt64(monitoringInterval * 1_000_000_000))
            } catch {
                if !Task.isCancelled {
                    logger.error("Background monitoring error: \(error)")
                }
                break
            }
        }

        logger.info("Background monitoring stopped")
    }

    /// Perform periodic connectivity tests
    private func performPeriodicTests() async throws {
        // Test different targets with optimized intervals
        let targets = ["8.8.8.8", "1.1.1.1", "google.com"]

        for target in targets where await shouldPerformTest(testType: .ping, target: target) {
            _ = try await performConnectivityTest(
                testType: .ping,
                target: target,
                timeout: 5.0
            )
        }
    }

    /// Check if we should skip a test based on recent activity
    private func shouldSkipTest(testType: TestType) async -> Bool {
        guard let lastTime = lastTestTime[testType] else { return false }
        let timeSinceLastTest = Date().timeIntervalSince(lastTime)
        return timeSinceLastTest < minTestInterval
    }

    /// Check if we should perform a test
    private func shouldPerformTest(testType: TestType, target: String) async -> Bool {
        return !(await shouldSkipTest(testType: testType))
    }
}

// MARK: - Test Result
public struct TestResult: Sendable {
    public let success: Bool
    public let errorMessage: String?
    public let errorCode: Int?
    public let pingData: PingData?
    public let httpData: HttpData?
    public let dnsData: DnsData?
    public let speedtestData: SpeedtestData?

    public init(
        success: Bool,
        errorMessage: String? = nil,
        errorCode: Int? = nil,
        pingData: PingData? = nil,
        httpData: HttpData? = nil,
        dnsData: DnsData? = nil,
        speedtestData: SpeedtestData? = nil
    ) {
        self.success = success
        self.errorMessage = errorMessage
        self.errorCode = errorCode
        self.pingData = pingData
        self.httpData = httpData
        self.dnsData = dnsData
        self.speedtestData = speedtestData
    }
}

// MARK: - Network Error
public enum NetworkError: Error, Sendable {
    case testTooRecent
    case monitoringNotStarted
    case invalidTarget(String)
    case timeoutExceeded
    case networkUnavailable

    public var localizedDescription: String {
        switch self {
        case .testTooRecent:
            return "Test too recent, please wait before retrying"
        case .monitoringNotStarted:
            return "Network monitoring not started"
        case .invalidTarget(let target):
            return "Invalid target: \(target)"
        case .timeoutExceeded:
            return "Network test timeout exceeded"
        case .networkUnavailable:
            return "Network interface unavailable"
        }
    }
}
