# ISP Snitch - Quick Start Guide

**Feature ID:** 001  
**Branch:** 001-isp-snitch-a  
**Generated:** 2024-12-19  
**Status:** Quick Start Guide Complete

## Overview

ISP Snitch is a lightweight ISP service monitor that runs in the background on your Mac, continuously testing network connectivity and generating accurate reports. This guide will help you get started quickly.

## Prerequisites

- macOS 12.0 or later
- Homebrew package manager
- Internet connection for initial setup

## Installation

### Option 1: Homebrew Installation (Recommended)

```bash
# Install ISP Snitch
brew install isp-snitch

# Start the service
brew services start isp-snitch
```

### Option 2: Manual Installation

```bash
# Clone the repository
git clone https://github.com/isp-snitch/isp-snitch.git
cd isp-snitch

# Build the project
swift build --configuration release

# Install the binary
sudo cp .build/release/isp-snitch /usr/local/bin/

# Set up the service
./scripts/install-service.sh
```

## First Run

### 1. Check Service Status

```bash
# Check if the service is running
isp-snitch status
```

Expected output:
```
ISP Snitch Service Status
========================
Status: Running
Uptime: 2m 30s
Last Update: 2024-12-19 14:30:25

Current Connectivity:
  Ping (8.8.8.8): ✓ 12ms
  HTTP (google.com): ✓ 45ms
  DNS (cloudflare.com): ✓ 8ms

System Metrics:
  CPU Usage: 0.8%
  Memory Usage: 42MB
  Network Interface: WiFi (en0)
```

### 2. View Web Interface

Open your browser and navigate to:
- **Local:** http://localhost:8080
- **Network:** http://[your-computer-name].local:8080

### 3. Generate Your First Report

```bash
# Generate a report for the last hour
isp-snitch report --hours 1

# Generate a report in JSON format
isp-snitch report --format json --output report.json
```

## Basic Configuration

### 1. View Current Configuration

```bash
# List all configuration settings
isp-snitch config list
```

### 2. Modify Test Targets

```bash
# Add a custom ping target
isp-snitch config set ping_targets "8.8.8.8,1.1.1.1,9.9.9.9"

# Add a custom HTTP target
isp-snitch config set http_targets "https://google.com,https://cloudflare.com,https://github.com"
```

### 3. Adjust Test Intervals

```bash
# Change test interval to 60 seconds
isp-snitch config set test_interval 60

# Change timeout to 15 seconds
isp-snitch config set timeout 15
```

### 4. Restart Service

```bash
# Restart the service to apply changes
isp-snitch restart
```

## Common Tasks

### Viewing Reports

```bash
# Last 24 hours (default)
isp-snitch report

# Last 7 days
isp-snitch report --days 7

# Last 2 hours
isp-snitch report --hours 2

# Only ping tests
isp-snitch report --test-type ping

# Only failed tests
isp-snitch report --failed-only
```

### Exporting Data

```bash
# Export as JSON
isp-snitch export --format json --output connectivity_data.json

# Export as CSV
isp-snitch export --format csv --output connectivity_data.csv

# Export last 30 days
isp-snitch export --days 30 --format json --output monthly_report.json
```

### Service Management

```bash
# Start the service
isp-snitch start

# Stop the service
isp-snitch stop

# Restart the service
isp-snitch restart

# View service logs
isp-snitch logs --follow
```

## Web Interface Usage

### Dashboard

The web interface provides a real-time dashboard showing:
- Current connectivity status
- Recent test results
- System metrics
- Service status

### Historical Data

Navigate to the "Reports" section to:
- View historical connectivity data
- Filter by test type or time period
- Export data in various formats
- Analyze connectivity trends

### Configuration

Use the "Settings" section to:
- Modify test targets
- Adjust test intervals
- Enable/disable notifications
- Configure data retention

## Troubleshooting

### Service Not Starting

```bash
# Check service status
launchctl list | grep isp-snitch

# View error logs
isp-snitch logs --level error

# Check configuration
isp-snitch config validate
```

### No Data in Reports

```bash
# Check if tests are running
isp-snitch status

# Verify network connectivity
ping 8.8.8.8

# Check service logs
isp-snitch logs --follow
```

### Web Interface Not Accessible

```bash
# Check if web server is running
curl http://localhost:8080/api/health

# Check port configuration
isp-snitch config get web_port

# Restart web interface
isp-snitch restart
```

### High Resource Usage

```bash
# Check current resource usage
isp-snitch status

# View system metrics
isp-snitch logs --level info | grep "CPU\|Memory"

# Restart service if needed
isp-snitch restart
```

## Advanced Configuration

### Custom Test Targets

Create a custom configuration file:

```json
{
  "name": "custom",
  "pingTargets": ["8.8.8.8", "1.1.1.1", "9.9.9.9"],
  "httpTargets": ["https://google.com", "https://cloudflare.com"],
  "dnsTargets": ["google.com", "cloudflare.com"],
  "testInterval": 30,
  "timeout": 10,
  "retryCount": 3
}
```

### Data Retention

```bash
# Set data retention to 60 days
isp-snitch config set data_retention_days 60

# Enable automatic cleanup
isp-snitch config set enable_cleanup true
```

### Notifications

```bash
# Enable system notifications
isp-snitch config set enable_notifications true

# Configure notification thresholds
isp-snitch config set notification_threshold 3
```

## Performance Optimization

### Resource Usage

ISP Snitch is designed to use minimal resources:
- **CPU:** < 1% average, < 5% peak
- **Memory:** < 50MB baseline, < 100MB peak
- **Network:** < 1KB/s for monitoring

### Battery Impact

On laptops, ISP Snitch:
- Respects system power settings
- Minimizes CPU wake-ups
- Optimizes for background operation

### Monitoring Performance

```bash
# View performance metrics
isp-snitch status

# Check resource usage
isp-snitch logs --level info | grep "Performance"

# View system metrics
curl http://localhost:8080/api/metrics
```

## Data Management

### Backup

```bash
# Create a backup
isp-snitch export --format json --output backup.json

# Backup with system metrics
isp-snitch export --format json --include-system-metrics --output full_backup.json
```

### Restore

```bash
# Stop service
isp-snitch stop

# Restore data (manual process)
# Copy backup file to data directory

# Start service
isp-snitch start
```

### Cleanup

```bash
# Manual cleanup of old data
isp-snitch config set data_retention_days 30

# Force cleanup
isp-snitch cleanup --force
```

## Security Considerations

### Local Access Only

ISP Snitch:
- Runs locally on your machine
- No external network access
- No data transmission to external servers
- All data remains on your device

### Data Privacy

- No telemetry or usage data collection
- No external communication
- User control over data sharing
- Local encryption for sensitive data

### Access Control

- Single-user local access
- No external network exposure
- Minimal system permissions required

## Getting Help

### Documentation

- **Full Documentation:** [GitHub Wiki](https://github.com/isp-snitch/isp-snitch/wiki)
- **API Reference:** [API Documentation](https://github.com/isp-snitch/isp-snitch/wiki/API-Reference)
- **Configuration Guide:** [Configuration Documentation](https://github.com/isp-snitch/isp-snitch/wiki/Configuration)

### Support

- **Issues:** [GitHub Issues](https://github.com/isp-snitch/isp-snitch/issues)
- **Discussions:** [GitHub Discussions](https://github.com/isp-snitch/isp-snitch/discussions)
- **Community:** [Discord Server](https://discord.gg/isp-snitch)

### Command Help

```bash
# Get help for any command
isp-snitch --help
isp-snitch status --help
isp-snitch report --help
isp-snitch config --help
```

## Next Steps

1. **Explore the Web Interface:** Navigate to http://localhost:8080
2. **Customize Configuration:** Adjust test targets and intervals
3. **Generate Reports:** Create reports for different time periods
4. **Export Data:** Export data for analysis or sharing
5. **Monitor Performance:** Keep an eye on resource usage
6. **Join the Community:** Connect with other users and contributors

## Uninstallation

### Homebrew Uninstallation

```bash
# Stop the service
brew services stop isp-snitch

# Uninstall the package
brew uninstall isp-snitch
```

### Manual Uninstallation

```bash
# Stop the service
launchctl stop com.isp-snitch.monitor

# Remove LaunchAgent
launchctl unload ~/Library/LaunchAgents/com.isp-snitch.monitor.plist
rm ~/Library/LaunchAgents/com.isp-snitch.monitor.plist

# Remove files
sudo rm -f /usr/local/bin/isp-snitch
sudo rm -rf /usr/local/etc/isp-snitch
sudo rm -rf /usr/local/var/isp-snitch
```

### Data Preservation

Before uninstalling, you can preserve your data:

```bash
# Export all data
isp-snitch export --format json --output final_backup.json

# Or copy the data directory
cp -r /usr/local/var/isp-snitch/data ~/isp-snitch-backup
```

---

**Congratulations!** You now have ISP Snitch running and monitoring your network connectivity. The service will continue running in the background, collecting data and providing insights into your ISP's performance.
