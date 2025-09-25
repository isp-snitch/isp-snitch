# ISP Snitch - System Integration Contracts

**Feature ID:** 001  
**Branch:** 001-isp-snitch-a  
**Generated:** 2024-12-19  
**Status:** System Integration Contracts Complete

## Overview

This document defines the system integration contracts for ISP Snitch, including macOS integration, Homebrew package management, and system service contracts.

## macOS Integration

### LaunchAgent Configuration

#### Plist File Location
```
~/Library/LaunchAgents/com.isp-snitch.monitor.plist
```

#### Plist Content
```xml
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
    
    <key>StandardOutPath</key>
    <string>/usr/local/var/log/isp-snitch/out.log</string>
    
    <key>StandardErrorPath</key>
    <string>/usr/local/var/log/isp-snitch/error.log</string>
    
    <key>WorkingDirectory</key>
    <string>/usr/local/var/isp-snitch</string>
    
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/usr/local/bin:/usr/bin:/bin</string>
        <key>ISP_SNITCH_CONFIG</key>
        <string>/usr/local/etc/isp-snitch/config.json</string>
        <key>ISP_SNITCH_DATA</key>
        <string>/usr/local/var/isp-snitch/data</string>
    </dict>
    
    <key>ThrottleInterval</key>
    <integer>10</integer>
    
    <key>ProcessType</key>
    <string>Background</string>
    
    <key>LowPriorityIO</key>
    <true/>
    
    <key>Nice</key>
    <integer>1</integer>
</dict>
</plist>
```

### Service Management Commands

#### Install Service
```bash
# Copy LaunchAgent plist
cp com.isp-snitch.monitor.plist ~/Library/LaunchAgents/

# Load the service
launchctl load ~/Library/LaunchAgents/com.isp-snitch.monitor.plist

# Start the service
launchctl start com.isp-snitch.monitor
```

#### Uninstall Service
```bash
# Stop the service
launchctl stop com.isp-snitch.monitor

# Unload the service
launchctl unload ~/Library/LaunchAgents/com.isp-snitch.monitor.plist

# Remove the plist file
rm ~/Library/LaunchAgents/com.isp-snitch.monitor.plist
```

#### Service Status
```bash
# Check if service is loaded
launchctl list | grep com.isp-snitch.monitor

# Check service status
launchctl print user/$(id -u)/com.isp-snitch.monitor
```

### File System Structure

#### Installation Directories
```
/usr/local/bin/isp-snitch              # Main executable
/usr/local/etc/isp-snitch/             # Configuration files
/usr/local/var/isp-snitch/             # Data directory
/usr/local/var/isp-snitch/data/        # SQLite database
/usr/local/var/isp-snitch/logs/        # Log files
/usr/local/var/log/isp-snitch/         # System logs
```

#### Configuration Files
```
/usr/local/etc/isp-snitch/config.json  # Main configuration
/usr/local/etc/isp-snitch/targets.json # Test targets
/usr/local/etc/isp-snitch/logging.json # Logging configuration
```

#### Data Files
```
/usr/local/var/isp-snitch/data/connectivity.db  # SQLite database
/usr/local/var/isp-snitch/data/backups/         # Backup files
/usr/local/var/isp-snitch/data/exports/         # Export files
```

### Permissions and Security

#### Required Permissions
- Network access for connectivity testing
- File system access for data storage
- System monitoring for resource usage tracking

#### Security Considerations
- Run as current user (not root)
- Local access only (no external network exposure)
- Minimal file system permissions
- No elevated privileges required

## Homebrew Integration

### Formula Structure

#### Formula File
```ruby
class IspSnitch < Formula
  desc "Lightweight ISP service monitor for macOS"
  homepage "https://github.com/isp-snitch/isp-snitch"
  url "https://github.com/isp-snitch/isp-snitch/releases/download/v1.0.0/isp-snitch-1.0.0.tar.gz"
  sha256 "abc123def456..."
  license "MIT"
  
  depends_on "swift" => :build
  depends_on "sqlite"
  
  def install
    system "swift", "build", "--configuration", "release"
    bin.install ".build/release/isp-snitch"
    
    # Install configuration files
    etc.install "config/config.json" => "isp-snitch/config.json"
    etc.install "config/targets.json" => "isp-snitch/targets.json"
    
    # Create data directory
    (var/"isp-snitch").mkpath
    (var/"isp-snitch/data").mkpath
    (var/"isp-snitch/logs").mkpath
    
    # Install LaunchAgent
    (prefix/"Library/LaunchAgents").install "com.isp-snitch.monitor.plist"
  end
  
  def post_install
    # Set up LaunchAgent
    system "launchctl", "load", "#{prefix}/Library/LaunchAgents/com.isp-snitch.monitor.plist"
  end
  
  def uninstall
    # Stop and unload LaunchAgent
    system "launchctl", "unload", "#{prefix}/Library/LaunchAgents/com.isp-snitch.monitor.plist"
    
    # Remove LaunchAgent file
    rm_f "#{prefix}/Library/LaunchAgents/com.isp-snitch.monitor.plist"
  end
  
  test do
    system "#{bin}/isp-snitch", "--version"
  end
end
```

### Installation Process

#### Install via Homebrew
```bash
# Add tap (if using custom tap)
brew tap isp-snitch/isp-snitch

# Install package
brew install isp-snitch

# Start service
brew services start isp-snitch
```

#### Update via Homebrew
```bash
# Update package
brew upgrade isp-snitch

# Restart service
brew services restart isp-snitch
```

#### Uninstall via Homebrew
```bash
# Stop service
brew services stop isp-snitch

# Uninstall package
brew uninstall isp-snitch
```

### Dependencies

#### Required Dependencies
- `swift` (build dependency)
- `sqlite` (runtime dependency)

#### Optional Dependencies
- `speedtest-cli` (for bandwidth testing)
- `curl` (for HTTP testing)
- `dig` (for DNS testing)
- `ping` (for ICMP testing)

#### Dependency Management
```bash
# Install required dependencies
brew install sqlite

# Install optional dependencies
brew install speedtest-cli curl bind dig
```

## System Service Contracts

### Service Lifecycle

#### Startup Sequence
1. Load configuration from `/usr/local/etc/isp-snitch/config.json`
2. Initialize SQLite database
3. Start network monitoring tasks
4. Start web server
5. Register with system service manager
6. Begin connectivity testing

#### Shutdown Sequence
1. Stop network monitoring tasks
2. Stop web server
3. Flush pending data to database
4. Close database connections
5. Unregister from system service manager
6. Exit gracefully

### Service Health Monitoring

#### Health Check Endpoint
```http
GET /api/health
```

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-12-19T14:30:25Z",
  "uptime": 8130,
  "version": "1.0.0",
  "checks": {
    "database": "healthy",
    "network": "healthy",
    "web_server": "healthy",
    "monitoring": "healthy"
  }
}
```

#### Health Check Script
```bash
#!/bin/bash
# Health check script for monitoring systems

HEALTH_URL="http://localhost:8080/api/health"
TIMEOUT=5

# Check if service is responding
if curl -s --max-time $TIMEOUT "$HEALTH_URL" > /dev/null; then
    echo "ISP Snitch service is healthy"
    exit 0
else
    echo "ISP Snitch service is not responding"
    exit 1
fi
```

### Log Management

#### Log File Locations
```
/usr/local/var/log/isp-snitch/out.log      # Standard output
/usr/local/var/log/isp-snitch/error.log    # Standard error
/usr/local/var/isp-snitch/logs/app.log     # Application logs
/usr/local/var/isp-snitch/logs/access.log  # Web server access logs
```

#### Log Rotation
```bash
# Logrotate configuration
/usr/local/var/log/isp-snitch/*.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 644 $(whoami) staff
    postrotate
        launchctl kill -TERM com.isp-snitch.monitor
    endscript
}
```

#### Log Levels
- `DEBUG`: Detailed debugging information
- `INFO`: General information messages
- `WARN`: Warning messages
- `ERROR`: Error messages
- `FATAL`: Fatal error messages

### Resource Monitoring

#### Resource Limits
- CPU usage: < 1% average, < 5% peak
- Memory usage: < 50MB baseline, < 100MB peak
- Network bandwidth: < 1KB/s for monitoring
- Disk usage: < 100MB for data storage

#### Resource Monitoring Script
```bash
#!/bin/bash
# Resource monitoring script

# Get process ID
PID=$(pgrep -f "isp-snitch")

if [ -z "$PID" ]; then
    echo "ISP Snitch process not found"
    exit 1
fi

# Get resource usage
CPU_USAGE=$(ps -p $PID -o %cpu= | tr -d ' ')
MEMORY_USAGE=$(ps -p $PID -o %mem= | tr -d ' ')
MEMORY_KB=$(ps -p $PID -o rss= | tr -d ' ')

echo "CPU Usage: ${CPU_USAGE}%"
echo "Memory Usage: ${MEMORY_USAGE}% (${MEMORY_KB}KB)"

# Check if usage exceeds limits
if (( $(echo "$CPU_USAGE > 5" | bc -l) )); then
    echo "WARNING: CPU usage exceeds 5%"
fi

if (( $(echo "$MEMORY_KB > 102400" | bc -l) )); then
    echo "WARNING: Memory usage exceeds 100MB"
fi
```

### Backup and Recovery

#### Backup Script
```bash
#!/bin/bash
# Backup script for ISP Snitch data

BACKUP_DIR="/usr/local/var/isp-snitch/backups"
DATA_DIR="/usr/local/var/isp-snitch/data"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Create backup
tar -czf "$BACKUP_DIR/isp-snitch-backup-$TIMESTAMP.tar.gz" -C "$DATA_DIR" .

# Keep only last 7 backups
ls -t "$BACKUP_DIR"/isp-snitch-backup-*.tar.gz | tail -n +8 | xargs rm -f

echo "Backup created: isp-snitch-backup-$TIMESTAMP.tar.gz"
```

#### Recovery Script
```bash
#!/bin/bash
# Recovery script for ISP Snitch data

BACKUP_FILE="$1"
DATA_DIR="/usr/local/var/isp-snitch/data"

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: $0 <backup-file>"
    exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
    echo "Backup file not found: $BACKUP_FILE"
    exit 1
fi

# Stop service
launchctl stop com.isp-snitch.monitor

# Restore data
tar -xzf "$BACKUP_FILE" -C "$DATA_DIR"

# Start service
launchctl start com.isp-snitch.monitor

echo "Data restored from: $BACKUP_FILE"
```

## Network Integration

### Network Interface Detection
- Automatic detection of active network interfaces
- Support for WiFi, Ethernet, and other interface types
- Interface change detection and logging
- Fallback to default interface if detection fails

### Network Testing Integration
- Integration with system ping command
- Integration with curl for HTTP testing
- Integration with dig for DNS testing
- Integration with speedtest-cli for bandwidth testing

### Network Accessibility
- Web interface accessible via localhost
- Web interface accessible via .local addresses
- No external network exposure
- Local network access only

## Performance Integration

### System Performance Monitoring
- CPU usage tracking
- Memory usage tracking
- Network interface status monitoring
- Battery level monitoring (on laptops)

### Performance Optimization
- Efficient async/await patterns
- Minimal resource usage
- Background operation optimization
- Power management integration

### Performance Reporting
- Real-time performance metrics
- Historical performance data
- Performance trend analysis
- Resource usage alerts
