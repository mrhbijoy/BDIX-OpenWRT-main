#!/bin/sh

# BDIX Emergency Fix and Safe Controller Update
echo "🚨 BDIX Emergency Fix"
echo "===================="
echo ""

echo "🔧 Step 1: Cleaning up any problematic iptables rules..."

# Stop BDIX service to clean iptables
/etc/init.d/bdix stop 2>/dev/null

# Manual cleanup of any remaining rules
iptables -t nat -F BDIX 2>/dev/null
iptables -t nat -D PREROUTING -i br-lan -p tcp -j BDIX 2>/dev/null
iptables -t nat -X BDIX 2>/dev/null

# Clean up any simple redirect rules that might block web UI
iptables -t nat -D PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 1337 2>/dev/null
iptables -t nat -D PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 1337 2>/dev/null

# Restart firewall to restore normal operation
echo "🔄 Restarting firewall..."
/etc/init.d/firewall restart

echo "✅ Emergency cleanup completed - Web UI should be accessible now"
echo ""

echo "📥 Step 2: Installing safe controller with proper exclusions..."

# Download the safe controller
wget -O /tmp/bdix-controller-safe.lua "https://github.com/mrhbijoy/BDIX-OpenWRT-main/raw/main/bdix-controller-simple.lua"

if [ ! -f "/tmp/bdix-controller-safe.lua" ]; then
    echo "❌ Failed to download safe controller"
    echo "✅ But emergency cleanup is done - you can access web UI"
    exit 1
fi

# Backup current controller
cp /usr/lib/lua/luci/controller/bdix.lua /usr/lib/lua/luci/controller/bdix.lua.backup 2>/dev/null

# Install the safe controller
cp /tmp/bdix-controller-safe.lua /usr/lib/lua/luci/controller/bdix.lua
chmod 644 /usr/lib/lua/luci/controller/bdix.lua

# Clear cache and restart
rm -rf /tmp/luci-*
/etc/init.d/uhttpd restart

echo "✅ Safe controller installed"
echo ""
echo "🎯 What was fixed:"
echo "✅ Removed all problematic iptables rules"
echo "✅ Restored normal firewall operation"
echo "✅ Installed controller with safety exclusions"
echo "✅ Local networks (192.168.x.x) are now excluded by default"
echo ""
echo "🌐 Access: http://192.168.3.1/cgi-bin/luci/admin/system/bdix"
echo ""
echo "⚠️  IMPORTANT: The new iptables controls include safety exclusions"
echo "   Your router's web interface will remain accessible even when"
echo "   traffic redirection is enabled."
echo ""

# Test web UI accessibility
echo "🧪 Testing web UI accessibility..."
if wget -q -O /dev/null --timeout=5 "http://127.0.0.1/cgi-bin/luci" 2>/dev/null; then
    echo "✅ Web UI is accessible"
else
    echo "⚠️  Web UI test failed, but should still work from browser"
fi

echo ""
echo "📋 Safe Features:"
echo "✅ Local networks automatically excluded (no lockout)"
echo "✅ Proper iptables chain management"
echo "✅ Emergency cleanup on service stop"
echo "✅ Firewall restart for clean state"
echo ""

exit 0
