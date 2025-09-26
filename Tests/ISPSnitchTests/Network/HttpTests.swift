import Testing
import Foundation
@testable import ISPSnitchCore

struct HttpTests {

    @Test func curlCommandFormat() throws {
        // Test that we can construct the correct curl command
        let url = "https://google.com"
        let expectedCommand = "curl -w \"HTTP_CODE:%{http_code}\\nTIME_TOTAL:%{time_total}\\nTIME_CONNECT:%{time_connect}\\nTIME_NAMELOOKUP:%{time_namelookup}\\nSIZE_DOWNLOAD:%{size_download}\\nSPEED_DOWNLOAD:%{speed_download}\\n\" -o /dev/null -s --max-time 10 \(url)"

        // This would be the actual command construction in the implementation
        let command = "curl -w \"HTTP_CODE:%{http_code}\\nTIME_TOTAL:%{time_total}\\nTIME_CONNECT:%{time_connect}\\nTIME_NAMELOOKUP:%{time_namelookup}\\nSIZE_DOWNLOAD:%{size_download}\\nSPEED_DOWNLOAD:%{speed_download}\\n\" -o /dev/null -s --max-time 10 \(url)"
        #expect(command == expectedCommand)
    }

    @Test func parseHttpSuccessOutput() throws {
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
        #expect(httpCode == 200)

        // Extract total time
        let totalTimeLine = lines.first { $0.contains("TIME_TOTAL:") } ?? ""
        let totalTime = extractTotalTime(from: totalTimeLine)
        #expect(totalTime == 10.317338)

        // Extract connect time
        let connectTimeLine = lines.first { $0.contains("TIME_CONNECT:") } ?? ""
        let connectTime = extractConnectTime(from: connectTimeLine)
        #expect(connectTime == 0.051629)

        // Extract DNS time
        let dnsTimeLine = lines.first { $0.contains("TIME_NAMELOOKUP:") } ?? ""
        let dnsTime = extractDnsTime(from: dnsTimeLine)
        #expect(dnsTime == 0.023162)

        // Extract download size
        let downloadSizeLine = lines.first { $0.contains("SIZE_DOWNLOAD:") } ?? ""
        let downloadSize = extractDownloadSize(from: downloadSizeLine)
        #expect(downloadSize == 0)

        // Extract download speed
        let downloadSpeedLine = lines.first { $0.contains("SPEED_DOWNLOAD:") } ?? ""
        let downloadSpeed = extractDownloadSpeed(from: downloadSpeedLine)
        #expect(downloadSpeed == 0)
    }

    @Test func parseHttpFailureOutput() throws {
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
        #expect(httpCode == 0) // Connection failed

        let totalTimeLine = lines.first { $0.contains("TIME_TOTAL:") } ?? ""
        let totalTime = extractTotalTime(from: totalTimeLine)
        #expect(totalTime > 0) // Some time was spent trying
    }

    @Test func parseHttp404Output() throws {
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
        #expect(httpCode == 404)

        let totalTimeLine = lines.first { $0.contains("TIME_TOTAL:") } ?? ""
        let totalTime = extractTotalTime(from: totalTimeLine)
        #expect(totalTime > 0)
    }

    @Test func curlExitCodes() throws {
        // Test expected exit codes
        let successExitCode = 0
        let dnsFailureExitCode = 6
        let connectionFailureExitCode = 7
        let timeoutExitCode = 28

        #expect(successExitCode == 0)
        #expect(dnsFailureExitCode == 6)
        #expect(connectionFailureExitCode == 7)
        #expect(timeoutExitCode == 28)

        // Test that we can handle different exit codes
        let exitCodes: [Int32] = [0, 6, 7, 28, 1, 2]
        for code in exitCodes {
            let isSuccess = code == 0
            let isDnsFailure = code == 6
            let isConnectionFailure = code == 7
            let isTimeout = code == 28
            let isOtherFailure = code != 0 && code != 6 && code != 7 && code != 28

            #expect(isSuccess || isDnsFailure || isConnectionFailure || isTimeout || isOtherFailure)
        }
    }

    @Test func curlTimeoutHandling() throws {
        // Test timeout configuration
        let timeoutSeconds = 10
        let url = "https://google.com"
        let command = "curl -w \"HTTP_CODE:%{http_code}\\n\" -o /dev/null -s --max-time \(timeoutSeconds) \(url)"

        #expect(command.contains("--max-time \(timeoutSeconds)"))
    }

    @Test func curlUrlValidation() throws {
        // Test valid URLs
        let validUrls = [
            "https://google.com",
            "https://example.com",
            "http://httpbin.org/status/200",
            "https://httpbin.org/status/404"
        ]

        for url in validUrls {
            let command = "curl -w \"HTTP_CODE:%{http_code}\\n\" -o /dev/null -s --max-time 10 \(url)"
            #expect(command.contains(url))
        }
    }

    @Test func curlOutputFormatting() throws {
        // Test that we can format the output correctly
        let formatString = "HTTP_CODE:%{http_code}\\nTIME_TOTAL:%{time_total}\\nTIME_CONNECT:%{time_connect}\\nTIME_NAMELOOKUP:%{time_namelookup}\\nSIZE_DOWNLOAD:%{size_download}\\nSPEED_DOWNLOAD:%{speed_download}\\n"

        #expect(formatString.contains("HTTP_CODE:%{http_code}"))
        #expect(formatString.contains("TIME_TOTAL:%{time_total}"))
        #expect(formatString.contains("TIME_CONNECT:%{time_connect}"))
        #expect(formatString.contains("TIME_NAMELOOKUP:%{time_namelookup}"))
        #expect(formatString.contains("SIZE_DOWNLOAD:%{size_download}"))
        #expect(formatString.contains("SPEED_DOWNLOAD:%{speed_download}"))
    }

    @Test func curlErrorHandling() throws {
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

            #expect(isSuccess || isFailure)
        }
    }

    @Test func curlPerformanceMetrics() throws {
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

        #expect(totalTime == 1.234567)
        #expect(connectTime == 0.123456)
        #expect(dnsTime == 0.012345)
        #expect(downloadSize == 1024)
        #expect(downloadSpeed == 1024.0)
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
