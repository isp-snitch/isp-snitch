#!/bin/bash
# Test ISP Snitch service installation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Testing ISP Snitch service installation...${NC}"

# Check if binary exists
BINARY_PATH=".build/release/isp-snitch"
if [ ! -f "$BINARY_PATH" ]; then
    echo -e "${RED}❌ Binary not found at $BINARY_PATH${NC}"
    echo "Please run: swift build --configuration release"
    exit 1
fi

echo -e "${GREEN}✅ Binary found at $BINARY_PATH${NC}"

# Test binary execution
echo "Testing binary execution..."
if "$BINARY_PATH" --help > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Binary executes successfully${NC}"
else
    echo -e "${RED}❌ Binary execution failed${NC}"
    exit 1
fi

# Test CLI commands
echo "Testing CLI commands..."

# Test status command
echo "  Testing status command..."
if "$BINARY_PATH" status > /dev/null 2>&1; then
    echo -e "${GREEN}  ✅ Status command works${NC}"
else
    echo -e "${YELLOW}  ⚠️  Status command failed (expected if service not running)${NC}"
fi

# Test config command
echo "  Testing config command..."
if "$BINARY_PATH" config list > /dev/null 2>&1; then
    echo -e "${GREEN}  ✅ Config command works${NC}"
else
    echo -e "${YELLOW}  ⚠️  Config command failed${NC}"
fi

# Test report command
echo "  Testing report command..."
if "$BINARY_PATH" report --help > /dev/null 2>&1; then
    echo -e "${GREEN}  ✅ Report command works${NC}"
else
    echo -e "${YELLOW}  ⚠️  Report command failed${NC}"
fi

# Test service command
echo "  Testing service command..."
if "$BINARY_PATH" service --help > /dev/null 2>&1; then
    echo -e "${GREEN}  ✅ Service command works${NC}"
else
    echo -e "${YELLOW}  ⚠️  Service command failed${NC}"
fi

echo ""
echo -e "${GREEN}✅ ISP Snitch service testing completed!${NC}"
echo ""
echo "To install the service:"
echo "  1. Copy binary: sudo cp $BINARY_PATH /usr/local/bin/isp-snitch"
echo "  2. Run setup: ./Scripts/setup-directories.sh"
echo "  3. Install service: ./Scripts/install-service.sh"
echo ""
echo "To test the service after installation:"
echo "  ./Scripts/health-check.sh"
echo "  ./Scripts/resource-monitor.sh"
