# ISP Snitch - CLI Interface Contracts

**Feature ID:** 001  
**Branch:** 001-isp-snitch-a  
**Generated:** 2024-12-19  
**Status:** CLI Contracts Complete

## Overview

This document defines the CLI interface contracts for ISP Snitch, including command specifications, argument parsing, and response formats.

## Command Structure

### Base Command
```bash
isp-snitch [COMMAND] [OPTIONS] [ARGUMENTS]
```

### Global Options
- `--help, -h`: Show help information
- `--version, -v`: Show version information
- `--verbose`: Enable verbose output
- `--quiet, -q`: Suppress non-error output
- `--config-file`: Specify custom configuration file path

## Command Specifications

### 1. Status Command
```bash
isp-snitch status [OPTIONS]
```

**Description:** Show service status and current connectivity information.

**Options:**
- `--json`: Output in JSON format
- `--format FORMAT`: Output format (text, json, csv)
- `--live`: Show live updates (refresh every 5 seconds)

**Output Format:**
```
ISP Snitch Service Status
========================
Status: Running
Uptime: 2h 15m 30s
Last Update: 2024-12-19 14:30:25

Current Connectivity:
  Ping (8.8.8.8): ✓ 24ms (TTL: 117, Loss: 0%)
  HTTP (google.com): ✓ 113ms (200 OK, 220 bytes)
  DNS (cloudflare.com): ✓ 28ms (1 answer, 8.8.8.8)

System Metrics:
  CPU Usage: 0.8%
  Memory Usage: 42MB
  Network Interface: WiFi (en1)

Recent Tests (Last 5):
  14:30:25 - Ping 8.8.8.8: ✓ 24ms (TTL: 117)
  14:30:20 - HTTP google.com: ✓ 113ms (200 OK)
  14:30:15 - DNS cloudflare.com: ✓ 28ms (1 answer)
  14:30:10 - Ping 1.1.1.1: ✓ 15ms (TTL: 117)
  14:30:05 - HTTP cloudflare.com: ✓ 38ms (200 OK)
```

**JSON Output:**
```json
{
  "serviceStatus": {
    "status": "running",
    "uptimeSeconds": 8130,
    "totalTests": 1250,
    "successfulTests": 1245,
    "failedTests": 5,
    "successRate": 0.996
  },
  "currentConnectivity": [
    {
      "id": "uuid",
      "timestamp": "2024-12-19T14:30:25Z",
      "testType": "ping",
      "target": "8.8.8.8",
      "latency": 0.024,
      "success": true,
      "errorCode": 0,
      "networkInterface": "en1",
      "pingData": {
        "latency": 0.024,
        "packetLoss": 0.0,
        "ttl": 117,
        "statistics": {
          "minLatency": 0.024,
          "avgLatency": 0.024,
          "maxLatency": 0.024,
          "stdDev": 0.0,
          "packetsTransmitted": 1,
          "packetsReceived": 1
        }
      }
    }
  ],
  "systemMetrics": {
    "cpuUsage": 0.8,
    "memoryUsage": 42.0,
    "networkInterface": "en0",
    "networkInterfaceStatus": "active"
  }
}
```

### 2. Report Command
```bash
isp-snitch report [OPTIONS]
```

**Description:** Generate connectivity report for specified time period.

**Options:**
- `--days N`: Number of days to include (default: 1)
- `--hours N`: Number of hours to include
- `--format FORMAT`: Output format (text, json, csv, html)
- `--output FILE`: Save output to file
- `--test-type TYPE`: Filter by test type (ping, http, dns, bandwidth, latency)
- `--target TARGET`: Filter by specific target
- `--success-only`: Show only successful tests
- `--failed-only`: Show only failed tests

**Default Behavior:** Shows last 24 hours of data in text format.

**Output Format:**
```
ISP Snitch Connectivity Report
=============================
Period: 2024-12-18 14:30:00 to 2024-12-19 14:30:00 (24 hours)
Generated: 2024-12-19 14:30:25

Summary:
  Total Tests: 2,880
  Successful: 2,875 (99.8%)
  Failed: 5 (0.2%)
  Average Latency: 23ms
  Min Latency: 8ms
  Max Latency: 156ms

Test Type Breakdown:
  Ping Tests: 1,440 tests, 99.9% success, 15ms avg latency
  HTTP Tests: 288 tests, 99.3% success, 45ms avg latency
  DNS Tests: 1,152 tests, 99.8% success, 12ms avg latency

Outage Events:
  2024-12-19 02:15:30 - HTTP google.com failed (3 consecutive failures)
  2024-12-19 02:15:45 - HTTP google.com recovered
  2024-12-19 08:30:15 - Ping 8.8.8.8 failed (1 failure)
  2024-12-19 08:30:30 - Ping 8.8.8.8 recovered

Top Failed Targets:
  google.com: 3 failures
  8.8.8.8: 1 failure
  cloudflare.com: 1 failure
```

### 3. Config Command
```bash
isp-snitch config [SUBCOMMAND] [OPTIONS] [ARGUMENTS]
```

**Subcommands:**
- `get [KEY]`: Get configuration value(s)
- `set KEY VALUE`: Set configuration value
- `list`: List all configuration values
- `reset`: Reset to default configuration
- `validate`: Validate current configuration

**Examples:**
```bash
# Get all configuration
isp-snitch config get

# Get specific configuration
isp-snitch config get test_interval

# Set configuration
isp-snitch config set test_interval 60
isp-snitch config set ping_targets "8.8.8.8,1.1.1.1,9.9.9.9"

# List configuration
isp-snitch config list

# Reset to defaults
isp-snitch config reset
```

**Configuration Keys:**
- `test_interval`: Test interval in seconds (default: 30)
- `timeout`: Test timeout in seconds (default: 10)
- `retry_count`: Number of retries (default: 3)
- `web_port`: Web interface port (default: 8080)
- `data_retention_days`: Data retention period (default: 30)
- `enable_notifications`: Enable system notifications (default: true)
- `enable_web_interface`: Enable web interface (default: true)
- `ping_targets`: Comma-separated ping targets
- `http_targets`: Comma-separated HTTP targets
- `dns_targets`: Comma-separated DNS targets

### 4. Export Command
```bash
isp-snitch export [OPTIONS]
```

**Description:** Export connectivity data in various formats.

**Options:**
- `--format FORMAT`: Export format (json, csv, html)
- `--output FILE`: Output file path
- `--days N`: Number of days to export (default: 30)
- `--test-type TYPE`: Filter by test type
- `--target TARGET`: Filter by specific target
- `--include-system-metrics`: Include system metrics in export

**Examples:**
```bash
# Export last 7 days as JSON
isp-snitch export --format json --days 7 --output connectivity_data.json

# Export all data as CSV
isp-snitch export --format csv --output full_report.csv

# Export only ping tests
isp-snitch export --format json --test-type ping --output ping_data.json
```

### 5. Service Control Commands

#### Start Command
```bash
isp-snitch start [OPTIONS]
```

**Description:** Start the monitoring service.

**Options:**
- `--background`: Start in background (default)
- `--foreground`: Start in foreground
- `--wait`: Wait for service to be ready

#### Stop Command
```bash
isp-snitch stop [OPTIONS]
```

**Description:** Stop the monitoring service.

**Options:**
- `--force`: Force stop without graceful shutdown
- `--wait`: Wait for service to stop

#### Restart Command
```bash
isp-snitch restart [OPTIONS]
```

**Description:** Restart the monitoring service.

**Options:**
- `--wait`: Wait for service to be ready after restart

### 6. Logs Command
```bash
isp-snitch logs [OPTIONS]
```

**Description:** View service logs.

**Options:**
- `--follow, -f`: Follow log output (like tail -f)
- `--lines N`: Number of lines to show (default: 50)
- `--level LEVEL`: Log level filter (debug, info, warn, error)
- `--since TIME`: Show logs since specified time
- `--until TIME`: Show logs until specified time

**Examples:**
```bash
# Show last 100 lines
isp-snitch logs --lines 100

# Follow logs in real-time
isp-snitch logs --follow

# Show only error logs
isp-snitch logs --level error

# Show logs from last hour
isp-snitch logs --since "1 hour ago"
```

## Error Handling

### Exit Codes
- `0`: Success
- `1`: General error
- `2`: Configuration error
- `3`: Service not running
- `4`: Permission denied
- `5`: Invalid arguments
- `6`: Network error
- `7`: Database error

### Error Messages
All error messages follow the format:
```
Error: [ERROR_TYPE] - [DESCRIPTION]
```

**Error Types:**
- `CONFIG_ERROR`: Configuration-related errors
- `SERVICE_ERROR`: Service-related errors
- `NETWORK_ERROR`: Network-related errors
- `DATABASE_ERROR`: Database-related errors
- `PERMISSION_ERROR`: Permission-related errors
- `VALIDATION_ERROR`: Input validation errors

**Examples:**
```
Error: CONFIG_ERROR - Invalid test interval: must be positive
Error: SERVICE_ERROR - Service is not running
Error: NETWORK_ERROR - Failed to connect to target 8.8.8.8
Error: DATABASE_ERROR - Failed to read connectivity records
Error: PERMISSION_ERROR - Insufficient permissions to start service
Error: VALIDATION_ERROR - Invalid target format: empty string
```

## Output Formats

### Text Format
Human-readable text output with proper formatting, colors, and tables.

### JSON Format
Structured JSON output for programmatic consumption.

### CSV Format
Comma-separated values for spreadsheet import.

### HTML Format
HTML report with embedded CSS for web viewing.

## Performance Requirements

### Response Times
- Status command: < 100ms
- Report command: < 500ms for 24 hours of data
- Config commands: < 50ms
- Export command: < 1s for 30 days of data

### Memory Usage
- CLI process: < 10MB
- No memory leaks during long-running operations

### Error Recovery
- Graceful handling of service unavailability
- Clear error messages with suggested solutions
- Automatic retry for transient failures
