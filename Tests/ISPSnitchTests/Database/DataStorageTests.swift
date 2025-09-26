import Testing
import Foundation
import SQLite
@testable import ISPSnitchCore

struct DataStorageTests {

    @Test func insertConnectivityRecord() throws {
        let db = try Connection(":memory:")

        // Create table
        let connectivityRecords = Table("connectivity_records")
        let id = Expression<String>("id")
        let timestamp = Expression<String>("timestamp")
        let testType = Expression<String>("test_type")
        let target = Expression<String>("target")
        let latency = Expression<Double?>("latency")
        let success = Expression<Bool>("success")
        let networkInterface = Expression<String>("network_interface")
        let cpuUsage = Expression<Double?>("cpu_usage")
        let memoryUsage = Expression<Double?>("memory_usage")

        try db.run(connectivityRecords.create { t in
            t.column(id, primaryKey: true)
            t.column(timestamp)
            t.column(testType)
            t.column(target)
            t.column(latency)
            t.column(success)
            t.column(networkInterface)
            t.column(cpuUsage)
            t.column(memoryUsage)
        })

        // Insert test record
        let recordId = UUID().uuidString
        let now = ISO8601DateFormatter().string(from: Date())

        try db.run(connectivityRecords.insert(
            id <- recordId,
            timestamp <- now,
            testType <- "ping",
            target <- "8.8.8.8",
            latency <- 0.024,
            success <- true,
            networkInterface <- "en0",
            cpuUsage <- 0.5,
            memoryUsage <- 42.0
        ))

        // Verify insertion
        let count = try db.scalar(connectivityRecords.count)
        #expect(count == 1)

        // Verify data
        let record = try db.pluck(connectivityRecords.filter(id == recordId))
        #expect(record != nil)
        #expect(record![testType] == "ping")
        #expect(record![target] == "8.8.8.8")
        #expect(record![latency] == 0.024)
        #expect(record![success] == true)
    }

    @Test func insertTestConfiguration() throws {
        let db = try Connection(":memory:")

        // Create table
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
            t.column(isActive)
        })

        // Insert test configuration
        let configId = UUID().uuidString
        let pingTargetsJson = try JSONSerialization.data(withJSONObject: ["8.8.8.8", "1.1.1.1"])
        let httpTargetsJson = try JSONSerialization.data(withJSONObject: ["https://google.com"])
        let dnsTargetsJson = try JSONSerialization.data(withJSONObject: ["google.com"])

        try db.run(testConfigurations.insert(
            id <- configId,
            name <- "Default Configuration",
            pingTargets <- String(data: pingTargetsJson, encoding: .utf8)!,
            httpTargets <- String(data: httpTargetsJson, encoding: .utf8)!,
            dnsTargets <- String(data: dnsTargetsJson, encoding: .utf8)!,
            testInterval <- 60,
            timeout <- 30,
            retryCount <- 3,
            webPort <- 8080,
            dataRetentionDays <- 30,
            enableNotifications <- true,
            enableWebInterface <- true,
            isActive <- true
        ))

        // Verify insertion
        let count = try db.scalar(testConfigurations.count)
        #expect(count == 1)

        // Verify data
        let config = try db.pluck(testConfigurations.filter(id == configId))
        #expect(config != nil)
        #expect(config![name] == "Default Configuration")
        #expect(config![testInterval] == 60)
        #expect(config![timeout] == 30)
        #expect(config![retryCount] == 3)
        #expect(config![webPort] == 8080)
        #expect(config![dataRetentionDays] == 30)
        #expect(config![enableNotifications] == true)
        #expect(config![enableWebInterface] == true)
        #expect(config![isActive] == true)
    }

    @Test func insertSystemMetrics() throws {
        let db = try Connection(":memory:")

        // Create table
        let systemMetrics = Table("system_metrics")
        let id = Expression<String>("id")
        let timestamp = Expression<String>("timestamp")
        let cpuUsage = Expression<Double>("cpu_usage")
        let memoryUsage = Expression<Double>("memory_usage")
        let networkInterface = Expression<String>("network_interface")
        let networkInterfaceStatus = Expression<String>("network_interface_status")
        let batteryLevel = Expression<Double?>("battery_level")

        try db.run(systemMetrics.create { t in
            t.column(id, primaryKey: true)
            t.column(timestamp)
            t.column(cpuUsage)
            t.column(memoryUsage)
            t.column(networkInterface)
            t.column(networkInterfaceStatus)
            t.column(batteryLevel)
        })

        // Insert test metrics
        let metricsId = UUID().uuidString
        let now = ISO8601DateFormatter().string(from: Date())

        try db.run(systemMetrics.insert(
            id <- metricsId,
            timestamp <- now,
            cpuUsage <- 0.25,
            memoryUsage <- 512.0,
            networkInterface <- "en0",
            networkInterfaceStatus <- "active",
            batteryLevel <- 85.0
        ))

        // Verify insertion
        let count = try db.scalar(systemMetrics.count)
        #expect(count == 1)

        // Verify data
        let metrics = try db.pluck(systemMetrics.filter(id == metricsId))
        #expect(metrics != nil)
        #expect(metrics![cpuUsage] == 0.25)
        #expect(metrics![memoryUsage] == 512.0)
        #expect(metrics![networkInterface] == "en0")
        #expect(metrics![networkInterfaceStatus] == "active")
        #expect(metrics![batteryLevel] == 85.0)
    }

    @Test func insertServiceStatus() throws {
        let db = try Connection(":memory:")

        // Create table
        let serviceStatus = Table("service_status")
        let id = Expression<String>("id")
        let status = Expression<String>("status")
        let lastHeartbeat = Expression<String>("last_heartbeat")
        let uptimeSeconds = Expression<Int>("uptime_seconds")
        let totalTests = Expression<Int>("total_tests")
        let successfulTests = Expression<Int>("successful_tests")
        let failedTests = Expression<Int>("failed_tests")

        try db.run(serviceStatus.create { t in
            t.column(id, primaryKey: true)
            t.column(status)
            t.column(lastHeartbeat)
            t.column(uptimeSeconds)
            t.column(totalTests, defaultValue: 0)
            t.column(successfulTests, defaultValue: 0)
            t.column(failedTests, defaultValue: 0)
        })

        // Insert test status
        let statusId = UUID().uuidString
        let now = ISO8601DateFormatter().string(from: Date())

        try db.run(serviceStatus.insert(
            id <- statusId,
            status <- "running",
            lastHeartbeat <- now,
            uptimeSeconds <- 3600,
            totalTests <- 100,
            successfulTests <- 95,
            failedTests <- 5
        ))

        // Verify insertion
        let count = try db.scalar(serviceStatus.count)
        #expect(count == 1)

        // Verify data
        let statusRecord = try db.pluck(serviceStatus.filter(id == statusId))
        #expect(statusRecord != nil)
        #expect(statusRecord![status] == "running")
        #expect(statusRecord![uptimeSeconds] == 3600)
        #expect(statusRecord![totalTests] == 100)
        #expect(statusRecord![successfulTests] == 95)
        #expect(statusRecord![failedTests] == 5)
    }

    @Test func queryConnectivityRecords() throws {
        let db = try Connection(":memory:")

        // Create table and insert test data
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

        // Insert multiple test records
        let now = ISO8601DateFormatter().string(from: Date())
        for i in 1...5 {
            try db.run(connectivityRecords.insert(
                id <- "test-\(i)",
                timestamp <- now,
                testType <- i % 2 == 0 ? "ping" : "http",
                target <- i % 2 == 0 ? "8.8.8.8" : "https://google.com",
                success <- i % 3 != 0, // Some failures
                networkInterface <- "en0"
            ))
        }

        // Test queries
        let allRecords = try db.prepare(connectivityRecords)
        let allCount = try allRecords.map { _ in 1 }.reduce(0, +)
        #expect(allCount == 5)

        let pingRecords = try db.prepare(connectivityRecords.filter(testType == "ping"))
        let pingCount = try pingRecords.map { _ in 1 }.reduce(0, +)
        #expect(pingCount == 2)

        let successfulRecords = try db.prepare(connectivityRecords.filter(success == true))
        let successCount = try successfulRecords.map { _ in 1 }.reduce(0, +)
        #expect(successCount == 4) // 1,2,4,5 are successful (i % 3 != 0)

        let failedRecords = try db.prepare(connectivityRecords.filter(success == false))
        let failCount = try failedRecords.map { _ in 1 }.reduce(0, +)
        #expect(failCount == 1) // Only 3 fails (i % 3 == 0)
    }

    @Test func updateServiceStatus() throws {
        let db = try Connection(":memory:")

        // Create table
        let serviceStatus = Table("service_status")
        let id = Expression<String>("id")
        let status = Expression<String>("status")
        let lastHeartbeat = Expression<String>("last_heartbeat")
        let uptimeSeconds = Expression<Int>("uptime_seconds")
        let totalTests = Expression<Int>("total_tests")
        let successfulTests = Expression<Int>("successful_tests")
        let failedTests = Expression<Int>("failed_tests")

        try db.run(serviceStatus.create { t in
            t.column(id, primaryKey: true)
            t.column(status)
            t.column(lastHeartbeat)
            t.column(uptimeSeconds)
            t.column(totalTests, defaultValue: 0)
            t.column(successfulTests, defaultValue: 0)
            t.column(failedTests, defaultValue: 0)
        })

        // Insert initial status
        let statusId = UUID().uuidString
        let now = ISO8601DateFormatter().string(from: Date())

        try db.run(serviceStatus.insert(
            id <- statusId,
            status <- "running",
            lastHeartbeat <- now,
            uptimeSeconds <- 0,
            totalTests <- 0,
            successfulTests <- 0,
            failedTests <- 0
        ))

        // Update status
        let updateTime = ISO8601DateFormatter().string(from: Date())
        try db.run(serviceStatus.filter(id == statusId).update(
            status <- "running",
            lastHeartbeat <- updateTime,
            uptimeSeconds <- 3600,
            totalTests <- 100,
            successfulTests <- 95,
            failedTests <- 5
        ))

        // Verify update
        let updatedStatus = try db.pluck(serviceStatus.filter(id == statusId))
        #expect(updatedStatus != nil)
        #expect(updatedStatus![status] == "running")
        #expect(updatedStatus![uptimeSeconds] == 3600)
        #expect(updatedStatus![totalTests] == 100)
        #expect(updatedStatus![successfulTests] == 95)
        #expect(updatedStatus![failedTests] == 5)
    }

    @Test func deleteOldRecords() throws {
        let db = try Connection(":memory:")

        // Create table
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

        // Insert test records with different timestamps
        let formatter = ISO8601DateFormatter()
        let now = Date()
        let oldDate = now.addingTimeInterval(-86400 * 35) // 35 days ago

        for i in 1...5 {
            let recordDate = i <= 2 ? oldDate : now
            try db.run(connectivityRecords.insert(
                id <- "test-\(i)",
                timestamp <- formatter.string(from: recordDate),
                testType <- "ping",
                target <- "8.8.8.8",
                success <- true,
                networkInterface <- "en0"
            ))
        }

        // Verify initial count
        let initialCount = try db.scalar(connectivityRecords.count)
        #expect(initialCount == 5)

        // Delete old records (older than 30 days)
        let cutoffDate = now.addingTimeInterval(-86400 * 30)
        let cutoffString = formatter.string(from: cutoffDate)

        try db.run(connectivityRecords.filter(timestamp < cutoffString).delete())

        // Verify deletion
        let finalCount = try db.scalar(connectivityRecords.count)
        #expect(finalCount == 3) // Should have deleted 2 old records
    }
}
