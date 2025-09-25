# ISP Snitch - Utility Analysis and Real-World Behavior

**Feature ID:** 001  
**Branch:** 001-isp-snitch-a  
**Generated:** 2024-12-19  
**Status:** Utility Analysis Complete

## Overview

This document provides a comprehensive analysis of the actual Homebrew utilities that ISP Snitch will use, including their real-world outputs, behaviors, and integration requirements. This analysis ensures our contracts and data models accurately reflect actual utility capabilities.

## Utility Inventory

### Available Utilities
- **ping**: `/sbin/ping` (macOS system utility)
- **curl**: `/usr/bin/curl` v8.7.1 (macOS system utility)
- **dig**: `/usr/bin/dig` v9.10.6 (macOS system utility)
- **speedtest-cli**: Available via Homebrew (v2.1.4b1)

### Installation Requirements
```bash
# Required system utilities (pre-installed on macOS)
# ping, curl, dig are available by default

# Optional utility (requires Homebrew installation)
brew install speedtest-cli
```

## Ping Utility Analysis

### Command Behavior
```bash
ping -c 1 -W 1000 8.8.8.8
```

### Success Output Format
```
PING 8.8.8.8 (8.8.8.8): 56 data bytes
64 bytes from 8.8.8.8: icmp_seq=0 ttl=117 time=24.155 ms

--- 8.8.8.8 ping statistics ---
1 packets transmitted, 1 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 24.155/24.155/24.155/0.000 ms
```

### Failure Output Format
```
ping: cannot resolve 192.168.1.999: Unknown host
```

### Exit Codes
- **0**: Success (packets received)
- **68**: DNS resolution failure
- **Other**: Network unreachable, timeout, etc.

### Parsing Requirements
- **Latency**: Extract from `time=XX.XXX ms` pattern
- **Success**: Check exit code and presence of "packets received"
- **Packet Loss**: Extract from "X.X% packet loss" pattern
- **TTL**: Extract from `ttl=XXX` pattern
- **Statistics**: Parse min/avg/max/stddev from statistics line

### Recommended Command Format
```bash
ping -c 1 -W 1000 <target>
```

## Curl Utility Analysis

### Command Behavior
```bash
curl -w "HTTP_CODE:%{http_code}\nTIME_TOTAL:%{time_total}\nTIME_CONNECT:%{time_connect}\nTIME_NAMELOOKUP:%{time_namelookup}\nSIZE_DOWNLOAD:%{size_download}\nSPEED_DOWNLOAD:%{speed_download}\n" -o /dev/null -s <url>
```

### Success Output Format (HTTP 200)
```
HTTP_CODE:200
TIME_TOTAL:10.317338
TIME_CONNECT:0.051629
TIME_NAMELOOKUP:0.023162
SIZE_DOWNLOAD:0
SPEED_DOWNLOAD:0
```

### Success Output Format (HTTP 404)
```
HTTP_CODE:404
TIME_TOTAL:8.592113
TIME_CONNECT:0.026646
TIME_NAMELOOKUP:0.002379
SIZE_DOWNLOAD:0
SPEED_DOWNLOAD:0
```

### Failure Output Format (Connection Error)
```
HTTP_CODE:000
TIME_TOTAL:0.075493
TIME_CONNECT:0.000000
TIME_NAMELOOKUP:0.000000
SIZE_DOWNLOAD:0
SPEED_DOWNLOAD:0
```

### Exit Codes
- **0**: Success (HTTP request completed)
- **6**: Couldn't resolve host
- **7**: Failed to connect to host
- **28**: Operation timeout
- **Other**: Various HTTP and network errors

### Parsing Requirements
- **HTTP Code**: Extract from `HTTP_CODE:XXX` pattern
- **Total Time**: Extract from `TIME_TOTAL:X.XXXXXX` pattern
- **Connect Time**: Extract from `TIME_CONNECT:X.XXXXXX` pattern
- **DNS Time**: Extract from `TIME_NAMELOOKUP:X.XXXXXX` pattern
- **Download Size**: Extract from `SIZE_DOWNLOAD:XXX` pattern
- **Download Speed**: Extract from `SPEED_DOWNLOAD:XXX` pattern

### Recommended Command Format
```bash
curl -w "HTTP_CODE:%{http_code}\nTIME_TOTAL:%{time_total}\nTIME_CONNECT:%{time_connect}\nTIME_NAMELOOKUP:%{time_namelookup}\nSIZE_DOWNLOAD:%{size_download}\nSPEED_DOWNLOAD:%{speed_download}\n" -o /dev/null -s --max-time 10 <url>
```

## Dig Utility Analysis

### Command Behavior
```bash
dig @8.8.8.8 google.com +short
```

### Success Output Format (Short)
```
142.251.40.238
```

### Success Output Format (Detailed)
```
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
```

### Failure Output Format (Non-existent Domain)
```
(empty output)
```

### Exit Codes
- **0**: Success (query completed)
- **9**: Server failure
- **Other**: Various DNS errors

### Parsing Requirements
- **Query Time**: Extract from `Query time: XX msec` pattern
- **Status**: Extract from `status: XXXXXX` pattern
- **Answer Count**: Count records in ANSWER SECTION
- **Server**: Extract from `SERVER: X.X.X.X#53` pattern
- **Success**: Check for non-empty output and NOERROR status

### Recommended Command Format
```bash
dig @8.8.8.8 <domain> +short +stats
```

## Speedtest-CLI Analysis

### Command Behavior
```bash
speedtest-cli --simple
```

### Success Output Format
```
Ping: 25.288 ms
Download: 327.21 Mbit/s
Upload: 29.69 Mbit/s
```

### Exit Codes
- **0**: Success
- **1**: General error
- **2**: Invalid arguments

### Parsing Requirements
- **Ping**: Extract from `Ping: XX.XXX ms` pattern
- **Download**: Extract from `Download: XXX.XX Mbit/s` pattern
- **Upload**: Extract from `Upload: XXX.XX Mbit/s` pattern

### Recommended Command Format
```bash
speedtest-cli --simple --timeout 30
```

## Network Interface Analysis

### Interface Detection
```bash
ifconfig | grep -E "^[a-z]|inet "
```

### Output Format
```
lo0: flags=8049<UP,LOOPBACK,RUNNING,MULTICAST> mtu 16384
	inet 127.0.0.1 netmask 0xff000000
en0: flags=8863<UP,BROADCAST,SMART,RUNNING,SIMPLEX,MULTICAST> mtu 1500
en1: flags=8863<UP,BROADCAST,SMART,RUNNING,SIMPLEX,MULTICAST> mtu 1500
	inet 192.168.0.196 netmask 0xffffff00 broadcast 192.168.0.255
```

### Default Route Detection
```bash
route -n get default | grep interface
```

### Output Format
```
  interface: en1
```

### Parsing Requirements
- **Interface Name**: Extract from `^[a-z][a-z0-9]*:` pattern
- **IP Address**: Extract from `inet X.X.X.X` pattern
- **Status**: Check for `UP` flag in flags
- **Default Interface**: Extract from route command output

## Error Handling Patterns

### Common Error Scenarios
1. **DNS Resolution Failure**: ping/curl return specific error codes
2. **Network Unreachable**: ping returns "Network is unreachable"
3. **Connection Timeout**: curl returns timeout error codes
4. **HTTP Errors**: curl returns HTTP error codes (4xx, 5xx)
5. **DNS Server Failure**: dig returns server failure codes

### Error Classification
- **Network Errors**: DNS resolution, connection failures
- **Timeout Errors**: Request timeouts, connection timeouts
- **HTTP Errors**: 4xx client errors, 5xx server errors
- **DNS Errors**: Server failures, NXDOMAIN responses

## Performance Characteristics

### Typical Response Times
- **Ping**: 10-100ms (local network), 20-200ms (internet)
- **HTTP**: 50-500ms (depending on server and content)
- **DNS**: 10-100ms (depending on DNS server)
- **Speedtest**: 10-60 seconds (full test)

### Resource Usage
- **CPU**: Minimal for individual tests
- **Memory**: Negligible for command execution
- **Network**: Varies by test type and frequency

## Integration Requirements

### Swift Integration Patterns
```swift
// Example ping integration
func executePing(target: String) async throws -> PingResult {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/sbin/ping")
    process.arguments = ["-c", "1", "-W", "1000", target]
    
    let output = try await process.execute()
    return parsePingOutput(output)
}

// Example curl integration
func executeCurl(url: String) async throws -> CurlResult {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/curl")
    process.arguments = [
        "-w", "HTTP_CODE:%{http_code}\nTIME_TOTAL:%{time_total}\n",
        "-o", "/dev/null", "-s", "--max-time", "10", url
    ]
    
    let output = try await process.execute()
    return parseCurlOutput(output)
}
```

### Parsing Requirements
- **Robust Error Handling**: Handle all exit codes and error conditions
- **Output Parsing**: Parse structured output from each utility
- **Timeout Management**: Implement appropriate timeouts for each test
- **Resource Management**: Clean up processes and resources

## Recommendations for Implementation

### 1. Command Standardization
- Use consistent command formats across all utilities
- Implement proper timeout handling
- Add error output capture for debugging

### 2. Output Parsing
- Implement robust regex-based parsing
- Handle edge cases and malformed output
- Provide fallback parsing for unexpected formats

### 3. Error Handling
- Map utility exit codes to internal error types
- Provide meaningful error messages
- Implement retry logic for transient failures

### 4. Performance Optimization
- Cache DNS resolutions when appropriate
- Implement connection pooling for HTTP tests
- Optimize test scheduling to minimize resource usage

### 5. Monitoring and Logging
- Log all command executions and outputs
- Monitor utility performance and reliability
- Track error rates and patterns

## Updated Data Model Implications

### ConnectivityRecord Updates
```swift
struct ConnectivityRecord {
    let id: UUID
    let timestamp: Date
    let testType: TestType
    let target: String
    let latency: TimeInterval?
    let success: Bool
    let errorMessage: String?
    let errorCode: Int?  // Added: utility exit code
    let networkInterface: String
    let systemContext: SystemContext
    
    // Test-specific data
    let pingData: PingData?
    let httpData: HttpData?
    let dnsData: DnsData?
    let speedtestData: SpeedtestData?
}

struct PingData {
    let latency: TimeInterval
    let packetLoss: Double
    let ttl: Int?
    let statistics: PingStatistics?
}

struct HttpData {
    let httpCode: Int
    let totalTime: TimeInterval
    let connectTime: TimeInterval
    let dnsTime: TimeInterval
    let downloadSize: Int
    let downloadSpeed: Double
}

struct DnsData {
    let queryTime: TimeInterval
    let status: String
    let answerCount: Int
    let server: String
    let answers: [String]
}

struct SpeedtestData {
    let ping: TimeInterval
    let downloadSpeed: Double  // Mbit/s
    let uploadSpeed: Double    // Mbit/s
}
```

## Conclusion

This analysis provides the foundation for implementing ISP Snitch with accurate utility integration. The actual behaviors and outputs of the Homebrew utilities are well-defined and predictable, enabling robust implementation of the connectivity monitoring system.

Key takeaways:
1. All required utilities are available on macOS
2. Output formats are consistent and parseable
3. Error handling is well-defined through exit codes
4. Performance characteristics are suitable for background monitoring
5. Integration patterns are straightforward for Swift implementation
