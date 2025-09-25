# ISP Snitch - Implementation Tasks (SPM-Focused)

**Feature ID:** 001  
**Branch:** 001-isp-snitch-a  
**Generated:** 2024-12-19  
**Status:** Implementation Tasks Ready

## Overview

This document provides actionable, dependency-ordered tasks for implementing ISP Snitch using Swift Package Manager (SPM) exclusively, without Xcode. All tasks are based on comprehensive research analysis including utility validation (`utility-analysis.md`) and Swift 6.2 package evaluation (`swift62-packages-analysis.md`).

## Technology Stack (Based on Research)

- **Swift Version:** 6.2+ (Enhanced concurrency, performance optimizations)
- **Package Manager:** Swift Package Manager (SPM)
- **HTTP Server:** SwiftNIO (Apple official) - High-performance, WebSocket support
- **Database:** SQLite.swift (Community) - Type-safe, async/await compatible
- **System Integration:** Swift System (Apple official) - Enhanced macOS integration
- **CLI Interface:** ArgumentParser (Apple official) - Type-safe command parsing
- **Monitoring:** Swift Metrics + Swift Log (Apple official) - System monitoring
- **Testing:** Swift Testing Framework
- **Network Utilities:** ping, curl, dig, speedtest-cli (Validated outputs and behaviors)

## Task Execution Strategy

### Parallel Execution Groups
Tasks marked with **[P]** can be executed in parallel. Use these commands to run parallel tasks:

```bash
# Example: Run multiple tasks in parallel
swift test --parallel --num-workers 4
```

### Sequential Dependencies
Tasks without **[P]** must be completed in order due to file dependencies.

## Setup Tasks

### T001: Project Structure Setup
**Priority:** P0  
**Estimated Time:** 1 hour  
**Dependencies:** None  
**Constitution Alignment:** Modern Swift Architecture

**Description:** Create the basic Swift Package Manager project structure with proper target organization.

**Files to Create:**
- `Package.swift` - Main package configuration with Swift 6.2
- `Sources/ISPSnitchCore/` - Core service implementation
- `Sources/ISPSnitchCLI/` - CLI interface
- `Sources/ISPSnitchWeb/` - Web interface
- `Tests/ISPSnitchTests/` - Test suite
- `README.md` - Project documentation

**Acceptance Criteria:**
;- [x] `swift package init --type executable` creates basic structure
- [x] `Package.swift` includes all required dependencies
- [x] Project builds with `swift build`
- [x] Tests run with `swift test`

**Implementation:**
```bash
cd /Users/khaos/Projects/isp_snitch
swift package init --type executable --name ISPSnitch
```

### T002: Package Dependencies Configuration
**Priority:** P0  
**Estimated Time:** 30 minutes  
**Dependencies:** T001  
**Constitution Alignment:** Modern Swift Architecture

**Description:** Configure Package.swift with all required dependencies based on `swift62-packages-analysis.md`.

**Files to Modify:**
- `Package.swift` - Add all dependencies and targets

**Acceptance Criteria:**
- [x] SwiftNIO dependency added (Apple official)
- [x] SQLite.swift dependency added (Community)
- [x] Swift System dependency added (Apple official)
- [x] ArgumentParser dependency added (Apple official)
- [x] Swift Metrics dependency added (Apple official)
- [x] Swift Log dependency added (Apple official)
- [x] All targets properly configured
- [x] `swift package resolve` succeeds

**Implementation:**
```bash
# Add dependencies to Package.swift based on swift62-packages-analysis.md
swift package resolve
swift build
```

## Test Tasks (TDD Approach)

### T003: Data Model Tests [P]
**Priority:** P0  
**Estimated Time:** 2 hours  
**Dependencies:** T002  
**Constitution Alignment:** Accurate Connectivity Reporting

**Description:** Create comprehensive tests for all data models with Swift 6.2 Sendable conformance based on `data-model.md`.

**Files to Create:**
- `Tests/ISPSnitchTests/Models/ConnectivityRecordTests.swift`
- `Tests/ISPSnitchTests/Models/PingDataTests.swift`
- `Tests/ISPSnitchTests/Models/HttpDataTests.swift`
- `Tests/ISPSnitchTests/Models/DnsDataTests.swift`
- `Tests/ISPSnitchTests/Models/SpeedtestDataTests.swift`
- `Tests/ISPSnitchTests/Models/SystemContextTests.swift`
- `Tests/ISPSnitchTests/Models/TestConfigurationTests.swift`

**Acceptance Criteria:**
- [x] All data models have comprehensive test coverage
- [x] Sendable conformance tests pass
- [x] Codable serialization/deserialization tests pass
- [x] Validation tests cover all edge cases
- [x] `swift test` passes for all model tests

**Test Commands:**
```bash
swift test --filter ConnectivityRecordTests
swift test --filter PingDataTests
swift test --filter HttpDataTests
swift test --filter DnsDataTests
swift test --filter SpeedtestDataTests
```

### T004: Database Schema Tests [P]
**Priority:** P0  
**Estimated Time:** 1.5 hours  
**Dependencies:** T002  
**Constitution Alignment:** Data Privacy and Security

**Description:** Create tests for database schema and operations with SQLite.swift based on `data-model.md`.

**Files to Create:**
- `Tests/ISPSnitchTests/Database/DatabaseSchemaTests.swift`
- `Tests/ISPSnitchTests/Database/DataStorageTests.swift`
- `Tests/ISPSnitchTests/Database/MigrationTests.swift`
- `Tests/ISPSnitchTests/Database/DataRetentionTests.swift`

**Acceptance Criteria:**
- [x] Database schema creation tests pass
- [x] CRUD operations tests pass
- [x] Migration tests pass
- [x] Data validation tests pass
- [x] Performance tests for large datasets pass
- [x] Data retention policy tests pass

**Test Commands:**
```bash
swift test --filter DatabaseSchemaTests
swift test --filter DataStorageTests
swift test --filter MigrationTests
```

### T005: Network Utility Tests [P]
**Priority:** P0  
**Estimated Time:** 2 hours  
**Dependencies:** T002  
**Constitution Alignment:** Accurate Connectivity Reporting

**Description:** Create tests for network utility integration based on `utility-analysis.md`.

**Files to Create:**
- `Tests/ISPSnitchTests/Network/PingTests.swift`
- `Tests/ISPSnitchTests/Network/HttpTests.swift`
- `Tests/ISPSnitchTests/Network/DnsTests.swift`
- `Tests/ISPSnitchTests/Network/SpeedtestTests.swift`
- `Tests/ISPSnitchTests/Network/UtilityExecutorTests.swift`

**Acceptance Criteria:**
- [x] Ping utility integration tests pass (validated output format)
- [x] HTTP utility integration tests pass (curl output parsing)
- [x] DNS utility integration tests pass (dig output parsing)
- [x] Speedtest utility integration tests pass (speedtest-cli output)
- [x] Error handling tests pass (exit codes and error messages)
- [x] Output parsing tests pass (regex patterns from utility-analysis.md)

**Test Commands:**
```bash
swift test --filter PingTests
swift test --filter HttpTests
swift test --filter DnsTests
swift test --filter SpeedtestTests
```

### T006: CLI Interface Tests [P]
**Priority:** P0  
**Estimated Time:** 1.5 hours  
**Dependencies:** T002  
**Constitution Alignment:** Multi-Access Interface

**Description:** Create tests for CLI interface contracts with ArgumentParser based on `contracts/cli-contracts.md`.

**Files to Create:**
- `Tests/ISPSnitchTests/CLI/StatusCommandTests.swift`
- `Tests/ISPSnitchTests/CLI/ReportCommandTests.swift`
- `Tests/ISPSnitchTests/CLI/ConfigCommandTests.swift`
- `Tests/ISPSnitchTests/CLI/ExportCommandTests.swift`
- `Tests/ISPSnitchTests/CLI/ServiceCommandTests.swift`

**Acceptance Criteria:**
- [x] Status command tests pass
- [x] Report command tests pass
- [x] Config command tests pass
- [x] Export command tests pass
- [x] Service command tests pass
- [x] Error handling tests pass
- [x] Output format tests pass

**Test Commands:**
```bash
swift test --filter StatusCommandTests
swift test --filter ReportCommandTests
swift test --filter ConfigCommandTests
swift test --filter ExportCommandTests
```

### T007: Web API Tests [P]
**Priority:** P0  
**Estimated Time:** 2 hours  
**Dependencies:** T002  
**Constitution Alignment:** Multi-Access Interface

**Description:** Create tests for web API contracts with SwiftNIO based on `contracts/web-api-contracts.md`.

**Files to Create:**
- `Tests/ISPSnitchTests/WebAPI/StatusEndpointTests.swift`
- `Tests/ISPSnitchTests/WebAPI/ReportsEndpointTests.swift`
- `Tests/ISPSnitchTests/WebAPI/ConfigEndpointTests.swift`
- `Tests/ISPSnitchTests/WebAPI/ExportEndpointTests.swift`
- `Tests/ISPSnitchTests/WebAPI/WebSocketTests.swift`
- `Tests/ISPSnitchTests/WebAPI/HealthEndpointTests.swift`
- `Tests/ISPSnitchTests/WebAPI/MetricsEndpointTests.swift`

**Acceptance Criteria:**
- [x] All REST endpoint tests pass
- [x] WebSocket connection tests pass
- [x] JSON response format tests pass
- [x] Error response tests pass
- [x] Authentication tests pass (local access only)
- [x] Health check tests pass
- [x] Metrics endpoint tests pass

**Test Commands:**
```bash
swift test --filter StatusEndpointTests
swift test --filter ReportsEndpointTests
swift test --filter ConfigEndpointTests
swift test --filter ExportEndpointTests
swift test --filter WebSocketTests
```

### T008: System Integration Tests [P]
**Priority:** P0  
**Estimated Time:** 1.5 hours  
**Dependencies:** T002  
**Constitution Alignment:** Automatic Startup Integration

**Description:** Create tests for system integration based on `contracts/system-integration-contracts.md`.

**Files to Create:**
- `Tests/ISPSnitchTests/System/LaunchAgentTests.swift`
- `Tests/ISPSnitchTests/System/ServiceManagementTests.swift`
- `Tests/ISPSnitchTests/System/PermissionTests.swift`
- `Tests/ISPSnitchTests/System/StartupTests.swift`

**Acceptance Criteria:**
- [x] LaunchAgent configuration tests pass
- [x] Service management tests pass
- [x] Permission tests pass
- [x] Startup integration tests pass
- [x] Graceful shutdown tests pass

**Test Commands:**
```bash
swift test --filter LaunchAgentTests
swift test --filter ServiceManagementTests
swift test --filter PermissionTests
swift test --filter StartupTests
```

## Core Implementation Tasks

### T009: Data Models Implementation
**Priority:** P0  
**Estimated Time:** 3 hours  
**Dependencies:** T003  
**Constitution Alignment:** Accurate Connectivity Reporting

**Description:** Implement all data models with Swift 6.2 features and Sendable conformance based on `data-model.md`.

**Files to Create:**
- `Sources/ISPSnitchCore/Models/ConnectivityRecord.swift`
- `Sources/ISPSnitchCore/Models/TestTypes.swift`
- `Sources/ISPSnitchCore/Models/SystemContext.swift`
- `Sources/ISPSnitchCore/Models/PingData.swift`
- `Sources/ISPSnitchCore/Models/HttpData.swift`
- `Sources/ISPSnitchCore/Models/DnsData.swift`
- `Sources/ISPSnitchCore/Models/SpeedtestData.swift`
- `Sources/ISPSnitchCore/Models/TestConfiguration.swift`

**Acceptance Criteria:**
- [x] All models conform to Sendable (Swift 6.2)
- [x] All models conform to Codable
- [x] All models have proper validation
- [x] All models pass existing tests
- [x] Models compile without warnings

**Build Commands:**
```bash
swift build
swift test --filter ConnectivityRecordTests
```

### T010: Database Implementation
**Priority:** P0  
**Estimated Time:** 4 hours  
**Dependencies:** T004, T009  
**Constitution Alignment:** Data Privacy and Security

**Description:** Implement SQLite database layer with Swift 6.2 actors and SQLite.swift based on `data-model.md`.

**Files to Create:**
- `Sources/ISPSnitchCore/Database/DatabaseManager.swift`
- `Sources/ISPSnitchCore/Database/DataStorage.swift`
- `Sources/ISPSnitchCore/Database/Migrations.swift`
- `Sources/ISPSnitchCore/Database/Schema.sql`
- `Sources/ISPSnitchCore/Database/DataRetentionManager.swift`

**Acceptance Criteria:**
- [x] Database schema creates successfully
- [x] CRUD operations work correctly
- [x] Migration system functions properly
- [x] Actor-based thread safety implemented (Swift 6.2)
- [x] All database tests pass
- [x] Data retention policies work correctly

**Build Commands:**
```bash
swift build
swift test --filter DatabaseSchemaTests
swift test --filter DataStorageTests
```

### T011: Network Monitoring Implementation
**Priority:** P0  
**Estimated Time:** 5 hours  
**Dependencies:** T005, T009  
**Constitution Alignment:** Accurate Connectivity Reporting

**Description:** Implement network monitoring with system utilities based on `utility-analysis.md`.

**Files to Create:**
- `Sources/ISPSnitchCore/Network/NetworkMonitor.swift`
- `Sources/ISPSnitchCore/Network/PingMonitor.swift`
- `Sources/ISPSnitchCore/Network/HttpMonitor.swift`
- `Sources/ISPSnitchCore/Network/DnsMonitor.swift`
- `Sources/ISPSnitchCore/Network/SpeedtestMonitor.swift`
- `Sources/ISPSnitchCore/Network/UtilityExecutor.swift`
- `Sources/ISPSnitchCore/Network/OutputParser.swift`

**Acceptance Criteria:**
- [x] All network tests execute successfully
- [x] Output parsing works correctly (based on utility-analysis.md)
- [x] Error handling is robust (exit codes and error messages)
- [x] Resource usage is minimal
- [x] All network tests pass

**Build Commands:**
```bash
swift build
swift test --filter PingTests
swift test --filter HttpTests
swift test --filter DnsTests
swift test --filter SpeedtestTests
```

### T012: CLI Interface Implementation
**Priority:** P0  
**Estimated Time:** 4 hours  
**Dependencies:** T006, T009, T010, T011  
**Constitution Alignment:** Multi-Access Interface

**Description:** Implement CLI interface with ArgumentParser based on `contracts/cli-contracts.md`.

**Files to Create:**
- `Sources/ISPSnitchCLI/main.swift`
- `Sources/ISPSnitchCLI/Commands/StatusCommand.swift`
- `Sources/ISPSnitchCLI/Commands/ReportCommand.swift`
- `Sources/ISPSnitchCLI/Commands/ConfigCommand.swift`
- `Sources/ISPSnitchCLI/Commands/ExportCommand.swift`
- `Sources/ISPSnitchCLI/Commands/ServiceCommand.swift`
- `Sources/ISPSnitchCLI/Output/OutputFormatter.swift`

**Acceptance Criteria:**
- [x] All CLI commands work correctly
- [x] Help text is comprehensive
- [x] Error handling is user-friendly
- [x] Output formats work as specified
- [x] All CLI tests pass

**Build Commands:**
```bash
swift build
swift test --filter StatusCommandTests
swift test --filter ReportCommandTests
swift test --filter ConfigCommandTests
swift test --filter ExportCommandTests
```

### T013: Web Server Implementation
**Priority:** P0  
**Estimated Time:** 5 hours  
**Dependencies:** T007, T009, T010, T011  
**Constitution Alignment:** Multi-Access Interface

**Description:** Implement HTTP server with SwiftNIO and WebSocket support based on `contracts/web-api-contracts.md`.

**Files to Create:**
- `Sources/ISPSnitchWeb/WebServer.swift`
- `Sources/ISPSnitchWeb/Handlers/StatusHandler.swift`
- `Sources/ISPSnitchWeb/Handlers/ReportsHandler.swift`
- `Sources/ISPSnitchWeb/Handlers/ConfigHandler.swift`
- `Sources/ISPSnitchWeb/Handlers/ExportHandler.swift`
- `Sources/ISPSnitchWeb/Handlers/HealthHandler.swift`
- `Sources/ISPSnitchWeb/Handlers/MetricsHandler.swift`
- `Sources/ISPSnitchWeb/WebSocket/WebSocketHandler.swift`
- `Sources/ISPSnitchWeb/Resources/web/` - Static web files

**Acceptance Criteria:**
- [x] HTTP server starts successfully
- [x] All REST endpoints respond correctly
- [x] WebSocket connections work
- [x] Static web files serve correctly
- [x] All web API tests pass

**Build Commands:**
```bash
swift build
swift test --filter StatusEndpointTests
swift test --filter ReportsEndpointTests
swift test --filter ConfigEndpointTests
swift test --filter ExportEndpointTests
swift test --filter WebSocketTests
```

## Integration Tasks

### T014: Core Service Integration
**Priority:** P0  
**Estimated Time:** 3 hours  
**Dependencies:** T009, T010, T011  
**Constitution Alignment:** Modern Swift Architecture

**Description:** Integrate all core components into main service with Swift 6.2 structured concurrency.

**Files to Create:**
- `Sources/ISPSnitchCore/ISPSnitchService.swift`
- `Sources/ISPSnitchCore/ConfigurationManager.swift`
- `Sources/ISPSnitchCore/SystemMetrics.swift`
- `Sources/ISPSnitchCore/ResourceMonitor.swift`

**Acceptance Criteria:**
- [x] Service starts and stops gracefully
- [x] All components integrate correctly
- [x] Resource usage is within limits
- [x] Error handling is comprehensive
- [x] Service runs continuously

**Build Commands:**
```bash
swift build
swift run ISPSnitch
```

### T015: System Integration
**Priority:** P0  
**Estimated Time:** 2 hours  
**Dependencies:** T014  
**Constitution Alignment:** Automatic Startup Integration

**Description:** Implement macOS system integration based on `contracts/system-integration-contracts.md`.

**Files to Create:**
- `Resources/com.isp-snitch.monitor.plist`
- `Scripts/install-service.sh`
- `Scripts/uninstall-service.sh`
- `Scripts/start-service.sh`
- `Scripts/stop-service.sh`

**Acceptance Criteria:**
- [ ] LaunchAgent installs correctly
- [ ] Service starts on boot
- [ ] Service stops gracefully
- [ ] Logs are properly managed
- [ ] Uninstall works cleanly

**Test Commands:**
```bash
./Scripts/install-service.sh
launchctl list | grep isp-snitch
./Scripts/uninstall-service.sh
```

### T016: Homebrew Package Creation
**Priority:** P0  
**Estimated Time:** 2 hours  
**Dependencies:** T015  
**Constitution Alignment:** Homebrew Integration

**Description:** Create Homebrew formula for distribution based on `contracts/system-integration-contracts.md`.

**Files to Create:**
- `Formula/isp-snitch.rb`
- `Scripts/build-package.sh`
- `Scripts/test-package.sh`
- `Scripts/package-release.sh`

**Acceptance Criteria:**
- [ ] Homebrew formula is valid
- [ ] Package builds successfully
- [ ] Installation works via Homebrew
- [ ] Service starts after installation
- [ ] Uninstallation works correctly

**Test Commands:**
```bash
brew install --build-from-source ./Formula/isp-snitch.rb
brew services start isp-snitch
brew services stop isp-snitch
brew uninstall isp-snitch
```

## Polish Tasks

### T017: Performance Optimization [P]
**Priority:** P1  
**Estimated Time:** 3 hours  
**Dependencies:** T016  
**Constitution Alignment:** Minimal Resource Footprint

**Description:** Optimize performance and resource usage using Swift 6.2 features based on `research.md`.

**Files to Modify:**
- All source files for performance optimization

**Acceptance Criteria:**
- [ ] CPU usage < 1% average (measured via `top` command)
- [ ] Memory usage < 50MB baseline (measured via `ps` command)
- [ ] Network overhead < 1KB/s (measured via `netstat` command)
- [ ] Startup time < 5 seconds (measured from LaunchAgent start)
- [ ] Response time < 100ms for CLI (measured via `time` command)

**Performance Tests:**
```bash
swift test --filter PerformanceTests
```

### T018: Comprehensive Testing [P]
**Priority:** P1  
**Estimated Time:** 4 hours  
**Dependencies:** T016  
**Constitution Alignment:** Public Project Transparency

**Description:** Add comprehensive test coverage based on `quickstart.md` test scenarios.

**Files to Create:**
- `Tests/ISPSnitchTests/Integration/ServiceIntegrationTests.swift`
- `Tests/ISPSnitchTests/Integration/CLIIntegrationTests.swift`
- `Tests/ISPSnitchTests/Integration/WebIntegrationTests.swift`
- `Tests/ISPSnitchTests/Performance/ResourceUsageTests.swift`
- `Tests/ISPSnitchTests/Security/SecurityTests.swift`
- `Tests/ISPSnitchTests/EndToEnd/EndToEndTests.swift`

**Acceptance Criteria:**
- [ ] Test coverage > 90%
- [ ] All integration tests pass
- [ ] Performance tests pass
- [ ] Security tests pass
- [ ] End-to-end tests pass
- [ ] Tests run in parallel successfully

**Test Commands:**
```bash
swift test --parallel --num-workers 4
swift test --filter IntegrationTests
swift test --filter PerformanceTests
swift test --filter SecurityTests
```

### T019: Documentation Completion [P]
**Priority:** P1  
**Estimated Time:** 3 hours  
**Dependencies:** T016  
**Constitution Alignment:** Public Project Transparency

**Description:** Complete all documentation based on `quickstart.md`.

**Files to Create/Update:**
- `README.md` - Complete project documentation
- `docs/API.md` - API documentation
- `docs/CLI.md` - CLI documentation
- `docs/INSTALLATION.md` - Installation guide
- `docs/TROUBLESHOOTING.md` - Troubleshooting guide
- `docs/CONTRIBUTING.md` - Contributing guidelines

**Acceptance Criteria:**
- [ ] README is comprehensive
- [ ] API documentation is complete
- [ ] CLI documentation is accurate
- [ ] Installation guide works
- [ ] Troubleshooting guide is helpful
- [ ] Contributing guidelines are clear

**Documentation Tests:**
```bash
# Verify all documentation links work
# Verify installation instructions work
# Verify CLI help text is accurate
```

## Parallel Execution Examples

### Phase 1: Setup (Sequential)
```bash
# T001: Project Structure Setup
swift package init --type executable --name ISPSnitch

# T002: Package Dependencies Configuration
# Edit Package.swift, then:
swift package resolve
swift build
```

### Phase 2: Tests (Parallel)
```bash
# Run all test tasks in parallel
swift test --parallel --num-workers 4
```

### Phase 3: Core Implementation (Sequential)
```bash
# T009: Data Models Implementation
swift build
swift test --filter ConnectivityRecordTests

# T010: Database Implementation
swift build
swift test --filter DatabaseSchemaTests

# T011: Network Monitoring Implementation
swift build
swift test --filter PingTests

# T012: CLI Interface Implementation
swift build
swift test --filter StatusCommandTests

# T013: Web Server Implementation
swift build
swift test --filter StatusEndpointTests
```

### Phase 4: Integration (Sequential)
```bash
# T014: Core Service Integration
swift build
swift run ISPSnitch

# T015: System Integration
./Scripts/install-service.sh

# T016: Homebrew Package Creation
brew install --build-from-source ./Formula/isp-snitch.rb
```

### Phase 5: Polish (Parallel)
```bash
# T017: Performance Optimization
swift test --filter PerformanceTests

# T018: Comprehensive Testing
swift test --parallel --num-workers 4

# T019: Documentation Completion
# Manual verification of documentation
```

## Success Criteria

### Functional Requirements
- [ ] Service starts automatically on Mac boot
- [ ] Continuous network monitoring operational
- [ ] Accurate connectivity reporting functional
- [ ] CLI interface with all specified commands
- [ ] Web interface accessible via localhost and .local
- [ ] Local data storage operational
- [ ] Swift Package Manager installation working

### Performance Requirements
- [ ] < 50MB memory usage baseline (measured via `ps` command)
- [ ] < 5 second startup time (measured from LaunchAgent start)
- [ ] < 100ms CLI response time (measured via `time` command)
- [ ] < 500ms web interface response time (measured via browser dev tools)
- [ ] < 2% additional battery drain per hour (measured via `pmset` command)
- [ ] Stable operation over 24+ hour periods

### Quality Requirements
- [ ] Test coverage > 90%
- [ ] All tests pass in parallel
- [ ] No memory leaks detected
- [ ] No data races detected
- [ ] Comprehensive documentation
- [ ] Homebrew package functional

## Task Execution Summary

**Total Tasks:** 19  
**Estimated Time:** 48 hours  
**Parallel Tasks:** 9 (can be executed concurrently)  
**Sequential Tasks:** 10 (must be executed in order)

**Critical Path:**
T001 → T002 → T003-T008 (parallel) → T009 → T010 → T011 → T012 → T013 → T014 → T015 → T016 → T017-T019 (parallel)

**Ready for Implementation:** All tasks are immediately actionable with specific file paths, build commands, and acceptance criteria based on comprehensive research analysis including utility validation and Swift 6.2 package evaluation.