import Foundation

// MARK: - Observer Pattern Implementation
public protocol Observer: AnyObject {
    func update(with event: ServiceEvent)
}

public protocol Observable {
    func addObserver(_ observer: Observer)
    func removeObserver(_ observer: Observer)
    func notifyObservers(with event: ServiceEvent)
}

// MARK: - Service Events
public enum ServiceEvent {
    case serviceStarted
    case serviceStopped
    case testCompleted(ConnectivityRecord)
    case testFailed(target: String, error: String)
    case metricsUpdated(SystemMetrics)
    case configurationChanged(TestConfiguration)
    case errorOccurred(Error)
}

// MARK: - Service Event Bus
public class ServiceEventBus: Observable {
    private var observers: [WeakObserver] = []
    private let queue = DispatchQueue(label: "ServiceEventBus", attributes: .concurrent)

    public init() {}

    public func addObserver(_ observer: Observer) {
        queue.async(flags: .barrier) {
            self.observers.append(WeakObserver(observer: observer))
            self.cleanupWeakReferences()
        }
    }

    public func removeObserver(_ observer: Observer) {
        queue.async(flags: .barrier) {
            self.observers.removeAll { $0.observer === observer }
        }
    }

    public func notifyObservers(with event: ServiceEvent) {
        queue.async {
            let activeObservers = self.observers.compactMap { $0.observer }
            for observer in activeObservers {
                observer.update(with: event)
            }
        }
    }

    private func cleanupWeakReferences() {
        observers.removeAll { $0.observer == nil }
    }
}

// MARK: - Weak Observer Wrapper
private class WeakObserver {
    weak var observer: Observer?

    init(observer: Observer) {
        self.observer = observer
    }
}

// MARK: - Service Status Observer
public class ServiceStatusObserver: Observer {
    private let logger: Logger

    public init(logger: Logger = Logger(label: "ServiceStatusObserver")) {
        self.logger = logger
    }

    public func update(with event: ServiceEvent) {
        switch event {
        case .serviceStarted:
            logger.info("Service started")
        case .serviceStopped:
            logger.info("Service stopped")
        case .testCompleted(let record):
            logger.info("Test completed: \(record.testType.rawValue) for \(record.target) - \(record.success ? "success" : "failure")")
        case .testFailed(let target, let error):
            logger.error("Test failed for \(target): \(error)")
        case .metricsUpdated(let metrics):
            logger.debug("Metrics updated: CPU \(metrics.cpuUsage)%, Memory \(metrics.memoryUsage)MB")
        case .configurationChanged(let config):
            logger.info("Configuration changed: \(config.name)")
        case .errorOccurred(let error):
            logger.error("Error occurred: \(error)")
        }
    }
}

// MARK: - Metrics Observer
public class MetricsObserver: Observer {
    private var lastMetrics: SystemMetrics?
    private let threshold: Double

    public init(threshold: Double = 80.0) {
        self.threshold = threshold
    }

    public func update(with event: ServiceEvent) {
        switch event {
        case .metricsUpdated(let metrics):
            checkMetricsThreshold(metrics)
            lastMetrics = metrics
        default:
            break
        }
    }

    private func checkMetricsThreshold(_ metrics: SystemMetrics) {
        if metrics.cpuUsage > threshold {
            print("⚠️ High CPU usage: \(metrics.cpuUsage)%")
        }

        if metrics.memoryUsage > threshold {
            print("⚠️ High memory usage: \(metrics.memoryUsage)MB")
        }

        if metrics.diskUsage > threshold {
            print("⚠️ High disk usage: \(metrics.diskUsage)%")
        }
    }
}

// MARK: - Test Results Observer
public class TestResultsObserver: Observer {
    private var testResults: [TestType: [ConnectivityRecord]] = [:]
    private let maxResultsPerType = 100

    public init() {}

    public func update(with event: ServiceEvent) {
        switch event {
        case .testCompleted(let record):
            addTestResult(record)
        case .testFailed(let target, let error):
            // Create a failed record for tracking
            let failedRecord = ConnectivityRecordBuilder()
                .withTarget(target)
                .withFailure(error: error)
                .build()
            addTestResult(failedRecord)
        default:
            break
        }
    }

    private func addTestResult(_ record: ConnectivityRecord) {
        if testResults[record.testType] == nil {
            testResults[record.testType] = []
        }

        testResults[record.testType]?.append(record)

        // Keep only the most recent results
        if let count = testResults[record.testType]?.count, count > maxResultsPerType {
            testResults[record.testType]?.removeFirst(count - maxResultsPerType)
        }
    }

    public func getResults(for testType: TestType) -> [ConnectivityRecord] {
        return testResults[testType] ?? []
    }

    public func getSuccessRate(for testType: TestType) -> Double {
        let results = getResults(for: testType)
        guard !results.isEmpty else { return 0.0 }

        let successfulTests = results.filter { $0.success }.count
        return Double(successfulTests) / Double(results.count)
    }
}

// MARK: - Event Publisher
public class EventPublisher {
    private let eventBus: ServiceEventBus

    public init(eventBus: ServiceEventBus) {
        self.eventBus = eventBus
    }

    public func publishServiceStarted() {
        eventBus.notifyObservers(with: .serviceStarted)
    }

    public func publishServiceStopped() {
        eventBus.notifyObservers(with: .serviceStopped)
    }

    public func publishTestCompleted(_ record: ConnectivityRecord) {
        eventBus.notifyObservers(with: .testCompleted(record))
    }

    public func publishTestFailed(target: String, error: String) {
        eventBus.notifyObservers(with: .testFailed(target: target, error: error))
    }

    public func publishMetricsUpdated(_ metrics: SystemMetrics) {
        eventBus.notifyObservers(with: .metricsUpdated(metrics))
    }

    public func publishConfigurationChanged(_ config: TestConfiguration) {
        eventBus.notifyObservers(with: .configurationChanged(config))
    }

    public func publishErrorOccurred(_ error: Error) {
        eventBus.notifyObservers(with: .errorOccurred(error))
    }
}

// MARK: - Observable Service
public class ObservableISPSnitchService: ISPSnitchServiceProtocol {
    private let service: ISPSnitchServiceProtocol
    private let eventPublisher: EventPublisher

    public init(service: ISPSnitchServiceProtocol, eventPublisher: EventPublisher) {
        self.service = service
        self.eventPublisher = eventPublisher
    }

    public func start() async throws {
        try await service.start()
        eventPublisher.publishServiceStarted()
    }

    public func stop() async throws {
        try await service.stop()
        eventPublisher.publishServiceStopped()
    }

    public func getStatus() async -> ServiceStatus {
        return await service.getStatus()
    }

    public func getMetrics() async -> SystemMetrics {
        let metrics = await service.getMetrics()
        eventPublisher.publishMetricsUpdated(metrics)
        return metrics
    }
}
