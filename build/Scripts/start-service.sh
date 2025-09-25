#!/bin/bash
# Start ISP Snitch service script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SERVICE_NAME="com.isp-snitch.monitor"

echo -e "${GREEN}Starting ISP Snitch service...${NC}"

# Check if service is already running
if launchctl list | grep -q "$SERVICE_NAME"; then
    echo -e "${YELLOW}Service is already running${NC}"
    echo "Current status:"
    launchctl list | grep "$SERVICE_NAME"
    exit 0
fi

# Start the service
echo "Starting service..."
launchctl start "$SERVICE_NAME"

# Wait a moment for service to start
sleep 2

# Check if service started successfully
if launchctl list | grep -q "$SERVICE_NAME"; then
    echo -e "${GREEN}✅ ISP Snitch service started successfully!${NC}"
    echo ""
    echo "Service status:"
    launchctl list | grep "$SERVICE_NAME"
    echo ""
    echo "To check logs:"
    echo "  tail -f /usr/local/var/log/isp-snitch/out.log"
    echo "  tail -f /usr/local/var/log/isp-snitch/error.log"
else
    echo -e "${RED}❌ Failed to start service${NC}"
    echo "Check the logs for details:"
    echo "  cat /usr/local/var/log/isp-snitch/error.log"
    exit 1
fi
