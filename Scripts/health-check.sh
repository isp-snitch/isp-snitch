#!/bin/bash
# Health check script for ISP Snitch service

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
HEALTH_URL="http://localhost:8080/api/health"
TIMEOUT=5
SERVICE_NAME="com.isp-snitch.monitor"

echo "Checking ISP Snitch service health..."

# Check if service is loaded
if ! launchctl list | grep -q "$SERVICE_NAME"; then
    echo -e "${RED}❌ Service is not loaded${NC}"
    exit 1
fi

# Check if service is running
if ! launchctl list | grep "$SERVICE_NAME" | grep -q "running"; then
    echo -e "${RED}❌ Service is not running${NC}"
    exit 1
fi

# Check if web interface is responding
if curl -s --max-time $TIMEOUT "$HEALTH_URL" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Service is healthy${NC}"
    
    # Get detailed health information
    echo ""
    echo "Health details:"
    curl -s --max-time $TIMEOUT "$HEALTH_URL" | python3 -m json.tool 2>/dev/null || echo "Health endpoint responded but JSON parsing failed"
    
    exit 0
else
    echo -e "${RED}❌ Service is not responding to health checks${NC}"
    echo "Service may be starting up or there may be an issue."
    echo ""
    echo "Check logs for details:"
    echo "  tail -f /usr/local/var/log/isp-snitch/error.log"
    exit 1
fi
