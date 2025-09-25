#!/bin/bash
# Build package script for ISP Snitch

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PACKAGE_NAME="isp-snitch"
VERSION="1.0.0"
BUILD_DIR="build"
DIST_DIR="dist"
FORMULA_DIR="Formula"

echo -e "${GREEN}Building ISP Snitch package...${NC}"

# Clean previous builds
echo "Cleaning previous builds..."
rm -rf "$BUILD_DIR"
rm -rf "$DIST_DIR"
mkdir -p "$BUILD_DIR"
mkdir -p "$DIST_DIR"

# Build the application
echo "Building application..."
swift build --configuration release

# Verify build
if [ ! -f ".build/release/isp-snitch" ]; then
    echo -e "${RED}❌ Build failed - binary not found${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Application built successfully${NC}"

# Create package structure
echo "Creating package structure..."

# Copy binary
cp ".build/release/isp-snitch" "$BUILD_DIR/"

# Copy configuration files
mkdir -p "$BUILD_DIR/config"
if [ -f "config/config.json" ]; then
    cp "config/config.json" "$BUILD_DIR/config/"
else
    # Create default configuration
    cat > "$BUILD_DIR/config/config.json" << 'EOF'
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

if [ -f "config/targets.json" ]; then
    cp "config/targets.json" "$BUILD_DIR/config/"
else
    # Create default targets configuration
    cat > "$BUILD_DIR/config/targets.json" << 'EOF'
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

# Copy LaunchAgent
cp "Resources/com.isp-snitch.monitor.plist" "$BUILD_DIR/"

# Copy service management scripts
mkdir -p "$BUILD_DIR/Scripts"
cp Scripts/*.sh "$BUILD_DIR/Scripts/"
chmod +x "$BUILD_DIR/Scripts/"*.sh

# Copy documentation
cp "README.md" "$BUILD_DIR/" 2>/dev/null || true
cp "Scripts/install-guide.md" "$BUILD_DIR/" 2>/dev/null || true

# Copy Package.swift and Package.resolved
cp "Package.swift" "$BUILD_DIR/" 2>/dev/null || true
cp "Package.resolved" "$BUILD_DIR/" 2>/dev/null || true

# Copy Sources directory
cp -r "Sources" "$BUILD_DIR/" 2>/dev/null || true

# Create package archive
echo "Creating package archive..."
cd "$BUILD_DIR"
tar -czf "../$DIST_DIR/$PACKAGE_NAME-$VERSION.tar.gz" .
cd ..

# Calculate SHA256 hash
SHA256=$(shasum -a 256 "$DIST_DIR/$PACKAGE_NAME-$VERSION.tar.gz" | cut -d' ' -f1)

echo -e "${GREEN}✅ Package created successfully!${NC}"
echo ""
echo "Package details:"
echo "  Name: $PACKAGE_NAME-$VERSION.tar.gz"
echo "  Size: $(du -h "$DIST_DIR/$PACKAGE_NAME-$VERSION.tar.gz" | cut -f1)"
echo "  SHA256: $SHA256"
echo ""
echo "To update the formula with the correct SHA256:"
echo "  sed -i '' 's/placeholder-sha256-will-be-updated/$SHA256/' Formula/isp-snitch.rb"
echo ""
echo "To test the package:"
echo "  ./Scripts/test-package.sh"
echo ""
echo "To create a release:"
echo "  ./Scripts/package-release.sh"
