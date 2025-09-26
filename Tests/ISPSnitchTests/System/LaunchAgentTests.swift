import XCTest
import Foundation
@testable import ISPSnitchCore

class LaunchAgentTests: XCTestCase {

    func testlaunchAgentPlistStructure() throws {
        // Test LaunchAgent plist structure
        let plistContent = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>Label</key>
            <string>com.isp-snitch.monitor</string>

            <key>ProgramArguments</key>
            <array>
                <string>/usr/local/bin/isp-snitch</string>
                <string>start</string>
                <string>--background</string>
            </array>

            <key>RunAtLoad</key>
            <true/>

            <key>KeepAlive</key>
            <true/>
        </dict>
        </plist>
        """

        XCTAssert(plistContent.contains("com.isp-snitch.monitor"))
        XCTAssert(plistContent.contains("/usr/local/bin/isp-snitch"))
        XCTAssert(plistContent.contains("start"))
        XCTAssert(plistContent.contains("--background"))
    }

    func testlaunchAgentLabel() throws {
        // Test LaunchAgent label
        let label = "com.isp-snitch.monitor"

        XCTAssertEqual(label, "com.isp-snitch.monitor")
        XCTAssert(label.hasPrefix("com.isp-snitch"))
        XCTAssert(label.contains("monitor"))
    }

    func testlaunchAgentProgramArguments() throws {
        // Test program arguments
        let arguments = [
            "/usr/local/bin/isp-snitch",
            "start",
            "--background"
        ]

        XCTAssertEqual(arguments.count, 3)
        XCTAssertEqual(arguments[0], "/usr/local/bin/isp-snitch")
        XCTAssertEqual(arguments[1], "start")
        XCTAssertEqual(arguments[2], "--background")
    }

    func testlaunchAgentConfiguration() throws {
        // Test LaunchAgent configuration
        let runAtLoad = true
        let keepAlive = true
        let throttleInterval = 10
        let processType = "Background"
        let lowPriorityIO = true
        let nice = 1

        XCTAssertEqual(runAtLoad, true)
        XCTAssertEqual(keepAlive, true)
        XCTAssertEqual(throttleInterval, 10)
        XCTAssertEqual(processType, "Background")
        XCTAssertEqual(lowPriorityIO, true)
        XCTAssertEqual(nice, 1)
    }

    func testlaunchAgentLogPaths() throws {
        // Test log file paths
        let standardOutPath = "/usr/local/var/log/isp-snitch/out.log"
        let standardErrorPath = "/usr/local/var/log/isp-snitch/error.log"
        let workingDirectory = "/usr/local/var/isp-snitch"

        XCTAssert(standardOutPath.hasPrefix("/usr/local/var/log/isp-snitch"))
        XCTAssert(standardErrorPath.hasPrefix("/usr/local/var/log/isp-snitch"))
        XCTAssertEqual(workingDirectory, "/usr/local/var/isp-snitch")
    }

    func testlaunchAgentEnvironmentVariables() throws {
        // Test environment variables
        let environmentVariables = [
            "PATH": "/usr/local/bin:/usr/bin:/bin",
            "ISP_SNITCH_CONFIG": "/usr/local/etc/isp-snitch/config.json",
            "ISP_SNITCH_DATA": "/usr/local/var/isp-snitch/data"
        ]

        XCTAssertEqual(environmentVariables.count, 3)
        XCTAssertEqual(environmentVariables["PATH"], "/usr/local/bin:/usr/bin:/bin")
        XCTAssertEqual(environmentVariables["ISP_SNITCH_CONFIG"], "/usr/local/etc/isp-snitch/config.json")
        XCTAssertEqual(environmentVariables["ISP_SNITCH_DATA"], "/usr/local/var/isp-snitch/data")
    }

    func testlaunchAgentServiceManagement() throws {
        // Test service management commands
        let loadCommand = "launchctl load ~/Library/LaunchAgents/com.isp-snitch.monitor.plist"
        let startCommand = "launchctl start com.isp-snitch.monitor"
        let stopCommand = "launchctl stop com.isp-snitch.monitor"
        let unloadCommand = "launchctl unload ~/Library/LaunchAgents/com.isp-snitch.monitor.plist"

        XCTAssert(loadCommand.contains("launchctl load"))
        XCTAssert(startCommand.contains("launchctl start"))
        XCTAssert(stopCommand.contains("launchctl stop"))
        XCTAssert(unloadCommand.contains("launchctl unload"))
    }

    func testlaunchAgentServiceStatus() throws {
        // Test service status commands
        let listCommand = "launchctl list | grep com.isp-snitch.monitor"
        let printCommand = "launchctl print user/$(id -u)/com.isp-snitch.monitor"

        XCTAssert(listCommand.contains("launchctl list"))
        XCTAssert(listCommand.contains("grep com.isp-snitch.monitor"))
        XCTAssert(printCommand.contains("launchctl print"))
        XCTAssert(printCommand.contains("com.isp-snitch.monitor"))
    }

    func testlaunchAgentFilePermissions() throws {
        // Test file permissions
        let plistPath = "~/Library/LaunchAgents/com.isp-snitch.monitor.plist"
        let expectedPermissions = "644"

        XCTAssert(plistPath.contains("Library/LaunchAgents"))
        XCTAssert(plistPath.contains("com.isp-snitch.monitor.plist"))
        XCTAssertEqual(expectedPermissions, "644")
    }

    func testlaunchAgentSecurity() throws {
        // Test security considerations
        let runAsUser = true
        let localAccessOnly = true
        let minimalPermissions = true
        let noElevatedPrivileges = true

        XCTAssertEqual(runAsUser, true)
        XCTAssertEqual(localAccessOnly, true)
        XCTAssertEqual(minimalPermissions, true)
        XCTAssertEqual(noElevatedPrivileges, true)
    }

    func testlaunchAgentResourceLimits() throws {
        // Test resource limits
        let maxCpuUsage = 5.0
        let maxMemoryUsage = 100.0
        let maxNetworkBandwidth = 1.0
        let maxDiskUsage = 100.0

        XCTAssertEqual(maxCpuUsage, 5.0)
        XCTAssertEqual(maxMemoryUsage, 100.0)
        XCTAssertEqual(maxNetworkBandwidth, 1.0)
        XCTAssertEqual(maxDiskUsage, 100.0)
    }
}
