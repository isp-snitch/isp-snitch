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
- **Data Privacy and Security:** Local data handling with encryption

## Feature Overview

ISP Snitch is a lightweight ISP service monitor designed to help track outages and network issues from a local Mac. The solution generates accurate connectivity reports while running in the background using minimal resources. Reports can be viewed via CLI or by opening browser on localhost at specific port (accessible over network via .local address too). The service runs in background automatically when Mac starts. Built atop Homebrew package manager to provide underlying utilities. Built in modern Swift for services and CLI.

## System Architecture

### Core Components
1. **Background Service (Swift)**
   - Network monitoring daemon using Swift concurrency
   - Continuous connectivity testing and data collection
   - Local SQLite database with encrypted storage
   - Resource usage tracking and optimization
   - Automatic startup integration via LaunchAgent

2. **CLI Interface (Swift)**
   - Command-line reporting and status checking
   - Configuration management and service control
   - Data export functionality (JSON, CSV formats)
   - Real-time monitoring and alerting
   - Integration with system tools via Homebrew

3. **Web Interface (Swift + HTML/JS)**
   - Real-time dashboard with live connectivity status
   - Historical data visualization with charts and graphs
   - Configuration interface for test targets and intervals
   - Network accessibility via localhost and .local addresses
   - Responsive design for mobile and desktop access

4. **Data Layer**
   - Local SQLite database with AES-256 encryption
   - Configurable data retention policies
   - Efficient data compression and indexing
   - Export capabilities for ISP performance claims
   - Backup and restore functionality

## Technical Requirements

### Performance Requirements
- **CPU Usage:** < 1% average, < 5% peak during normal operation
- **Memory Usage:** < 50MB baseline, < 100MB peak with full dataset
- **Network Overhead:** < 1KB/s for monitoring operations
- **Startup Time:** < 5 seconds from system boot to active monitoring
- **Response Time:** < 100ms for CLI commands, < 500ms for web interface
- **Battery Impact:** Minimal impact on laptop battery life

### Connectivity Testing
- **Ping Tests:** ICMP ping to multiple targets (8.8.8.8, 1.1.1.1, ISP gateway)
- **HTTP Tests:** GET requests to test endpoints (google.com, cloudflare.com)
- **DNS Tests:** Resolution time and accuracy testing
- **Bandwidth Tests:** Periodic download/upload speed measurements
- **Latency Tests:** Round-trip time measurements with statistical analysis
- **ISP-Specific Tests:** Custom endpoints for ISP performance validation

### Data Collection
- **Timestamp:** ISO 8601 format with timezone information
- **Latency:** Millisecond precision with statistical analysis
- **Success/Failure:** Boolean with detailed error categorization
- **Network Interface:** Source interface identification (WiFi, Ethernet, etc.)
- **Target Information:** Test endpoint details and response codes
- **System Context:** CPU usage, memory usage, network interface status

### Security Requirements
- **Data Encryption:** AES-256 for all stored data at rest
- **Local Access Only:** No external network access or data transmission
- **Authentication:** Optional local authentication for web interface
- **Audit Logging:** All actions logged locally with tamper protection
- **Privacy:** No telemetry, usage data, or external communication
- **Sandboxing:** Minimal required permissions for security

## Implementation Details

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

### Homebrew Integration
- **Formula:** `isp-snitch.rb` with proper dependency management
- **Dependencies:** Swift 5.9+, SQLite3, curl, ping utilities
- **Installation:** `brew install isp-snitch`
- **Service Management:** `brew services start isp-snitch`
- **Updates:** Automatic updates via Homebrew with version checking
- **Uninstallation:** Clean removal with data preservation option

### macOS Integration
- **LaunchAgent:** `com.isp-snitch.monitor.plist` in user's LaunchAgents
- **User Agent:** Runs in user context with minimal privileges
- **Permissions:** Network access, file system access for data storage
- **Startup:** Automatic on user login with delay for system stability
- **System Integration:** Menu bar integration for quick status access
- **Notifications:** Optional system notifications for connectivity issues

### Web Interface
- **Framework:** Swift HTTP server with async/await support
- **Frontend:** HTML5, CSS3, JavaScript with modern frameworks
- **Real-time:** WebSocket connections for live updates
- **Responsive:** Mobile-friendly design with touch support
- **Accessibility:** WCAG 2.1 AA compliance for inclusive access
- **Performance:** Optimized for low-latency updates and smooth animations

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
- `isp-snitch report [--format json|csv] [--days N]` - Generate connectivity report
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
- Data storage operations with encrypted database
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
- Data encryption verification and key management
- Local access restrictions and network isolation
- Input validation and sanitization
- Authentication mechanisms and session management
- Audit logging and tamper detection
- Permission escalation prevention

## Deployment

### Installation Process
1. **Homebrew Installation:** `brew install isp-snitch`
2. **Service Registration:** Automatic LaunchAgent creation
3. **Configuration Setup:** Default configuration with user customization
4. **Initial Data Collection:** Start monitoring with default targets
5. **Web Interface Access:** Available at http://localhost:8080
6. **Network Access:** Available at http://[hostname].local:8080

### Configuration
- **Default Test Targets:** Google DNS, Cloudflare, ISP gateway
- **Monitoring Intervals:** 30 seconds for ping, 5 minutes for bandwidth
- **Data Retention:** 30 days by default, configurable
- **Web Interface:** Port 8080, optional authentication
- **Security Preferences:** Encryption enabled, local access only
- **Notifications:** Optional system notifications for outages

### Maintenance
- **Automatic Updates:** Via Homebrew with user notification
- **Data Backup:** Automatic daily backups with retention policy
- **Log Rotation:** Automatic log rotation with size limits
- **Performance Monitoring:** Built-in performance metrics collection
- **Security Updates:** Prompt installation of security patches
- **Health Checks:** Regular service health monitoring

## Success Criteria

### Functional Requirements
- [ ] Service starts automatically on Mac boot
- [ ] Continuous network monitoring with < 1% CPU usage
- [ ] Accurate connectivity reporting with scientific methodology
- [ ] CLI interface with all specified commands
- [ ] Web interface accessible via localhost and .local
- [ ] Data encryption and local storage
- [ ] Homebrew package installation and management

### Performance Requirements
- [ ] < 50MB memory usage baseline
- [ ] < 5 second startup time
- [ ] < 100ms CLI response time
- [ ] < 500ms web interface response time
- [ ] Minimal battery impact on laptops
- [ ] Stable operation over 24+ hour periods

### Security Requirements
- [ ] AES-256 encryption for all stored data
- [ ] No external network access or data transmission
- [ ] Local access only with optional authentication
- [ ] Comprehensive audit logging
- [ ] Minimal required system permissions

### User Experience Requirements
- [ ] Seamless Homebrew installation
- [ ] Intuitive CLI commands with help text
- [ ] Responsive web interface for all devices
- [ ] Clear error messages and troubleshooting
- [ ] Comprehensive documentation and examples