# ISP Snitch - Data Model Specification

**Feature ID:** 001  
**Branch:** 001-isp-snitch-a  
**Generated:** 2024-12-19  
**Status:** Data Model Complete

## Overview

This document defines the complete data model for ISP Snitch, including database schema, Swift data structures, and API contracts. The model is designed to support accurate connectivity reporting while maintaining minimal resource usage.

## Database Schema

### SQLite Database Structure

```sql
-- Main connectivity records table
CREATE TABLE connectivity_records (
    id TEXT PRIMARY KEY,
    timestamp TEXT NOT NULL,
    test_type TEXT NOT NULL,
    target TEXT NOT NULL,
    latency REAL,
    success INTEGER NOT NULL,
    error_message TEXT,
    error_code INTEGER,
    network_interface TEXT NOT NULL,
    cpu_usage REAL,
    memory_usage REAL,
    network_interface_status TEXT,
    battery_level REAL,
    
    -- Test-specific data (JSON for flexibility)
    ping_data TEXT,  -- JSON: PingData
    http_data TEXT,  -- JSON: HttpData
    dns_data TEXT,   -- JSON: DnsData
    speedtest_data TEXT,  -- JSON: SpeedtestData
    
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Test configurations table
CREATE TABLE test_configurations (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    ping_targets TEXT NOT NULL, -- JSON array
    http_targets TEXT NOT NULL, -- JSON array
    dns_targets TEXT NOT NULL, -- JSON array
    test_interval INTEGER NOT NULL,
    timeout INTEGER NOT NULL,
    retry_count INTEGER NOT NULL,
    web_port INTEGER NOT NULL,
    data_retention_days INTEGER NOT NULL,
    enable_notifications INTEGER NOT NULL,
    enable_web_interface INTEGER NOT NULL,
    is_active INTEGER NOT NULL DEFAULT 1,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- System metrics table
CREATE TABLE system_metrics (
    id TEXT PRIMARY KEY,
    timestamp TEXT NOT NULL,
    cpu_usage REAL NOT NULL,
    memory_usage REAL NOT NULL,
    network_interface TEXT NOT NULL,
    network_interface_status TEXT NOT NULL,
    battery_level REAL,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Service status table
CREATE TABLE service_status (
    id TEXT PRIMARY KEY,
    status TEXT NOT NULL, -- running, stopped, error
    last_heartbeat TEXT NOT NULL,
    uptime_seconds INTEGER NOT NULL,
    total_tests INTEGER NOT NULL DEFAULT 0,
    successful_tests INTEGER NOT NULL DEFAULT 0,
    failed_tests INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX idx_connectivity_timestamp ON connectivity_records(timestamp);
CREATE INDEX idx_connectivity_test_type ON connectivity_records(test_type);
CREATE INDEX idx_connectivity_success ON connectivity_records(success);
CREATE INDEX idx_system_metrics_timestamp ON system_metrics(timestamp);
```

## Swift Data Structures

### Core Data Models

```swift
import Foundation

// MARK: - Connectivity Record
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
    
    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        testType: TestType,
        target: String,
        latency: TimeInterval? = nil,
        success: Bool,
        errorMessage: String? = nil,
        errorCode: Int? = nil,
        networkInterface: String,
        systemContext: SystemContext,
        pingData: PingData? = nil,
        httpData: HttpData? = nil,
        dnsData: DnsData? = nil,
        speedtestData: SpeedtestData? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.testType = testType
        self.target = target
        self.latency = latency
        self.success = success
        self.errorMessage = errorMessage
        self.errorCode = errorCode
        self.networkInterface = networkInterface
        self.systemContext = systemContext
        self.pingData = pingData
        self.httpData = httpData
        self.dnsData = dnsData
        self.speedtestData = speedtestData
    }
}

// MARK: - Test Types
enum TestType: String, CaseIterable, Codable, Sendable {
    case ping = "ping"
    case http = "http"
    case dns = "dns"
    case bandwidth = "bandwidth"
    case latency = "latency"
    
    var displayName: String {
        switch self {
        case .ping: return "Ping Test"
        case .http: return "HTTP Test"
        case .dns: return "DNS Test"
        case .bandwidth: return "Bandwidth Test"
        case .latency: return "Latency Test"
        }
    }
    
    var defaultTargets: [String] {
        switch self {
        case .ping: return ["8.8.8.8", "1.1.1.1"]
        case .http: return ["https://google.com", "https://cloudflare.com"]
        case .dns: return ["google.com", "cloudflare.com"]
        case .bandwidth: return ["speedtest.net"]
        case .latency: return ["8.8.8.8", "1.1.1.1"]
        }
    }
}

// MARK: - System Context
struct SystemContext: Sendable, Codable {
    let cpuUsage: Double
    let memoryUsage: Double
    let networkInterfaceStatus: String
    let batteryLevel: Double?
    
    init(
        cpuUsage: Double,
        memoryUsage: Double,
        networkInterfaceStatus: String,
        batteryLevel: Double? = nil
    ) {
        self.cpuUsage = cpuUsage
        self.memoryUsage = memoryUsage
        self.networkInterfaceStatus = networkInterfaceStatus
        self.batteryLevel = batteryLevel
    }
}

// MARK: - Test-Specific Data Structures
struct PingData: Sendable, Codable {
    let latency: TimeInterval
    let packetLoss: Double
    let ttl: Int?
    let statistics: PingStatistics?
    
    init(
        latency: TimeInterval,
        packetLoss: Double,
        ttl: Int? = nil,
        statistics: PingStatistics? = nil
    ) {
        self.latency = latency
        self.packetLoss = packetLoss
        self.ttl = ttl
        self.statistics = statistics
    }
}

struct PingStatistics: Sendable, Codable {
    let minLatency: TimeInterval
    let avgLatency: TimeInterval
    let maxLatency: TimeInterval
    let stdDev: TimeInterval
    let packetsTransmitted: Int
    let packetsReceived: Int
    
    init(
        minLatency: TimeInterval,
        avgLatency: TimeInterval,
        maxLatency: TimeInterval,
        stdDev: TimeInterval,
        packetsTransmitted: Int,
        packetsReceived: Int
    ) {
        self.minLatency = minLatency
        self.avgLatency = avgLatency
        self.maxLatency = maxLatency
        self.stdDev = stdDev
        self.packetsTransmitted = packetsTransmitted
        self.packetsReceived = packetsReceived
    }
}

struct HttpData: Sendable, Codable {
    let httpCode: Int
    let totalTime: TimeInterval
    let connectTime: TimeInterval
    let dnsTime: TimeInterval
    let downloadSize: Int
    let downloadSpeed: Double
    
    init(
        httpCode: Int,
        totalTime: TimeInterval,
        connectTime: TimeInterval,
        dnsTime: TimeInterval,
        downloadSize: Int,
        downloadSpeed: Double
    ) {
        self.httpCode = httpCode
        self.totalTime = totalTime
        self.connectTime = connectTime
        self.dnsTime = dnsTime
        self.downloadSize = downloadSize
        self.downloadSpeed = downloadSpeed
    }
}

struct DnsData: Sendable, Codable {
    let queryTime: TimeInterval
    let status: String
    let answerCount: Int
    let server: String
    let answers: [String]
    
    init(
        queryTime: TimeInterval,
        status: String,
        answerCount: Int,
        server: String,
        answers: [String]
    ) {
        self.queryTime = queryTime
        self.status = status
        self.answerCount = answerCount
        self.server = server
        self.answers = answers
    }
}

struct SpeedtestData: Sendable, Codable {
    let ping: TimeInterval
    let downloadSpeed: Double  // Mbit/s
    let uploadSpeed: Double    // Mbit/s
    
    init(
        ping: TimeInterval,
        downloadSpeed: Double,
        uploadSpeed: Double
    ) {
        self.ping = ping
        self.downloadSpeed = downloadSpeed
        self.uploadSpeed = uploadSpeed
    }
}

// MARK: - Test Configuration
struct TestConfiguration: Codable, Identifiable {
    let id: UUID
    let name: String
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
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        pingTargets: [String] = TestType.ping.defaultTargets,
        httpTargets: [String] = TestType.http.defaultTargets,
        dnsTargets: [String] = TestType.dns.defaultTargets,
        testInterval: TimeInterval = 30.0,
        timeout: TimeInterval = 10.0,
        retryCount: Int = 3,
        webPort: Int = 8080,
        dataRetentionDays: Int = 30,
        enableNotifications: Bool = true,
        enableWebInterface: Bool = true,
        isActive: Bool = true
    ) {
        self.id = id
        self.name = name
        self.pingTargets = pingTargets
        self.httpTargets = httpTargets
        self.dnsTargets = dnsTargets
        self.testInterval = testInterval
        self.timeout = timeout
        self.retryCount = retryCount
        self.webPort = webPort
        self.dataRetentionDays = dataRetentionDays
        self.enableNotifications = enableNotifications
        self.enableWebInterface = enableWebInterface
        self.isActive = isActive
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - System Metrics
struct SystemMetrics: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let cpuUsage: Double
    let memoryUsage: Double
    let networkInterface: String
    let networkInterfaceStatus: String
    let batteryLevel: Double?
    
    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        cpuUsage: Double,
        memoryUsage: Double,
        networkInterface: String,
        networkInterfaceStatus: String,
        batteryLevel: Double? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.cpuUsage = cpuUsage
        self.memoryUsage = memoryUsage
        self.networkInterface = networkInterface
        self.networkInterfaceStatus = networkInterfaceStatus
        self.batteryLevel = batteryLevel
    }
}

// MARK: - Service Status
struct ServiceStatus: Codable, Identifiable {
    let id: UUID
    let status: ServiceStatusType
    let lastHeartbeat: Date
    let uptimeSeconds: Int
    let totalTests: Int
    let successfulTests: Int
    let failedTests: Int
    let createdAt: Date
    let updatedAt: Date
    
    var successRate: Double {
        guard totalTests > 0 else { return 0.0 }
        return Double(successfulTests) / Double(totalTests)
    }
    
    init(
        id: UUID = UUID(),
        status: ServiceStatusType,
        lastHeartbeat: Date = Date(),
        uptimeSeconds: Int = 0,
        totalTests: Int = 0,
        successfulTests: Int = 0,
        failedTests: Int = 0
    ) {
        self.id = id
        self.status = status
        self.lastHeartbeat = lastHeartbeat
        self.uptimeSeconds = uptimeSeconds
        self.totalTests = totalTests
        self.successfulTests = successfulTests
        self.failedTests = failedTests
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum ServiceStatusType: String, CaseIterable, Codable {
    case running = "running"
    case stopped = "stopped"
    case error = "error"
    case starting = "starting"
    case stopping = "stopping"
    
    var displayName: String {
        switch self {
        case .running: return "Running"
        case .stopped: return "Stopped"
        case .error: return "Error"
        case .starting: return "Starting"
        case .stopping: return "Stopping"
        }
    }
}
```

## API Data Models

### Request/Response Models

```swift
// MARK: - API Request Models
struct ReportRequest: Codable {
    let days: Int?
    let format: ReportFormat?
    let testType: TestType?
    let target: String?
    
    init(days: Int? = nil, format: ReportFormat? = nil, testType: TestType? = nil, target: String? = nil) {
        self.days = days
        self.format = format
        self.testType = testType
        self.target = target
    }
}

struct ConfigUpdateRequest: Codable {
    let pingTargets: [String]?
    let httpTargets: [String]?
    let dnsTargets: [String]?
    let testInterval: TimeInterval?
    let timeout: TimeInterval?
    let retryCount: Int?
    let webPort: Int?
    let dataRetentionDays: Int?
    let enableNotifications: Bool?
    let enableWebInterface: Bool?
}

// MARK: - API Response Models
struct StatusResponse: Codable {
    let serviceStatus: ServiceStatus
    let currentConnectivity: [ConnectivityRecord]
    let systemMetrics: SystemMetrics
    let uptime: String
    let lastUpdate: Date
}

struct ReportResponse: Codable {
    let records: [ConnectivityRecord]
    let summary: ReportSummary
    let generatedAt: Date
    let timeRange: TimeRange
}

struct ReportSummary: Codable {
    let totalTests: Int
    let successfulTests: Int
    let failedTests: Int
    let averageLatency: TimeInterval?
    let minLatency: TimeInterval?
    let maxLatency: TimeInterval?
    let successRate: Double
    let testTypeBreakdown: [TestTypeSummary]
}

struct TestTypeSummary: Codable {
    let testType: TestType
    let totalTests: Int
    let successfulTests: Int
    let failedTests: Int
    let averageLatency: TimeInterval?
    let successRate: Double
}

struct TimeRange: Codable {
    let start: Date
    let end: Date
    let duration: TimeInterval
}

enum ReportFormat: String, CaseIterable, Codable {
    case json = "json"
    case csv = "csv"
    case html = "html"
}

// MARK: - Export Models
struct ExportRequest: Codable {
    let format: ReportFormat
    let days: Int?
    let testType: TestType?
    let target: String?
    let includeSystemMetrics: Bool
}

struct ExportResponse: Codable {
    let data: String
    let format: ReportFormat
    let recordCount: Int
    let generatedAt: Date
    let timeRange: TimeRange
}
```

## Data Validation

### Validation Rules

```swift
// MARK: - Data Validation
extension ConnectivityRecord {
    func validate() throws {
        guard !target.isEmpty else {
            throw ValidationError.invalidTarget("Target cannot be empty")
        }
        
        guard testInterval > 0 else {
            throw ValidationError.invalidInterval("Test interval must be positive")
        }
        
        if let latency = latency, latency < 0 {
            throw ValidationError.invalidLatency("Latency cannot be negative")
        }
    }
}

extension TestConfiguration {
    func validate() throws {
        guard !name.isEmpty else {
            throw ValidationError.invalidName("Configuration name cannot be empty")
        }
        
        guard testInterval > 0 else {
            throw ValidationError.invalidInterval("Test interval must be positive")
        }
        
        guard timeout > 0 else {
            throw ValidationError.invalidTimeout("Timeout must be positive")
        }
        
        guard retryCount >= 0 else {
            throw ValidationError.invalidRetryCount("Retry count cannot be negative")
        }
        
        guard webPort > 0 && webPort <= 65535 else {
            throw ValidationError.invalidPort("Web port must be between 1 and 65535")
        }
        
        guard dataRetentionDays > 0 else {
            throw ValidationError.invalidRetention("Data retention days must be positive")
        }
    }
}

enum ValidationError: Error, LocalizedError {
    case invalidTarget(String)
    case invalidInterval(String)
    case invalidLatency(String)
    case invalidName(String)
    case invalidTimeout(String)
    case invalidRetryCount(String)
    case invalidPort(String)
    case invalidRetention(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidTarget(let message),
             .invalidInterval(let message),
             .invalidLatency(let message),
             .invalidName(let message),
             .invalidTimeout(let message),
             .invalidRetryCount(let message),
             .invalidPort(let message),
             .invalidRetention(let message):
            return message
        }
    }
}
```

## Data Migration

### Version Management

```swift
// MARK: - Database Migration
struct DatabaseMigration {
    let version: Int
    let description: String
    let migration: () throws -> Void
    
    static let migrations: [DatabaseMigration] = [
        DatabaseMigration(
            version: 1,
            description: "Initial schema creation",
            migration: { try createInitialSchema() }
        ),
        DatabaseMigration(
            version: 2,
            description: "Add system metrics table",
            migration: { try addSystemMetricsTable() }
        ),
        DatabaseMigration(
            version: 3,
            description: "Add service status table",
            migration: { try addServiceStatusTable() }
        )
    ]
    
    private static func createInitialSchema() throws {
        // Implementation for initial schema creation
    }
    
    private static func addSystemMetricsTable() throws {
        // Implementation for adding system metrics table
    }
    
    private static func addServiceStatusTable() throws {
        // Implementation for adding service status table
    }
}
```

## Performance Considerations

### Indexing Strategy
- Primary indexes on timestamp fields for time-based queries
- Composite indexes on test_type and success for filtering
- Index on network_interface for interface-specific analysis

### Data Retention
- Automatic cleanup of old records based on retention policy
- Configurable retention periods per test type
- iCloud backup for long-term data preservation

### Memory Management
- Streaming data processing for large datasets
- Lazy loading of non-critical data
- Efficient data structures for minimal memory footprint

## Security Considerations

### Data Encryption
- SQLite database encryption for sensitive data
- Secure key management for encryption keys
- No external data transmission

### Access Control
- Local access only
- No external network exposure
- Simple user-based access control

### Privacy Protection
- No telemetry or usage data collection
- All data remains local to user's machine
- User control over data sharing and export
