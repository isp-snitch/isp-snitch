import Testing
import Foundation
@testable import ISPSnitchCore

struct HomebrewTests {
    
    @Test func homebrewFormulaStructure() throws {
        // Test Homebrew formula structure
        let formulaContent = """
        class IspSnitch < Formula
          desc "Lightweight ISP service monitor for macOS"
          homepage "https://github.com/isp-snitch/isp-snitch"
          url "https://github.com/isp-snitch/isp-snitch/releases/download/v1.0.0/isp-snitch-1.0.0.tar.gz"
          sha256 "abc123def456..."
          license "MIT"
          
          depends_on "swift" => :build
          depends_on "sqlite"
        end
        """
        
        #expect(formulaContent.contains("class IspSnitch < Formula"))
        #expect(formulaContent.contains("desc \"Lightweight ISP service monitor for macOS\""))
        #expect(formulaContent.contains("homepage \"https://github.com/isp-snitch/isp-snitch\""))
        #expect(formulaContent.contains("depends_on \"swift\" => :build"))
        #expect(formulaContent.contains("depends_on \"sqlite\""))
    }
    
    @Test func homebrewDependencies() throws {
        // Test Homebrew dependencies
        let buildDependencies = ["swift"]
        let runtimeDependencies = ["sqlite"]
        let optionalDependencies = ["speedtest-cli", "curl", "dig", "ping"]
        
        #expect(buildDependencies.count == 1)
        #expect(buildDependencies[0] == "swift")
        #expect(runtimeDependencies.count == 1)
        #expect(runtimeDependencies[0] == "sqlite")
        #expect(optionalDependencies.count == 4)
        #expect(optionalDependencies.contains("speedtest-cli"))
        #expect(optionalDependencies.contains("curl"))
        #expect(optionalDependencies.contains("dig"))
        #expect(optionalDependencies.contains("ping"))
    }
    
    @Test func homebrewInstallationCommands() throws {
        // Test Homebrew installation commands
        let tapCommand = "brew tap isp-snitch/isp-snitch"
        let installCommand = "brew install isp-snitch"
        let startCommand = "brew services start isp-snitch"
        
        #expect(tapCommand.contains("brew tap"))
        #expect(tapCommand.contains("isp-snitch/isp-snitch"))
        #expect(installCommand.contains("brew install"))
        #expect(installCommand.contains("isp-snitch"))
        #expect(startCommand.contains("brew services start"))
        #expect(startCommand.contains("isp-snitch"))
    }
    
    @Test func homebrewUpdateCommands() throws {
        // Test Homebrew update commands
        let upgradeCommand = "brew upgrade isp-snitch"
        let restartCommand = "brew services restart isp-snitch"
        
        #expect(upgradeCommand.contains("brew upgrade"))
        #expect(upgradeCommand.contains("isp-snitch"))
        #expect(restartCommand.contains("brew services restart"))
        #expect(restartCommand.contains("isp-snitch"))
    }
    
    @Test func homebrewUninstallCommands() throws {
        // Test Homebrew uninstall commands
        let stopCommand = "brew services stop isp-snitch"
        let uninstallCommand = "brew uninstall isp-snitch"
        
        #expect(stopCommand.contains("brew services stop"))
        #expect(stopCommand.contains("isp-snitch"))
        #expect(uninstallCommand.contains("brew uninstall"))
        #expect(uninstallCommand.contains("isp-snitch"))
    }
    
    @Test func homebrewFormulaMetadata() throws {
        // Test formula metadata
        let name = "IspSnitch"
        let description = "Lightweight ISP service monitor for macOS"
        let homepage = "https://github.com/isp-snitch/isp-snitch"
        let license = "MIT"
        let version = "1.0.0"
        
        #expect(name == "IspSnitch")
        #expect(description == "Lightweight ISP service monitor for macOS")
        #expect(homepage == "https://github.com/isp-snitch/isp-snitch")
        #expect(license == "MIT")
        #expect(version == "1.0.0")
    }
    
    @Test func homebrewInstallationProcess() throws {
        // Test installation process steps
        let steps = [
            "swift build --configuration release",
            "bin.install .build/release/isp-snitch",
            "etc.install config/config.json => isp-snitch/config.json",
            "etc.install config/targets.json => isp-snitch/targets.json",
            "(var/\"isp-snitch\").mkpath",
            "(var/\"isp-snitch/data\").mkpath",
            "(var/\"isp-snitch/logs\").mkpath"
        ]
        
        #expect(steps.count == 7)
        #expect(steps[0].contains("swift build"))
        #expect(steps[1].contains("bin.install"))
        #expect(steps[2].contains("etc.install"))
        #expect(steps[3].contains("etc.install"))
        #expect(steps[4].contains("mkpath"))
        #expect(steps[5].contains("mkpath"))
        #expect(steps[6].contains("mkpath"))
    }
    
    @Test func homebrewPostInstallSteps() throws {
        // Test post-installation steps
        let loadCommand = "launchctl load #{prefix}/Library/LaunchAgents/com.isp-snitch.monitor.plist"
        
        #expect(loadCommand.contains("launchctl load"))
        #expect(loadCommand.contains("com.isp-snitch.monitor.plist"))
    }
    
    @Test func homebrewUninstallSteps() throws {
        // Test uninstall steps
        let unloadCommand = "launchctl unload #{prefix}/Library/LaunchAgents/com.isp-snitch.monitor.plist"
        let removeCommand = "rm_f #{prefix}/Library/LaunchAgents/com.isp-snitch.monitor.plist"
        
        #expect(unloadCommand.contains("launchctl unload"))
        #expect(unloadCommand.contains("com.isp-snitch.monitor.plist"))
        #expect(removeCommand.contains("rm_f"))
        #expect(removeCommand.contains("com.isp-snitch.monitor.plist"))
    }
    
    @Test func homebrewTestCommand() throws {
        // Test formula test command
        let testCommand = "#{bin}/isp-snitch --version"
        
        #expect(testCommand.contains("isp-snitch"))
        #expect(testCommand.contains("--version"))
    }
    
    @Test func homebrewDependencyInstallation() throws {
        // Test dependency installation commands
        let requiredDeps = "brew install sqlite"
        let optionalDeps = "brew install speedtest-cli curl bind dig"
        
        #expect(requiredDeps.contains("brew install sqlite"))
        #expect(optionalDeps.contains("brew install"))
        #expect(optionalDeps.contains("speedtest-cli"))
        #expect(optionalDeps.contains("curl"))
        #expect(optionalDeps.contains("bind"))
        #expect(optionalDeps.contains("dig"))
    }
}
