import XCTest
import Foundation
@testable import ISPSnitchCore

class ConnectivityRecordSwiftTestingTests: XCTestCase {

    func testconnectivityRecordInitialization() throws {
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

        XCTAssertEqual(record.testType, .ping)
        XCTAssertEqual(record.target, "8.8.8.8")
        XCTAssertEqual(record.latency, 0.024)
        XCTAssertEqual(record.success, true)
        XCTAssertEqual(record.networkInterface, "en0")
        XCTAssertEqual(record.systemContext.cpuUsage, 0.5)
        XCTAssertEqual(record.systemContext.memoryUsage, 42.0)
        XCTAssertEqual(record.systemContext.networkInterfaceStatus, "active")
        XCTAssertEqual(record.systemContext.batteryLevel, 85.0)
    }

    func testconnectivityRecordWithPingData() throws {
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

        XCTAssert(record.pingData != nil)
        XCTAssertEqual(record.pingData?.latency, 0.024)
        XCTAssertEqual(record.pingData?.packetLoss, 0.0)
        XCTAssertEqual(record.pingData?.ttl, 117)
        XCTAssert(record.pingData?.statistics != nil)
    }

    func testconnectivityRecordWithHttpData() throws {
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

        XCTAssert(record.httpData != nil)
        XCTAssertEqual(record.httpData?.httpCode, 200)
        XCTAssertEqual(record.httpData?.totalTime, 0.113)
        XCTAssertEqual(record.httpData?.connectTime, 0.045)
        XCTAssertEqual(record.httpData?.dnsTime, 0.012)
        XCTAssertEqual(record.httpData?.downloadSize, 220)
        XCTAssertEqual(record.httpData?.downloadSpeed, 15.5)
    }

    func testconnectivityRecordWithDnsData() throws {
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

        XCTAssert(record.dnsData != nil)
        XCTAssertEqual(record.dnsData?.queryTime, 0.028)
        XCTAssertEqual(record.dnsData?.status, "NOERROR")
        XCTAssertEqual(record.dnsData?.answerCount, 1)
        XCTAssertEqual(record.dnsData?.server, "8.8.8.8")
        XCTAssertEqual(record.dnsData?.answers, ["142.250.191.14"])
    }

    func testconnectivityRecordWithSpeedtestData() throws {
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

        XCTAssert(record.speedtestData != nil)
        XCTAssertEqual(record.speedtestData?.ping, 0.012)
        XCTAssertEqual(record.speedtestData?.downloadSpeed, 95.5)
        XCTAssertEqual(record.speedtestData?.uploadSpeed, 12.3)
    }

    func testconnectivityRecordFailure() throws {
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

        XCTAssertEqual(record.success, false)
        XCTAssertEqual(record.errorMessage, "Invalid IP address")
        XCTAssertEqual(record.errorCode, 68)
        XCTAssertEqual(record.latency, nil)
    }

    func testconnectivityRecordCodable() throws {
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

        XCTAssertEqual(decodedRecord.testType, originalRecord.testType)
        XCTAssertEqual(decodedRecord.target, originalRecord.target)
        XCTAssertEqual(decodedRecord.latency, originalRecord.latency)
        XCTAssertEqual(decodedRecord.success, originalRecord.success)
        XCTAssertEqual(decodedRecord.networkInterface, originalRecord.networkInterface)
        XCTAssertEqual(decodedRecord.systemContext.cpuUsage, originalRecord.systemContext.cpuUsage)
        XCTAssertEqual(decodedRecord.systemContext.memoryUsage, originalRecord.systemContext.memoryUsage)
        XCTAssertEqual(decodedRecord.systemContext.networkInterfaceStatus, originalRecord.systemContext.networkInterfaceStatus)
        XCTAssertEqual(decodedRecord.systemContext.batteryLevel, originalRecord.systemContext.batteryLevel)
    }

    func testconnectivityRecordSendable() throws {
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
        XCTAssert(true) // This test passes if compilation succeeds
    }
}
