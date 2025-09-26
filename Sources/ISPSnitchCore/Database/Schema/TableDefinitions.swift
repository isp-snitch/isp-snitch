import Foundation
@preconcurrency import SQLite

// MARK: - Table Definitions
public struct TableDefinitions {
    public static let connectivityRecords = Table("connectivity_records")
    public static let testConfigurations = Table("test_configurations")
    public static let systemMetrics = Table("system_metrics")
    public static let serviceStatus = Table("service_status")
}

// MARK: - Column Definitions
public struct ConnectivityRecordColumns {
    public static let id = Expression<String>("id")
    public static let timestamp = Expression<Date>(value: "timestamp")
    public static let testType = Expression<String>(value: "test_type")
    public static let target = Expression<String>(value: "target")
    public static let latency = Expression<Double?>(value: "latency")
    public static let success = Expression<Bool>(value: "success")
    public static let errorMessage = Expression<String?>(value: "error_message")
    public static let errorCode = Expression<Int?>(value: "error_code")
    public static let networkInterface = Expression<String>(value: "network_interface")

    // System Context columns
    public static let cpuUsage = Expression<Double>(value: "cpu_usage")
    public static let memoryUsage = Expression<Double>(value: "memory_usage")
    public static let networkInterfaceStatus = Expression<String>(value: "network_interface_status")
    public static let batteryLevel = Expression<Double?>(value: "battery_level")

    // Test-specific data columns
    public static let pingData = Expression<String?>(value: "ping_data")
    public static let httpData = Expression<String?>(value: "http_data")
    public static let dnsData = Expression<String?>(value: "dns_data")
    public static let speedtestData = Expression<String?>(value: "speedtest_data")
}

public struct TestConfigurationColumns {
    public static let id = Expression<String>("id")
    public static let name = Expression<String>(value: "name")
    public static let pingTargets = Expression<String>(value: "ping_targets")
    public static let httpTargets = Expression<String>(value: "http_targets")
    public static let dnsTargets = Expression<String>(value: "dns_targets")
    public static let testInterval = Expression<Double>(value: "test_interval")
    public static let timeout = Expression<Double>(value: "timeout")
    public static let retryCount = Expression<Int>(value: "retry_count")
    public static let webPort = Expression<Int>(value: "web_port")
    public static let dataRetentionDays = Expression<Int>(value: "data_retention_days")
    public static let enableNotifications = Expression<Bool>(value: "enable_notifications")
    public static let enableWebInterface = Expression<Bool>(value: "enable_web_interface")
    public static let isActive = Expression<Bool>(value: "is_active")
    public static let createdAt = Expression<Date>(value: "created_at")
    public static let updatedAt = Expression<Date>(value: "updated_at")
}

public struct SystemMetricsColumns {
    public static let id = Expression<String>("id")
    public static let timestamp = Expression<Date>(value: "timestamp")
    public static let cpuUsage = Expression<Double>(value: "cpu_usage")
    public static let memoryUsage = Expression<Double>(value: "memory_usage")
    public static let diskUsage = Expression<Double>(value: "disk_usage")
    public static let networkBytesIn = Expression<Int64>(value: "network_bytes_in")
    public static let networkBytesOut = Expression<Int64>(value: "network_bytes_out")
}

public struct ServiceStatusColumns {
    public static let id = Expression<String>("id")
    public static let timestamp = Expression<Date>(value: "timestamp")
    public static let status = Expression<String>(value: "status")
    public static let uptime = Expression<Double>(value: "uptime")
    public static let version = Expression<String>(value: "version")
}
