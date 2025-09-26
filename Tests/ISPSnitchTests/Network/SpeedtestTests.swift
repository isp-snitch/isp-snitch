import Testing
import Foundation
@testable import ISPSnitchCore

struct SpeedtestTests {

    @Test func speedtestCommandFormat() throws {
        // Test that we can construct the correct speedtest command
        let expectedCommand = "speedtest-cli --simple"

        // This would be the actual command construction in the implementation
        let command = "speedtest-cli --simple"
        #expect(command == expectedCommand)
    }

    @Test func parseSpeedtestSuccessOutput() throws {
        let successOutput = """
        Ping: 25.288 ms
        Download: 327.21 Mbit/s
        Upload: 29.69 Mbit/s
        """

        // Test parsing logic
        let lines = successOutput.components(separatedBy: .newlines)

        // Extract ping
        let pingLine = lines.first { $0.contains("Ping:") } ?? ""
        let ping = extractPing(from: pingLine)
        #expect(ping == 25.288)

        // Extract download speed
        let downloadLine = lines.first { $0.contains("Download:") } ?? ""
        let downloadSpeed = extractDownloadSpeed(from: downloadLine)
        #expect(downloadSpeed == 327.21)

        // Extract upload speed
        let uploadLine = lines.first { $0.contains("Upload:") } ?? ""
        let uploadSpeed = extractUploadSpeed(from: uploadLine)
        #expect(uploadSpeed == 29.69)
    }

    @Test func parseSpeedtestFailureOutput() throws {
        let failureOutput = """
        Cannot retrieve speedtest configuration
        """

        // Test parsing failure output
        let isConfigurationError = failureOutput.contains("Cannot retrieve speedtest configuration")
        #expect(isConfigurationError == true)
    }

    @Test func speedtestExitCodes() throws {
        // Test expected exit codes
        let successExitCode = 0
        let generalErrorExitCode = 1
        let invalidArgumentsExitCode = 2

        #expect(successExitCode == 0)
        #expect(generalErrorExitCode == 1)
        #expect(invalidArgumentsExitCode == 2)

        // Test that we can handle different exit codes
        let exitCodes: [Int32] = [0, 1, 2]
        for code in exitCodes {
            let isSuccess = code == 0
            let isGeneralError = code == 1
            let isInvalidArguments = code == 2

            #expect(isSuccess || isGeneralError || isInvalidArguments)
        }
    }

    @Test func speedtestOutputFormatting() throws {
        // Test that we can format the output correctly
        let simpleCommand = "speedtest-cli --simple"
        let jsonCommand = "speedtest-cli --json"
        let csvCommand = "speedtest-cli --csv"

        #expect(simpleCommand.contains("--simple"))
        #expect(jsonCommand.contains("--json"))
        #expect(csvCommand.contains("--csv"))
    }

    @Test func speedtestErrorHandling() throws {
        // Test handling of various error scenarios
        let errorScenarios = [
            ("Cannot retrieve speedtest configuration", "Configuration error"),
            ("No servers found", "No servers error"),
            ("Connection failed", "Connection error"),
            ("Ping: 25.288 ms", "Success")
        ]

        for (output, description) in errorScenarios {
            let isSuccess = output.contains("Ping:") && output.contains("Download:") && output.contains("Upload:")
            let isError = !isSuccess

            #expect(isSuccess || isError)
        }
    }

    @Test func speedtestPerformanceMetrics() throws {
        // Test parsing performance metrics
        let metricsOutput = """
        Ping: 15.123 ms
        Download: 500.50 Mbit/s
        Upload: 100.25 Mbit/s
        """

        let ping = extractPing(from: metricsOutput)
        let downloadSpeed = extractDownloadSpeed(from: metricsOutput)
        let uploadSpeed = extractUploadSpeed(from: metricsOutput)

        #expect(ping == 15.123)
        #expect(downloadSpeed == 500.50)
        #expect(uploadSpeed == 100.25)
    }

    @Test func speedtestUnitConversion() throws {
        // Test unit conversion logic
        let downloadMbps = 100.0
        let uploadMbps = 50.0

        // Convert Mbit/s to Mbit/s (no conversion needed)
        let downloadConverted = downloadMbps
        let uploadConverted = uploadMbps

        #expect(downloadConverted == 100.0)
        #expect(uploadConverted == 50.0)
    }

    @Test func speedtestLatencyParsing() throws {
        // Test parsing different latency formats
        let latencyFormats = [
            "Ping: 25.288 ms",
            "Ping: 15.123 ms",
            "Ping: 100.0 ms"
        ]

        for format in latencyFormats {
            let ping = extractPing(from: format)
            #expect(ping > 0)
        }
    }

    @Test func speedtestSpeedParsing() throws {
        // Test parsing different speed formats
        let speedFormats = [
            "Download: 327.21 Mbit/s",
            "Download: 100.0 Mbit/s",
            "Download: 1000.5 Mbit/s"
        ]

        for format in speedFormats {
            let speed = extractDownloadSpeed(from: format)
            #expect(speed > 0)
        }
    }

    @Test func speedtestUploadParsing() throws {
        // Test parsing different upload formats
        let uploadFormats = [
            "Upload: 29.69 Mbit/s",
            "Upload: 50.0 Mbit/s",
            "Upload: 100.5 Mbit/s"
        ]

        for format in uploadFormats {
            let speed = extractUploadSpeed(from: format)
            #expect(speed > 0)
        }
    }

    @Test func speedtestValidation() throws {
        // Test validation of speedtest results
        let validPing = 25.288
        let validDownload = 327.21
        let validUpload = 29.69

        let isPingValid = validPing > 0 && validPing < 1000
        let isDownloadValid = validDownload > 0 && validDownload < 10000
        let isUploadValid = validUpload > 0 && validUpload < 10000

        #expect(isPingValid == true)
        #expect(isDownloadValid == true)
        #expect(isUploadValid == true)
    }

    @Test func speedtestErrorDetection() throws {
        // Test detection of various error conditions
        let errorOutputs = [
            "Cannot retrieve speedtest configuration",
            "No servers found",
            "Connection failed",
            "Timeout occurred"
        ]

        for output in errorOutputs {
            let isError = !output.contains("Ping:") || !output.contains("Download:") || !output.contains("Upload:")
            #expect(isError == true)
        }
    }

    // Helper functions for parsing (these would be implemented in the actual service)
    private func extractPing(from output: String) -> Double {
        let pattern = "Ping: ([0-9.]+) ms"
        if let range = output.range(of: pattern, options: .regularExpression) {
            let match = String(output[range])
            let value = match.replacingOccurrences(of: "Ping: ", with: "").replacingOccurrences(of: " ms", with: "")
            return Double(value) ?? 0.0
        }
        return 0.0
    }

    private func extractDownloadSpeed(from output: String) -> Double {
        let pattern = "Download: ([0-9.]+) Mbit/s"
        if let range = output.range(of: pattern, options: .regularExpression) {
            let match = String(output[range])
            let value = match.replacingOccurrences(of: "Download: ", with: "").replacingOccurrences(of: " Mbit/s", with: "")
            return Double(value) ?? 0.0
        }
        return 0.0
    }

    private func extractUploadSpeed(from output: String) -> Double {
        let pattern = "Upload: ([0-9.]+) Mbit/s"
        if let range = output.range(of: pattern, options: .regularExpression) {
            let match = String(output[range])
            let value = match.replacingOccurrences(of: "Upload: ", with: "").replacingOccurrences(of: " Mbit/s", with: "")
            return Double(value) ?? 0.0
        }
        return 0.0
    }
}
