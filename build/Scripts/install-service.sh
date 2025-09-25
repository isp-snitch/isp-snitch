#!/bin/bash
# Install ISP Snitch service script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SERVICE_NAME="com.isp-snitch.monitor"
PLIST_FILE="com.isp-snitch.monitor.plist"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
RESOURCES_DIR="$(dirname "$0")/../Resources"
BIN_DIR="/usr/local/bin"
ETC_DIR="/usr/local/etc/isp-snitch"
VAR_DIR="/usr/local/var/isp-snitch"
LOG_DIR="/usr/local/var/log/isp-snitch"

echo -e "${GREEN}Installing ISP Snitch service...${NC}"

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}Error: Do not run this script as root. Run as your regular user.${NC}"
   exit 1
fi

# Check if isp-snitch binary exists
if [ ! -f "$BIN_DIR/isp-snitch" ]; then
    echo -e "${RED}Error: ISP Snitch binary not found at $BIN_DIR/isp-snitch${NC}"
    echo "Please install the binary first using: swift build --configuration release"
    echo "Then copy the binary to $BIN_DIR/"
    exit 1
fi

# Create directories
echo "Creating directories..."
sudo mkdir -p "$ETC_DIR"
sudo mkdir -p "$VAR_DIR/data"
sudo mkdir -p "$VAR_DIR/logs"
sudo mkdir -p "$LOG_DIR"
sudo mkdir -p "$LAUNCH_AGENTS_DIR"

# Set permissions
echo "Setting permissions..."
sudo chown -R "$(whoami):staff" "$ETC_DIR"
sudo chown -R "$(whoami):staff" "$VAR_DIR"
sudo chown -R "$(whoami):staff" "$LOG_DIR"

# Copy LaunchAgent plist
echo "Installing LaunchAgent..."
cp "$RESOURCES_DIR/$PLIST_FILE" "$LAUNCH_AGENTS_DIR/"

# Set permissions on plist
chmod 644 "$LAUNCH_AGENTS_DIR/$PLIST_FILE"

# Create default configuration if it doesn't exist
if [ ! -f "$ETC_DIR/config.json" ]; then
    echo "Creating default configuration..."
    cat > "$ETC_DIR/config.json" << 'EOF'
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
  },
  "logging": {
    "level": "INFO",
    "file": "/usr/local/var/log/isp-snitch/app.log"
  }
}
EOF
fi

# Create targets configuration if it doesn't exist
if [ ! -f "$ETC_DIR/targets.json" ]; then
    echo "Creating default targets configuration..."
    cat > "$ETC_DIR/targets.json" << 'EOF'
{
  "ping": [
    "8.8.8.8",
    "1.1.1.1",
    "208.67.222.222"
  ],
  "http": [
    "https://www.google.com",
    "https://www.cloudflare.com",
    "https://httpbin.org/get"
  ],
  "dns": [
    "google.com",
    "cloudflare.com",
    "github.com"
  ]
}
EOF
fi

# Load the service
echo "Loading service..."
launchctl load "$LAUNCH_AGENTS_DIR/$PLIST_FILE"

# Start the service
echo "Starting service..."
launchctl start "$SERVICE_NAME"

# Wait a moment for service to start
sleep 2

# Check if service is running
if launchctl list | grep -q "$SERVICE_NAME"; then
    echo -e "${GREEN}✅ ISP Snitch service installed and started successfully!${NC}"
    echo ""
    echo "Service status:"
    launchctl list | grep "$SERVICE_NAME"
    echo ""
    echo "To check logs:"
    echo "  tail -f $LOG_DIR/out.log"
    echo "  tail -f $LOG_DIR/error.log"
    echo ""
    echo "To stop the service:"
    echo "  launchctl stop $SERVICE_NAME"
    echo ""
    echo "To uninstall the service:"
    echo "  ./Scripts/uninstall-service.sh"
else
    echo -e "${RED}❌ Service installation failed${NC}"
    echo "Check the logs for details:"
    echo "  cat $LOG_DIR/error.log"
    exit 1
fi
