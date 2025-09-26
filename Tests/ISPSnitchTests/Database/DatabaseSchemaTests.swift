import XCTest
import Foundation
import SQLite
@testable import ISPSnitchCore

class DatabaseSchemaTests: XCTestCase {

    func testdatabaseConnection() throws {
        let db = try Connection(":memory:")
        XCTAssert(db != nil)
    }

    func testcreateConnectivityRecordsTable() throws {
        let db = try Connection(":memory:")

        let connectivityRecords = Table("connectivity_records")
        let id = Expression<String>("id")
        let timestamp = Expression<String>("timestamp")
        let testType = Expression<String>("test_type")
        let target = Expression<String>("target")
        let latency = Expression<Double?>("latency")
        let success = Expression<Bool>("success")
        let errorMessage = Expression<String?>("error_message")
        let errorCode = Expression<Int?>("error_code")
        let networkInterface = Expression<String>("network_interface")
        let cpuUsage = Expression<Double?>("cpu_usage")
        let memoryUsage = Expression<Double?>("memory_usage")
        let networkInterfaceStatus = Expression<String?>("network_interface_status")
        let batteryLevel = Expression<Double?>("battery_level")
        let pingData = Expression<String?>("ping_data")
        let httpData = Expression<String?>("http_data")
        let dnsData = Expression<String?>("dns_data")
        let speedtestData = Expression<String?>("speedtest_data")
        let createdAt = Expression<String>("created_at")

        try db.run(connectivityRecords.create { t in
            t.column(id, primaryKey: true)
            t.column(timestamp)
            t.column(testType)
            t.column(target)
            t.column(latency)
            t.column(success)
            t.column(errorMessage)
            t.column(errorCode)
            t.column(networkInterface)
            t.column(cpuUsage)
            t.column(memoryUsage)
            t.column(networkInterfaceStatus)
            t.column(batteryLevel)
            t.column(pingData)
            t.column(httpData)
            t.column(dnsData)
            t.column(speedtestData)
            t.column(createdAt, defaultValue: "CURRENT_TIMESTAMP")
        })

        // Verify table was created
        let tables = try db.prepare("SELECT name FROM sqlite_master WHERE type='table' AND name='connectivity_records'")
        let tableNames = try tables.map { row in row[0] as! String }
        XCTAssert(tableNames.contains("connectivity_records"))
    }

    func testcreateTestConfigurationsTable() throws {
        let db = try Connection(":memory:")

        let testConfigurations = Table("test_configurations")
        let id = Expression<String>("id")
        let name = Expression<String>("name")
        let pingTargets = Expression<String>("ping_targets")
        let httpTargets = Expression<String>("http_targets")
        let dnsTargets = Expression<String>("dns_targets")
        let testInterval = Expression<Int>("test_interval")
        let timeout = Expression<Int>("timeout")
        let retryCount = Expression<Int>("retry_count")
        let webPort = Expression<Int>("web_port")
        let dataRetentionDays = Expression<Int>("data_retention_days")
        let enableNotifications = Expression<Bool>("enable_notifications")
        let enableWebInterface = Expression<Bool>("enable_web_interface")
        let isActive = Expression<Bool>("is_active")
        let createdAt = Expression<String>("created_at")
        let updatedAt = Expression<String>("updated_at")

        try db.run(testConfigurations.create { t in
            t.column(id, primaryKey: true)
            t.column(name)
            t.column(pingTargets)
            t.column(httpTargets)
            t.column(dnsTargets)
            t.column(testInterval)
            t.column(timeout)
            t.column(retryCount)
            t.column(webPort)
            t.column(dataRetentionDays)
            t.column(enableNotifications)
            t.column(enableWebInterface)
            t.column(isActive, defaultValue: true)
            t.column(createdAt, defaultValue: "CURRENT_TIMESTAMP")
            t.column(updatedAt, defaultValue: "CURRENT_TIMESTAMP")
        })

        // Verify table was created
        let tables = try db.prepare("SELECT name FROM sqlite_master WHERE type='table' AND name='test_configurations'")
        let tableNames = try tables.map { row in row[0] as! String }
        XCTAssert(tableNames.contains("test_configurations"))
    }

    func testcreateSystemMetricsTable() throws {
        let db = try Connection(":memory:")

        let systemMetrics = Table("system_metrics")
        let id = Expression<String>("id")
        let timestamp = Expression<String>("timestamp")
        let cpuUsage = Expression<Double>("cpu_usage")
        let memoryUsage = Expression<Double>("memory_usage")
        let networkInterface = Expression<String>("network_interface")
        let networkInterfaceStatus = Expression<String>("network_interface_status")
        let batteryLevel = Expression<Double?>("battery_level")
        let createdAt = Expression<String>("created_at")

        try db.run(systemMetrics.create { t in
            t.column(id, primaryKey: true)
            t.column(timestamp)
            t.column(cpuUsage)
            t.column(memoryUsage)
            t.column(networkInterface)
            t.column(networkInterfaceStatus)
            t.column(batteryLevel)
            t.column(createdAt, defaultValue: "CURRENT_TIMESTAMP")
        })

        // Verify table was created
        let tables = try db.prepare("SELECT name FROM sqlite_master WHERE type='table' AND name='system_metrics'")
        let tableNames = try tables.map { row in row[0] as! String }
        XCTAssert(tableNames.contains("system_metrics"))
    }

    func testcreateServiceStatusTable() throws {
        let db = try Connection(":memory:")

        let serviceStatus = Table("service_status")
        let id = Expression<String>("id")
        let status = Expression<String>("status")
        let lastHeartbeat = Expression<String>("last_heartbeat")
        let uptimeSeconds = Expression<Int>("uptime_seconds")
        let totalTests = Expression<Int>("total_tests")
        let successfulTests = Expression<Int>("successful_tests")
        let failedTests = Expression<Int>("failed_tests")
        let createdAt = Expression<String>("created_at")
        let updatedAt = Expression<String>("updated_at")

        try db.run(serviceStatus.create { t in
            t.column(id, primaryKey: true)
            t.column(status)
            t.column(lastHeartbeat)
            t.column(uptimeSeconds)
            t.column(totalTests, defaultValue: 0)
            t.column(successfulTests, defaultValue: 0)
            t.column(failedTests, defaultValue: 0)
            t.column(createdAt, defaultValue: "CURRENT_TIMESTAMP")
            t.column(updatedAt, defaultValue: "CURRENT_TIMESTAMP")
        })

        // Verify table was created
        let tables = try db.prepare("SELECT name FROM sqlite_master WHERE type='table' AND name='service_status'")
        let tableNames = try tables.map { row in row[0] as! String }
        XCTAssert(tableNames.contains("service_status"))
    }

    func testcreatePerformanceIndexes() throws {
        let db = try Connection(":memory:")

        // Create connectivity_records table first
        let connectivityRecords = Table("connectivity_records")
        let timestamp = Expression<String>("timestamp")
        let testType = Expression<String>("test_type")
        let success = Expression<Bool>("success")

        try db.run(connectivityRecords.create { t in
            t.column(Expression<String>("id"), primaryKey: true)
            t.column(timestamp)
            t.column(testType)
            t.column(Expression<String>("target"))
            t.column(Expression<Bool>("success"))
        })

        // Create indexes
        try db.run(connectivityRecords.createIndex(timestamp))
        try db.run(connectivityRecords.createIndex(testType))
        try db.run(connectivityRecords.createIndex(success))

        // Verify indexes were created
        let indexes = try db.prepare("SELECT name FROM sqlite_master WHERE type='index'")
        let indexNames = try indexes.map { row in row[0] as! String }
        XCTAssert(indexNames.contains("index_connectivity_records_on_timestamp"))
        XCTAssert(indexNames.contains("index_connectivity_records_on_test_type"))
        XCTAssert(indexNames.contains("index_connectivity_records_on_success"))
    }

    func testdatabaseConstraints() throws {
        let db = try Connection(":memory:")

        let connectivityRecords = Table("connectivity_records")
        let id = Expression<String>("id")
        let timestamp = Expression<String>("timestamp")
        let testType = Expression<String>("test_type")
        let target = Expression<String>("target")
        let success = Expression<Bool>("success")
        let networkInterface = Expression<String>("network_interface")

        try db.run(connectivityRecords.create { t in
            t.column(id, primaryKey: true)
            t.column(timestamp)
            t.column(testType)
            t.column(target)
            t.column(success)
            t.column(networkInterface)
        })

        // Test NOT NULL constraints
        do {
            try db.run(connectivityRecords.insert(
                id <- "test-id",
                timestamp <- "2024-01-01T00:00:00Z",
                testType <- "ping",
                target <- "8.8.8.8",
                success <- true,
                networkInterface <- "en0"
            ))
            XCTAssert(true) // Should succeed
        } catch {
            XCTAssert(false, "Valid insert should not fail")
        }

        // Test that missing required fields fail
        do {
            try db.run(connectivityRecords.insert(
                id <- "test-id-2"
                // Missing required fields
            ))
            XCTAssert(false, "Insert with missing required fields should fail")
        } catch {
            XCTAssert(true) // Should fail
        }
    }

    func testdatabaseSchemaVersion() throws {
        let db = try Connection(":memory:")

        // Test that we can query the schema version
        let version = try db.scalar("SELECT sqlite_version()") as! String
        XCTAssert(!version.isEmpty)

        // Test that we can get table info
        let tables = try db.prepare("SELECT name FROM sqlite_master WHERE type='table'")
        let tableNames = try tables.map { row in row[0] as! String }
        XCTAssert(tableNames.isEmpty) // Should be empty for new database
    }
}
