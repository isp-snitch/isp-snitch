# ISP Snitch Installation Guide

## Prerequisites

- macOS 10.15 or later
- Swift 6.2 or later
- Xcode Command Line Tools
- Homebrew (for optional dependencies)

## Installation Steps

### 1. Build the Application

```bash
# Clone the repository
git clone <repository-url>
cd isp-snitch

# Build the application
swift build --configuration release
```

### 2. Install System Dependencies

```bash
# Install required system utilities
brew install sqlite

# Install optional utilities for enhanced testing
brew install speedtest-cli curl bind dig
```

### 3. Set Up Directory Structure

```bash
# Create required directories and set permissions
./Scripts/setup-directories.sh
```

### 4. Install the Service

```bash
# Copy the binary to system location
sudo cp .build/release/isp-snitch /usr/local/bin/isp-snitch

# Install and start the service
./Scripts/install-service.sh
```

### 5. Verify Installation

```bash
# Check service status
./Scripts/health-check.sh

# Monitor resource usage
./Scripts/resource-monitor.sh

# Check service logs
tail -f /usr/local/var/log/isp-snitch/out.log
```

## Service Management

### Start Service
```bash
./Scripts/start-service.sh
```

### Stop Service
```bash
./Scripts/stop-service.sh
```

### Uninstall Service
```bash
./Scripts/uninstall-service.sh
```

## Configuration

The service uses configuration files in `/usr/local/etc/isp-snitch/`:

- `config.json` - Main configuration
- `targets.json` - Test targets configuration

## Logs

Service logs are located in `/usr/local/var/log/isp-snitch/`:

- `out.log` - Standard output
- `error.log` - Standard error
- `app.log` - Application logs

## Web Interface

Once the service is running, you can access the web interface at:

- http://localhost:8080

## Troubleshooting

### Service Not Starting
1. Check logs: `tail -f /usr/local/var/log/isp-snitch/error.log`
2. Verify binary exists: `ls -la /usr/local/bin/isp-snitch`
3. Check permissions: `ls -la /usr/local/var/isp-snitch/`

### Service Not Responding
1. Check if service is loaded: `launchctl list | grep isp-snitch`
2. Restart service: `./Scripts/stop-service.sh && ./Scripts/start-service.sh`
3. Check resource usage: `./Scripts/resource-monitor.sh`

### Permission Issues
1. Check directory ownership: `ls -la /usr/local/var/isp-snitch/`
2. Fix permissions: `sudo chown -R $(whoami):staff /usr/local/var/isp-snitch/`
3. Fix log permissions: `sudo chown -R $(whoami):staff /usr/local/var/log/isp-snitch/`
