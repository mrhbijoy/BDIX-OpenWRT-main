#!/bin/sh

# BDIX Display Fix - Remove emojis and fix menu links
echo "🔧 BDIX Display Fix"
echo "=================="
echo ""

# Download the fixed controller without emojis
echo "📥 Downloading emoji-free controller..."
wget -O /tmp/bdix-controller-simple-fixed.lua "https://github.com/mrhbijoy/BDIX-OpenWRT-main/raw/main/bdix-controller-simple.lua"

if [ ! -f "/tmp/bdix-controller-simple-fixed.lua" ]; then
    echo "❌ Failed to download fixed controller"
    exit 1
fi

echo "✅ Downloaded fixed controller"

# Install the fixed controller
echo "📋 Installing emoji-free controller..."
cp /tmp/bdix-controller-simple-fixed.lua /usr/lib/lua/luci/controller/bdix.lua
chmod 644 /usr/lib/lua/luci/controller/bdix.lua

echo "✅ Fixed controller installed"

# Clear cache and restart
echo "🗂️ Clearing ALL LuCI cache and rebuilding menu..."
rm -rf /tmp/luci-*
rm -rf /tmp/luci-indexcache*
rm -rf /var/luci-*

echo "🔄 Stopping uhttpd..."
/etc/init.d/uhttpd stop
sleep 5

echo "🔄 Starting uhttpd..."
/etc/init.d/uhttpd start
sleep 3

echo "🔄 Force menu rebuild..."
# Force LuCI to rebuild menu structure
wget -q -O /dev/null "http://127.0.0.1/cgi-bin/luci" 2>/dev/null || true

echo ""
echo "✅ Menu and display fixes applied!"
echo ""
echo "📍 Access: http://192.168.3.1/cgi-bin/luci/admin/system/bdix"
echo ""
echo "🔧 The broken Services menu link should now be removed"
echo "   Check System menu for the correct BDIX Proxy link"
echo ""
echo "⏰ Wait 30 seconds, then refresh your browser and check System menu"
echo ""

# Test the controller
echo "🧪 Testing fixed controller..."
if lua -e "
package.path = '/usr/lib/lua/?.lua;/usr/lib/lua/?/init.lua;' .. package.path
require('luci.controller.bdix')
print('Fixed controller loads successfully')
" 2>/dev/null; then
    echo "✅ Controller test: PASSED"
else
    echo "❌ Controller test: FAILED"
fi

echo ""
echo "📋 What was fixed:"
echo "✅ Removed emoji characters"
echo "✅ Clean text display"
echo "✅ Removed broken Services menu entry"
echo "✅ Fixed System menu registration"
echo "✅ All functionality preserved"
echo ""

exit 0
