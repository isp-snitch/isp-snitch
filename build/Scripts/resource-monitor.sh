#!/bin/bash
# Resource monitoring script for ISP Snitch

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SERVICE_NAME="com.isp-snitch.monitor"
CPU_LIMIT=5.0
MEMORY_LIMIT_MB=100

echo "Monitoring ISP Snitch resource usage..."

# Get process ID
PID=$(pgrep -f "isp-snitch" | head -1)

if [ -z "$PID" ]; then
    echo -e "${RED}❌ ISP Snitch process not found${NC}"
    exit 1
fi

echo "Process ID: $PID"

# Get resource usage
CPU_USAGE=$(ps -p $PID -o %cpu= | tr -d ' ')
MEMORY_USAGE=$(ps -p $PID -o %mem= | tr -d ' ')
MEMORY_KB=$(ps -p $PID -o rss= | tr -d ' ')
MEMORY_MB=$((MEMORY_KB / 1024))

echo "CPU Usage: ${CPU_USAGE}%"
echo "Memory Usage: ${MEMORY_USAGE}% (${MEMORY_MB}MB)"

# Check CPU usage
if (( $(echo "$CPU_USAGE > $CPU_LIMIT" | bc -l 2>/dev/null || echo "0") )); then
    echo -e "${YELLOW}⚠️  WARNING: CPU usage exceeds ${CPU_LIMIT}%${NC}"
else
    echo -e "${GREEN}✅ CPU usage is within limits${NC}"
fi

# Check memory usage
if [ $MEMORY_MB -gt $MEMORY_LIMIT_MB ]; then
    echo -e "${YELLOW}⚠️  WARNING: Memory usage exceeds ${MEMORY_LIMIT_MB}MB${NC}"
else
    echo -e "${GREEN}✅ Memory usage is within limits${NC}"
fi

# Get additional process information
echo ""
echo "Process details:"
ps -p $PID -o pid,ppid,user,start,time,command

# Check if service is healthy
if launchctl list | grep -q "$SERVICE_NAME"; then
    echo -e "${GREEN}✅ Service is loaded in LaunchAgent${NC}"
else
    echo -e "${RED}❌ Service is not loaded in LaunchAgent${NC}"
fi
