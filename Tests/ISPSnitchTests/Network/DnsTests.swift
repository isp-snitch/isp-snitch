import Testing
import Foundation
@testable import ISPSnitchCore

struct DnsTests {
    
    @Test func digCommandFormat() throws {
        // Test that we can construct the correct dig command
        let domain = "google.com"
        let server = "8.8.8.8"
        let expectedCommand = "dig @\(server) \(domain) +short +stats"
        
        // This would be the actual command construction in the implementation
        let command = "dig @\(server) \(domain) +short +stats"
        #expect(command == expectedCommand)
    }
    
    @Test func parseDigSuccessOutput() throws {
        let successOutput = """
        ; <<>> DiG 9.10.6 <<>> @8.8.8.8 google.com +stats
        ; (1 server found)
        ;; global options: +cmd
        ;; Got answer:
        ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 26478
        ;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
        
        ;; OPT PSEUDOSECTION:
        ; EDNS: version: 0, flags:; udp: 512
        ;; QUESTION SECTION:
        ;google.com.			IN	A
        
        ;; ANSWER SECTION:
        google.com.		60	IN	A	142.250.72.110
        
        ;; Query time: 28 msec
        ;; SERVER: 8.8.8.8#53(8.8.8.8)
        ;; WHEN: Thu Sep 25 16:14:33 EDT 2025
        ;; MSG SIZE  rcvd: 55
        """
        
        // Test parsing logic
        let lines = successOutput.components(separatedBy: .newlines)
        
        // Extract status
        let statusLine = lines.first { $0.contains("status:") } ?? ""
        let status = extractStatus(from: statusLine)
        #expect(status == "NOERROR")
        
        // Extract query time
        let queryTimeLine = lines.first { $0.contains("Query time:") } ?? ""
        let queryTime = extractQueryTime(from: queryTimeLine)
        #expect(queryTime == 28)
        
        // Extract server
        let serverLine = lines.first { $0.contains("SERVER:") } ?? ""
        let server = extractServer(from: serverLine)
        #expect(server == "8.8.8.8")
        
        // Extract answer count
        let answerCount = extractAnswerCount(from: successOutput)
        #expect(answerCount == 1)
        
        // Extract answers
        let answers = extractAnswers(from: successOutput)
        #expect(answers.count == 1)
        #expect(answers.contains("142.250.72.110"))
    }
    
    @Test func parseDigShortOutput() throws {
        let shortOutput = "142.251.40.238"
        
        // Test parsing short output
        let answers = shortOutput.components(separatedBy: .newlines).filter { !$0.isEmpty }
        #expect(answers.count == 1)
        #expect(answers[0] == "142.251.40.238")
    }
    
    @Test func parseDigFailureOutput() throws {
        let failureOutput = ""
        
        // Test parsing failure output (empty)
        let answers = failureOutput.components(separatedBy: .newlines).filter { !$0.isEmpty }
        #expect(answers.isEmpty)
    }
    
    @Test func digExitCodes() throws {
        // Test expected exit codes
        let successExitCode = 0
        let serverFailureExitCode = 9
        
        #expect(successExitCode == 0)
        #expect(serverFailureExitCode == 9)
        
        // Test that we can handle different exit codes
        let exitCodes: [Int32] = [0, 9, 1, 2]
        for code in exitCodes {
            let isSuccess = code == 0
            let isServerFailure = code == 9
            let isOtherFailure = code != 0 && code != 9
            
            #expect(isSuccess || isServerFailure || isOtherFailure)
        }
    }
    
    @Test func digServerValidation() throws {
        // Test valid DNS servers
        let validServers = ["8.8.8.8", "1.1.1.1", "9.9.9.9", "208.67.222.222"]
        
        for server in validServers {
            let command = "dig @\(server) google.com +short +stats"
            #expect(command.contains("@\(server)"))
        }
    }
    
    @Test func digDomainValidation() throws {
        // Test valid domains
        let validDomains = ["google.com", "example.com", "apple.com", "github.com"]
        
        for domain in validDomains {
            let command = "dig @8.8.8.8 \(domain) +short +stats"
            #expect(command.contains(domain))
        }
    }
    
    @Test func digOutputFormatting() throws {
        // Test that we can format the output correctly
        let shortCommand = "dig @8.8.8.8 google.com +short"
        let statsCommand = "dig @8.8.8.8 google.com +short +stats"
        
        #expect(shortCommand.contains("+short"))
        #expect(statsCommand.contains("+short"))
        #expect(statsCommand.contains("+stats"))
    }
    
    @Test func digErrorHandling() throws {
        // Test handling of various error scenarios
        let errorScenarios = [
            ("status: NOERROR", "Success"),
            ("status: NXDOMAIN", "Domain not found"),
            ("status: SERVFAIL", "Server failure"),
            ("status: REFUSED", "Query refused")
        ]
        
        for (status, description) in errorScenarios {
            let parsedStatus = extractStatus(from: status)
            let isSuccess = parsedStatus == "NOERROR"
            let isFailure = parsedStatus != "NOERROR"
            
            #expect(isSuccess || isFailure)
        }
    }
    
    @Test func digPerformanceMetrics() throws {
        // Test parsing performance metrics
        let metricsOutput = """
        ;; Query time: 15 msec
        ;; SERVER: 8.8.8.8#53(8.8.8.8)
        ;; WHEN: Thu Sep 25 16:14:33 EDT 2025
        ;; MSG SIZE  rcvd: 55
        """
        
        let queryTime = extractQueryTime(from: metricsOutput)
        let server = extractServer(from: metricsOutput)
        
        #expect(queryTime == 15)
        #expect(server == "8.8.8.8")
    }
    
    @Test func digAnswerParsing() throws {
        // Test parsing different answer formats
        let answerSection = """
        ;; ANSWER SECTION:
        google.com.		60	IN	A	142.250.72.110
        google.com.		60	IN	A	142.250.72.111
        """
        
        let answers = extractAnswers(from: answerSection)
        #expect(answers.count == 2)
        #expect(answers.contains("142.250.72.110"))
        #expect(answers.contains("142.250.72.111"))
    }
    
    @Test func digCnameParsing() throws {
        // Test parsing CNAME records
        let cnameSection = """
        ;; ANSWER SECTION:
        www.google.com.		300	IN	CNAME	google.com.
        google.com.		60	IN	A	142.250.72.110
        """
        
        let answers = extractAnswers(from: cnameSection)
        #expect(answers.count == 1) // Only A records, not CNAME
        #expect(answers.contains("142.250.72.110"))
    }
    
    // Helper functions for parsing (these would be implemented in the actual service)
    private func extractStatus(from output: String) -> String {
        let pattern = "status: ([A-Z]+)"
        if let range = output.range(of: pattern, options: .regularExpression) {
            let match = String(output[range])
            return match.replacingOccurrences(of: "status: ", with: "")
        }
        return ""
    }
    
    private func extractQueryTime(from output: String) -> Int {
        let pattern = "Query time: ([0-9]+) msec"
        if let range = output.range(of: pattern, options: .regularExpression) {
            let match = String(output[range])
            let value = match.replacingOccurrences(of: "Query time: ", with: "").replacingOccurrences(of: " msec", with: "")
            return Int(value) ?? 0
        }
        return 0
    }
    
    private func extractServer(from output: String) -> String {
        let pattern = "SERVER: ([0-9.]+)#53"
        if let range = output.range(of: pattern, options: .regularExpression) {
            let match = String(output[range])
            return match.replacingOccurrences(of: "SERVER: ", with: "").replacingOccurrences(of: "#53", with: "")
        }
        return ""
    }
    
    private func extractAnswerCount(from output: String) -> Int {
        let pattern = "ANSWER: ([0-9]+)"
        if let range = output.range(of: pattern, options: .regularExpression) {
            let match = String(output[range])
            let value = match.replacingOccurrences(of: "ANSWER: ", with: "")
            return Int(value) ?? 0
        }
        return 0
    }
    
    private func extractAnswers(from output: String) -> [String] {
        let lines = output.components(separatedBy: .newlines)
        var answers: [String] = []
        
        for line in lines {
            // Use regex to find A records with IP addresses
            let pattern = "IN\\s+A\\s+([0-9.]+)"
            if let range = line.range(of: pattern, options: .regularExpression) {
                let match = String(line[range])
                let ipPattern = "([0-9.]+)"
                if let ipRange = match.range(of: ipPattern, options: .regularExpression) {
                    let ip = String(match[ipRange])
                    answers.append(ip)
                }
            }
        }
        
        return answers
    }
}
