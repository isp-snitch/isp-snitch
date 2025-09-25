# ISP Snitch - Lightweight ISP Service Monitor

**Feature ID:** 001  
**Branch:** 001-isp-snitch-a  
**Status:** Specification  
**Created:** 2024-12-19

## Constitution Alignment
This specification MUST implement ISP Snitch constitution principles:
- **Minimal Resource Footprint:** All components designed for low resource usage
- **Accurate Connectivity Reporting:** Scientific measurement methodology
- **Modern Swift Architecture:** Swift-based implementation with concurrency
- **Homebrew Integration:** Package management through Homebrew
- **Multi-Access Interface:** CLI and web interfaces
- **Automatic Startup Integration:** macOS service integration
- **Public Project Transparency:** Open source with comprehensive documentation
- **Data Privacy and Security:** Local data handling with simple storage

## Feature Overview

ISP Snitch is a lightweight, single-user ISP service monitor designed to help track outages and network issues from a local Mac. The solution generates accurate connectivity reports while running in the background using minimal resources. Reports can be viewed via CLI or by opening browser on localhost at specific port (accessible over network via .local address too). The service runs in background automatically when Mac starts. Built as a clean, simple vanilla Swift package using Swift Package Manager (SPM) that leverages proven network utilities (ping, curl, dig, speedtest-cli) rather than reinventing network testing. Built in Swift 6.2+ for services and CLI with minimal complexity.

## Clarifications

### Session 2024-12-19
- Q: When the user's network interface changes (e.g., switching from WiFi to Ethernet, or connecting to a different WiFi network), how should the service behave? → A: Continue monitoring with the new interface, logging the change
- Q: When a required system utility (ping, curl, dig, speedtest-cli) is missing or fails to execute, how should the service handle this? → A: Log error and retry after a delay
- Q: When the web interface encounters errors (e.g., database connection issues, network test failures), how should it display these to the user? → A: Show error messages inline with retry buttons
- Q: What should happen to old connectivity data when the retention period is exceeded? → A: iCloud backup
- Q: When a user runs `isp-snitch report` without any arguments, what should be the default time range? → A: Last 24 hours
- Q: Should the local SQLite database be encrypted or not? → A: No encryption - simple local storage only

## System Architecture

### Core Components
1. **Background Service (Swift)**
   - Simple network monitoring daemon using Swift concurrency
   - Continuous connectivity testing using Homebrew utilities
   - Local SQLite database for data storage
   - Resource usage tracking and optimization
   - Automatic startup integration via LaunchAgent

2. **CLI Interface (Swift)**
   - Command-line reporting and status checking
   - Configuration management and service control
   - Data export functionality (JSON, CSV formats)
   - Real-time monitoring and alerting
   - Integration with system tools via Homebrew

3. **Web Interface (Swift + HTML/JS)**
   - Simple real-time dashboard with live connectivity status
   - Basic historical data visualization
   - Simple configuration interface for test targets and intervals
   - Network accessibility via localhost and .local addresses
   - Clean, minimal design for easy use

4. **Data Layer**
   - Local SQLite database for simple data storage
   - Configurable data retention policies
   - Export capabilities for ISP performance claims
   - iCloud backup for old data beyond retention period

## Technical Requirements

### Performance Requirements
- **CPU Usage:** < 1% average, < 5% peak during normal operation (measured via `top` command over 1-hour period)
- **Memory Usage:** < 50MB baseline, < 100MB peak with full dataset (measured via `ps` command RSS field)
- **Network Overhead:** < 1KB/s for monitoring operations (measured via `netstat` command)
- **Startup Time:** < 5 seconds from system boot to active monitoring (measured from LaunchAgent start to first successful network test)
- **Response Time:** < 100ms for CLI commands, < 500ms for web interface (measured via `time` command and browser dev tools)
- **Battery Impact:** < 2% additional battery drain per hour on laptops (measured via `pmset` command)

### Connectivity Testing
The service leverages Homebrew-installed utilities for reliable network testing. Detailed utility behaviors and output parsing are documented in `utility-analysis.md`:

- **Ping Tests:** Uses system `ping` command for ICMP connectivity to multiple targets (8.8.8.8, 1.1.1.1, ISP gateway)
  - Command: `ping -c 1 -W 1000 <target>`
  - Output parsing: Extracts latency, TTL, packet loss, and statistics from structured output
  - Error handling: Exit code 0 (success), 68 (DNS failure), others (network errors)
- **HTTP Tests:** Uses `curl` for GET requests to test endpoints (google.com, cloudflare.com)
  - Command: `curl -w "%{http_code}:%{time_total}:%{time_connect}:%{time_namelookup}" -s -o /dev/null <target>`
  - Output parsing: Extracts HTTP codes, timing breakdowns, download metrics
  - Error handling: Exit code 0 (success), 6 (DNS failure), 7 (connection failure), 28 (timeout)
- **DNS Tests:** Uses `dig` for resolution time and accuracy testing
  - Command: `dig +short +time=1 +tries=1 <target>`
  - Output parsing: Extracts query times, DNS status, answer counts, server info
  - Error handling: Exit code 0 (success), 9 (server failure)
- **Bandwidth Tests:** Uses `speedtest-cli` for periodic download/upload speed measurements
  - Command: `speedtest-cli --simple`
  - Output parsing: Extracts ping latency, download/upload speeds in Mbit/s
  - Error handling: Exit code 0 (success), 1 (general error), 2 (invalid args)
- **Latency Tests:** Uses `ping` with statistical analysis for round-trip time measurements
- **ISP-Specific Tests:** Custom endpoints for ISP performance validation using `curl`
- **Utility Failure Handling:** Log errors and retry after delay when system utilities fail or are missing

### Data Collection
- **Timestamp:** ISO 8601 format with timezone information
- **Latency:** Millisecond precision with statistical analysis
- **Success/Failure:** Boolean with detailed error categorization
- **Network Interface:** Source interface identification (WiFi, Ethernet, etc.)
- **Target Information:** Test endpoint details and response codes
- **System Context:** CPU usage, memory usage, network interface status
- **Interface Changes:** Log network interface changes and continue monitoring with new interface

### Security Requirements
- **Local Access Only:** No external network access or data transmission
- **Simple Privacy:** No telemetry, usage data, or external communication
- **Basic Access Control:** Simple local access for single user
- **Minimal Permissions:** Only network and file system access required

## Implementation Details

### Swift Package Structure
```
ISP-Snitch/
├── Package.swift
├── Sources/
│   └── ISPSnitch/
│       ├── ISPSnitch.swift          # Main service
│       ├── NetworkMonitor.swift     # Network testing
│       ├── DataStorage.swift        # SQLite storage
│       ├── WebServer.swift          # HTTP server
│       └── CLI/
│           └── main.swift           # CLI interface
├── Tests/
│   └── ISPSnitchTests/
└── README.md
```

### Swift Architecture
```swift
// Core service structure with modern Swift concurrency
@main
struct ISPSnitchService {
    static func main() async {
        let config = ConfigurationManager()
        let monitor = NetworkMonitor(config: config)
        let storage = DataStorage()
        let webServer = WebServer(port: config.webPort)
        
        // Start monitoring with resource tracking
        await monitor.startMonitoring()
        await webServer.start()
        
        // Graceful shutdown handling
        signal(SIGINT) { _ in
            Task {
                await monitor.stopMonitoring()
                await webServer.stop()
                exit(0)
            }
        }
    }
}
```

### Swift Package Manager Integration
- **Package Structure:** Clean vanilla Swift package with SPM
- **Dependencies:** Minimal external dependencies, leverages system utilities
- **Installation:** `swift build` and `swift run` for development
- **Distribution:** Binary distribution or SPM package for easy installation
- **Utility Backing:** Leverages system-installed tools for network testing
  - `ping` for ICMP connectivity tests
  - `curl` for HTTP connectivity tests  
  - `dig` for DNS resolution tests
  - `speedtest-cli` for bandwidth measurements
- **Updates:** Simple package updates via SPM
- **Uninstallation:** Clean removal with data preservation option

### macOS Integration
Detailed system integration specifications are documented in `system-integration-contracts.md`:

- **LaunchAgent:** `com.isp-snitch.monitor.plist` in user's LaunchAgents
  - Plist configuration: User agent, network access, file system permissions
  - Startup behavior: Automatic on user login with 30-second delay for system stability
  - Graceful shutdown: SIGTERM handling with cleanup procedures
- **User Agent:** Runs in user context with minimal privileges
  - No root access required
  - Network access for connectivity testing
  - File system access for local data storage
- **Permissions:** Network access, file system access for data storage
- **Startup:** Automatic on user login with delay for system stability
- **System Integration:** Menu bar integration for quick status access
- **Notifications:** Optional system notifications for connectivity issues
- **Service Management:** Install/uninstall scripts for seamless setup

### Web Interface
- **Framework:** Swift HTTP server with async/await support
- **Frontend:** HTML5, CSS3, JavaScript with modern frameworks
- **Real-time:** WebSocket connections for live updates
- **Responsive:** Mobile-friendly design with touch support
- **Accessibility:** WCAG 2.1 AA compliance for inclusive access
- **Performance:** Optimized for low-latency updates and smooth animations
- **Error Handling:** Show error messages inline with retry buttons for database and network issues

## Data Models

### Connectivity Record
```swift
struct ConnectivityRecord {
    let id: UUID
    let timestamp: Date
    let testType: TestType
    let target: String
    let latency: TimeInterval?
    let success: Bool
    let errorMessage: String?
    let networkInterface: String
    let systemContext: SystemContext
}

enum TestType: String, CaseIterable {
    case ping = "ping"
    case http = "http"
    case dns = "dns"
    case bandwidth = "bandwidth"
    case latency = "latency"
}

struct SystemContext {
    let cpuUsage: Double
    let memoryUsage: Double
    let networkInterfaceStatus: String
    let batteryLevel: Double?
}
```

### Test Configuration
```swift
struct TestConfiguration {
    let pingTargets: [String]
    let httpTargets: [String]
    let dnsTargets: [String]
    let testInterval: TimeInterval
    let timeout: TimeInterval
    let retryCount: Int
    let webPort: Int
    let dataRetentionDays: Int
    let enableNotifications: Bool
    let enableWebInterface: Bool
}
```

## API Specifications

### CLI Commands
- `isp-snitch status` - Show service status and current connectivity
- `isp-snitch report [--format json|csv] [--days N]` - Generate connectivity report (default: last 24 hours)
- `isp-snitch config [get|set] [key] [value]` - Manage configuration
- `isp-snitch export [--format json|csv] [--output file]` - Export data
- `isp-snitch start` - Start monitoring service
- `isp-snitch stop` - Stop monitoring service
- `isp-snitch restart` - Restart monitoring service
- `isp-snitch logs [--follow]` - View service logs

### Web API Endpoints
- `GET /api/status` - Service status and current connectivity
- `GET /api/reports?days=N&format=json` - Historical reports
- `GET /api/config` - Current configuration
- `POST /api/config` - Update configuration
- `GET /api/export?format=json&days=N` - Export data
- `WebSocket /ws/realtime` - Real-time connectivity updates
- `GET /api/health` - Health check endpoint
- `GET /api/metrics` - Performance metrics

## Testing Strategy

### Unit Tests
- Network monitoring logic with mock network conditions
- Data storage operations with simple SQLite database
- Configuration management and validation
- Report generation with various data scenarios
- CLI command parsing and execution
- Web API endpoint functionality

### Integration Tests
- Service startup/shutdown with LaunchAgent
- Web interface functionality across browsers
- CLI command execution with various parameters
- Data persistence across service restarts
- Homebrew installation and service management
- Network accessibility via .local addresses

### Performance Tests
- Resource usage monitoring under various loads
- Network test accuracy with controlled conditions
- Concurrent user handling for web interface
- Long-running stability over 24+ hour periods
- Memory leak detection and prevention
- Battery usage impact measurement

### Security Tests
- Local access restrictions and network isolation
- Input validation and sanitization
- Basic access control verification
- Permission escalation prevention

## Deployment

### Installation Process
1. **Swift Package Installation:** Clone repository and `swift build`
2. **Service Registration:** Manual LaunchAgent creation or automated setup
3. **Configuration Setup:** Default configuration with user customization
4. **Initial Data Collection:** Start monitoring with default targets
5. **Web Interface Access:** Available at http://localhost:8080
6. **Network Access:** Available at http://[hostname].local:8080

### Configuration
- **Default Test Targets:** Google DNS, Cloudflare, ISP gateway
- **Monitoring Intervals:** 30 seconds for ping, 5 minutes for bandwidth
- **Data Retention:** 30 days by default, configurable
- **Web Interface:** Port 8080, optional authentication
- **Security Preferences:** Simple local storage, local access only
- **Notifications:** Optional system notifications for outages

### Maintenance
- **Package Updates:** Via SPM with `swift package update`
- **Data Backup:** Simple backup procedures with retention policy
- **Log Rotation:** Basic log rotation with size limits
- **Performance Monitoring:** Built-in performance metrics collection
- **Health Checks:** Regular service health monitoring

## Success Criteria

### Functional Requirements
- [ ] Service starts automatically on Mac boot
- [ ] Continuous network monitoring with < 1% CPU usage
- [ ] Accurate connectivity reporting with scientific methodology
- [ ] CLI interface with all specified commands
- [ ] Web interface accessible via localhost and .local
- [ ] Simple local data storage
- [ ] Swift Package Manager installation and management

### Performance Requirements
- [ ] < 50MB memory usage baseline
- [ ] < 5 second startup time
- [ ] < 100ms CLI response time
- [ ] < 500ms web interface response time
- [ ] Minimal battery impact on laptops
- [ ] Stable operation over 24+ hour periods

### Security Requirements
- [ ] No external network access or data transmission
- [ ] Local access only for single user
- [ ] Basic access control
- [ ] Minimal required system permissions

### User Experience Requirements
- [ ] Simple Swift package installation
- [ ] Intuitive CLI commands with help text
- [ ] Clean, minimal web interface
- [ ] Clear error messages and troubleshooting
- [ ] Simple documentation and examples