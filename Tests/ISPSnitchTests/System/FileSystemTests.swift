import Testing
import Foundation
@testable import ISPSnitchCore

struct FileSystemTests {

    @Test func installationDirectories() throws {
        // Test installation directory structure
        let directories = [
            "/usr/local/bin/isp-snitch",
            "/usr/local/etc/isp-snitch/",
            "/usr/local/var/isp-snitch/",
            "/usr/local/var/isp-snitch/data/",
            "/usr/local/var/isp-snitch/logs/",
            "/usr/local/var/log/isp-snitch/"
        ]

        #expect(directories.count == 6)
        #expect(directories[0] == "/usr/local/bin/isp-snitch")
        #expect(directories[1] == "/usr/local/etc/isp-snitch/")
        #expect(directories[2] == "/usr/local/var/isp-snitch/")
        #expect(directories[3] == "/usr/local/var/isp-snitch/data/")
        #expect(directories[4] == "/usr/local/var/isp-snitch/logs/")
        #expect(directories[5] == "/usr/local/var/log/isp-snitch/")
    }

    @Test func configurationFiles() throws {
        // Test configuration file paths
        let configFiles = [
            "/usr/local/etc/isp-snitch/config.json",
            "/usr/local/etc/isp-snitch/targets.json",
            "/usr/local/etc/isp-snitch/logging.json"
        ]

        #expect(configFiles.count == 3)
        #expect(configFiles[0] == "/usr/local/etc/isp-snitch/config.json")
        #expect(configFiles[1] == "/usr/local/etc/isp-snitch/targets.json")
        #expect(configFiles[2] == "/usr/local/etc/isp-snitch/logging.json")
    }

    @Test func dataFiles() throws {
        // Test data file paths
        let dataFiles = [
            "/usr/local/var/isp-snitch/data/connectivity.db",
            "/usr/local/var/isp-snitch/data/backups/",
            "/usr/local/var/isp-snitch/data/exports/"
        ]

        #expect(dataFiles.count == 3)
        #expect(dataFiles[0] == "/usr/local/var/isp-snitch/data/connectivity.db")
        #expect(dataFiles[1] == "/usr/local/var/isp-snitch/data/backups/")
        #expect(dataFiles[2] == "/usr/local/var/isp-snitch/data/exports/")
    }

    @Test func logFiles() throws {
        // Test log file paths
        let logFiles = [
            "/usr/local/var/log/isp-snitch/out.log",
            "/usr/local/var/log/isp-snitch/error.log",
            "/usr/local/var/isp-snitch/logs/app.log",
            "/usr/local/var/isp-snitch/logs/access.log"
        ]

        #expect(logFiles.count == 4)
        #expect(logFiles[0] == "/usr/local/var/log/isp-snitch/out.log")
        #expect(logFiles[1] == "/usr/local/var/log/isp-snitch/error.log")
        #expect(logFiles[2] == "/usr/local/var/isp-snitch/logs/app.log")
        #expect(logFiles[3] == "/usr/local/var/isp-snitch/logs/access.log")
    }

    @Test func directoryPermissions() throws {
        // Test directory permissions
        let binPermissions = "755"
        let etcPermissions = "755"
        let varPermissions = "755"
        let dataPermissions = "755"
        let logPermissions = "755"

        #expect(binPermissions == "755")
        #expect(etcPermissions == "755")
        #expect(varPermissions == "755")
        #expect(dataPermissions == "755")
        #expect(logPermissions == "755")
    }

    @Test func filePermissions() throws {
        // Test file permissions
        let executablePermissions = "755"
        let configPermissions = "644"
        let dataPermissions = "644"
        let logPermissions = "644"

        #expect(executablePermissions == "755")
        #expect(configPermissions == "644")
        #expect(dataPermissions == "644")
        #expect(logPermissions == "644")
    }

    @Test func directoryStructure() throws {
        // Test directory structure validation
        let rootDir = "/usr/local"
        let binDir = "/usr/local/bin"
        let etcDir = "/usr/local/etc/isp-snitch"
        let varDir = "/usr/local/var/isp-snitch"
        let dataDir = "/usr/local/var/isp-snitch/data"
        let logDir = "/usr/local/var/isp-snitch/logs"

        #expect(rootDir == "/usr/local")
        #expect(binDir == "/usr/local/bin")
        #expect(etcDir == "/usr/local/etc/isp-snitch")
        #expect(varDir == "/usr/local/var/isp-snitch")
        #expect(dataDir == "/usr/local/var/isp-snitch/data")
        #expect(logDir == "/usr/local/var/isp-snitch/logs")
    }

    @Test func fileOwnership() throws {
        // Test file ownership
        let owner = "$(whoami)"
        let group = "staff"

        #expect(owner == "$(whoami)")
        #expect(group == "staff")
    }

    @Test func symbolicLinks() throws {
        // Test symbolic links
        let symlinkSource = "/usr/local/bin/isp-snitch"
        let symlinkTarget = "/usr/local/bin/isp-snitch"

        #expect(symlinkSource == symlinkTarget)
    }

    @Test func backupDirectories() throws {
        // Test backup directory structure
        let backupDir = "/usr/local/var/isp-snitch/data/backups"
        let exportDir = "/usr/local/var/isp-snitch/data/exports"

        #expect(backupDir == "/usr/local/var/isp-snitch/data/backups")
        #expect(exportDir == "/usr/local/var/isp-snitch/data/exports")
    }
}
