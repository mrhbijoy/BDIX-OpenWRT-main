#!/bin/sh

# BDIX Controller Fix - Registers under System menu instead of Services
echo "🔧 BDIX Controller Fix"
echo "====================="
echo ""
echo "This will register BDIX under the System menu instead of Services"
echo ""

# Download the alternative controller
echo "📥 Downloading alternative controller..."
wget -O /tmp/bdix-controller-system.lua "https://github.com/mrhbijoy/BDIX-OpenWRT-main/raw/main/bdix-controller-system.lua"

if [ ! -f "/tmp/bdix-controller-system.lua" ]; then
    echo "❌ Failed to download alternative controller"
    exit 1
fi

echo "✅ Downloaded alternative controller"

# Backup original controller
echo "💾 Backing up original controller..."
cp /usr/lib/lua/luci/controller/bdix.lua /usr/lib/lua/luci/controller/bdix.lua.backup

# Install the new controller
echo "📋 Installing alternative controller..."
cp /tmp/bdix-controller-system.lua /usr/lib/lua/luci/controller/bdix.lua
chmod 644 /usr/lib/lua/luci/controller/bdix.lua

echo "✅ Alternative controller installed"

# Clear cache and restart
echo "🗂️ Clearing LuCI cache..."
rm -rf /tmp/luci-*

echo "🔄 Restarting uhttpd..."
/etc/init.d/uhttpd stop
sleep 3
/etc/init.d/uhttpd start

echo ""
echo "✅ Fix applied! Try these URLs:"
echo "   📍 http://192.168.3.1/cgi-bin/luci/admin/system/bdix"
echo "   📍 http://192.168.3.1/cgi-bin/luci (then System > BDIX Proxy)"
echo ""
echo "⏰ Wait 30 seconds for LuCI to rebuild its cache, then try accessing"
echo ""

# Test the controller
echo "🧪 Testing controller..."
if lua -e "
package.path = '/usr/lib/lua/?.lua;/usr/lib/lua/?/init.lua;' .. package.path
require('luci.controller.bdix')
print('Controller loads successfully')
" 2>/dev/null; then
    echo "✅ Controller test: PASSED"
else
    echo "❌ Controller test: FAILED"
    echo "   Restoring backup..."
    cp /usr/lib/lua/luci/controller/bdix.lua.backup /usr/lib/lua/luci/controller/bdix.lua
fi

echo ""
echo "📋 If it still doesn't work:"
echo "1. Check System menu for 'BDIX Proxy' item"
echo "2. Try: /etc/init.d/uhttpd restart"
echo "3. Wait 1 minute and refresh browser"
echo ""

exit 0
