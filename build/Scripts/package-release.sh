#!/bin/bash
# Package release script for ISP Snitch

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PACKAGE_NAME="isp-snitch"
VERSION="1.0.0"
DIST_DIR="dist"
FORMULA_DIR="Formula"
RELEASE_DIR="releases"

echo -e "${GREEN}Creating ISP Snitch release package...${NC}"

# Check if build exists
if [ ! -d "$DIST_DIR" ]; then
    echo "Build directory not found. Running build script..."
    ./Scripts/build-package.sh
fi

# Create release directory
echo "Creating release directory..."
rm -rf "$RELEASE_DIR"
mkdir -p "$RELEASE_DIR"

# Copy distribution files
echo "Copying distribution files..."
cp "$DIST_DIR"/*.tar.gz "$RELEASE_DIR/" 2>/dev/null || true

# Copy formula
cp "$FORMULA_DIR/isp-snitch.rb" "$RELEASE_DIR/"

# Create release notes
echo "Creating release notes..."
cat > "$RELEASE_DIR/RELEASE_NOTES.md" << EOF
# ISP Snitch v$VERSION Release Notes

## What's New

- Initial release of ISP Snitch
- Complete macOS system integration
- Homebrew package distribution
- Comprehensive service management
- Web interface and CLI tools

## Installation

### Via Homebrew (Recommended)

\`\`\`bash
# Install from local formula
brew install --build-from-source ./isp-snitch.rb

# Start the service
brew services start isp-snitch

# Check service status
brew services list | grep isp-snitch
\`\`\`

### Manual Installation

\`\`\`bash
# Extract the package
tar -xzf isp-snitch-$VERSION.tar.gz

# Run installation script
./Scripts/install-service.sh
\`\`\`

## Features

- **Network Monitoring**: Ping, HTTP, DNS, and speedtest monitoring
- **Web Interface**: Real-time dashboard at http://localhost:8080
- **CLI Tools**: Comprehensive command-line interface
- **Service Management**: Automatic startup and service management
- **Data Storage**: SQLite database with data retention
- **Logging**: Comprehensive logging and monitoring

## Service Management

\`\`\`bash
# Start service
brew services start isp-snitch

# Stop service
brew services stop isp-snitch

# Restart service
brew services restart isp-snitch

# Check status
brew services list | grep isp-snitch
\`\`\`

## Configuration

Configuration files are located in \`/usr/local/etc/isp-snitch/\`:

- \`config.json\` - Main configuration
- \`targets.json\` - Test targets configuration

## Logs

Service logs are located in \`/usr/local/var/log/isp-snitch/\`:

- \`out.log\` - Standard output
- \`error.log\` - Standard error
- \`app.log\` - Application logs

## Web Interface

Once the service is running, access the web interface at:

- http://localhost:8080

## CLI Usage

\`\`\`bash
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
\`\`\`

## Troubleshooting

### Service Not Starting

1. Check logs: \`tail -f /usr/local/var/log/isp-snitch/error.log\`
2. Verify installation: \`brew services list | grep isp-snitch\`
3. Restart service: \`brew services restart isp-snitch\`

### Web Interface Not Accessible

1. Check if service is running: \`brew services list | grep isp-snitch\`
2. Check port 8080: \`lsof -i :8080\`
3. Check firewall settings

### Permission Issues

1. Check directory ownership: \`ls -la /usr/local/var/isp-snitch/\`
2. Fix permissions: \`sudo chown -R \$(whoami):staff /usr/local/var/isp-snitch/\`

## Uninstallation

\`\`\`bash
# Stop and uninstall service
brew services stop isp-snitch
brew uninstall isp-snitch
\`\`\`

## Support

For issues and support, please check the logs and configuration files.
EOF

# Create installation guide
echo "Creating installation guide..."
cat > "$RELEASE_DIR/INSTALL.md" << EOF
# ISP Snitch Installation Guide

## Prerequisites

- macOS 10.15 or later
- Homebrew installed
- Xcode Command Line Tools

## Quick Installation

\`\`\`bash
# Install ISP Snitch
brew install --build-from-source ./isp-snitch.rb

# Start the service
brew services start isp-snitch

# Access web interface
open http://localhost:8080
\`\`\`

## Manual Installation

If you prefer manual installation:

\`\`\`bash
# Extract the package
tar -xzf isp-snitch-$VERSION.tar.gz

# Set up directories
./Scripts/setup-directories.sh

# Install service
./Scripts/install-service.sh
\`\`\`

## Verification

After installation, verify the service is running:

\`\`\`bash
# Check service status
brew services list | grep isp-snitch

# Check web interface
curl http://localhost:8080/api/health

# Check logs
tail -f /usr/local/var/log/isp-snitch/out.log
\`\`\`

## Configuration

Edit configuration files in \`/usr/local/etc/isp-snitch/\`:

- \`config.json\` - Main configuration
- \`targets.json\` - Test targets

## Service Management

\`\`\`bash
# Start service
brew services start isp-snitch

# Stop service
brew services stop isp-snitch

# Restart service
brew services restart isp-snitch

# Check status
brew services list | grep isp-snitch
\`\`\`

## Uninstallation

\`\`\`bash
# Stop and remove service
brew services stop isp-snitch
brew uninstall isp-snitch
\`\`\`
EOF

# Create checksums
echo "Creating checksums..."
cd "$RELEASE_DIR"
if [ -f "isp-snitch-$VERSION.tar.gz" ]; then
    shasum -a 256 "isp-snitch-$VERSION.tar.gz" > "isp-snitch-$VERSION.tar.gz.sha256"
    echo "SHA256 checksum created"
fi
cd ..

# Create release summary
echo "Creating release summary..."
cat > "$RELEASE_DIR/RELEASE_SUMMARY.md" << EOF
# ISP Snitch v$VERSION Release Summary

## Package Contents

- \`isp-snitch-$VERSION.tar.gz\` - Source package
- \`isp-snitch.rb\` - Homebrew formula
- \`RELEASE_NOTES.md\` - Release notes
- \`INSTALL.md\` - Installation guide
- \`isp-snitch-$VERSION.tar.gz.sha256\` - SHA256 checksum

## Installation Methods

1. **Homebrew (Recommended)**: \`brew install --build-from-source ./isp-snitch.rb\`
2. **Manual**: Extract tar.gz and run installation scripts

## Features Included

- Complete macOS system integration
- Homebrew package distribution
- Service management scripts
- Web interface and CLI tools
- Comprehensive documentation

## Next Steps

1. Test the package: \`./Scripts/test-package.sh\`
2. Install locally: \`brew install --build-from-source ./isp-snitch.rb\`
3. Verify installation: \`brew services list | grep isp-snitch\`
4. Access web interface: http://localhost:8080

## Support

Check the logs and configuration files for troubleshooting.
EOF

echo -e "${GREEN}✅ Release package created successfully!${NC}"
echo ""
echo "Release contents:"
echo "  📦 Package: $RELEASE_DIR/isp-snitch-$VERSION.tar.gz"
echo "  🍺 Formula: $RELEASE_DIR/isp-snitch.rb"
echo "  📋 Release Notes: $RELEASE_DIR/RELEASE_NOTES.md"
echo "  📖 Install Guide: $RELEASE_DIR/INSTALL.md"
echo "  📊 Summary: $RELEASE_DIR/RELEASE_SUMMARY.md"
echo "  🔐 Checksum: $RELEASE_DIR/isp-snitch-$VERSION.tar.gz.sha256"
echo ""
echo "To test the release:"
echo "  ./Scripts/test-package.sh"
echo ""
echo "To install locally:"
echo "  brew install --build-from-source ./$RELEASE_DIR/isp-snitch.rb"
echo ""
echo "To distribute:"
echo "  Upload the contents of $RELEASE_DIR/ to your distribution platform"
