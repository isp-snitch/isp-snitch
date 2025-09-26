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
    public static let timestamp = Expression<Date>("timestamp")
    public static let testType = Expression<String>("test_type")
    public static let target = Expression<String>("target")
    public static let latency = Expression<Double?>("latency")
    public static let success = Expression<Bool>("success")
    public static let errorMessage = Expression<String?>("error_message")
    public static let errorCode = Expression<Int?>("error_code")
    public static let networkInterface = Expression<String>("network_interface")
    
    // System Context columns
    public static let cpuUsage = Expression<Double>("cpu_usage")
    public static let memoryUsage = Expression<Double>("memory_usage")
    public static let networkInterfaceStatus = Expression<String>("network_interface_status")
    public static let batteryLevel = Expression<Double?>("battery_level")
    
    // Test-specific data columns
    public static let pingData = Expression<String?>("ping_data")
    public static let httpData = Expression<String?>("http_data")
    public static let dnsData = Expression<String?>("dns_data")
    public static let speedtestData = Expression<String?>("speedtest_data")
}

public struct TestConfigurationColumns {
    public static let id = Expression<String>("id")
    public static let name = Expression<String>("name")
    public static let pingTargets = Expression<String>("ping_targets")
    public static let httpTargets = Expression<String>("http_targets")
    public static let dnsTargets = Expression<String>("dns_targets")
    public static let testInterval = Expression<Double>("test_interval")
    public static let timeout = Expression<Double>("timeout")
    public static let retryCount = Expression<Int>("retry_count")
    public static let webPort = Expression<Int>("web_port")
    public static let dataRetentionDays = Expression<Int>("data_retention_days")
    public static let enableNotifications = Expression<Bool>("enable_notifications")
    public static let enableWebInterface = Expression<Bool>("enable_web_interface")
    public static let isActive = Expression<Bool>("is_active")
    public static let createdAt = Expression<Date>("created_at")
    public static let updatedAt = Expression<Date>("updated_at")
}

public struct SystemMetricsColumns {
    public static let id = Expression<String>("id")
    public static let timestamp = Expression<Date>("timestamp")
    public static let cpuUsage = Expression<Double>("cpu_usage")
    public static let memoryUsage = Expression<Double>("memory_usage")
    public static let diskUsage = Expression<Double>("disk_usage")
    public static let networkBytesIn = Expression<Int64>("network_bytes_in")
    public static let networkBytesOut = Expression<Int64>("network_bytes_out")
}

public struct ServiceStatusColumns {
    public static let id = Expression<String>("id")
    public static let timestamp = Expression<Date>("timestamp")
    public static let status = Expression<String>("status")
    public static let uptime = Expression<Double>("uptime")
    public static let version = Expression<String>("version")
}
