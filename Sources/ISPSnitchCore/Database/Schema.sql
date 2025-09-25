-- ISP Snitch Database Schema
-- This file contains the complete database schema for ISP Snitch
-- It serves as documentation and reference for the SQLite database structure

-- Connectivity Records Table
-- Stores all connectivity test results
CREATE TABLE IF NOT EXISTS connectivity_records (
    id TEXT PRIMARY KEY,
    timestamp DATETIME NOT NULL,
    test_type TEXT NOT NULL,
    target TEXT NOT NULL,
    latency REAL NULL,
    success BOOLEAN NOT NULL,
    error_message TEXT NULL,
    error_code INTEGER NULL,
    network_interface TEXT NOT NULL,
    cpu_usage REAL NOT NULL,
    memory_usage REAL NOT NULL,
    network_interface_status TEXT NOT NULL,
    battery_level REAL NULL,
    ping_data TEXT NULL,      -- JSON serialized PingData
    http_data TEXT NULL,      -- JSON serialized HttpData
    dns_data TEXT NULL,       -- JSON serialized DnsData
    speedtest_data TEXT NULL  -- JSON serialized SpeedtestData
);

-- Test Configurations Table
-- Stores test configuration settings
CREATE TABLE IF NOT EXISTS test_configurations (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    target TEXT NOT NULL,
    test_type TEXT NOT NULL,
    test_interval REAL NOT NULL,
    timeout REAL NOT NULL,
    retry_count INTEGER NOT NULL,
    is_active BOOLEAN NOT NULL
);

-- System Metrics Table
-- Stores system performance metrics
CREATE TABLE IF NOT EXISTS system_metrics (
    id TEXT PRIMARY KEY,
    timestamp DATETIME NOT NULL,
    cpu_usage REAL NOT NULL,
    memory_usage REAL NOT NULL,
    disk_usage REAL NOT NULL,
    network_bytes_in INTEGER NOT NULL,
    network_bytes_out INTEGER NOT NULL
);

-- Service Status Table
-- Stores service status information
CREATE TABLE IF NOT EXISTS service_status (
    id TEXT PRIMARY KEY,
    timestamp DATETIME NOT NULL,
    status TEXT NOT NULL,
    uptime REAL NOT NULL,
    version TEXT NOT NULL
);

-- Migrations Table
-- Tracks applied database migrations
CREATE TABLE IF NOT EXISTS migrations (
    version INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    timestamp DATETIME NOT NULL
);

-- Indexes for Performance

-- Connectivity Records Indexes
CREATE INDEX IF NOT EXISTS idx_connectivity_records_timestamp ON connectivity_records(timestamp);
CREATE INDEX IF NOT EXISTS idx_connectivity_records_test_type ON connectivity_records(test_type);
CREATE INDEX IF NOT EXISTS idx_connectivity_records_success ON connectivity_records(success);
CREATE INDEX IF NOT EXISTS idx_connectivity_records_network_interface ON connectivity_records(network_interface);

-- Composite Indexes for Common Queries
CREATE INDEX IF NOT EXISTS idx_connectivity_records_test_type_timestamp ON connectivity_records(test_type, timestamp);
CREATE INDEX IF NOT EXISTS idx_connectivity_records_success_timestamp ON connectivity_records(success, timestamp);
CREATE INDEX IF NOT EXISTS idx_connectivity_records_network_interface_timestamp ON connectivity_records(network_interface, timestamp);

-- System Metrics Indexes
CREATE INDEX IF NOT EXISTS idx_system_metrics_timestamp ON system_metrics(timestamp);

-- Service Status Indexes
CREATE INDEX IF NOT EXISTS idx_service_status_timestamp ON service_status(timestamp);

-- Test Configurations Indexes
CREATE INDEX IF NOT EXISTS idx_test_configurations_is_active ON test_configurations(is_active);
CREATE INDEX IF NOT EXISTS idx_test_configurations_test_type ON test_configurations(test_type);

-- Comments for Documentation

-- connectivity_records table stores all network connectivity test results
-- Each record includes:
-- - Basic test information (id, timestamp, test_type, target)
-- - Test results (latency, success, error information)
-- - System context (CPU, memory, network interface status, battery level)
-- - Test-specific data (JSON serialized for flexibility)

-- test_configurations table stores test settings
-- Allows for different test configurations to be defined and managed
-- Each configuration specifies what to test, how often, and with what parameters

-- system_metrics table stores system performance data
-- Tracks resource usage over time for correlation with connectivity issues
-- Helps identify if connectivity problems are related to system performance

-- service_status table stores service health information
-- Tracks the overall status and uptime of the ISP Snitch service
-- Used for health monitoring and service status reporting

-- migrations table tracks database schema versions
-- Ensures database schema can be upgraded safely
-- Records when migrations were applied for debugging and rollback purposes
