# ISP Snitch - Technical Research Analysis

**Feature ID:** 001  
**Branch:** 001-isp-snitch-a  
**Generated:** 2024-12-19  
**Status:** Research Complete

## Executive Summary

ISP Snitch is a lightweight ISP service monitor designed to track network connectivity and performance from a local Mac. The solution leverages modern Swift architecture with minimal resource footprint while providing accurate connectivity reporting through both CLI and web interfaces.

**Research Foundation:** This analysis is based on comprehensive utility validation (see `utility-analysis.md`) and Swift 6.2 package evaluation (see `swift62-packages-analysis.md`) to ensure real-world compatibility and modern language feature adoption.

## Technical Architecture Analysis

### Core Technology Stack
- **Primary Language:** Swift 6.2+ with enhanced concurrency and modern language features (see `swift62-packages-analysis.md`)
- **Package Management:** Swift Package Manager (SPM) with Apple official packages
- **HTTP Server:** SwiftNIO (Apple official) for high-performance web interface
- **Database:** SQLite.swift for type-safe local data storage
- **System Integration:** Swift System package for enhanced macOS integration
- **Network Testing:** Homebrew utilities (ping, curl, dig, speedtest-cli) with validated behaviors (see `utility-analysis.md`)
- **Monitoring:** Swift Metrics and Swift Log for system monitoring and logging
- **CLI Interface:** ArgumentParser (Apple official) for command-line interface

### Resource Optimization Strategy
Based on constitutional requirements for minimal resource footprint:

1. **CPU Usage Optimization:**
   - Target: < 1% average, < 5% peak
   - Strategy: Efficient async/await patterns, minimal polling intervals
   - Implementation: Background tasks with proper cancellation

2. **Memory Management:**
   - Target: < 50MB baseline, < 100MB peak
   - Strategy: Streaming data processing, efficient data structures
   - Implementation: Automatic memory cleanup, bounded data retention

3. **Network Efficiency:**
   - Target: < 1KB/s monitoring overhead
   - Strategy: Optimized test intervals, compressed data storage
   - Implementation: Smart scheduling based on network conditions

### Connectivity Testing Methodology

#### Scientific Measurement Approach
Based on comprehensive utility validation documented in `utility-analysis.md`:

- **ICMP Testing:** System ping command (`/sbin/ping`) for latency measurement with TTL and packet loss data
  - Command: `ping -c 1 -W 1000 <target>`
  - Output parsing: Structured latency, TTL, packet loss, and statistics extraction
  - Error handling: Exit code 0 (success), 68 (DNS failure), others (network errors)
- **HTTP Testing:** Curl-based GET requests (`/usr/bin/curl`) for connectivity validation with detailed timing metrics
  - Command: `curl -w "%{http_code}:%{time_total}:%{time_connect}:%{time_namelookup}" -s -o /dev/null <target>`
  - Output parsing: HTTP codes, timing breakdowns, download metrics
  - Error handling: Exit code 0 (success), 6 (DNS failure), 7 (connection failure), 28 (timeout)
- **DNS Testing:** Dig command (`/usr/bin/dig`) for resolution time and accuracy with server response data
  - Command: `dig +short +time=1 +tries=1 <target>`
  - Output parsing: Query times, DNS status, answer counts, server info
  - Error handling: Exit code 0 (success), 9 (server failure)
- **Bandwidth Testing:** Speedtest-cli (Homebrew) for periodic speed measurements with ping, download, and upload metrics
  - Command: `speedtest-cli --simple`
  - Output parsing: Ping latency, download/upload speeds in Mbit/s
  - Error handling: Exit code 0 (success), 1 (general error), 2 (invalid args)
- **Statistical Analysis:** Latency percentiles, success rates, error categorization, and utility-specific data parsing

#### Actual Utility Behaviors (Validated)
- **Ping Output:** Structured output with latency, TTL, packet loss, and statistics
- **Curl Output:** HTTP codes, timing breakdowns (total, connect, DNS), download metrics
- **Dig Output:** Query times, DNS status, answer counts, server information
- **Speedtest Output:** Ping latency, download/upload speeds in Mbit/s
- **Error Handling:** Consistent exit codes and error message formats across utilities

#### Test Target Strategy
- **Primary Targets:** 8.8.8.8, 1.1.1.1 (reliable DNS servers)
- **HTTP Endpoints:** google.com, cloudflare.com (high availability)
- **ISP Gateway:** Dynamic detection for ISP-specific testing
- **Custom Endpoints:** User-configurable targets for specific needs

### Data Model Design

#### Core Data Structures (Swift 6.2)
```swift
struct ConnectivityRecord: Sendable, Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let testType: TestType
    let target: String
    let latency: TimeInterval?
    let success: Bool
    let errorMessage: String?
    let errorCode: Int?  // Utility exit code
    let networkInterface: String
    let systemContext: SystemContext
    
    // Test-specific data based on actual utility outputs
    let pingData: PingData?
    let httpData: HttpData?
    let dnsData: DnsData?
    let speedtestData: SpeedtestData?
}
```

#### Storage Strategy (Swift 6.2 + SQLite.swift)
- **SQLite.swift:** Type-safe, async/await compatible database operations
- **Actor-based Storage:** Thread-safe data access with Swift 6.2 actors
- **Data Retention:** Configurable (default 30 days) with automatic cleanup
- **Backup Strategy:** iCloud integration for long-term storage
- **Encryption:** Simple local encryption for sensitive data

### Security and Privacy Analysis

#### Local-First Architecture
- **No External Communication:** All data remains on local machine
- **No Telemetry:** Zero usage data collection or transmission
- **Minimal Permissions:** Only network and file system access required
- **Access Control:** Single-user local access only

#### Data Protection
- **Local Encryption:** SQLite database encryption for sensitive data
- **Network Isolation:** No external network access for data transmission
- **Privacy by Design:** All monitoring data stays local unless explicitly shared

### Performance Benchmarks

#### Startup Performance
- **Target:** < 5 seconds from boot to active monitoring
- **Strategy:** Optimized LaunchAgent configuration, minimal initialization
- **Implementation:** Lazy loading of non-critical components

#### Response Times
- **CLI Commands:** < 100ms response time
- **Web Interface:** < 500ms page load time
- **Real-time Updates:** < 1 second latency for live data

#### Battery Impact
- **Laptop Optimization:** Minimal CPU wake-ups, efficient scheduling
- **Power Management:** Respects system power settings
- **Background Efficiency:** Optimized for background operation

### Integration Requirements

#### macOS System Integration
- **LaunchAgent:** Automatic startup on user login
- **Menu Bar:** Optional system tray integration
- **Notifications:** Optional system notifications for outages
- **Permissions:** Network access, file system access

#### Homebrew Integration
- **Package Management:** Standard Homebrew formula
- **Dependencies:** Automatic installation of required utilities
- **Updates:** Standard Homebrew update mechanism
- **Uninstallation:** Clean removal with data preservation

### Web Interface Architecture

#### Frontend Technology
- **HTML5/CSS3:** Modern, responsive design
- **JavaScript:** Real-time updates via WebSocket
- **Progressive Enhancement:** Works without JavaScript
- **Accessibility:** WCAG 2.1 AA compliance

#### Backend Implementation
- **Swift HTTP Server:** Native Swift web server
- **WebSocket Support:** Real-time connectivity updates
- **RESTful API:** Standard HTTP endpoints for data access
- **Error Handling:** Graceful error handling with user feedback

### Network Accessibility

#### Local Access
- **Localhost:** http://localhost:8080 (default port)
- **Network Access:** http://[hostname].local:8080
- **Security:** Local network access only, no external exposure

#### Configuration
- **Port Configuration:** User-configurable web interface port
- **Access Control:** Simple local access control
- **Network Discovery:** Automatic .local address resolution

## Risk Assessment

### Technical Risks
1. **Resource Usage Exceedance**
   - **Risk:** Service consumes more resources than specified
   - **Mitigation:** Continuous monitoring, optimization cycles
   - **Monitoring:** Built-in resource usage tracking

2. **Network Test Accuracy**
   - **Risk:** Inaccurate connectivity measurements
   - **Mitigation:** Standardized testing protocols, multiple test targets
   - **Validation:** Cross-validation with multiple test methods

3. **macOS Compatibility**
   - **Risk:** Service fails on different macOS versions
   - **Mitigation:** Multi-version testing, graceful degradation
   - **Support:** Minimum macOS 12.0+ support

4. **Security Vulnerabilities**
   - **Risk:** Local security issues or data exposure
   - **Mitigation:** Regular security reviews, minimal permissions
   - **Audit:** Security-focused code review process

### Operational Risks
1. **Service Reliability**
   - **Risk:** Service crashes or stops monitoring
   - **Mitigation:** Robust error handling, automatic restart
   - **Monitoring:** Health check endpoints, logging

2. **Data Loss**
   - **Risk:** Loss of connectivity data
   - **Mitigation:** Regular backups, data retention policies
   - **Recovery:** Data export/import capabilities

3. **User Experience**
   - **Risk:** Poor user experience or confusing interface
   - **Mitigation:** User testing, iterative design
   - **Feedback:** Community feedback integration

## Implementation Recommendations

### Development Approach
1. **Incremental Development:** Build core service first, then interfaces
2. **Test-Driven Development:** Comprehensive testing from day one
3. **Performance Monitoring:** Continuous performance measurement
4. **User Feedback:** Early user testing and feedback integration

### Quality Assurance
1. **Automated Testing:** Unit, integration, and performance tests
2. **Code Review:** Mandatory code review for all changes
3. **Security Audit:** Regular security reviews and audits
4. **Documentation:** Comprehensive documentation and examples

### Deployment Strategy
1. **Beta Testing:** Limited beta release for testing
2. **Gradual Rollout:** Phased release to community
3. **Feedback Integration:** Active community feedback collection
4. **Continuous Improvement:** Regular updates and improvements

## Conclusion

ISP Snitch represents a well-architected solution for local ISP monitoring that balances functionality with resource efficiency. The Swift-based architecture provides excellent performance while maintaining simplicity and reliability. The constitutional principles ensure the solution remains focused on its core mission while providing a solid foundation for future enhancements.

The technical research confirms the feasibility of all specified requirements and provides a clear path forward for implementation. The risk assessment identifies key areas for attention during development, with appropriate mitigation strategies in place.
