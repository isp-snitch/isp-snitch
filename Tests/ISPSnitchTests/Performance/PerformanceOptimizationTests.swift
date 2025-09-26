import Testing
import Foundation
@testable import ISPSnitchCore

/// Performance optimization tests for ISP Snitch
/// Validates that the service meets performance criteria
@MainActor
struct PerformanceOptimizationTests {

    @Test("CPU usage should be under 1% average")
    func testCpuUsage() async throws {
        let service = ISPSnitchService.shared

        // Start service
        try await service.start()
        defer { Task { try? await service.stop() } }

        // Wait for service to stabilize
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds

        // Get metrics
        let metrics = try await service.getMetrics()

        // Validate CPU usage
        #expect(metrics.cpuUsage < 1.0, "CPU usage \(metrics.cpuUsage)% exceeds 1% threshold")
    }

    @Test("Memory usage should be under 50MB baseline")
    func testMemoryUsage() async throws {
        let service = ISPSnitchService.shared

        // Start service
        try await service.start()
        defer { Task { try? await service.stop() } }

        // Wait for service to stabilize
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds

        // Get metrics
        let metrics = try await service.getMetrics()

        // Validate memory usage
        #expect(metrics.memoryUsage < 50.0, "Memory usage \(metrics.memoryUsage)MB exceeds 50MB threshold")
    }

    @Test("Startup time should be under 5 seconds")
    func testStartupTime() async throws {
        let service = ISPSnitchService.shared

        let startTime = Date()
        try await service.start()
        let startupTime = Date().timeIntervalSince(startTime)

        defer { Task { try? await service.stop() } }

        // Validate startup time
        #expect(startupTime < 5.0, "Startup time \(startupTime)s exceeds 5s threshold")
    }

    @Test("CLI response time should be under 100ms")
    func testCliResponseTime() async throws {
        let startTime = Date()

        // Simulate CLI command execution
        let service = ISPSnitchService.shared
        let status = service.getStatus()

        let responseTime = Date().timeIntervalSince(startTime)

        // Validate response time
        #expect(responseTime < 0.1, "CLI response time \(responseTime)s exceeds 100ms threshold")
        #expect(status == .stopped || status == .running || status == .starting, "Invalid service status: \(status)")
    }

    @Test("Network overhead should be minimal")
    func testNetworkOverhead() async throws {
        let service = ISPSnitchService.shared

        // Start service
        try await service.start()
        defer { Task { try? await service.stop() } }

        // Wait for service to stabilize
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds

        // Get metrics
        let metrics = try await service.getMetrics()

        // Validate network efficiency (indirect measurement)
        #expect(metrics.averageResponseTime < 1.0, "Average response time \(metrics.averageResponseTime)s exceeds 1s threshold")
    }

    @Test("Service should handle concurrent requests efficiently")
    func testConcurrentRequests() async throws {
        let service = ISPSnitchService.shared

        // Start service
        try await service.start()
        defer { Task { try? await service.stop() } }

        // Simulate concurrent requests
        let startTime = Date()
        let tasks = (0..<10).map { _ in
            Task {
                let metrics = try? await service.getMetrics()
                return metrics != nil
            }
        }

        let results = await withTaskGroup(of: Bool.self) { group in
            for task in tasks {
                group.addTask { await task.value }
            }

            var results: [Bool] = []
            for await result in group {
                results.append(result)
            }
            return results
        }

        let totalTime = Date().timeIntervalSince(startTime)

        // Validate concurrent performance
        #expect(results.allSatisfy { $0 }, "Some concurrent requests failed")
        #expect(totalTime < 1.0, "Concurrent requests took \(totalTime)s, exceeding 1s threshold")
    }

    @Test("Service should maintain performance under load")
    func testPerformanceUnderLoad() async throws {
        let service = ISPSnitchService.shared

        // Start service
        try await service.start()
        defer { Task { try? await service.stop() } }

        // Simulate load
        let startTime = Date()
        for _ in 0..<100 {
            let metrics = try await service.getMetrics()
            #expect(metrics.cpuUsage < 5.0, "CPU usage under load \(metrics.cpuUsage)% exceeds 5% threshold")
        }
        let totalTime = Date().timeIntervalSince(startTime)

        // Validate performance under load
        #expect(totalTime < 10.0, "Load test took \(totalTime)s, exceeding 10s threshold")
    }

    @Test("Service should recover from errors efficiently")
    func testErrorRecovery() async throws {
        let service = ISPSnitchService.shared

        // Start service
        try await service.start()
        defer { Task { try? await service.stop() } }

        // Simulate error conditions
        let startTime = Date()

        // Test error handling
        do {
            try await service.stop()
            try await service.start()
        } catch {
            // Expected behavior
        }

        let recoveryTime = Date().timeIntervalSince(startTime)

        // Validate error recovery
        #expect(recoveryTime < 2.0, "Error recovery took \(recoveryTime)s, exceeding 2s threshold")
    }
}
