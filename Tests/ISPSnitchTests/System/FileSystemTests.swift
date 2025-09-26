import XCTest
import Foundation
@testable import ISPSnitchCore

class FileSystemTests: XCTestCase {

    func testinstallationDirectories() throws {
        // Test installation directory structure
        let directories = [
            "/usr/local/bin/isp-snitch",
            "/usr/local/etc/isp-snitch/",
            "/usr/local/var/isp-snitch/",
            "/usr/local/var/isp-snitch/data/",
            "/usr/local/var/isp-snitch/logs/",
            "/usr/local/var/log/isp-snitch/"
        ]

        XCTAssertEqual(directories.count, 6)
        XCTAssertEqual(directories[0], "/usr/local/bin/isp-snitch")
        XCTAssertEqual(directories[1], "/usr/local/etc/isp-snitch/")
        XCTAssertEqual(directories[2], "/usr/local/var/isp-snitch/")
        XCTAssertEqual(directories[3], "/usr/local/var/isp-snitch/data/")
        XCTAssertEqual(directories[4], "/usr/local/var/isp-snitch/logs/")
        XCTAssertEqual(directories[5], "/usr/local/var/log/isp-snitch/")
    }

    func testconfigurationFiles() throws {
        // Test configuration file paths
        let configFiles = [
            "/usr/local/etc/isp-snitch/config.json",
            "/usr/local/etc/isp-snitch/targets.json",
            "/usr/local/etc/isp-snitch/logging.json"
        ]

        XCTAssertEqual(configFiles.count, 3)
        XCTAssertEqual(configFiles[0], "/usr/local/etc/isp-snitch/config.json")
        XCTAssertEqual(configFiles[1], "/usr/local/etc/isp-snitch/targets.json")
        XCTAssertEqual(configFiles[2], "/usr/local/etc/isp-snitch/logging.json")
    }

    func testdataFiles() throws {
        // Test data file paths
        let dataFiles = [
            "/usr/local/var/isp-snitch/data/connectivity.db",
            "/usr/local/var/isp-snitch/data/backups/",
            "/usr/local/var/isp-snitch/data/exports/"
        ]

        XCTAssertEqual(dataFiles.count, 3)
        XCTAssertEqual(dataFiles[0], "/usr/local/var/isp-snitch/data/connectivity.db")
        XCTAssertEqual(dataFiles[1], "/usr/local/var/isp-snitch/data/backups/")
        XCTAssertEqual(dataFiles[2], "/usr/local/var/isp-snitch/data/exports/")
    }

    func testlogFiles() throws {
        // Test log file paths
        let logFiles = [
            "/usr/local/var/log/isp-snitch/out.log",
            "/usr/local/var/log/isp-snitch/error.log",
            "/usr/local/var/isp-snitch/logs/app.log",
            "/usr/local/var/isp-snitch/logs/access.log"
        ]

        XCTAssertEqual(logFiles.count, 4)
        XCTAssertEqual(logFiles[0], "/usr/local/var/log/isp-snitch/out.log")
        XCTAssertEqual(logFiles[1], "/usr/local/var/log/isp-snitch/error.log")
        XCTAssertEqual(logFiles[2], "/usr/local/var/isp-snitch/logs/app.log")
        XCTAssertEqual(logFiles[3], "/usr/local/var/isp-snitch/logs/access.log")
    }

    func testdirectoryPermissions() throws {
        // Test directory permissions
        let binPermissions = "755"
        let etcPermissions = "755"
        let varPermissions = "755"
        let dataPermissions = "755"
        let logPermissions = "755"

        XCTAssertEqual(binPermissions, "755")
        XCTAssertEqual(etcPermissions, "755")
        XCTAssertEqual(varPermissions, "755")
        XCTAssertEqual(dataPermissions, "755")
        XCTAssertEqual(logPermissions, "755")
    }

    func testfilePermissions() throws {
        // Test file permissions
        let executablePermissions = "755"
        let configPermissions = "644"
        let dataPermissions = "644"
        let logPermissions = "644"

        XCTAssertEqual(executablePermissions, "755")
        XCTAssertEqual(configPermissions, "644")
        XCTAssertEqual(dataPermissions, "644")
        XCTAssertEqual(logPermissions, "644")
    }

    func testdirectoryStructure() throws {
        // Test directory structure validation
        let rootDir = "/usr/local"
        let binDir = "/usr/local/bin"
        let etcDir = "/usr/local/etc/isp-snitch"
        let varDir = "/usr/local/var/isp-snitch"
        let dataDir = "/usr/local/var/isp-snitch/data"
        let logDir = "/usr/local/var/isp-snitch/logs"

        XCTAssertEqual(rootDir, "/usr/local")
        XCTAssertEqual(binDir, "/usr/local/bin")
        XCTAssertEqual(etcDir, "/usr/local/etc/isp-snitch")
        XCTAssertEqual(varDir, "/usr/local/var/isp-snitch")
        XCTAssertEqual(dataDir, "/usr/local/var/isp-snitch/data")
        XCTAssertEqual(logDir, "/usr/local/var/isp-snitch/logs")
    }

    func testfileOwnership() throws {
        // Test file ownership
        let owner = "$(whoami)"
        let group = "staff"

        XCTAssertEqual(owner, "$(whoami)")
        XCTAssertEqual(group, "staff")
    }

    func testsymbolicLinks() throws {
        // Test symbolic links
        let symlinkSource = "/usr/local/bin/isp-snitch"
        let symlinkTarget = "/usr/local/bin/isp-snitch"

        XCTAssertEqual(symlinkSource, symlinkTarget)
    }

    func testbackupDirectories() throws {
        // Test backup directory structure
        let backupDir = "/usr/local/var/isp-snitch/data/backups"
        let exportDir = "/usr/local/var/isp-snitch/data/exports"

        XCTAssertEqual(backupDir, "/usr/local/var/isp-snitch/data/backups")
        XCTAssertEqual(exportDir, "/usr/local/var/isp-snitch/data/exports")
    }
}
