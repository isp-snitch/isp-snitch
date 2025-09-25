#!/bin/bash
# Setup directory structure for ISP Snitch

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
ETC_DIR="/usr/local/etc/isp-snitch"
VAR_DIR="/usr/local/var/isp-snitch"
LOG_DIR="/usr/local/var/log/isp-snitch"
BIN_DIR="/usr/local/bin"

echo -e "${GREEN}Setting up ISP Snitch directory structure...${NC}"

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}Error: Do not run this script as root. Run as your regular user.${NC}"
   exit 1
fi

# Create directories
echo "Creating directories..."

# Configuration directory
echo "  Creating configuration directory: $ETC_DIR"
sudo mkdir -p "$ETC_DIR"

# Data directory
echo "  Creating data directory: $VAR_DIR"
sudo mkdir -p "$VAR_DIR/data"
sudo mkdir -p "$VAR_DIR/logs"
sudo mkdir -p "$VAR_DIR/backups"
sudo mkdir -p "$VAR_DIR/exports"

# Log directory
echo "  Creating log directory: $LOG_DIR"
sudo mkdir -p "$LOG_DIR"

# Set permissions
echo "Setting permissions..."
sudo chown -R "$(whoami):staff" "$ETC_DIR"
sudo chown -R "$(whoami):staff" "$VAR_DIR"
sudo chown -R "$(whoami):staff" "$LOG_DIR"

# Set directory permissions
chmod 755 "$ETC_DIR"
chmod 755 "$VAR_DIR"
chmod 755 "$VAR_DIR/data"
chmod 755 "$VAR_DIR/logs"
chmod 755 "$VAR_DIR/backups"
chmod 755 "$VAR_DIR/exports"
chmod 755 "$LOG_DIR"

echo -e "${GREEN}✅ Directory structure created successfully!${NC}"
echo ""
echo "Created directories:"
echo "  $ETC_DIR (configuration)"
echo "  $VAR_DIR/data (database)"
echo "  $VAR_DIR/logs (application logs)"
echo "  $VAR_DIR/backups (backup files)"
echo "  $VAR_DIR/exports (export files)"
echo "  $LOG_DIR (system logs)"
echo ""
echo "All directories are owned by $(whoami):staff"
