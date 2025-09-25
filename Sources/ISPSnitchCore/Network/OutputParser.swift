import Foundation
import Logging

// MARK: - Output Parser
public struct OutputParser: Sendable {
    private let logger: Logger
    
    public init(logger: Logger = Logger(label: "OutputParser")) {
        self.logger = logger
    }
    
    // MARK: - Ping Output Parsing
    
    public func parsePingOutput(_ output: String) throws -> PingData {
        let lines = output.components(separatedBy: .newlines)
        
        // Extract latency from "time=XX.XXX ms" pattern
        guard let timeLine = lines.first(where: { $0.contains("time=") }) else {
            throw ParsingError("No time information found in ping output")
        }
        
        let latency = try extractLatency(from: timeLine)
        let ttl = try extractTtl(from: timeLine)
        let packetLoss = try extractPacketLoss(from: output)
        let statistics = try extractPingStatistics(from: output)
        
        return PingData(
            latency: latency,
            packetLoss: packetLoss,
            ttl: ttl,
            statistics: statistics
        )
    }
    
    private func extractLatency(from line: String) throws -> TimeInterval {
        let pattern = "time=([0-9.]+) ms"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
              let range = Range(match.range(at: 1), in: line) else {
            throw ParsingError("Could not extract latency from ping output")
        }
        
        let latencyString = String(line[range])
        guard let latency = Double(latencyString) else {
            throw ParsingError("Invalid latency value: \(latencyString)")
        }
        
        return latency / 1000.0 // Convert ms to seconds
    }
    
    private func extractTtl(from line: String) throws -> Int? {
        let pattern = "ttl=([0-9]+)"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
              let range = Range(match.range(at: 1), in: line) else {
            return nil
        }
        
        let ttlString = String(line[range])
        return Int(ttlString)
    }
    
    private func extractPacketLoss(from output: String) throws -> Double {
        let pattern = "([0-9.]+)% packet loss"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: output, range: NSRange(output.startIndex..., in: output)),
              let range = Range(match.range(at: 1), in: output) else {
            return 0.0
        }
        
        let packetLossString = String(output[range])
        return Double(packetLossString) ?? 0.0
    }
    
    private func extractPingStatistics(from output: String) throws -> PingStatistics? {
        let pattern = "round-trip min/avg/max/stddev = ([0-9.]+)/([0-9.]+)/([0-9.]+)/([0-9.]+) ms"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: output, range: NSRange(output.startIndex..., in: output)) else {
            return nil
        }
        
        let minRange = Range(match.range(at: 1), in: output)!
        let avgRange = Range(match.range(at: 2), in: output)!
        let maxRange = Range(match.range(at: 3), in: output)!
        let stdDevRange = Range(match.range(at: 4), in: output)!
        
        let min = Double(String(output[minRange]))! / 1000.0
        let avg = Double(String(output[avgRange]))! / 1000.0
        let max = Double(String(output[maxRange]))! / 1000.0
        let stdDev = Double(String(output[stdDevRange]))! / 1000.0
        
        return PingStatistics(
            minLatency: min,
            avgLatency: avg,
            maxLatency: max,
            stdDev: stdDev,
            packetsTransmitted: 1,
            packetsReceived: 1
        )
    }
    
    // MARK: - HTTP Output Parsing
    
    public func parseHttpOutput(_ output: String) throws -> HttpData {
        let components = output.components(separatedBy: ":")
        guard components.count >= 4 else {
            throw ParsingError("Invalid HTTP output format")
        }
        
        let httpCode = Int(components[0]) ?? 0
        let totalTime = Double(components[1]) ?? 0.0
        let connectTime = Double(components[2]) ?? 0.0
        let dnsTime = Double(components[3]) ?? 0.0
        
        return HttpData(
            httpCode: httpCode,
            totalTime: totalTime,
            connectTime: connectTime,
            dnsTime: dnsTime,
            downloadSize: 0, // Would need additional parsing
            downloadSpeed: 0.0 // Would need additional parsing
        )
    }
    
    // MARK: - DNS Output Parsing
    
    public func parseDnsOutput(_ output: String) throws -> DnsData {
        let lines = output.components(separatedBy: .newlines)
        let answers = lines.filter { !$0.isEmpty }
        
        return DnsData(
            queryTime: 0.0, // Would need additional parsing
            status: "NOERROR",
            answerCount: answers.count,
            server: "8.8.8.8", // Would need additional parsing
            answers: answers
        )
    }
    
    // MARK: - Speedtest Output Parsing
    
    public func parseSpeedtestOutput(_ output: String) throws -> SpeedtestData {
        let lines = output.components(separatedBy: .newlines)
        
        var ping: TimeInterval = 0.0
        var downloadSpeed: Double = 0.0
        var uploadSpeed: Double = 0.0
        
        for line in lines {
            if line.contains("Ping:") {
                let components = line.components(separatedBy: ":")
                if components.count > 1 {
                    let pingString = components[1].trimmingCharacters(in: .whitespaces)
                    ping = Double(pingString.replacingOccurrences(of: " ms", with: "")) ?? 0.0 / 1000.0
                }
            } else if line.contains("Download:") {
                let components = line.components(separatedBy: ":")
                if components.count > 1 {
                    let downloadString = components[1].trimmingCharacters(in: .whitespaces)
                    downloadSpeed = Double(downloadString.replacingOccurrences(of: " Mbit/s", with: "")) ?? 0.0
                }
            } else if line.contains("Upload:") {
                let components = line.components(separatedBy: ":")
                if components.count > 1 {
                    let uploadString = components[1].trimmingCharacters(in: .whitespaces)
                    uploadSpeed = Double(uploadString.replacingOccurrences(of: " Mbit/s", with: "")) ?? 0.0
                }
            }
        }
        
        return SpeedtestData(
            ping: ping,
            downloadSpeed: downloadSpeed,
            uploadSpeed: uploadSpeed
        )
    }
}

// MARK: - Parsing Error
public struct ParsingError: Error, Sendable {
    public let message: String
    
    public init(_ message: String) {
        self.message = message
    }
}
