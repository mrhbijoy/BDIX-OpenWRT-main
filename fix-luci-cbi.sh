#!/bin/sh

# BDIX LuCI CBI Fix - Install missing LuCI components
echo "🔧 BDIX LuCI CBI Fix"
echo "==================="
echo ""
echo "Installing missing LuCI CBI and core components..."

# Update package lists
opkg update

# Install core LuCI components that provide CBI functionality
echo "📦 Installing LuCI core components..."
opkg install luci-lib-base luci-lib-nixio luci-lib-jsonc luci-lib-ip

# Install LuCI CBI module specifically
echo "📦 Installing LuCI CBI components..."
opkg install luci-mod-admin-full luci-theme-bootstrap luci-app-firewall

# Check if luci-base exists and install it
echo "📦 Installing LuCI base..."
opkg install luci-base 2>/dev/null || echo "luci-base not available as separate package"

# Install additional LuCI libraries that might be needed
echo "📦 Installing additional LuCI libraries..."
opkg install luci-lib-httpclient luci-lib-json

# List what we have now
echo ""
echo "📋 Installed LuCI packages:"
opkg list-installed | grep luci | sort

echo ""
echo "🔍 Checking for luci.cbi module..."
if [ -f "/usr/lib/lua/luci/cbi.lua" ]; then
    echo "✅ luci.cbi module found at /usr/lib/lua/luci/cbi.lua"
    ls -la /usr/lib/lua/luci/cbi.lua
else
    echo "❌ luci.cbi module still missing"
    echo "   Checking alternative locations..."
    find /usr -name "cbi.lua" 2>/dev/null
    find /usr -name "*cbi*" -type f 2>/dev/null | grep lua
fi

echo ""
echo "🔍 Checking LuCI module paths..."
echo "Contents of /usr/lib/lua/luci/:"
ls -la /usr/lib/lua/luci/ | head -20

echo ""
echo "🔄 Restarting services..."
rm -rf /tmp/luci-*
/etc/init.d/uhttpd restart

echo ""
echo "✅ Fix applied! Try accessing:"
echo "   📍 http://192.168.3.1/cgi-bin/luci/admin/system/bdix"
echo ""

exit 0
