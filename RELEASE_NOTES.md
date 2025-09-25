# ISP Snitch v1.0.0

## What's New

- Initial release of ISP Snitch
- Complete macOS system integration
- Homebrew package distribution
- Comprehensive service management
- Web interface and CLI tools

## Installation

### Via Homebrew (Recommended)

```bash
# Install from GitHub
brew install isp-snitch/isp-snitch/isp-snitch

# Start the service
brew services start isp-snitch

# Check service status
brew services list | grep isp-snitch
```

### Manual Installation

```bash
# Clone the repository
git clone https://github.com/isp-snitch/isp-snitch.git
cd isp-snitch

# Build the application
swift build --configuration release

# Install the service
./Scripts/install-service.sh
```

## Features

- **Network Monitoring**: Ping, HTTP, DNS, and speedtest monitoring
- **Web Interface**: Real-time dashboard at http://localhost:8080
- **CLI Tools**: Comprehensive command-line interface
- **Service Management**: Automatic startup and service management
- **Data Storage**: SQLite database with data retention
- **Logging**: Comprehensive logging and monitoring

## Service Management

```bash
# Start service
brew services start isp-snitch

# Stop service
brew services stop isp-snitch

# Restart service
brew services restart isp-snitch

# Check status
brew services list | grep isp-snitch
```

## Configuration

Configuration files are located in `/usr/local/etc/isp-snitch/`:

- `config.json` - Main configuration
- `targets.json` - Test targets configuration

## Logs

Service logs are located in `/usr/local/var/log/isp-snitch/`:

- `out.log` - Standard output
- `error.log` - Standard error
- `app.log` - Application logs

## Web Interface

Once the service is running, access the web interface at:

- http://localhost:8080

## CLI Usage

```bash
# Check service status
isp-snitch status

# View reports
isp-snitch report

# Configure settings
isp-snitch config list
isp-snitch config set monitoring.interval 300

# Service management
isp-snitch service start
isp-snitch service stop
isp-snitch service status
```

## Troubleshooting

### Service Not Starting

1. Check logs: `tail -f /usr/local/var/log/isp-snitch/error.log`
2. Verify installation: `brew services list | grep isp-snitch`
3. Restart service: `brew services restart isp-snitch`

### Web Interface Not Accessible

1. Check if service is running: `brew services list | grep isp-snitch`
2. Check port 8080: `lsof -i :8080`
3. Check firewall settings

### Permission Issues

1. Check directory ownership: `ls -la /usr/local/var/isp-snitch/`
2. Fix permissions: `sudo chown -R $(whoami):staff /usr/local/var/isp-snitch/`

## Uninstallation

```bash
# Stop and uninstall service
brew services stop isp-snitch
brew uninstall isp-snitch
```

## Support

For issues and support, please check the logs and configuration files.
