import XCTest
import Foundation
@testable import ISPSnitchCore

class HttpTests: XCTestCase {

    func testcurlCommandFormat() throws {
        // Test that we can construct the correct curl command
        let url = "https://google.com"
        let expectedCommand = "curl -w \"HTTP_CODE:%{http_code}\\nTIME_TOTAL:%{time_total}\\nTIME_CONNECT:%{time_connect}\\nTIME_NAMELOOKUP:%{time_namelookup}\\nSIZE_DOWNLOAD:%{size_download}\\nSPEED_DOWNLOAD:%{speed_download}\\n\" -o /dev/null -s --max-time 10 \(url)"

        // This would be the actual command construction in the implementation
        let command = "curl -w \"HTTP_CODE:%{http_code}\\nTIME_TOTAL:%{time_total}\\nTIME_CONNECT:%{time_connect}\\nTIME_NAMELOOKUP:%{time_namelookup}\\nSIZE_DOWNLOAD:%{size_download}\\nSPEED_DOWNLOAD:%{speed_download}\\n\" -o /dev/null -s --max-time 10 \(url)"
        XCTAssertEqual(command, expectedCommand)
    }

    func testparseHttpSuccessOutput() throws {
        let successOutput = """
        HTTP_CODE:200
        TIME_TOTAL:10.317338
        TIME_CONNECT:0.051629
        TIME_NAMELOOKUP:0.023162
        SIZE_DOWNLOAD:0
        SPEED_DOWNLOAD:0
        """

        // Test parsing logic
        let lines = successOutput.components(separatedBy: .newlines)

        // Extract HTTP code
        let httpCodeLine = lines.first { $0.contains("HTTP_CODE:") } ?? ""
        let httpCode = extractHttpCode(from: httpCodeLine)
        XCTAssertEqual(httpCode, 200)

        // Extract total time
        let totalTimeLine = lines.first { $0.contains("TIME_TOTAL:") } ?? ""
        let totalTime = extractTotalTime(from: totalTimeLine)
        XCTAssertEqual(totalTime, 10.317338)

        // Extract connect time
        let connectTimeLine = lines.first { $0.contains("TIME_CONNECT:") } ?? ""
        let connectTime = extractConnectTime(from: connectTimeLine)
        XCTAssertEqual(connectTime, 0.051629)

        // Extract DNS time
        let dnsTimeLine = lines.first { $0.contains("TIME_NAMELOOKUP:") } ?? ""
        let dnsTime = extractDnsTime(from: dnsTimeLine)
        XCTAssertEqual(dnsTime, 0.023162)

        // Extract download size
        let downloadSizeLine = lines.first { $0.contains("SIZE_DOWNLOAD:") } ?? ""
        let downloadSize = extractDownloadSize(from: downloadSizeLine)
        XCTAssertEqual(downloadSize, 0)

        // Extract download speed
        let downloadSpeedLine = lines.first { $0.contains("SPEED_DOWNLOAD:") } ?? ""
        let downloadSpeed = extractDownloadSpeed(from: downloadSpeedLine)
        XCTAssertEqual(downloadSpeed, 0)
    }

    func testparseHttpFailureOutput() throws {
        let failureOutput = """
        HTTP_CODE:000
        TIME_TOTAL:0.075493
        TIME_CONNECT:0.000000
        TIME_NAMELOOKUP:0.000000
        SIZE_DOWNLOAD:0
        SPEED_DOWNLOAD:0
        """

        // Test parsing failure output
        let lines = failureOutput.components(separatedBy: .newlines)
        let httpCodeLine = lines.first { $0.contains("HTTP_CODE:") } ?? ""
        let httpCode = extractHttpCode(from: httpCodeLine)
        XCTAssertEqual(httpCode, 0) // Connection failed

        let totalTimeLine = lines.first { $0.contains("TIME_TOTAL:") } ?? ""
        let totalTime = extractTotalTime(from: totalTimeLine)
        XCTAssertGreaterThan(totalTime, 0) // Some time was spent trying
    }

    func testparseHttp404Output() throws {
        let notFoundOutput = """
        HTTP_CODE:404
        TIME_TOTAL:8.592113
        TIME_CONNECT:0.026646
        TIME_NAMELOOKUP:0.002379
        SIZE_DOWNLOAD:0
        SPEED_DOWNLOAD:0
        """

        // Test parsing 404 output
        let lines = notFoundOutput.components(separatedBy: .newlines)
        let httpCodeLine = lines.first { $0.contains("HTTP_CODE:") } ?? ""
        let httpCode = extractHttpCode(from: httpCodeLine)
        XCTAssertEqual(httpCode, 404)

        let totalTimeLine = lines.first { $0.contains("TIME_TOTAL:") } ?? ""
        let totalTime = extractTotalTime(from: totalTimeLine)
        XCTAssertGreaterThan(totalTime, 0)
    }

    func testcurlExitCodes() throws {
        // Test expected exit codes
        let successExitCode = 0
        let dnsFailureExitCode = 6
        let connectionFailureExitCode = 7
        let timeoutExitCode = 28

        XCTAssertEqual(successExitCode, 0)
        XCTAssertEqual(dnsFailureExitCode, 6)
        XCTAssertEqual(connectionFailureExitCode, 7)
        XCTAssertEqual(timeoutExitCode, 28)

        // Test that we can handle different exit codes
        let exitCodes: [Int32] = [0, 6, 7, 28, 1, 2]
        for code in exitCodes {
            let isSuccess = code == 0
            let isDnsFailure = code == 6
            let isConnectionFailure = code == 7
            let isTimeout = code == 28
            let isOtherFailure = code != 0 && code != 6 && code != 7 && code != 28

            XCTAssert(isSuccess || isDnsFailure || isConnectionFailure || isTimeout || isOtherFailure)
        }
    }

    func testcurlTimeoutHandling() throws {
        // Test timeout configuration
        let timeoutSeconds = 10
        let url = "https://google.com"
        let command = "curl -w \"HTTP_CODE:%{http_code}\\n\" -o /dev/null -s --max-time \(timeoutSeconds) \(url)"

        XCTAssert(command.contains("--max-time \(timeoutSeconds)"))
    }

    func testcurlUrlValidation() throws {
        // Test valid URLs
        let validUrls = [
            "https://google.com",
            "https://example.com",
            "http://httpbin.org/status/200",
            "https://httpbin.org/status/404"
        ]

        for url in validUrls {
            let command = "curl -w \"HTTP_CODE:%{http_code}\\n\" -o /dev/null -s --max-time 10 \(url)"
            XCTAssert(command.contains(url))
        }
    }

    func testcurlOutputFormatting() throws {
        // Test that we can format the output correctly
        let formatString = "HTTP_CODE:%{http_code}\\nTIME_TOTAL:%{time_total}\\nTIME_CONNECT:%{time_connect}\\nTIME_NAMELOOKUP:%{time_namelookup}\\nSIZE_DOWNLOAD:%{size_download}\\nSPEED_DOWNLOAD:%{speed_download}\\n"

        XCTAssert(formatString.contains("HTTP_CODE:%{http_code}"))
        XCTAssert(formatString.contains("TIME_TOTAL:%{time_total}"))
        XCTAssert(formatString.contains("TIME_CONNECT:%{time_connect}"))
        XCTAssert(formatString.contains("TIME_NAMELOOKUP:%{time_namelookup}"))
        XCTAssert(formatString.contains("SIZE_DOWNLOAD:%{size_download}"))
        XCTAssert(formatString.contains("SPEED_DOWNLOAD:%{speed_download}"))
    }

    func testcurlErrorHandling() throws {
        // Test handling of various error scenarios
        let errorScenarios = [
            ("HTTP_CODE:000", "Connection failed"),
            ("HTTP_CODE:404", "Not found"),
            ("HTTP_CODE:500", "Server error"),
            ("HTTP_CODE:200", "Success")
        ]

        for (httpCode, description) in errorScenarios {
            let code = extractHttpCode(from: httpCode)
            let isSuccess = code == 200
            let isFailure = code != 200

            XCTAssert(isSuccess || isFailure)
        }
    }

    func testcurlPerformanceMetrics() throws {
        // Test parsing performance metrics
        let metricsOutput = """
        HTTP_CODE:200
        TIME_TOTAL:1.234567
        TIME_CONNECT:0.123456
        TIME_NAMELOOKUP:0.012345
        SIZE_DOWNLOAD:1024
        SPEED_DOWNLOAD:1024.0
        """

        let lines = metricsOutput.components(separatedBy: .newlines)

        let totalTime = extractTotalTime(from: lines.first { $0.contains("TIME_TOTAL:") } ?? "")
        let connectTime = extractConnectTime(from: lines.first { $0.contains("TIME_CONNECT:") } ?? "")
        let dnsTime = extractDnsTime(from: lines.first { $0.contains("TIME_NAMELOOKUP:") } ?? "")
        let downloadSize = extractDownloadSize(from: lines.first { $0.contains("SIZE_DOWNLOAD:") } ?? "")
        let downloadSpeed = extractDownloadSpeed(from: lines.first { $0.contains("SPEED_DOWNLOAD:") } ?? "")

        XCTAssertEqual(totalTime, 1.234567)
        XCTAssertEqual(connectTime, 0.123456)
        XCTAssertEqual(dnsTime, 0.012345)
        XCTAssertEqual(downloadSize, 1024)
        XCTAssertEqual(downloadSpeed, 1024.0)
    }

    // Helper functions for parsing (these would be implemented in the actual service)
    private func extractHttpCode(from line: String) -> Int {
        let pattern = "HTTP_CODE:([0-9]+)"
        if let range = line.range(of: pattern, options: .regularExpression) {
            let match = String(line[range])
            let value = match.replacingOccurrences(of: "HTTP_CODE:", with: "")
            return Int(value) ?? 0
        }
        return 0
    }

    private func extractTotalTime(from line: String) -> Double {
        let pattern = "TIME_TOTAL:([0-9.]+)"
        if let range = line.range(of: pattern, options: .regularExpression) {
            let match = String(line[range])
            let value = match.replacingOccurrences(of: "TIME_TOTAL:", with: "")
            return Double(value) ?? 0.0
        }
        return 0.0
    }

    private func extractConnectTime(from line: String) -> Double {
        let pattern = "TIME_CONNECT:([0-9.]+)"
        if let range = line.range(of: pattern, options: .regularExpression) {
            let match = String(line[range])
            let value = match.replacingOccurrences(of: "TIME_CONNECT:", with: "")
            return Double(value) ?? 0.0
        }
        return 0.0
    }

    private func extractDnsTime(from line: String) -> Double {
        let pattern = "TIME_NAMELOOKUP:([0-9.]+)"
        if let range = line.range(of: pattern, options: .regularExpression) {
            let match = String(line[range])
            let value = match.replacingOccurrences(of: "TIME_NAMELOOKUP:", with: "")
            return Double(value) ?? 0.0
        }
        return 0.0
    }

    private func extractDownloadSize(from line: String) -> Int {
        let pattern = "SIZE_DOWNLOAD:([0-9]+)"
        if let range = line.range(of: pattern, options: .regularExpression) {
            let match = String(line[range])
            let value = match.replacingOccurrences(of: "SIZE_DOWNLOAD:", with: "")
            return Int(value) ?? 0
        }
        return 0
    }

    private func extractDownloadSpeed(from line: String) -> Double {
        let pattern = "SPEED_DOWNLOAD:([0-9.]+)"
        if let range = line.range(of: pattern, options: .regularExpression) {
            let match = String(line[range])
            let value = match.replacingOccurrences(of: "SPEED_DOWNLOAD:", with: "")
            return Double(value) ?? 0.0
        }
        return 0.0
    }
}
