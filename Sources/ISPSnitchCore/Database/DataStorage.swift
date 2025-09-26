import Foundation
@preconcurrency import SQLite

// MARK: - DataStorage Main Class
public actor DataStorage {
    private let connection: Connection

    // Tables
    private let connectivityRecords = Table("connectivity_records")
    private let testConfigurations = Table("test_configurations")
    private let systemMetrics = Table("system_metrics")
    private let serviceStatus = Table("service_status")

    // Connectivity Records columns
    private let id = Expression<String>("id")
    private let timestamp = Expression<Date>("timestamp")
    private let testType = Expression<String>("test_type")
    private let target = Expression<String>("target")
    private let latency = Expression<Double?>("latency")
    private let success = Expression<Bool>("success")
    private let errorMessage = Expression<String?>("error_message")
    private let errorCode = Expression<Int?>("error_code")
    private let networkInterface = Expression<String>("network_interface")

    // System Context columns
    private let cpuUsage = Expression<Double>("cpu_usage")
    private let memoryUsage = Expression<Double>("memory_usage")
    private let networkInterfaceStatus = Expression<String>("network_interface_status")
    private let batteryLevel = Expression<Double?>("battery_level")

    // Test-specific data columns
    private let pingData = Expression<String?>("ping_data")
    private let httpData = Expression<String?>("http_data")
    private let dnsData = Expression<String?>("dns_data")
    private let speedtestData = Expression<String?>("speedtest_data")

    // Test Configuration columns
    private let name = Expression<String>("name")
    private let pingTargets = Expression<String>("ping_targets")
    private let httpTargets = Expression<String>("http_targets")
    private let dnsTargets = Expression<String>("dns_targets")
    private let testInterval = Expression<Double>("test_interval")
    private let timeout = Expression<Double>("timeout")
    private let retryCount = Expression<Int>("retry_count")
    private let webPort = Expression<Int>("web_port")
    private let dataRetentionDays = Expression<Int>("data_retention_days")
    private let enableNotifications = Expression<Bool>("enable_notifications")
    private let enableWebInterface = Expression<Bool>("enable_web_interface")
    private let isActive = Expression<Bool>("is_active")
    private let createdAt = Expression<Date>("created_at")
    private let updatedAt = Expression<Date>("updated_at")

    // System Metrics columns
    private let diskUsage = Expression<Double>("disk_usage")
    private let networkBytesIn = Expression<Int64>("network_bytes_in")
    private let networkBytesOut = Expression<Int64>("network_bytes_out")

    // Service Status columns
    private let status = Expression<String>("status")
    private let uptime = Expression<Double>("uptime")
    private let version = Expression<String>("version")

    public init(connection: Connection) throws {
        self.connection = connection
    }
}
