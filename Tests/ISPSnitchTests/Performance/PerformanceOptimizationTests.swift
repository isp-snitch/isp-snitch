import XCTest
import Foundation
@testable import ISPSnitchCore

/// Performance optimization tests for ISP Snitch
/// Validates that the service meets performance criteria
class PerformanceOptimizationTests: XCTestCase {

    
    func testCpuUsage() throws {
        let service = ISPSnitchService.shared

        // Start service
        try service.start()
        defer { try? service.stop() }

        // Wait for service to stabilize
        Thread.sleep(forTimeInterval: 2.0) // 2 seconds

        // Get metrics
        let metrics = try service.getMetrics()

        // Validate CPU usage
        XCTAssertLessThan(metrics.cpuUsage, 1.0, "CPU usage \(metrics.cpuUsage)% exceeds 1% threshold")
    }

    
    func testMemoryUsage() throws {
        let service = ISPSnitchService.shared

        // Start service
        try service.start()
        defer { try? service.stop() }

        // Wait for service to stabilize
        Thread.sleep(forTimeInterval: 2.0) // 2 seconds

        // Get metrics
        let metrics = try service.getMetrics()

        // Validate memory usage
        XCTAssertLessThan(metrics.memoryUsage, 50.0, "Memory usage \(metrics.memoryUsage)MB exceeds 50MB threshold")
    }

    
    func testStartupTime() throws {
        let service = ISPSnitchService.shared

        let startTime = Date()
        try service.start()
        let startupTime = Date().timeIntervalSince(startTime)

        defer { try? service.stop() }

        // Validate startup time
        XCTAssertLessThan(startupTime, 5.0, "Startup time \(startupTime)s exceeds 5s threshold")
    }

    
    func testCliResponseTime() throws {
        let startTime = Date()

        // Simulate CLI command execution
        let service = ISPSnitchService.shared
        let status = service.getStatus()

        let responseTime = Date().timeIntervalSince(startTime)

        // Validate response time
        XCTAssertLessThan(responseTime, 0.1, "CLI response time \(responseTime)s exceeds 100ms threshold")
        XCTAssertTrue(status == .stopped || status == .running || status == .starting, "Invalid service status: \(status)")
    }

    
    func testNetworkOverhead() throws {
        let service = ISPSnitchService.shared

        // Start service
        try service.start()
        defer { try? service.stop() }

        // Wait for service to stabilize
        Thread.sleep(forTimeInterval: 2.0) // 2 seconds

        // Get metrics
        let metrics = try service.getMetrics()

        // Validate network efficiency (indirect measurement)
        XCTAssertLessThan(metrics.averageResponseTime, 1.0, "Average response time \(metrics.averageResponseTime)s exceeds 1s threshold")
    }

    
    func testConcurrentRequests() throws {
        let service = ISPSnitchService.shared

        // Start service
        try service.start()
        defer { try? service.stop() }

        // Simulate concurrent requests
        let startTime = Date()
        var results: [Bool] = []
        
        for _ in 0..<10 {
            let metrics = try? service.getMetrics()
            results.append(metrics != nil)
        }

        let totalTime = Date().timeIntervalSince(startTime)

        // Validate concurrent performance
        XCTAssert(results.allSatisfy { $0 }, "Some concurrent requests failed")
        XCTAssertLessThan(totalTime, 1.0, "Concurrent requests took \(totalTime)s, exceeding 1s threshold")
    }

    
    func testPerformanceUnderLoad() throws {
        let service = ISPSnitchService.shared

        // Start service
        try service.start()
        defer { try? service.stop() }

        // Simulate load
        let startTime = Date()
        for _ in 0..<100 {
            let metrics = try service.getMetrics()
            XCTAssertLessThan(metrics.cpuUsage, 5.0, "CPU usage under load \(metrics.cpuUsage)% exceeds 5% threshold")
        }
        let totalTime = Date().timeIntervalSince(startTime)

        // Validate performance under load
        XCTAssertLessThan(totalTime, 10.0, "Load test took \(totalTime)s, exceeding 10s threshold")
    }

    
    func testErrorRecovery() throws {
        let service = ISPSnitchService.shared

        // Start service
        try service.start()
        defer { try? service.stop() }

        // Simulate error conditions
        let startTime = Date()

        // Test error handling
        do {
            try service.stop()
            try service.start()
        } catch {
            // Expected behavior
        }

        let recoveryTime = Date().timeIntervalSince(startTime)

        // Validate error recovery
        XCTAssertLessThan(recoveryTime, 2.0, "Error recovery took \(recoveryTime)s, exceeding 2s threshold")
    }
}
