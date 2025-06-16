#!/bin/sh

# BDIX Simple Controller - No CBI dependency
echo "🔧 BDIX Simple Controller (No CBI)"
echo "=================================="
echo ""
echo "Installing controller that doesn't require CBI module..."

# Download the simple controller
echo "📥 Downloading simple controller..."
wget -O /tmp/bdix-controller-simple.lua "https://github.com/mrhbijoy/BDIX-OpenWRT-main/raw/main/bdix-controller-simple.lua"

if [ ! -f "/tmp/bdix-controller-simple.lua" ]; then
    echo "❌ Failed to download simple controller"
    exit 1
fi

echo "✅ Downloaded simple controller"

# Backup current controller
echo "💾 Backing up current controller..."
cp /usr/lib/lua/luci/controller/bdix.lua /usr/lib/lua/luci/controller/bdix.lua.backup

# Install the simple controller
echo "📋 Installing simple controller..."
cp /tmp/bdix-controller-simple.lua /usr/lib/lua/luci/controller/bdix.lua
chmod 644 /usr/lib/lua/luci/controller/bdix.lua

echo "✅ Simple controller installed"

# Clear cache and restart
echo "🗂️ Clearing LuCI cache..."
rm -rf /tmp/luci-*

echo "🔄 Restarting uhttpd..."
/etc/init.d/uhttpd stop
sleep 3
/etc/init.d/uhttpd start

echo ""
echo "✅ Simple controller applied!"
echo ""
echo "📍 Try: http://192.168.3.1/cgi-bin/luci/admin/system/bdix"
echo "📍 Or: http://192.168.3.1/cgi-bin/luci → System → BDIX Proxy"
echo ""
echo "⏰ Wait 30 seconds for LuCI to rebuild its cache"
echo ""

# Test the controller
echo "🧪 Testing simple controller..."
if lua -e "
package.path = '/usr/lib/lua/?.lua;/usr/lib/lua/?/init.lua;' .. package.path
require('luci.controller.bdix')
print('Simple controller loads successfully')
" 2>/dev/null; then
    echo "✅ Controller test: PASSED"
else
    echo "❌ Controller test: FAILED"
    echo "   Restoring backup..."
    cp /usr/lib/lua/luci/controller/bdix.lua.backup /usr/lib/lua/luci/controller/bdix.lua
fi

echo ""
echo "📋 Features of simple interface:"
echo "✅ No CBI dependency"
echo "✅ Built-in HTML forms"
echo "✅ Service start/stop/restart"
echo "✅ Configuration management"
echo "✅ Status monitoring"
echo ""

exit 0
