# ISP Snitch

A lightweight ISP service monitor for macOS that tracks network connectivity, performance, and service quality.

## Features

- **Network Monitoring**: Ping, HTTP, DNS, and speedtest monitoring
- **Web Interface**: Real-time dashboard at http://localhost:8080
- **CLI Tools**: Comprehensive command-line interface
- **Service Management**: Automatic startup and service management
- **Data Storage**: SQLite database with data retention
- **Logging**: Comprehensive logging and monitoring
- **Quality Monitoring**: Documentation quality metrics and monitoring
- **Performance Tracking**: System performance and resource monitoring

## Quick Start

### Installation via Homebrew (Recommended)

```bash
# Install ISP Snitch
brew install isp-snitch/isp-snitch/isp-snitch

# Start the service
brew services start isp-snitch

# Access web interface
open http://localhost:8080
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

## Usage

### CLI Commands

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

# Quality monitoring
isp-snitch quality check
```

### Web Interface

Once the service is running, access the web interface at:

- **Dashboard**: http://localhost:8080
- **API Status**: http://localhost:8080/api/status
- **Health Check**: http://localhost:8080/api/health
- **Metrics**: http://localhost:8080/api/metrics

## Quality Monitoring

ISP Snitch includes comprehensive quality monitoring capabilities to track documentation quality, API coverage, and system performance.

### Quality Metrics

The quality monitoring system provides:

- **Documentation Coverage**: Tracks percentage of documented public APIs
- **Quality Scoring**: Assigns quality scores based on documentation completeness
- **Performance Metrics**: Monitors generation time, memory usage, and CPU usage
- **Trend Analysis**: Tracks quality trends over time
- **Alert System**: Configurable alerts for quality degradation

### Quality Commands

```bash
# Check current documentation quality
isp-snitch quality check

# Generate quality report
isp-snitch quality check --format json

# View quality metrics
isp-snitch quality check --format text
```

### Quality Configuration

Quality monitoring can be configured through the main configuration file:

```json
{
  "quality": {
    "enabled": true,
    "minimum_coverage": 0.8,
    "minimum_quality_score": 70,
    "documentation_directory": "Sources",
    "excluded_files": [],
    "excluded_api_prefixes": ["private", "fileprivate"]
  }
}
```

## Configuration

Configuration files are located in `/usr/local/etc/isp-snitch/`:

- `config.json` - Main configuration
- `targets.json` - Test targets configuration

### Example Configuration

```json
{
  "monitoring": {
    "enabled": true,
    "interval": 300,
    "tests": ["ping", "http", "dns", "speedtest"]
  },
  "web": {
    "enabled": true,
    "port": 8080,
    "host": "localhost"
  },
  "database": {
    "path": "/usr/local/var/isp-snitch/data/connectivity.db",
    "retention_days": 30
  }
}
```

## Service Management

### Homebrew Services

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

### Manual Service Management

```bash
# Start service
./Scripts/start-service.sh

# Stop service
./Scripts/stop-service.sh

# Check health
./Scripts/health-check.sh

# Monitor resources
./Scripts/resource-monitor.sh
```

## Logs

Service logs are located in `/usr/local/var/log/isp-snitch/`:

- `out.log` - Standard output
- `error.log` - Standard error
- `app.log` - Application logs

## Development

### Prerequisites

- macOS 10.15 or later
- Swift 6.0 or later
- Xcode Command Line Tools

### Building

```bash
# Clone the repository
git clone https://github.com/isp-snitch/isp-snitch.git
cd isp-snitch

# Build the application
swift build --configuration release

# Run tests
swift test

# Run the application
swift run isp-snitch
```

### Project Structure

```
ISP Snitch/
├── Sources/
│   ├── ISPSnitchCLI/          # CLI interface
│   ├── ISPSnitchCore/         # Core library
│   └── ISPSnitchWeb/          # Web interface
├── Tests/                     # Test suite
├── Scripts/                   # Management scripts
├── Resources/                 # LaunchAgent configuration
├── Formula/                   # Homebrew formula
└── README.md                  # This file
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

### Homebrew

```bash
# Stop and uninstall service
brew services stop isp-snitch
brew uninstall isp-snitch
```

### Manual

```bash
# Stop and uninstall service
./Scripts/uninstall-service.sh
```

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes
4. Run tests: `swift test`
5. Commit your changes: `git commit -am 'Add feature'`
6. Push to the branch: `git push origin feature-name`
7. Create a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For issues and support, please check the logs and configuration files, or open an issue on GitHub.

## Changelog

### v1.1.0

- **Quality Monitoring**: Added comprehensive documentation quality monitoring
- **Performance Tracking**: System performance and resource monitoring
- **Quality Metrics**: Documentation coverage and quality scoring
- **Quality CLI**: New `quality check` command for monitoring
- **Quality Configuration**: Configurable quality thresholds and settings
- **Quality Reports**: JSON and text format quality reports
- **Quality Alerts**: Configurable alerts for quality degradation

### v1.0.0

- Initial release
- Complete macOS system integration
- Homebrew package distribution
- Web interface and CLI tools
- Service management and monitoring
- SQLite database with data retention
- Comprehensive logging and health checks
