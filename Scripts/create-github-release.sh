#!/bin/bash
# Create GitHub release script for ISP Snitch

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
REPO="isp-snitch/isp-snitch"
VERSION="1.0.0"
TAG="v$VERSION"
BRANCH="main"

echo -e "${GREEN}Creating GitHub release for ISP Snitch...${NC}"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}❌ Not in a git repository${NC}"
    exit 1
fi

# Check if we're on the main branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo -e "${YELLOW}⚠️  Not on main branch (currently on $CURRENT_BRANCH)${NC}"
    echo "Switching to main branch..."
    git checkout main
fi

# Check if there are uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}⚠️  There are uncommitted changes${NC}"
    echo "Please commit or stash your changes before creating a release"
    exit 1
fi

# Check if tag already exists
if git tag -l | grep -q "^$TAG$"; then
    echo -e "${YELLOW}⚠️  Tag $TAG already exists${NC}"
    echo "Deleting existing tag..."
    git tag -d "$TAG"
    git push origin :refs/tags/"$TAG"
fi

# Create and push tag
echo "Creating tag $TAG..."
git tag -a "$TAG" -m "Release $TAG"
git push origin "$TAG"

# Create release notes
echo "Creating release notes..."
cat > RELEASE_NOTES.md << EOF
# ISP Snitch v$VERSION

## What's New

- Initial release of ISP Snitch
- Complete macOS system integration
- Homebrew package distribution
- Comprehensive service management
- Web interface and CLI tools

## Installation

### Via Homebrew (Recommended)

\`\`\`bash
# Install from GitHub
brew install isp-snitch/isp-snitch/isp-snitch

# Start the service
brew services start isp-snitch

# Check service status
brew services list | grep isp-snitch
\`\`\`

### Manual Installation

\`\`\`bash
# Clone the repository
git clone https://github.com/isp-snitch/isp-snitch.git
cd isp-snitch

# Build the application
swift build --configuration release

# Install the service
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

# Create GitHub release using gh CLI
echo "Creating GitHub release..."
if command -v gh > /dev/null 2>&1; then
    gh release create "$TAG" \
        --title "ISP Snitch v$VERSION" \
        --notes-file RELEASE_NOTES.md \
        --target main
    echo -e "${GREEN}✅ GitHub release created successfully!${NC}"
else
    echo -e "${YELLOW}⚠️  GitHub CLI (gh) not found${NC}"
    echo "Please install GitHub CLI and run:"
    echo "  gh release create $TAG --title 'ISP Snitch v$VERSION' --notes-file RELEASE_NOTES.md --target main"
fi

# Get the SHA256 hash of the main branch tarball
echo "Getting SHA256 hash of main branch tarball..."
MAIN_SHA256=$(curl -sL "https://github.com/isp-snitch/isp-snitch/archive/refs/heads/main.tar.gz" | shasum -a 256 | cut -d' ' -f1)
echo "SHA256: $MAIN_SHA256"

# Update the formula with the correct SHA256
echo "Updating formula with correct SHA256..."
sed -i '' "s/placeholder-sha256-will-be-updated/$MAIN_SHA256/" Formula/isp-snitch.rb

# Commit the updated formula
echo "Committing updated formula..."
git add Formula/isp-snitch.rb
git commit -m "Update formula SHA256 for v$VERSION release"
git push origin main

echo -e "${GREEN}✅ GitHub release process completed!${NC}"
echo ""
echo "Release details:"
echo "  🏷️  Tag: $TAG"
echo "  📦 Repository: https://github.com/$REPO"
echo "  🔗 Release: https://github.com/$REPO/releases/tag/$TAG"
echo "  📋 SHA256: $MAIN_SHA256"
echo ""
echo "To install from the release:"
echo "  brew install isp-snitch/isp-snitch/isp-snitch"
echo ""
echo "To update the Homebrew tap:"
echo "  cp Formula/isp-snitch.rb /opt/homebrew/Library/Taps/isp-snitch/homebrew-isp-snitch/Formula/isp-snitch.rb"
