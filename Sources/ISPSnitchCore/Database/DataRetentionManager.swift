import Foundation
@preconcurrency import SQLite

// MARK: - Data Retention Manager
public actor DataRetentionManager: Sendable {
    private let connection: Connection
    private let retentionDays: Int
    
    // Tables
    private let connectivityRecords = Table("connectivity_records")
    private let systemMetrics = Table("system_metrics")
    private let serviceStatus = Table("service_status")
    
    // Columns
    private let timestamp = Expression<Date>(value: "timestamp")
    
    public init(connection: Connection, retentionDays: Int = 30) {
        self.connection = connection
        self.retentionDays = retentionDays
    }
    
    // MARK: - Public Interface
    
    public func cleanupOldData() async throws {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -retentionDays, to: Date()) ?? Date.distantPast
        
        let deletedConnectivityRecords = try cleanupConnectivityRecords(olderThan: cutoffDate)
        let deletedSystemMetrics = try cleanupSystemMetrics(olderThan: cutoffDate)
        let deletedServiceStatus = try cleanupServiceStatus(olderThan: cutoffDate)
        
        print("Data retention cleanup completed:")
        print("- Deleted \(deletedConnectivityRecords) connectivity records")
        print("- Deleted \(deletedSystemMetrics) system metrics")
        print("- Deleted \(deletedServiceStatus) service status records")
        print("- Retention period: \(retentionDays) days")
    }
    
    public func getDataStorageStats() async throws -> DataStorageStats {
        let connectivityCount = try connection.scalar(connectivityRecords.count)
        let systemMetricsCount = try connection.scalar(systemMetrics.count)
        let serviceStatusCount = try connection.scalar(serviceStatus.count)
        
        let oldestConnectivity = try connection.pluck(
            connectivityRecords.select(timestamp.min)
        )?[timestamp.min]
        
        let newestConnectivity = try connection.pluck(
            connectivityRecords.select(timestamp.max)
        )?[timestamp.max]
        
        return DataStorageStats(
            connectivityRecordsCount: connectivityCount,
            systemMetricsCount: systemMetricsCount,
            serviceStatusCount: serviceStatusCount,
            oldestRecord: oldestConnectivity,
            newestRecord: newestConnectivity,
            retentionDays: retentionDays
        )
    }
    
    public func vacuum() async throws {
        try connection.execute("VACUUM")
        print("Database vacuum completed")
    }
    
    public func analyzeDatabase() async throws {
        try connection.execute("ANALYZE")
        print("Database analysis completed")
    }
    
    // MARK: - Private Methods
    
    private func cleanupConnectivityRecords(olderThan cutoffDate: Date) throws -> Int {
        let deleteQuery = connectivityRecords.filter(timestamp < cutoffDate)
        return try connection.run(deleteQuery.delete())
    }
    
    private func cleanupSystemMetrics(olderThan cutoffDate: Date) throws -> Int {
        let deleteQuery = systemMetrics.filter(timestamp < cutoffDate)
        return try connection.run(deleteQuery.delete())
    }
    
    private func cleanupServiceStatus(olderThan cutoffDate: Date) throws -> Int {
        // Keep at least the 10 most recent service status records
        let keepCount = 10
        
        let totalCount = try connection.scalar(serviceStatus.count)
        
        if totalCount <= keepCount {
            return 0 // Don't delete anything if we have fewer records than we want to keep
        }
        
        // Delete records older than cutoff date, but keep at least the most recent ones
        let recentRecords = serviceStatus
            .select(timestamp)
            .order(timestamp.desc)
            .limit(keepCount)
        
        let deleteQuery = serviceStatus.filter(timestamp < cutoffDate)
        
        return try connection.run(deleteQuery.delete())
    }
}

// MARK: - Data Storage Stats
public struct DataStorageStats: Sendable, Codable {
    public let connectivityRecordsCount: Int
    public let systemMetricsCount: Int
    public let serviceStatusCount: Int
    public let oldestRecord: Date?
    public let newestRecord: Date?
    public let retentionDays: Int
    
    public init(
        connectivityRecordsCount: Int,
        systemMetricsCount: Int,
        serviceStatusCount: Int,
        oldestRecord: Date?,
        newestRecord: Date?,
        retentionDays: Int
    ) {
        self.connectivityRecordsCount = connectivityRecordsCount
        self.systemMetricsCount = systemMetricsCount
        self.serviceStatusCount = serviceStatusCount
        self.oldestRecord = oldestRecord
        self.newestRecord = newestRecord
        self.retentionDays = retentionDays
    }
    
    public var totalRecords: Int {
        return connectivityRecordsCount + systemMetricsCount + serviceStatusCount
    }
    
    public var dataSpanDays: Int? {
        guard let oldest = oldestRecord,
              let newest = newestRecord else {
            return nil
        }
        
        return Calendar.current.dateComponents([.day], from: oldest, to: newest).day
    }
}
