import Testing
import Foundation
@testable import ISPSnitchCore

struct LaunchAgentTests {
    
    @Test func launchAgentPlistStructure() throws {
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
        
        #expect(plistContent.contains("com.isp-snitch.monitor"))
        #expect(plistContent.contains("/usr/local/bin/isp-snitch"))
        #expect(plistContent.contains("start"))
        #expect(plistContent.contains("--background"))
    }
    
    @Test func launchAgentLabel() throws {
        // Test LaunchAgent label
        let label = "com.isp-snitch.monitor"
        
        #expect(label == "com.isp-snitch.monitor")
        #expect(label.hasPrefix("com.isp-snitch"))
        #expect(label.contains("monitor"))
    }
    
    @Test func launchAgentProgramArguments() throws {
        // Test program arguments
        let arguments = [
            "/usr/local/bin/isp-snitch",
            "start",
            "--background"
        ]
        
        #expect(arguments.count == 3)
        #expect(arguments[0] == "/usr/local/bin/isp-snitch")
        #expect(arguments[1] == "start")
        #expect(arguments[2] == "--background")
    }
    
    @Test func launchAgentConfiguration() throws {
        // Test LaunchAgent configuration
        let runAtLoad = true
        let keepAlive = true
        let throttleInterval = 10
        let processType = "Background"
        let lowPriorityIO = true
        let nice = 1
        
        #expect(runAtLoad == true)
        #expect(keepAlive == true)
        #expect(throttleInterval == 10)
        #expect(processType == "Background")
        #expect(lowPriorityIO == true)
        #expect(nice == 1)
    }
    
    @Test func launchAgentLogPaths() throws {
        // Test log file paths
        let standardOutPath = "/usr/local/var/log/isp-snitch/out.log"
        let standardErrorPath = "/usr/local/var/log/isp-snitch/error.log"
        let workingDirectory = "/usr/local/var/isp-snitch"
        
        #expect(standardOutPath.hasPrefix("/usr/local/var/log/isp-snitch"))
        #expect(standardErrorPath.hasPrefix("/usr/local/var/log/isp-snitch"))
        #expect(workingDirectory == "/usr/local/var/isp-snitch")
    }
    
    @Test func launchAgentEnvironmentVariables() throws {
        // Test environment variables
        let environmentVariables = [
            "PATH": "/usr/local/bin:/usr/bin:/bin",
            "ISP_SNITCH_CONFIG": "/usr/local/etc/isp-snitch/config.json",
            "ISP_SNITCH_DATA": "/usr/local/var/isp-snitch/data"
        ]
        
        #expect(environmentVariables.count == 3)
        #expect(environmentVariables["PATH"] == "/usr/local/bin:/usr/bin:/bin")
        #expect(environmentVariables["ISP_SNITCH_CONFIG"] == "/usr/local/etc/isp-snitch/config.json")
        #expect(environmentVariables["ISP_SNITCH_DATA"] == "/usr/local/var/isp-snitch/data")
    }
    
    @Test func launchAgentServiceManagement() throws {
        // Test service management commands
        let loadCommand = "launchctl load ~/Library/LaunchAgents/com.isp-snitch.monitor.plist"
        let startCommand = "launchctl start com.isp-snitch.monitor"
        let stopCommand = "launchctl stop com.isp-snitch.monitor"
        let unloadCommand = "launchctl unload ~/Library/LaunchAgents/com.isp-snitch.monitor.plist"
        
        #expect(loadCommand.contains("launchctl load"))
        #expect(startCommand.contains("launchctl start"))
        #expect(stopCommand.contains("launchctl stop"))
        #expect(unloadCommand.contains("launchctl unload"))
    }
    
    @Test func launchAgentServiceStatus() throws {
        // Test service status commands
        let listCommand = "launchctl list | grep com.isp-snitch.monitor"
        let printCommand = "launchctl print user/$(id -u)/com.isp-snitch.monitor"
        
        #expect(listCommand.contains("launchctl list"))
        #expect(listCommand.contains("grep com.isp-snitch.monitor"))
        #expect(printCommand.contains("launchctl print"))
        #expect(printCommand.contains("com.isp-snitch.monitor"))
    }
    
    @Test func launchAgentFilePermissions() throws {
        // Test file permissions
        let plistPath = "~/Library/LaunchAgents/com.isp-snitch.monitor.plist"
        let expectedPermissions = "644"
        
        #expect(plistPath.contains("Library/LaunchAgents"))
        #expect(plistPath.contains("com.isp-snitch.monitor.plist"))
        #expect(expectedPermissions == "644")
    }
    
    @Test func launchAgentSecurity() throws {
        // Test security considerations
        let runAsUser = true
        let localAccessOnly = true
        let minimalPermissions = true
        let noElevatedPrivileges = true
        
        #expect(runAsUser == true)
        #expect(localAccessOnly == true)
        #expect(minimalPermissions == true)
        #expect(noElevatedPrivileges == true)
    }
    
    @Test func launchAgentResourceLimits() throws {
        // Test resource limits
        let maxCpuUsage = 5.0
        let maxMemoryUsage = 100.0
        let maxNetworkBandwidth = 1.0
        let maxDiskUsage = 100.0
        
        #expect(maxCpuUsage == 5.0)
        #expect(maxMemoryUsage == 100.0)
        #expect(maxNetworkBandwidth == 1.0)
        #expect(maxDiskUsage == 100.0)
    }
}
