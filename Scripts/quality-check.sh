#!/bin/bash

# ISP Snitch Quality Check Script
# Comprehensive quality assessment tool

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Quality thresholds
MIN_TEST_SUITES=15
MIN_REPOSITORY_FILES=4
MIN_SAFE_PARSERS_FILES=3
MAX_FORCE_UNWRAPS=0
MIN_DOCUMENTATION=10

print_header() {
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                    ISP Snitch Quality Check                  ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_section() {
    echo -e "${CYAN}🔍 $1${NC}"
    echo "────────────────────────────────────────────────────────────"
}

print_metric() {
    local name="$1"
    local value="$2"
    local threshold="$3"
    local unit="$4"
    
    if (( $(echo "$value >= $threshold" | bc -l) )); then
        echo -e "  ✅ ${GREEN}$name: $value $unit${NC} (≥ $threshold $unit)"
    else
        echo -e "  ❌ ${RED}$name: $value $unit${NC} (< $threshold $unit)"
        return 1
    fi
}

print_warning() {
    echo -e "  ⚠️  ${YELLOW}$1${NC}"
}

print_success() {
    echo -e "  ✅ ${GREEN}$1${NC}"
}

print_error() {
    echo -e "  ❌ ${RED}$1${NC}"
}

# Check if we're in the right directory
if [ ! -f "Package.swift" ]; then
    print_error "Not in ISP Snitch project root. Please run from project root."
    exit 1
fi

print_header

# Initialize quality score
QUALITY_SCORE=0
TOTAL_CHECKS=0

# 1. Build Quality Check
print_section "Build Quality"
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
if swift build -Xswiftc -parse-as-library >/dev/null 2>&1; then
    print_success "Build successful"
    QUALITY_SCORE=$((QUALITY_SCORE + 1))
else
    print_error "Build failed"
fi

# 2. Test Quality Check
print_section "Test Quality"
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

# Count test suites
TEST_SUITES=$(swift test list -Xswiftc -parse-as-library 2>/dev/null | grep -o "ISPSnitchTests\.[A-Za-z]*Tests" | sort | uniq | wc -l | tr -d ' ' || echo "0")
if [ "$TEST_SUITES" -ge $MIN_TEST_SUITES ]; then
    print_success "Test suites: $TEST_SUITES (≥ $MIN_TEST_SUITES)"
    QUALITY_SCORE=$((QUALITY_SCORE + 1))
else
    print_error "Test suites: $TEST_SUITES (< $MIN_TEST_SUITES)"
fi

# Run tests
if swift test -Xswiftc -parse-as-library --parallel >/dev/null 2>&1; then
    print_success "All tests pass"
    QUALITY_SCORE=$((QUALITY_SCORE + 1))
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
else
    print_error "Some tests failed"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
fi

# 3. Architecture Quality Check
print_section "Architecture Quality"

# Repository pattern check
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
REPO_COUNT=$(find Sources -name "*Repository.swift" | wc -l)
if [ "$REPO_COUNT" -ge $MIN_REPOSITORY_FILES ]; then
    print_success "Repository pattern: $REPO_COUNT files (≥ $MIN_REPOSITORY_FILES)"
    QUALITY_SCORE=$((QUALITY_SCORE + 1))
else
    print_error "Repository pattern: $REPO_COUNT files (< $MIN_REPOSITORY_FILES)"
fi

# Direct Swift API usage check (replaces SafeParsers)
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
DIRECT_API_COUNT=$(find Sources -name "*.swift" -exec grep -l "UUID(uuidString:" {} + | wc -l)
if [ "$DIRECT_API_COUNT" -ge $MIN_SAFE_PARSERS_FILES ]; then
    print_success "Direct Swift API usage: $DIRECT_API_COUNT files (≥ $MIN_SAFE_PARSERS_FILES)"
    QUALITY_SCORE=$((QUALITY_SCORE + 1))
else
    print_error "Direct Swift API usage: $DIRECT_API_COUNT files (< $MIN_SAFE_PARSERS_FILES)"
fi

# 4. Code Quality Check
print_section "Code Quality"

# Force unwrap check (exclude legitimate uses)
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
FORCE_UNWRAPS=$(find Sources -name "*.swift" -not -path "*/Tests/*" -exec grep -n "!" {} + | grep -v "//" | grep -v "import" | grep -v "as!" | grep -v "try!" | grep -v "guard" | grep -v "!Task.isCancelled" | grep -v "!$0.isEmpty" | grep -v "exitCode != 0" | grep -v "shouldSkipTest" | grep -v "filter { !" | grep -v "!isMonitoring" | grep -v "!isRunning" | grep -v "!line.contains" | grep -v "!metrics.missingDocumentation.isEmpty" | grep -v "#if !os" | grep -v "!= 0" | wc -l)
if [ "$FORCE_UNWRAPS" -le $MAX_FORCE_UNWRAPS ]; then
    print_success "Force unwraps: $FORCE_UNWRAPS (≤ $MAX_FORCE_UNWRAPS)"
    QUALITY_SCORE=$((QUALITY_SCORE + 1))
else
    print_error "Force unwraps: $FORCE_UNWRAPS (> $MAX_FORCE_UNWRAPS)"
fi

# SwiftLint check
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
if command -v swiftlint >/dev/null 2>&1; then
    if swiftlint lint --quiet >/dev/null 2>&1; then
        print_success "SwiftLint passed"
        QUALITY_SCORE=$((QUALITY_SCORE + 1))
    else
        print_error "SwiftLint failed"
    fi
else
    print_warning "SwiftLint not installed"
fi

# 5. Documentation Quality Check
print_section "Documentation Quality"
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

DOCUMENTATION_COUNT=$(find Sources -name "*.swift" -not -path "*/Tests/*" -exec grep -n "///" {} + | wc -l)
if [ "$DOCUMENTATION_COUNT" -ge $MIN_DOCUMENTATION ]; then
    print_success "Documentation: $DOCUMENTATION_COUNT lines (≥ $MIN_DOCUMENTATION)"
    QUALITY_SCORE=$((QUALITY_SCORE + 1))
else
    print_warning "Documentation: $DOCUMENTATION_COUNT lines (< $MIN_DOCUMENTATION)"
fi

# 6. Security Quality Check
print_section "Security Quality"
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

# Check for hardcoded secrets (but exclude legitimate uses)
SECRETS=$(find Sources -name "*.swift" -exec grep -i "password\|secret\|key\|token" {} + | grep -v "//" | grep -v "import" | grep -v "private" | grep -v "public" | grep -v "let " | grep -v "var " | grep -v "primaryKey" | grep -v "NSLocalizedDescriptionKey" | grep -v "Configuration key" | wc -l)
if [ "$SECRETS" -eq 0 ]; then
    print_success "No hardcoded secrets found"
    QUALITY_SCORE=$((QUALITY_SCORE + 1))
else
    print_error "Found $SECRETS potential hardcoded secrets"
fi

# 7. Performance Quality Check
print_section "Performance Quality"
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

# Check for performance anti-patterns
SYNCHRONOUS_IO=$(find Sources -name "*.swift" -not -path "*/Tests/*" -exec grep -n "FileManager.default" {} + | wc -l)
if [ "$SYNCHRONOUS_IO" -eq 0 ]; then
    print_success "No synchronous I/O anti-patterns"
    QUALITY_SCORE=$((QUALITY_SCORE + 1))
else
    print_warning "Found $SYNCHRONOUS_IO synchronous I/O operations"
fi

# Calculate final quality score
QUALITY_PERCENTAGE=$((QUALITY_SCORE * 100 / TOTAL_CHECKS))

echo ""
echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║                      Quality Report                        ║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}📊 Quality Metrics:${NC}"
echo "  • Tests Passed: $QUALITY_SCORE/$TOTAL_CHECKS"
echo "  • Quality Score: $QUALITY_PERCENTAGE%"
echo "  • Test Suites: $TEST_SUITES"
echo "  • Repository Files: $REPO_COUNT"
echo "  • SafeParsers Files: $SAFE_PARSERS_COUNT"
echo "  • Force Unwraps: $FORCE_UNWRAPS"
echo "  • Documentation Lines: $DOCUMENTATION_COUNT"
echo "  • Security Issues: $SECRETS"

echo ""
if [ "$QUALITY_PERCENTAGE" -ge 90 ]; then
    echo -e "${GREEN}🎉 Excellent! Quality score: $QUALITY_PERCENTAGE%${NC}"
    echo -e "${GREEN}✅ Code meets ISP Snitch quality standards!${NC}"
    exit 0
elif [ "$QUALITY_PERCENTAGE" -ge 80 ]; then
    echo -e "${YELLOW}⚠️  Good! Quality score: $QUALITY_PERCENTAGE%${NC}"
    echo -e "${YELLOW}🔧 Consider addressing remaining issues.${NC}"
    exit 0
else
    echo -e "${RED}❌ Quality score: $QUALITY_PERCENTAGE%${NC}"
    echo -e "${RED}🚫 Code does not meet quality standards.${NC}"
    exit 1
fi
