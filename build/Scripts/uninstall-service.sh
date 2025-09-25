#!/bin/bash
# Uninstall ISP Snitch service script

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
ETC_DIR="/usr/local/etc/isp-snitch"
VAR_DIR="/usr/local/var/isp-snitch"
LOG_DIR="/usr/local/var/log/isp-snitch"

echo -e "${YELLOW}Uninstalling ISP Snitch service...${NC}"

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}Error: Do not run this script as root. Run as your regular user.${NC}"
   exit 1
fi

# Stop the service if running
if launchctl list | grep -q "$SERVICE_NAME"; then
    echo "Stopping service..."
    launchctl stop "$SERVICE_NAME"
    sleep 1
fi

# Unload the service
if [ -f "$LAUNCH_AGENTS_DIR/$PLIST_FILE" ]; then
    echo "Unloading service..."
    launchctl unload "$LAUNCH_AGENTS_DIR/$PLIST_FILE"
fi

# Remove the plist file
if [ -f "$LAUNCH_AGENTS_DIR/$PLIST_FILE" ]; then
    echo "Removing LaunchAgent plist..."
    rm "$LAUNCH_AGENTS_DIR/$PLIST_FILE"
fi

# Ask user if they want to remove data and configuration
echo ""
echo -e "${YELLOW}Do you want to remove all data and configuration files?${NC}"
echo "This will delete:"
echo "  - Configuration: $ETC_DIR"
echo "  - Data: $VAR_DIR"
echo "  - Logs: $LOG_DIR"
echo ""
read -p "Remove all data? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Removing data and configuration..."
    
    # Remove configuration
    if [ -d "$ETC_DIR" ]; then
        sudo rm -rf "$ETC_DIR"
        echo "  ✅ Removed configuration directory"
    fi
    
    # Remove data directory
    if [ -d "$VAR_DIR" ]; then
        sudo rm -rf "$VAR_DIR"
        echo "  ✅ Removed data directory"
    fi
    
    # Remove log directory
    if [ -d "$LOG_DIR" ]; then
        sudo rm -rf "$LOG_DIR"
        echo "  ✅ Removed log directory"
    fi
else
    echo "Keeping data and configuration files."
    echo "To remove them manually later:"
    echo "  sudo rm -rf $ETC_DIR"
    echo "  sudo rm -rf $VAR_DIR"
    echo "  sudo rm -rf $LOG_DIR"
fi

# Check if service is still running
if launchctl list | grep -q "$SERVICE_NAME"; then
    echo -e "${RED}❌ Service is still running${NC}"
    echo "You may need to restart your computer to fully stop the service."
else
    echo -e "${GREEN}✅ ISP Snitch service uninstalled successfully!${NC}"
fi

echo ""
echo "Note: The ISP Snitch binary at /usr/local/bin/isp-snitch is still installed."
echo "To remove it, run: sudo rm /usr/local/bin/isp-snitch"
