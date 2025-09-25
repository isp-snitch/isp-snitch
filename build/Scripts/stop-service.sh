#!/bin/bash
# Stop ISP Snitch service script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SERVICE_NAME="com.isp-snitch.monitor"

echo -e "${YELLOW}Stopping ISP Snitch service...${NC}"

# Check if service is running
if ! launchctl list | grep -q "$SERVICE_NAME"; then
    echo -e "${YELLOW}Service is not running${NC}"
    exit 0
fi

# Stop the service
echo "Stopping service..."
launchctl stop "$SERVICE_NAME"

# Wait a moment for service to stop
sleep 2

# Check if service stopped successfully
if ! launchctl list | grep -q "$SERVICE_NAME"; then
    echo -e "${GREEN}✅ ISP Snitch service stopped successfully!${NC}"
else
    echo -e "${RED}❌ Failed to stop service${NC}"
    echo "The service may still be running. You may need to force stop it:"
    echo "  launchctl kill -TERM $SERVICE_NAME"
    exit 1
fi
