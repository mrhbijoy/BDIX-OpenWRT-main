#!/bin/sh

# BDIX Enhanced UI - Add iptables control interface
echo "🔧 BDIX Enhanced UI - IPTables Control"
echo "====================================="
echo ""

# Download the enhanced controller with iptables UI
echo "📥 Downloading enhanced controller..."
wget -O /tmp/bdix-controller-enhanced.lua "https://github.com/mrhbijoy/BDIX-OpenWRT-main/raw/main/bdix-controller-simple.lua"

if [ ! -f "/tmp/bdix-controller-enhanced.lua" ]; then
    echo "❌ Failed to download enhanced controller"
    exit 1
fi

echo "✅ Downloaded enhanced controller"

# Backup current controller
echo "💾 Backing up current controller..."
cp /usr/lib/lua/luci/controller/bdix.lua /usr/lib/lua/luci/controller/bdix.lua.backup

# Install the enhanced controller
echo "📋 Installing enhanced controller..."
cp /tmp/bdix-controller-enhanced.lua /usr/lib/lua/luci/controller/bdix.lua
chmod 644 /usr/lib/lua/luci/controller/bdix.lua

echo "✅ Enhanced controller installed"

# Clear cache and restart
echo "🗂️ Clearing LuCI cache..."
rm -rf /tmp/luci-*

echo "🔄 Restarting uhttpd..."
/etc/init.d/uhttpd restart

echo ""
echo "✅ Enhanced UI applied!"
echo ""
echo "📍 Access: http://192.168.3.1/cgi-bin/luci/admin/system/bdix"
echo ""

# Test the controller
echo "🧪 Testing enhanced controller..."
if lua -e "
package.path = '/usr/lib/lua/?.lua;/usr/lib/lua/?/init.lua;' .. package.path
require('luci.controller.bdix')
print('Enhanced controller loads successfully')
" 2>/dev/null; then
    echo "✅ Controller test: PASSED"
else
    echo "❌ Controller test: FAILED"
    echo "   Restoring backup..."
    cp /usr/lib/lua/luci/controller/bdix.lua.backup /usr/lib/lua/luci/controller/bdix.lua
fi

echo ""
echo "📋 New features added:"
echo "✅ IPTables rules status display"
echo "✅ Traffic redirection status"
echo "✅ Manual iptables control buttons"
echo "✅ Active rules preview"
echo "✅ Better status explanation"
echo ""
echo "🎯 You can now:"
echo "• See if traffic redirection is active"
echo "• View current iptables rules"
echo "• Manually enable/disable traffic redirection"
echo "• Control service and iptables separately"
echo ""

exit 0
