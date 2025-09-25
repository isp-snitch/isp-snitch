# ISP Snitch

A lightweight ISP service monitor for macOS that tracks network connectivity and performance from your local Mac.

## Features

- **Continuous Monitoring**: Automatically tests network connectivity using ping, HTTP, DNS, and bandwidth tests
- **Accurate Reporting**: Scientific measurement approach with detailed connectivity data
- **Multi-Access Interface**: Both CLI and web interfaces for data visualization
- **Local Data Storage**: All data remains on your machine with configurable retention
- **Minimal Resource Usage**: < 1% CPU, < 50MB memory, < 1KB/s network overhead
- **Automatic Startup**: Integrates with macOS LaunchAgent for automatic operation
- **Homebrew Integration**: Easy installation and management via Homebrew

## Quick Start

### Installation

```bash
# Install via Homebrew (recommended)
brew install isp-snitch

# Start the service
brew services start isp-snitch
```

### Basic Usage

```bash
# Check service status
isp-snitch status

# Generate a report
isp-snitch report --days 7

# View web interface
open http://localhost:8080
```

## Technology Stack

- **Swift 6.2+**: Modern Swift with enhanced concurrency
- **Swift Package Manager**: Apple's official package management
- **SwiftNIO**: High-performance HTTP server
- **SQLite.swift**: Type-safe local data storage
- **ArgumentParser**: CLI interface
- **System Utilities**: ping, curl, dig, speedtest-cli

## Requirements

- macOS 12.0 or later
- Homebrew package manager
- Internet connection for initial setup

## Documentation

- [Quick Start Guide](docs/QUICKSTART.md)
- [CLI Reference](docs/CLI.md)
- [API Documentation](docs/API.md)
- [Configuration Guide](docs/CONFIG.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT License - see [LICENSE](LICENSE) for details.

## Support

- [GitHub Issues](https://github.com/isp-snitch/isp-snitch/issues)
- [GitHub Discussions](https://github.com/isp-snitch/isp-snitch/discussions)
- [Discord Server](https://discord.gg/isp-snitch)
