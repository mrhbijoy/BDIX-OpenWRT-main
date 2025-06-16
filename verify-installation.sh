#!/bin/sh

# BDIX Installation Verification Script
# This script checks if BDIX web interface is properly installed and configured

echo "======================================"
echo "BDIX Installation Verification Script"
echo "======================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to check status
check_status() {
    if [ $1 -eq 0 ]; then
        echo "${GREEN}✓ $2${NC}"
        return 0
    else
        echo "${RED}✗ $3${NC}"
        return 1
    fi
}

# Check if luci-app-bdix is installed
echo "1. Checking BDIX package installation..."
opkg list-installed | grep -q "luci-app-bdix"
check_status $? "BDIX web interface package is installed" "BDIX package not found"

# Check dependencies
echo ""
echo "2. Checking dependencies..."

opkg list-installed | grep -q "redsocks"
check_status $? "redsocks is installed" "redsocks not found"

opkg list-installed | grep -q "iptables[^-]"
check_status $? "iptables is installed" "iptables not found"

opkg list-installed | grep -q "iptables-mod-nat-extra"
check_status $? "iptables-mod-nat-extra is installed" "iptables-mod-nat-extra not found"

# Check configuration files
echo ""
echo "3. Checking configuration files..."

[ -f "/etc/config/bdix" ]
check_status $? "UCI configuration file exists" "UCI configuration missing"

[ -f "/etc/init.d/bdix" ]
check_status $? "Init script exists" "Init script missing"

[ -x "/etc/init.d/bdix" ]
check_status $? "Init script is executable" "Init script not executable"

# Check LuCI files
echo ""
echo "4. Checking LuCI web interface files..."

[ -f "/usr/lib/lua/luci/controller/bdix.lua" ]
check_status $? "Controller file exists" "Controller file missing"

[ -f "/usr/lib/lua/luci/model/cbi/bdix.lua" ]
check_status $? "Model file exists" "Model file missing"

[ -f "/usr/lib/lua/luci/view/bdix/status.htm" ]
check_status $? "View template exists" "View template missing"

# Check service status
echo ""
echo "5. Checking service status..."

pgrep redsocks > /dev/null
if [ $? -eq 0 ]; then
    echo "${GREEN}✓ BDIX service is running${NC}"
else
    echo "${YELLOW}⚠ BDIX service is not running (this is normal if not configured)${NC}"
fi

# Check web interface accessibility
echo ""
echo "6. Checking web interface accessibility..."

if [ -f "/etc/config/bdix" ]; then
    echo "${GREEN}✓ Web interface should be accessible at: Services → BDIX Proxy${NC}"
else
    echo "${RED}✗ Web interface may not be accessible${NC}"
fi

echo ""
echo "======================================"
echo "Verification Complete!"
echo "======================================"
echo ""

# Provide next steps
echo "${YELLOW}Next Steps:${NC}"
echo "1. Access your router's web interface"
echo "2. Navigate to: Services → BDIX Proxy"
echo "3. Configure your proxy settings"
echo "4. Enable the service and enjoy!"
echo ""

# Check if any critical issues found
if [ ! -f "/usr/lib/lua/luci/controller/bdix.lua" ] || [ ! -f "/etc/config/bdix" ]; then
    echo "${RED}⚠ Critical issues found. You may need to reinstall the package.${NC}"
    echo ""
    echo "To reinstall:"
    echo "opkg remove luci-app-bdix"
    echo "opkg install luci-app-bdix_1.0.0-2_all.ipk"
    echo ""
fi

echo "For support, visit: https://fb.me/emoncontact"
