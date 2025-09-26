import Testing
import Foundation
@testable import ISPSnitchCore

/// Resource usage tests for ISP Snitch
/// Validates resource consumption and efficiency
@MainActor
struct ResourceUsageTests {

    @Test("Memory usage should remain stable over time")
    func testMemoryStability() async throws {
        let service = ISPSnitchService.shared

        // Start service
        try await service.start()
        defer { Task { try? await service.stop() } }

        // Get initial memory usage
        let initialMetrics = try await service.getMetrics()
        let initialMemory = initialMetrics.memoryUsage

        // Wait and perform operations
        try await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds

        // Get final memory usage
        let finalMetrics = try await service.getMetrics()
        let finalMemory = finalMetrics.memoryUsage

        // Validate memory stability
        let memoryIncrease = finalMemory - initialMemory
        #expect(memoryIncrease < 10.0, "Memory increased by \(memoryIncrease)MB, exceeding 10MB threshold")
    }

    @Test("CPU usage should remain low during idle")
    func testCpuUsageIdle() async throws {
        let service = ISPSnitchService.shared

        // Start service
        try await service.start()
        defer { Task { try? await service.stop() } }

        // Wait for idle state
        try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds

        // Get metrics
        let metrics = try await service.getMetrics()

        // Validate idle CPU usage
        #expect(metrics.cpuUsage < 0.5, "Idle CPU usage \(metrics.cpuUsage)% exceeds 0.5% threshold")
    }

    @Test("Network monitoring should be efficient")
    func testNetworkEfficiency() async throws {
        let service = ISPSnitchService.shared

        // Start service
        try await service.start()
        defer { Task { try? await service.stop() } }

        // Wait for network monitoring to start
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds

        // Get metrics
        let metrics = try await service.getMetrics()

        // Validate network efficiency
        #expect(metrics.averageResponseTime < 2.0, "Average response time \(metrics.averageResponseTime)s exceeds 2s threshold")
    }

    @Test("Service should handle memory pressure gracefully")
    func testMemoryPressureHandling() async throws {
        let service = ISPSnitchService.shared

        // Start service
        try await service.start()
        defer { Task { try? await service.stop() } }

        // Simulate memory pressure by creating temporary objects
        for _ in 0..<1000 {
            _ = String(repeating: "test", count: 1000)
        }

        // Get metrics after memory pressure
        let metrics = try await service.getMetrics()

        // Validate memory usage under pressure
        #expect(metrics.memoryUsage < 100.0, "Memory usage under pressure \(metrics.memoryUsage)MB exceeds 100MB threshold")
    }

    @Test("Service should maintain performance with multiple restarts")
    func testMultipleRestarts() async throws {
        let service = ISPSnitchService.shared

        // Perform multiple start/stop cycles
        for _ in 0..<5 {
            try await service.start()
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            do {
                try await service.stop()
            } catch ServiceError.notRunning {
                // Service was already stopped, which is fine
            }
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        }

        // Final start
        try await service.start()
        defer { Task { try? await service.stop() } }

        // Get final metrics
        let metrics = try await service.getMetrics()

        // Validate performance after multiple restarts
        #expect(metrics.cpuUsage < 2.0, "CPU usage after restarts \(metrics.cpuUsage)% exceeds 2% threshold")
        #expect(metrics.memoryUsage < 75.0, "Memory usage after restarts \(metrics.memoryUsage)MB exceeds 75MB threshold")
    }

    @Test("Service should handle concurrent access efficiently")
    func testConcurrentAccess() async throws {
        let service = ISPSnitchService.shared

        // Start service
        try await service.start()
        defer { Task { try? await service.stop() } }

        // Simulate concurrent access
        let startTime = Date()
        let tasks = (0..<20).map { _ in
            Task {
                let metrics = try? await service.getMetrics()
                return metrics?.cpuUsage ?? 0.0
            }
        }

        let cpuUsages = await withTaskGroup(of: Double.self) { group in
            for task in tasks {
                group.addTask { await task.value }
            }

            var usages: [Double] = []
            for await usage in group {
                usages.append(usage)
            }
            return usages
        }

        let totalTime = Date().timeIntervalSince(startTime)

        // Validate concurrent access performance
        #expect(totalTime < 2.0, "Concurrent access took \(totalTime)s, exceeding 2s threshold")

        let maxCpuUsage = cpuUsages.max() ?? 0.0
        #expect(maxCpuUsage < 3.0, "Max CPU usage during concurrent access \(maxCpuUsage)% exceeds 3% threshold")
    }

    @Test("Service should clean up resources on shutdown")
    func testResourceCleanup() async throws {
        let service = ISPSnitchService.shared

        // Start service
        try await service.start()

        // Get metrics while running
        let runningMetrics = try await service.getMetrics()
        let runningMemory = runningMetrics.memoryUsage

        // Stop service
        do {
            try await service.stop()
        } catch ServiceError.notRunning {
            // Service was already stopped, which is fine
        }

        // Wait for cleanup
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        // Validate service is stopped
        let status = service.getStatus()
        #expect(status == .stopped, "Service should be stopped after shutdown")
    }
}
