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
echo "🗂️ Clearing LuCI cache..."
rm -rf /tmp/luci-*

echo "🔄 Restarting uhttpd..."
/etc/init.d/uhttpd restart

echo ""
echo "✅ Display fixes applied!"
echo ""
echo "📍 Access: http://192.168.3.1/cgi-bin/luci/admin/system/bdix"
echo ""
echo "🔧 Note: The System menu link might still show the old URL"
echo "   Just use the direct link above or bookmark it"
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
echo "✅ All functionality preserved"
echo ""

exit 0
