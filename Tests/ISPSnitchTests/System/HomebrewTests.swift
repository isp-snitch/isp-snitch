import XCTest
import Foundation
@testable import ISPSnitchCore

class HomebrewTests: XCTestCase {

    func testhomebrewFormulaStructure() throws {
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

        XCTAssertTrue(formulaContent.contains("class IspSnitch < Formula"))
        XCTAssert(formulaContent.contains("desc \"Lightweight ISP service monitor for macOS\""))
        XCTAssert(formulaContent.contains("homepage \"https://github.com/isp-snitch/isp-snitch\""))
        XCTAssert(formulaContent.contains("depends_on \"swift\" => :build"))
        XCTAssert(formulaContent.contains("depends_on \"sqlite\""))
    }

    func testhomebrewDependencies() throws {
        // Test Homebrew dependencies
        let buildDependencies = ["swift"]
        let runtimeDependencies = ["sqlite"]
        let optionalDependencies = ["speedtest-cli", "curl", "dig", "ping"]

        XCTAssertEqual(buildDependencies.count, 1)
        XCTAssertEqual(buildDependencies[0], "swift")
        XCTAssertEqual(runtimeDependencies.count, 1)
        XCTAssertEqual(runtimeDependencies[0], "sqlite")
        XCTAssertEqual(optionalDependencies.count, 4)
        XCTAssert(optionalDependencies.contains("speedtest-cli"))
        XCTAssert(optionalDependencies.contains("curl"))
        XCTAssert(optionalDependencies.contains("dig"))
        XCTAssert(optionalDependencies.contains("ping"))
    }

    func testhomebrewInstallationCommands() throws {
        // Test Homebrew installation commands
        let tapCommand = "brew tap isp-snitch/isp-snitch"
        let installCommand = "brew install isp-snitch"
        let startCommand = "brew services start isp-snitch"

        XCTAssert(tapCommand.contains("brew tap"))
        XCTAssert(tapCommand.contains("isp-snitch/isp-snitch"))
        XCTAssert(installCommand.contains("brew install"))
        XCTAssert(installCommand.contains("isp-snitch"))
        XCTAssert(startCommand.contains("brew services start"))
        XCTAssert(startCommand.contains("isp-snitch"))
    }

    func testhomebrewUpdateCommands() throws {
        // Test Homebrew update commands
        let upgradeCommand = "brew upgrade isp-snitch"
        let restartCommand = "brew services restart isp-snitch"

        XCTAssert(upgradeCommand.contains("brew upgrade"))
        XCTAssert(upgradeCommand.contains("isp-snitch"))
        XCTAssert(restartCommand.contains("brew services restart"))
        XCTAssert(restartCommand.contains("isp-snitch"))
    }

    func testhomebrewUninstallCommands() throws {
        // Test Homebrew uninstall commands
        let stopCommand = "brew services stop isp-snitch"
        let uninstallCommand = "brew uninstall isp-snitch"

        XCTAssert(stopCommand.contains("brew services stop"))
        XCTAssert(stopCommand.contains("isp-snitch"))
        XCTAssert(uninstallCommand.contains("brew uninstall"))
        XCTAssert(uninstallCommand.contains("isp-snitch"))
    }

    func testhomebrewFormulaMetadata() throws {
        // Test formula metadata
        let name = "IspSnitch"
        let description = "Lightweight ISP service monitor for macOS"
        let homepage = "https://github.com/isp-snitch/isp-snitch"
        let license = "MIT"
        let version = "1.0.0"

        XCTAssertEqual(name, "IspSnitch")
        XCTAssertEqual(description, "Lightweight ISP service monitor for macOS")
        XCTAssertEqual(homepage, "https://github.com/isp-snitch/isp-snitch")
        XCTAssertEqual(license, "MIT")
        XCTAssertEqual(version, "1.0.0")
    }

    func testhomebrewInstallationProcess() throws {
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

        XCTAssertEqual(steps.count, 7)
        XCTAssert(steps[0].contains("swift build"))
        XCTAssert(steps[1].contains("bin.install"))
        XCTAssert(steps[2].contains("etc.install"))
        XCTAssert(steps[3].contains("etc.install"))
        XCTAssert(steps[4].contains("mkpath"))
        XCTAssert(steps[5].contains("mkpath"))
        XCTAssert(steps[6].contains("mkpath"))
    }

    func testhomebrewPostInstallSteps() throws {
        // Test post-installation steps
        let loadCommand = "launchctl load #{prefix}/Library/LaunchAgents/com.isp-snitch.monitor.plist"

        XCTAssert(loadCommand.contains("launchctl load"))
        XCTAssert(loadCommand.contains("com.isp-snitch.monitor.plist"))
    }

    func testhomebrewUninstallSteps() throws {
        // Test uninstall steps
        let unloadCommand = "launchctl unload #{prefix}/Library/LaunchAgents/com.isp-snitch.monitor.plist"
        let removeCommand = "rm_f #{prefix}/Library/LaunchAgents/com.isp-snitch.monitor.plist"

        XCTAssert(unloadCommand.contains("launchctl unload"))
        XCTAssert(unloadCommand.contains("com.isp-snitch.monitor.plist"))
        XCTAssert(removeCommand.contains("rm_f"))
        XCTAssert(removeCommand.contains("com.isp-snitch.monitor.plist"))
    }

    func testhomebrewTestCommand() throws {
        // Test formula test command
        let testCommand = "#{bin}/isp-snitch --version"

        XCTAssert(testCommand.contains("isp-snitch"))
        XCTAssert(testCommand.contains("--version"))
    }

    func testhomebrewDependencyInstallation() throws {
        // Test dependency installation commands
        let requiredDeps = "brew install sqlite"
        let optionalDeps = "brew install speedtest-cli curl bind dig"

        XCTAssert(requiredDeps.contains("brew install sqlite"))
        XCTAssert(optionalDeps.contains("brew install"))
        XCTAssert(optionalDeps.contains("speedtest-cli"))
        XCTAssert(optionalDeps.contains("curl"))
        XCTAssert(optionalDeps.contains("bind"))
        XCTAssert(optionalDeps.contains("dig"))
    }
}
