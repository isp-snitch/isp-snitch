#!/bin/bash

# Quality Monitoring Dashboard
# Provides a comprehensive dashboard for documentation quality monitoring

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DASHBOARD_PORT="${DASHBOARD_PORT:-8080}"
DASHBOARD_HOST="${DASHBOARD_HOST:-localhost}"
REFRESH_INTERVAL="${REFRESH_INTERVAL:-5}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Dashboard state
DASHBOARD_RUNNING=false
QUALITY_MONITOR_PID=""
HTTP_SERVER_PID=""

# Cleanup function
cleanup() {
    echo -e "\n${YELLOW}Shutting down quality dashboard...${NC}"
    
    if [[ -n "$QUALITY_MONITOR_PID" ]]; then
        kill "$QUALITY_MONITOR_PID" 2>/dev/null || true
    fi
    
    if [[ -n "$HTTP_SERVER_PID" ]]; then
        kill "$HTTP_SERVER_PID" 2>/dev/null || true
    fi
    
    DASHBOARD_RUNNING=false
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Print header
print_header() {
    clear
    echo -e "${WHITE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}║                        ISP Snitch Quality Dashboard                        ║${NC}"
    echo -e "${WHITE}║                           Documentation Monitoring                          ║${NC}"
    echo -e "${WHITE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
}

# Print metrics section
print_metrics() {
    echo -e "${CYAN}📊 Current Metrics${NC}"
    echo -e "${WHITE}──────────────────────────────────────────────────────────────────────────────${NC}"
    
    # Get current metrics
    if command -v isp-snitch >/dev/null 2>&1; then
        local metrics_output
        if metrics_output=$(isp-snitch quality monitor --format json 2>/dev/null); then
            # Parse JSON metrics (simplified parsing)
            local total_apis=$(echo "$metrics_output" | grep -o '"totalPublicAPIs":[0-9]*' | cut -d':' -f2 || echo "0")
            local documented_apis=$(echo "$metrics_output" | grep -o '"documentedAPIs":[0-9]*' | cut -d':' -f2 || echo "0")
            local coverage=$(echo "$metrics_output" | grep -o '"coveragePercentage":[0-9.]*' | cut -d':' -f2 || echo "0")
            local quality_score=$(echo "$metrics_output" | grep -o '"qualityScore":[0-9]*' | cut -d':' -f2 || echo "0")
            local generation_time=$(echo "$metrics_output" | grep -o '"generationTime":[0-9.]*' | cut -d':' -f2 || echo "0")
            
            # Display metrics
            printf "%-20s %s\n" "Total APIs:" "$total_apis"
            printf "%-20s %s\n" "Documented APIs:" "$documented_apis"
            printf "%-20s %s\n" "Coverage:" "$(printf "%.1f%%" "$coverage")"
            printf "%-20s %s\n" "Quality Score:" "$quality_score"
            printf "%-20s %s\n" "Generation Time:" "$(printf "%.1fs" "$generation_time")"
            
            # Status indicators
            local coverage_status
            if (( $(echo "$coverage >= 85" | bc -l) )); then
                coverage_status="${GREEN}✅ PASS${NC}"
            else
                coverage_status="${RED}❌ FAIL${NC}"
            fi
            
            local quality_status
            if (( quality_score >= 80 )); then
                quality_status="${GREEN}✅ PASS${NC}"
            else
                quality_status="${RED}❌ FAIL${NC}"
            fi
            
            printf "%-20s %s\n" "Coverage Status:" "$coverage_status"
            printf "%-20s %s\n" "Quality Status:" "$quality_status"
            
        else
            echo -e "${RED}❌ Failed to retrieve metrics${NC}"
        fi
    else
        echo -e "${RED}❌ isp-snitch command not found${NC}"
    fi
    
    echo
}

# Print trends section
print_trends() {
    echo -e "${PURPLE}📈 Quality Trends${NC}"
    echo -e "${WHITE}──────────────────────────────────────────────────────────────────────────────${NC}"
    
    if command -v isp-snitch >/dev/null 2>&1; then
        local trends_output
        if trends_output=$(isp-snitch quality trends --period 7d --format json 2>/dev/null); then
            # Parse trends (simplified)
            local coverage_trend=$(echo "$trends_output" | grep -o '"coverageTrend":"[^"]*"' | cut -d'"' -f4 || echo "unknown")
            local quality_trend=$(echo "$trends_output" | grep -o '"qualityTrend":"[^"]*"' | cut -d'"' -f4 || echo "unknown")
            local performance_trend=$(echo "$trends_output" | grep -o '"performanceTrend":"[^"]*"' | cut -d'"' -f4 || echo "unknown")
            
            # Display trends with indicators
            local coverage_indicator
            case "$coverage_trend" in
                "improving") coverage_indicator="${GREEN}📈${NC}" ;;
                "declining") coverage_indicator="${RED}📉${NC}" ;;
                "stable") coverage_indicator="${YELLOW}➡️${NC}" ;;
                *) coverage_indicator="${WHITE}❓${NC}" ;;
            esac
            
            local quality_indicator
            case "$quality_trend" in
                "improving") quality_indicator="${GREEN}📈${NC}" ;;
                "declining") quality_indicator="${RED}📉${NC}" ;;
                "stable") quality_indicator="${YELLOW}➡️${NC}" ;;
                *) quality_indicator="${WHITE}❓${NC}" ;;
            esac
            
            local performance_indicator
            case "$performance_trend" in
                "improving") performance_indicator="${GREEN}📈${NC}" ;;
                "declining") performance_indicator="${RED}📉${NC}" ;;
                "stable") performance_indicator="${YELLOW}➡️${NC}" ;;
                *) performance_indicator="${WHITE}❓${NC}" ;;
            esac
            
            printf "%-20s %s %s\n" "Coverage Trend:" "$coverage_indicator" "$coverage_trend"
            printf "%-20s %s %s\n" "Quality Trend:" "$quality_indicator" "$quality_trend"
            printf "%-20s %s %s\n" "Performance Trend:" "$performance_indicator" "$performance_trend"
            
        else
            echo -e "${RED}❌ Failed to retrieve trends${NC}"
        fi
    else
        echo -e "${RED}❌ isp-snitch command not found${NC}"
    fi
    
    echo
}

# Print alerts section
print_alerts() {
    echo -e "${YELLOW}🚨 Recent Alerts${NC}"
    echo -e "${WHITE}──────────────────────────────────────────────────────────────────────────────${NC}"
    
    if command -v isp-snitch >/dev/null 2>&1; then
        local alerts_output
        if alerts_output=$(isp-snitch quality alerts --list --limit 5 --format json 2>/dev/null); then
            # Check if there are any alerts
            if echo "$alerts_output" | grep -q '"id"'; then
                echo "$alerts_output" | jq -r '.[] | "\(.level | ascii_upcase) - \(.timestamp) - \(.message)"' 2>/dev/null || {
                    echo -e "${GREEN}✅ No recent alerts${NC}"
                }
            else
                echo -e "${GREEN}✅ No recent alerts${NC}"
            fi
        else
            echo -e "${GREEN}✅ No recent alerts${NC}"
        fi
    else
        echo -e "${RED}❌ isp-snitch command not found${NC}"
    fi
    
    echo
}

# Print performance section
print_performance() {
    echo -e "${BLUE}⚡ Performance Metrics${NC}"
    echo -e "${WHITE}──────────────────────────────────────────────────────────────────────────────${NC}"
    
    if command -v isp-snitch >/dev/null 2>&1; then
        local performance_output
        if performance_output=$(isp-snitch quality monitor --format json 2>/dev/null); then
            # Parse performance metrics (simplified)
            local memory_usage=$(echo "$performance_output" | grep -o '"memoryUsage":[0-9]*' | cut -d':' -f2 || echo "0")
            local cpu_usage=$(echo "$performance_output" | grep -o '"cpuUsage":[0-9.]*' | cut -d':' -f2 || echo "0")
            local output_size=$(echo "$performance_output" | grep -o '"outputSize":[0-9]*' | cut -d':' -f2 || echo "0")
            
            printf "%-20s %s\n" "Memory Usage:" "${memory_usage}MB"
            printf "%-20s %s\n" "CPU Usage:" "$(printf "%.1f%%" "$cpu_usage")"
            printf "%-20s %s\n" "Output Size:" "${output_size}MB"
            
            # Performance indicators
            local memory_status
            if (( memory_usage <= 100 )); then
                memory_status="${GREEN}✅${NC}"
            elif (( memory_usage <= 200 )); then
                memory_status="${YELLOW}⚠️${NC}"
            else
                memory_status="${RED}❌${NC}"
            fi
            
            local cpu_status
            if (( $(echo "$cpu_usage <= 50" | bc -l) )); then
                cpu_status="${GREEN}✅${NC}"
            elif (( $(echo "$cpu_usage <= 75" | bc -l) )); then
                cpu_status="${YELLOW}⚠️${NC}"
            else
                cpu_status="${RED}❌${NC}"
            fi
            
            printf "%-20s %s\n" "Memory Status:" "$memory_status"
            printf "%-20s %s\n" "CPU Status:" "$cpu_status"
            
        else
            echo -e "${RED}❌ Failed to retrieve performance metrics${NC}"
        fi
    else
        echo -e "${RED}❌ isp-snitch command not found${NC}"
    fi
    
    echo
}

# Print footer
print_footer() {
    echo -e "${WHITE}──────────────────────────────────────────────────────────────────────────────${NC}"
    echo -e "${CYAN}Dashboard running on http://${DASHBOARD_HOST}:${DASHBOARD_PORT}${NC}"
    echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
    echo -e "${WHITE}Refresh interval: ${REFRESH_INTERVAL}s${NC}"
    echo
}

# Start HTTP server for web dashboard
start_http_server() {
    local dashboard_html="<!DOCTYPE html>
<html>
<head>
    <title>ISP Snitch Quality Dashboard</title>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <style>
        body { font-family: 'Monaco', 'Menlo', monospace; margin: 20px; background: #1e1e1e; color: #ffffff; }
        .header { text-align: center; margin-bottom: 30px; }
        .section { margin-bottom: 30px; padding: 20px; border: 1px solid #333; border-radius: 5px; }
        .metric { display: flex; justify-content: space-between; margin: 10px 0; }
        .status-pass { color: #4CAF50; }
        .status-fail { color: #F44336; }
        .status-warn { color: #FF9800; }
        .trend-up { color: #4CAF50; }
        .trend-down { color: #F44336; }
        .trend-stable { color: #FF9800; }
        .refresh { text-align: center; margin-top: 20px; }
        .timestamp { color: #888; font-size: 0.9em; }
    </style>
    <script>
        function refreshDashboard() {
            location.reload();
        }
        setInterval(refreshDashboard, ${REFRESH_INTERVAL}000);
    </script>
</head>
<body>
    <div class='header'>
        <h1>ISP Snitch Quality Dashboard</h1>
        <p class='timestamp'>Last updated: <span id='timestamp'></span></p>
    </div>
    
    <div class='section'>
        <h2>📊 Current Metrics</h2>
        <div id='metrics'>Loading...</div>
    </div>
    
    <div class='section'>
        <h2>📈 Quality Trends</h2>
        <div id='trends'>Loading...</div>
    </div>
    
    <div class='section'>
        <h2>🚨 Recent Alerts</h2>
        <div id='alerts'>Loading...</div>
    </div>
    
    <div class='section'>
        <h2>⚡ Performance Metrics</h2>
        <div id='performance'>Loading...</div>
    </div>
    
    <div class='refresh'>
        <p>Auto-refresh every ${REFRESH_INTERVAL} seconds</p>
    </div>
    
    <script>
        document.getElementById('timestamp').textContent = new Date().toLocaleString();
    </script>
</body>
</html>"
    
    # Start simple HTTP server
    echo "$dashboard_html" | python3 -m http.server "$DASHBOARD_PORT" >/dev/null 2>&1 &
    HTTP_SERVER_PID=$!
    
    echo -e "${GREEN}✅ HTTP server started on port ${DASHBOARD_PORT}${NC}"
}

# Main dashboard loop
run_dashboard() {
    DASHBOARD_RUNNING=true
    
    # Start HTTP server
    start_http_server
    
    while $DASHBOARD_RUNNING; do
        print_header
        print_metrics
        print_trends
        print_alerts
        print_performance
        print_footer
        
        sleep "$REFRESH_INTERVAL"
    done
}

# Show help
show_help() {
    echo "ISP Snitch Quality Dashboard"
    echo
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -p, --port PORT        Dashboard HTTP port (default: 8080)"
    echo "  -h, --host HOST        Dashboard HTTP host (default: localhost)"
    echo "  -r, --refresh SECONDS  Refresh interval in seconds (default: 5)"
    echo "  --help                 Show this help message"
    echo
    echo "Environment Variables:"
    echo "  DASHBOARD_PORT         Dashboard HTTP port"
    echo "  DASHBOARD_HOST         Dashboard HTTP host"
    echo "  REFRESH_INTERVAL       Refresh interval in seconds"
    echo
    echo "Examples:"
    echo "  $0                     # Start dashboard with defaults"
    echo "  $0 -p 9000 -r 10      # Start on port 9000 with 10s refresh"
    echo "  DASHBOARD_PORT=9000 $0 # Start on port 9000 via environment"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--port)
            DASHBOARD_PORT="$2"
            shift 2
            ;;
        -h|--host)
            DASHBOARD_HOST="$2"
            shift 2
            ;;
        -r|--refresh)
            REFRESH_INTERVAL="$2"
            shift 2
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Check dependencies
if ! command -v isp-snitch >/dev/null 2>&1; then
    echo -e "${RED}❌ isp-snitch command not found. Please install ISP Snitch first.${NC}"
    exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
    echo -e "${RED}❌ python3 not found. Required for HTTP server.${NC}"
    exit 1
fi

# Start dashboard
echo -e "${GREEN}🚀 Starting ISP Snitch Quality Dashboard...${NC}"
echo -e "${CYAN}Dashboard will be available at: http://${DASHBOARD_HOST}:${DASHBOARD_PORT}${NC}"
echo

run_dashboard
