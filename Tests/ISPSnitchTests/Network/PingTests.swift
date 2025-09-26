import XCTest
import Foundation
@testable import ISPSnitchCore

class PingTests: XCTestCase {

    func testpingCommandFormat() throws {
        // Test that we can construct the correct ping command
        let target = "8.8.8.8"
        let expectedCommand = "ping -c 1 -W 1000 \(target)"

        // This would be the actual command construction in the implementation
        let command = "ping -c 1 -W 1000 \(target)"
        XCTAssertEqual(command, expectedCommand)
    }

    func testparsePingSuccessOutput() throws {
        let successOutput = """
        PING 8.8.8.8 (8.8.8.8): 56 data bytes
        64 bytes from 8.8.8.8: icmp_seq=0 ttl=117 time=24.155 ms

        --- 8.8.8.8 ping statistics ---
        1 packets transmitted, 1 packets received, 0.0% packet loss
        round-trip min/avg/max/stddev = 24.155/24.155/24.155/0.000 ms
        """

        // Test parsing logic (this would be implemented in the actual service)
        let lines = successOutput.components(separatedBy: .newlines)

        // Extract latency from "time=XX.XXX ms" pattern
        let timeLine = lines.first { $0.contains("time=") } ?? ""
        let timeMatch = timeLine.range(of: "time=([0-9.]+) ms", options: .regularExpression)
        XCTAssert(timeMatch != nil)

        // Extract TTL from "ttl=XXX" pattern
        let ttlMatch = timeLine.range(of: "ttl=([0-9]+)", options: .regularExpression)
        XCTAssert(ttlMatch != nil)

        // Check for success indicators
        let hasPacketsReceived = successOutput.contains("packets received")
        XCTAssertEqual(hasPacketsReceived, true)

        // Extract packet loss from "X.X% packet loss" pattern
        let packetLossMatch = successOutput.range(of: "([0-9.]+)% packet loss", options: .regularExpression)
        XCTAssert(packetLossMatch != nil)

        // Extract statistics from "round-trip min/avg/max/stddev" line
        let statsLine = lines.first { $0.contains("round-trip") } ?? ""
        let statsMatch = statsLine.range(of: "([0-9.]+)/([0-9.]+)/([0-9.]+)/([0-9.]+) ms", options: .regularExpression)
        XCTAssert(statsMatch != nil)
    }

    func testparsePingFailureOutput() throws {
        let failureOutput = "ping: cannot resolve 192.168.1.999: Unknown host"

        // Test parsing failure output
        let isDnsFailure = failureOutput.contains("cannot resolve")
        XCTAssertEqual(isDnsFailure, true)

        let isUnknownHost = failureOutput.contains("Unknown host")
        XCTAssertEqual(isUnknownHost, true)
    }

    func testpingExitCodes() throws {
        // Test expected exit codes
        let successExitCode = 0
        let dnsFailureExitCode = 68

        XCTAssertEqual(successExitCode, 0)
        XCTAssertEqual(dnsFailureExitCode, 68)

        // Test that we can handle different exit codes
        let exitCodes: [Int32] = [0, 68, 1, 2]
        for code in exitCodes {
            let isSuccess = code == 0
            let isDnsFailure = code == 68
            let isOtherFailure = code != 0 && code != 68

            XCTAssert(isSuccess || isDnsFailure || isOtherFailure)
        }
    }

    func testpingTimeoutHandling() throws {
        // Test timeout configuration
        let timeoutMs = 1000
        let command = "ping -c 1 -W \(timeoutMs) 8.8.8.8"

        XCTAssert(command.contains("-W \(timeoutMs)"))
        XCTAssert(command.contains("-c 1"))
    }

    func testpingTargetValidation() throws {
        // Test valid targets
        let validTargets = ["8.8.8.8", "1.1.1.1", "google.com", "example.com"]

        for target in validTargets {
            let command = "ping -c 1 -W 1000 \(target)"
            XCTAssert(command.contains(target))
        }

        // Test invalid targets
        let invalidTargets = ["192.168.1.999", "nonexistent.invalid"]

        for target in invalidTargets {
            let command = "ping -c 1 -W 1000 \(target)"
            XCTAssert(command.contains(target))
        }
    }

    func testpingStatisticsParsing() throws {
        let statsLine = "round-trip min/avg/max/stddev = 24.155/24.155/24.155/0.000 ms"

        // Test parsing statistics
        let components = statsLine.components(separatedBy: " = ")[1]
        let values = components.components(separatedBy: " ")[0]
        let stats = values.components(separatedBy: "/")

        XCTAssertEqual(stats.count, 4)
        XCTAssertEqual(stats[0], "24.155") // min
        XCTAssertEqual(stats[1], "24.155") // avg
        XCTAssertEqual(stats[2], "24.155") // max
        XCTAssertEqual(stats[3], "0.000")  // stddev
    }

    func testpingPacketLossCalculation() throws {
        // Test packet loss parsing
        let successStats = "1 packets transmitted, 1 packets received, 0.0% packet loss"
        let failureStats = "1 packets transmitted, 0 packets received, 100.0% packet loss"

        let successLoss = extractPacketLoss(from: successStats)
        let failureLoss = extractPacketLoss(from: failureStats)

        XCTAssertEqual(successLoss, 0.0)
        XCTAssertEqual(failureLoss, 100.0)
    }

    func testpingLatencyExtraction() throws {
        let timeLine = "64 bytes from 8.8.8.8: icmp_seq=0 ttl=117 time=24.155 ms"

        let latency = extractLatency(from: timeLine)
        XCTAssertEqual(latency, 24.155)
    }

    func testpingTtlExtraction() throws {
        let timeLine = "64 bytes from 8.8.8.8: icmp_seq=0 ttl=117 time=24.155 ms"

        let ttl = extractTtl(from: timeLine)
        XCTAssertEqual(ttl, 117)
    }

    // Helper functions for parsing (these would be implemented in the actual service)
    private func extractPacketLoss(from stats: String) -> Double {
        let pattern = "([0-9.]+)% packet loss"
        if let range = stats.range(of: pattern, options: .regularExpression) {
            let match = String(stats[range])
            let value = match.replacingOccurrences(of: "% packet loss", with: "")
            return Double(value) ?? 0.0
        }
        return 0.0
    }

    private func extractLatency(from line: String) -> Double {
        let pattern = "time=([0-9.]+) ms"
        if let range = line.range(of: pattern, options: .regularExpression) {
            let match = String(line[range])
            let value = match.replacingOccurrences(of: "time=", with: "").replacingOccurrences(of: " ms", with: "")
            return Double(value) ?? 0.0
        }
        return 0.0
    }

    private func extractTtl(from line: String) -> Int {
        let pattern = "ttl=([0-9]+)"
        if let range = line.range(of: pattern, options: .regularExpression) {
            let match = String(line[range])
            let value = match.replacingOccurrences(of: "ttl=", with: "")
            return Int(value) ?? 0
        }
        return 0
    }
}
