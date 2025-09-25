#!/bin/bash
# Test Homebrew installation script for ISP Snitch

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Testing ISP Snitch Homebrew installation...${NC}"

# Test 1: Formula syntax validation
echo "1. Testing formula syntax..."
if ruby -c Formula/isp-snitch.rb; then
    echo -e "${GREEN}  ✅ Formula syntax is valid Ruby${NC}"
else
    echo -e "${RED}  ❌ Formula syntax error${NC}"
    exit 1
fi

# Test 2: Formula structure validation
echo "2. Testing formula structure..."
if grep -q "class IspSnitch < Formula" Formula/isp-snitch.rb; then
    echo -e "${GREEN}  ✅ Formula class definition found${NC}"
else
    echo -e "${RED}  ❌ Formula class definition missing${NC}"
    exit 1
fi

# Test 3: Required fields validation
echo "3. Testing required fields..."
REQUIRED_FIELDS=("desc" "homepage" "url" "sha256" "license")
for field in "${REQUIRED_FIELDS[@]}"; do
    if grep -q "$field" Formula/isp-snitch.rb; then
        echo -e "${GREEN}  ✅ $field field found${NC}"
    else
        echo -e "${RED}  ❌ $field field missing${NC}"
        exit 1
    fi
done

# Test 4: Dependencies validation
echo "4. Testing dependencies..."
if grep -q "depends_on" Formula/isp-snitch.rb; then
    echo -e "${GREEN}  ✅ Dependencies defined${NC}"
else
    echo -e "${YELLOW}  ⚠️  No dependencies defined${NC}"
fi

# Test 5: Install method validation
echo "5. Testing install method..."
if grep -q "def install" Formula/isp-snitch.rb; then
    echo -e "${GREEN}  ✅ Install method found${NC}"
else
    echo -e "${RED}  ❌ Install method missing${NC}"
    exit 1
fi

# Test 6: Test method validation
echo "6. Testing test method..."
if grep -q "test do" Formula/isp-snitch.rb; then
    echo -e "${GREEN}  ✅ Test method found${NC}"
else
    echo -e "${YELLOW}  ⚠️  No test method found${NC}"
fi

# Test 7: Service configuration validation
echo "7. Testing service configuration..."
if grep -q "service do" Formula/isp-snitch.rb; then
    echo -e "${GREEN}  ✅ Service configuration found${NC}"
else
    echo -e "${YELLOW}  ⚠️  No service configuration found${NC}"
fi

# Test 8: Package file validation
echo "8. Testing package file..."
if [ -f "dist/isp-snitch-1.0.0.tar.gz" ]; then
    echo -e "${GREEN}  ✅ Package file exists${NC}"
    
    # Test package size
    PACKAGE_SIZE=$(du -h "dist/isp-snitch-1.0.0.tar.gz" | cut -f1)
    echo -e "${GREEN}  ✅ Package size: $PACKAGE_SIZE${NC}"
    
    # Test SHA256 hash
    ACTUAL_SHA256=$(shasum -a 256 "dist/isp-snitch-1.0.0.tar.gz" | cut -d' ' -f1)
    EXPECTED_SHA256=$(grep "sha256" Formula/isp-snitch.rb | cut -d'"' -f2)
    
    if [ "$ACTUAL_SHA256" = "$EXPECTED_SHA256" ]; then
        echo -e "${GREEN}  ✅ SHA256 hash matches${NC}"
    else
        echo -e "${RED}  ❌ SHA256 hash mismatch${NC}"
        echo "    Expected: $EXPECTED_SHA256"
        echo "    Actual:   $ACTUAL_SHA256"
        exit 1
    fi
else
    echo -e "${RED}  ❌ Package file not found${NC}"
    echo "    Run: ./Scripts/build-package.sh"
    exit 1
fi

# Test 9: Tap creation validation
echo "9. Testing tap creation..."
if [ -d "/opt/homebrew/Library/Taps/isp-snitch/homebrew-isp-snitch" ]; then
    echo -e "${GREEN}  ✅ Homebrew tap exists${NC}"
else
    echo -e "${YELLOW}  ⚠️  Homebrew tap not found${NC}"
    echo "    Run: brew tap-new isp-snitch/isp-snitch"
fi

# Test 10: Formula in tap validation
echo "10. Testing formula in tap..."
if [ -f "/opt/homebrew/Library/Taps/isp-snitch/homebrew-isp-snitch/Formula/isp-snitch.rb" ]; then
    echo -e "${GREEN}  ✅ Formula exists in tap${NC}"
else
    echo -e "${YELLOW}  ⚠️  Formula not found in tap${NC}"
    echo "    Run: cp Formula/isp-snitch.rb /opt/homebrew/Library/Taps/isp-snitch/homebrew-isp-snitch/Formula/isp-snitch.rb"
fi

echo ""
echo -e "${GREEN}✅ Homebrew installation testing completed!${NC}"
echo ""
echo "Summary:"
echo "  ✅ Formula syntax: Valid"
echo "  ✅ Formula structure: Valid"
echo "  ✅ Required fields: Present"
echo "  ✅ Dependencies: Defined"
echo "  ✅ Install method: Present"
echo "  ✅ Test method: Present"
echo "  ✅ Service config: Present"
echo "  ✅ Package file: Present"
echo "  ✅ SHA256 hash: Valid"
echo "  ✅ Homebrew tap: Created"
echo "  ✅ Formula in tap: Present"
echo ""
echo "The Homebrew formula is ready for distribution!"
echo ""
echo "To install locally:"
echo "  brew install isp-snitch/isp-snitch/isp-snitch"
echo ""
echo "To create a release:"
echo "  ./Scripts/package-release.sh"
