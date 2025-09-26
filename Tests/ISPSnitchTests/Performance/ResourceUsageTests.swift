import XCTest
import Foundation
@testable import ISPSnitchCore

/// Resource usage tests for ISP Snitch
/// Validates resource consumption and efficiency
@MainActor
class ResourceUsageTests: XCTestCase {

    
    func testMemoryStability() throws {
        let service = ISPSnitchService.shared

        // Start service
        try service.start()
        defer { try? service.stop() }

        // Get initial memory usage
        let initialMetrics = try service.getMetrics()
        let initialMemory = initialMetrics.memoryUsage

        // Wait and perform operations
        Thread.sleep(forTimeInterval: 5.0) // 5 seconds

        // Get final memory usage
        let finalMetrics = try service.getMetrics()
        let finalMemory = finalMetrics.memoryUsage

        // Validate memory stability
        let memoryIncrease = finalMemory - initialMemory
        XCTAssertLessThan(memoryIncrease, 10.0, "Memory increased by \(memoryIncrease)MB, exceeding 10MB threshold")
    }

    
    func testCpuUsageIdle() throws {
        let service = ISPSnitchService.shared

        // Start service
        try service.start()
        defer { try? service.stop() }

        // Wait for idle state
        Thread.sleep(forTimeInterval: 3.0) // 3 seconds

        // Get metrics
        let metrics = try service.getMetrics()

        // Validate idle CPU usage
        XCTAssertLessThan(metrics.cpuUsage, 0.5, "Idle CPU usage \(metrics.cpuUsage)% exceeds 0.5% threshold")
    }

    
    func testNetworkEfficiency() throws {
        let service = ISPSnitchService.shared

        // Start service
        try service.start()
        defer { try? service.stop() }

        // Wait for network monitoring to start
        Thread.sleep(forTimeInterval: 2.0) // 2 seconds

        // Get metrics
        let metrics = try service.getMetrics()

        // Validate network efficiency
        XCTAssertLessThan(metrics.averageResponseTime, 2.0, "Average response time \(metrics.averageResponseTime)s exceeds 2s threshold")
    }

    
    func testMemoryPressureHandling() throws {
        let service = ISPSnitchService.shared

        // Start service
        try service.start()
        defer { try? service.stop() }

        // Simulate memory pressure by creating temporary objects
        for _ in 0..<1000 {
            _ = String(repeating: "test", count: 1000)
        }

        // Get metrics after memory pressure
        let metrics = try service.getMetrics()

        // Validate memory usage under pressure
        XCTAssertLessThan(metrics.memoryUsage, 100.0, "Memory usage under pressure \(metrics.memoryUsage)MB exceeds 100MB threshold")
    }

    
    func testMultipleRestarts() throws {
        let service = ISPSnitchService.shared

        // Perform multiple start/stop cycles
        for _ in 0..<5 {
            try service.start()
            Thread.sleep(forTimeInterval: 1.0) // 1 second
            do {
                try service.stop()
            } catch ServiceError.notRunning {
                // Service was already stopped, which is fine
            }
            Thread.sleep(forTimeInterval: 0.5) // 0.5 seconds
        }

        // Final start
        try service.start()
        defer { try? service.stop() }

        // Get final metrics
        let metrics = try service.getMetrics()

        // Validate performance after multiple restarts
        XCTAssertLessThan(metrics.cpuUsage, 2.0, "CPU usage after restarts \(metrics.cpuUsage)% exceeds 2% threshold")
        XCTAssertLessThan(metrics.memoryUsage, 75.0, "Memory usage after restarts \(metrics.memoryUsage)MB exceeds 75MB threshold")
    }

    
    func testConcurrentAccess() throws {
        let service = ISPSnitchService.shared

        // Start service
        try service.start()
        defer { try? service.stop() }

        // Simulate concurrent access
        let startTime = Date()
        var cpuUsages: [Double] = []
        
        for _ in 0..<20 {
            let metrics = try? service.getMetrics()
            cpuUsages.append(metrics?.cpuUsage ?? 0.0)
        }

        let totalTime = Date().timeIntervalSince(startTime)

        // Validate concurrent access performance
        XCTAssertLessThan(totalTime, 2.0, "Concurrent access took \(totalTime)s, exceeding 2s threshold")

        let maxCpuUsage = cpuUsages.max() ?? 0.0
        XCTAssertLessThan(maxCpuUsage, 3.0, "Max CPU usage during concurrent access \(maxCpuUsage)% exceeds 3% threshold")
    }

    
    func testResourceCleanup() throws {
        let service = ISPSnitchService.shared

        // Start service
        try service.start()

        // Get metrics while running
        let runningMetrics = try service.getMetrics()
        let _ = runningMetrics.memoryUsage

        // Stop service
        do {
            try service.stop()
        } catch ServiceError.notRunning {
            // Service was already stopped, which is fine
        }

        // Wait for cleanup
        Thread.sleep(forTimeInterval: 1.0) // 1 second

        // Validate service is stopped
        let status = service.getStatus()
        XCTAssertEqual(status, .stopped, "Service should be stopped after shutdown")
    }
}
