import Foundation

// MARK: - Test Strategy Pattern
public protocol TestStrategy {
    func execute(target: String, timeout: TimeInterval) async throws -> TestResult
    var testType: TestType { get }
}

// MARK: - Ping Test Strategy
public class PingTestStrategy: TestStrategy {
    private let utilityExecutor: UtilityExecutor

    public let testType: TestType = .ping

    public init(utilityExecutor: UtilityExecutor) {
        self.utilityExecutor = utilityExecutor
    }

    public func execute(target: String, timeout: TimeInterval) async throws -> TestResult {
        let command = "ping -c 1 -W \(Int(timeout * 1000)) \(target)"

        do {
            let output = try await utilityExecutor.executeCommand(command, timeout: timeout)
            let parser = OutputParser()
            let pingData = try parser.parsePingOutput(output)

            return TestResult(
                success: true,
                latency: pingData.averageLatency,
                data: pingData,
                errorMessage: nil,
                errorCode: nil
            )
        } catch {
            return TestResult(
                success: false,
                latency: nil,
                data: nil,
                errorMessage: error.localizedDescription,
                errorCode: (error as? UtilityExecutionError)?.exitCode
            )
        }
    }
}

// MARK: - HTTP Test Strategy
public class HttpTestStrategy: TestStrategy {
    private let utilityExecutor: UtilityExecutor

    public let testType: TestType = .http

    public init(utilityExecutor: UtilityExecutor) {
        self.utilityExecutor = utilityExecutor
    }

    public func execute(target: String, timeout: TimeInterval) async throws -> TestResult {
        let command = "curl -w \"%{http_code}:%{time_total}:%{time_connect}:%{time_namelookup}\" -s -o /dev/null \(target)"

        do {
            let output = try await utilityExecutor.executeCommand(command, timeout: timeout)
            let parser = OutputParser()
            let httpData = try parser.parseHttpOutput(output)

            return TestResult(
                success: httpData.statusCode == 200,
                latency: httpData.totalTime,
                data: httpData,
                errorMessage: httpData.statusCode != 200 ? "HTTP \(httpData.statusCode)" : nil,
                errorCode: httpData.statusCode
            )
        } catch {
            return TestResult(
                success: false,
                latency: nil,
                data: nil,
                errorMessage: error.localizedDescription,
                errorCode: (error as? UtilityExecutionError)?.exitCode
            )
        }
    }
}

// MARK: - DNS Test Strategy
public class DnsTestStrategy: TestStrategy {
    private let utilityExecutor: UtilityExecutor

    public let testType: TestType = .dns

    public init(utilityExecutor: UtilityExecutor) {
        self.utilityExecutor = utilityExecutor
    }

    public func execute(target: String, timeout: TimeInterval) async throws -> TestResult {
        let command = "dig +short +time=\(Int(timeout)) \(target)"

        do {
            let output = try await utilityExecutor.executeCommand(command, timeout: timeout)
            let parser = OutputParser()
            let dnsData = try parser.parseDnsOutput(output)

            return TestResult(
                success: dnsData.status == "NOERROR",
                latency: dnsData.queryTime,
                data: dnsData,
                errorMessage: dnsData.status != "NOERROR" ? "DNS \(dnsData.status)" : nil,
                errorCode: nil
            )
        } catch {
            return TestResult(
                success: false,
                latency: nil,
                data: nil,
                errorMessage: error.localizedDescription,
                errorCode: (error as? UtilityExecutionError)?.exitCode
            )
        }
    }
}

// MARK: - Speedtest Strategy
public class SpeedtestStrategy: TestStrategy {
    private let utilityExecutor: UtilityExecutor

    public let testType: TestType = .speedtest

    public init(utilityExecutor: UtilityExecutor) {
        self.utilityExecutor = utilityExecutor
    }

    public func execute(target: String, timeout: TimeInterval) async throws -> TestResult {
        let command = "speedtest-cli --simple --timeout \(Int(timeout))"

        do {
            let output = try await utilityExecutor.executeCommand(command, timeout: timeout)
            let parser = OutputParser()
            let speedtestData = try parser.parseSpeedtestOutput(output)

            return TestResult(
                success: speedtestData.ping != nil && speedtestData.download != nil && speedtestData.upload != nil,
                latency: speedtestData.ping,
                data: speedtestData,
                errorMessage: nil,
                errorCode: nil
            )
        } catch {
            return TestResult(
                success: false,
                latency: nil,
                data: nil,
                errorMessage: error.localizedDescription,
                errorCode: (error as? UtilityExecutionError)?.exitCode
            )
        }
    }
}

// MARK: - Test Strategy Factory
public class TestStrategyFactory {
    private let utilityExecutor: UtilityExecutor

    public init(utilityExecutor: UtilityExecutor) {
        self.utilityExecutor = utilityExecutor
    }

    public func createStrategy(for testType: TestType) -> TestStrategy {
        switch testType {
        case .ping:
            return PingTestStrategy(utilityExecutor: utilityExecutor)
        case .http:
            return HttpTestStrategy(utilityExecutor: utilityExecutor)
        case .dns:
            return DnsTestStrategy(utilityExecutor: utilityExecutor)
        case .speedtest:
            return SpeedtestStrategy(utilityExecutor: utilityExecutor)
        }
    }
}

// MARK: - Test Result
public struct TestResult {
    public let success: Bool
    public let latency: Double?
    public let data: Any?
    public let errorMessage: String?
    public let errorCode: Int?

    public init(success: Bool, latency: Double?, data: Any?, errorMessage: String?, errorCode: Int?) {
        self.success = success
        self.latency = latency
        self.data = data
        self.errorMessage = errorMessage
        self.errorCode = errorCode
    }
}

// MARK: - Test Context
public struct TestContext {
    public let target: String
    public let timeout: TimeInterval
    public let retryCount: Int
    public let testType: TestType

    public init(target: String, timeout: TimeInterval = 10.0, retryCount: Int = 3, testType: TestType) {
        self.target = target
        self.timeout = timeout
        self.retryCount = retryCount
        self.testType = testType
    }
}

// MARK: - Test Executor
public class TestExecutor {
    private let strategyFactory: TestStrategyFactory
    private let logger: Logger

    public init(strategyFactory: TestStrategyFactory, logger: Logger = Logger(label: "TestExecutor")) {
        self.strategyFactory = strategyFactory
        self.logger = logger
    }

    public func executeTest(context: TestContext) async -> TestResult {
        let strategy = strategyFactory.createStrategy(for: context.testType)

        logger.info("Executing \(context.testType.rawValue) test for \(context.target)")

        do {
            let result = try await strategy.execute(target: context.target, timeout: context.timeout)
            logger.info("Test completed: \(result.success ? "success" : "failure")")
            return result
        } catch {
            logger.error("Test execution failed: \(error)")
            return TestResult(
                success: false,
                latency: nil,
                data: nil,
                errorMessage: error.localizedDescription,
                errorCode: (error as? UtilityExecutionError)?.exitCode
            )
        }
    }

    public func executeTests(contexts: [TestContext]) async -> [TestResult] {
        return await withTaskGroup(of: TestResult.self) { group in
            for context in contexts {
                group.addTask {
                    await self.executeTest(context: context)
                }
            }

            var results: [TestResult] = []
            for await result in group {
                results.append(result)
            }
            return results
        }
    }
}
