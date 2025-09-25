import Testing
import Foundation
@testable import ISPSnitchCore

struct ConnectivityRecordTests {
    
    @Test func connectivityRecordInitialization() throws {
        let systemContext = SystemContext(
            cpuUsage: 0.5,
            memoryUsage: 42.0,
            networkInterfaceStatus: "active",
            batteryLevel: 85.0
        )
        
        let record = ConnectivityRecord(
            testType: .ping,
            target: "8.8.8.8",
            latency: 0.024,
            success: true,
            networkInterface: "en0",
            systemContext: systemContext
        )
        
        #expect(record.testType == .ping)
        #expect(record.target == "8.8.8.8")
        #expect(record.latency == 0.024)
        #expect(record.success == true)
        #expect(record.networkInterface == "en0")
        #expect(record.systemContext.cpuUsage == 0.5)
        #expect(record.systemContext.memoryUsage == 42.0)
        #expect(record.systemContext.networkInterfaceStatus == "active")
        #expect(record.systemContext.batteryLevel == 85.0)
    }
    
    @Test func connectivityRecordWithPingData() throws {
        let pingData = PingData(
            latency: 0.024,
            packetLoss: 0.0,
            ttl: 117,
            statistics: PingStatistics(
                minLatency: 0.024,
                avgLatency: 0.024,
                maxLatency: 0.024,
                stdDev: 0.0,
                packetsTransmitted: 1,
                packetsReceived: 1
            )
        )
        
        let systemContext = SystemContext(
            cpuUsage: 0.5,
            memoryUsage: 42.0,
            networkInterfaceStatus: "active"
        )
        
        let record = ConnectivityRecord(
            testType: .ping,
            target: "8.8.8.8",
            latency: 0.024,
            success: true,
            networkInterface: "en0",
            systemContext: systemContext,
            pingData: pingData
        )
        
        #expect(record.pingData != nil)
        #expect(record.pingData?.latency == 0.024)
        #expect(record.pingData?.packetLoss == 0.0)
        #expect(record.pingData?.ttl == 117)
        #expect(record.pingData?.statistics != nil)
    }
    
    @Test func connectivityRecordWithHttpData() throws {
        let httpData = HttpData(
            httpCode: 200,
            totalTime: 0.113,
            connectTime: 0.045,
            dnsTime: 0.012,
            downloadSize: 220,
            downloadSpeed: 15.5
        )
        
        let systemContext = SystemContext(
            cpuUsage: 0.5,
            memoryUsage: 42.0,
            networkInterfaceStatus: "active"
        )
        
        let record = ConnectivityRecord(
            testType: .http,
            target: "https://google.com",
            latency: 0.113,
            success: true,
            networkInterface: "en0",
            systemContext: systemContext,
            httpData: httpData
        )
        
        #expect(record.httpData != nil)
        #expect(record.httpData?.httpCode == 200)
        #expect(record.httpData?.totalTime == 0.113)
        #expect(record.httpData?.connectTime == 0.045)
        #expect(record.httpData?.dnsTime == 0.012)
        #expect(record.httpData?.downloadSize == 220)
        #expect(record.httpData?.downloadSpeed == 15.5)
    }
    
    @Test func connectivityRecordWithDnsData() throws {
        let dnsData = DnsData(
            queryTime: 0.028,
            status: "NOERROR",
            answerCount: 1,
            server: "8.8.8.8",
            answers: ["142.250.191.14"]
        )
        
        let systemContext = SystemContext(
            cpuUsage: 0.5,
            memoryUsage: 42.0,
            networkInterfaceStatus: "active"
        )
        
        let record = ConnectivityRecord(
            testType: .dns,
            target: "google.com",
            latency: 0.028,
            success: true,
            networkInterface: "en0",
            systemContext: systemContext,
            dnsData: dnsData
        )
        
        #expect(record.dnsData != nil)
        #expect(record.dnsData?.queryTime == 0.028)
        #expect(record.dnsData?.status == "NOERROR")
        #expect(record.dnsData?.answerCount == 1)
        #expect(record.dnsData?.server == "8.8.8.8")
        #expect(record.dnsData?.answers == ["142.250.191.14"])
    }
    
    @Test func connectivityRecordWithSpeedtestData() throws {
        let speedtestData = SpeedtestData(
            ping: 0.012,
            downloadSpeed: 95.5,
            uploadSpeed: 12.3
        )
        
        let systemContext = SystemContext(
            cpuUsage: 0.5,
            memoryUsage: 42.0,
            networkInterfaceStatus: "active"
        )
        
        let record = ConnectivityRecord(
            testType: .bandwidth,
            target: "speedtest.net",
            latency: 0.012,
            success: true,
            networkInterface: "en0",
            systemContext: systemContext,
            speedtestData: speedtestData
        )
        
        #expect(record.speedtestData != nil)
        #expect(record.speedtestData?.ping == 0.012)
        #expect(record.speedtestData?.downloadSpeed == 95.5)
        #expect(record.speedtestData?.uploadSpeed == 12.3)
    }
    
    @Test func connectivityRecordFailure() throws {
        let systemContext = SystemContext(
            cpuUsage: 0.5,
            memoryUsage: 42.0,
            networkInterfaceStatus: "active"
        )
        
        let record = ConnectivityRecord(
            testType: .ping,
            target: "192.168.1.999",
            success: false,
            errorMessage: "Invalid IP address",
            errorCode: 68,
            networkInterface: "en0",
            systemContext: systemContext
        )
        
        #expect(record.success == false)
        #expect(record.errorMessage == "Invalid IP address")
        #expect(record.errorCode == 68)
        #expect(record.latency == nil)
    }
    
    @Test func connectivityRecordCodable() throws {
        let systemContext = SystemContext(
            cpuUsage: 0.5,
            memoryUsage: 42.0,
            networkInterfaceStatus: "active",
            batteryLevel: 85.0
        )
        
        let originalRecord = ConnectivityRecord(
            testType: .ping,
            target: "8.8.8.8",
            latency: 0.024,
            success: true,
            networkInterface: "en0",
            systemContext: systemContext
        )
        
        // Test encoding
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(originalRecord)
        
        // Test decoding
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedRecord = try decoder.decode(ConnectivityRecord.self, from: data)
        
        #expect(decodedRecord.testType == originalRecord.testType)
        #expect(decodedRecord.target == originalRecord.target)
        #expect(decodedRecord.latency == originalRecord.latency)
        #expect(decodedRecord.success == originalRecord.success)
        #expect(decodedRecord.networkInterface == originalRecord.networkInterface)
        #expect(decodedRecord.systemContext.cpuUsage == originalRecord.systemContext.cpuUsage)
        #expect(decodedRecord.systemContext.memoryUsage == originalRecord.systemContext.memoryUsage)
        #expect(decodedRecord.systemContext.networkInterfaceStatus == originalRecord.systemContext.networkInterfaceStatus)
        #expect(decodedRecord.systemContext.batteryLevel == originalRecord.systemContext.batteryLevel)
    }
    
    @Test func connectivityRecordSendable() throws {
        // This test verifies that ConnectivityRecord conforms to Sendable
        let systemContext = SystemContext(
            cpuUsage: 0.5,
            memoryUsage: 42.0,
            networkInterfaceStatus: "active"
        )
        
        let record = ConnectivityRecord(
            testType: .ping,
            target: "8.8.8.8",
            latency: 0.024,
            success: true,
            networkInterface: "en0",
            systemContext: systemContext
        )
        
        // If this compiles, the type conforms to Sendable
        let _: any Sendable = record
        #expect(true) // This test passes if compilation succeeds
    }
}
