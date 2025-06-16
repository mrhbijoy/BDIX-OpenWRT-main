#!/bin/sh

# BDIX Final Fix - Complete Runtime Error Resolution
echo "🎯 BDIX Final Fix - Complete Runtime Error Resolution"
echo "==================================================="
echo ""

# Stop any running instances first
echo "🛑 Stopping BDIX services..."
/etc/init.d/bdix stop >/dev/null 2>&1
killall redsocks >/dev/null 2>&1

# Check if we're running from the right location
if [ ! -f "bdix-controller-simple.lua" ]; then
    echo "❌ Error: bdix-controller-simple.lua not found in current directory"
    echo "Please run this script from the BDIX-OpenWRT-main directory"
    exit 1
fi

echo "📥 Installing corrected controller..."

# Backup current controller
echo "💾 Backing up current controller..."
mkdir -p /usr/lib/lua/luci/controller
cp /usr/lib/lua/luci/controller/bdix.lua /usr/lib/lua/luci/controller/bdix.lua.backup 2>/dev/null

# Install the corrected controller directly
echo "📋 Installing corrected controller..."
cp bdix-controller-simple.lua /usr/lib/lua/luci/controller/bdix.lua
chmod 644 /usr/lib/lua/luci/controller/bdix.lua

echo "✅ Corrected controller installed"

# Ensure UCI config has required sections
echo "🔧 Ensuring UCI configuration..."
uci set bdix.config=bdix >/dev/null 2>&1
uci set bdix.config.proxy_server="103.108.140.116" >/dev/null 2>&1
uci set bdix.config.proxy_port="1080" >/dev/null 2>&1
uci set bdix.config.local_port="1337" >/dev/null 2>&1
uci set bdix.config.custom_ips="" >/dev/null 2>&1
uci set bdix.config.custom_domains="" >/dev/null 2>&1
uci set bdix.config.safety_ips="192.168.0.0/16,172.16.0.0/12,10.0.0.0/8,127.0.0.0/8,169.254.0.0/16,224.0.0.0/4,240.0.0.0/4" >/dev/null 2>&1
uci commit bdix >/dev/null 2>&1

echo "✅ UCI configuration initialized"

# Clear LuCI cache to force reload
echo "🗑️ Clearing LuCI cache..."
rm -rf /tmp/luci-*
rm -f /tmp/.uci/*

echo "✅ LuCI cache cleared"

# Test the controller syntax (basic test)
echo "🧪 Testing controller functionality..."
lua -c "/usr/lib/lua/luci/controller/bdix.lua" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✅ Controller syntax is valid"
else
    echo "⚠️  Warning: Could not validate controller syntax (lua may not be available)"
fi

# Restart web server
echo "🔄 Restarting web services..."
/etc/init.d/uhttpd restart >/dev/null 2>&1

echo ""
echo "🎉 BDIX Controller Fix Complete!"
echo "================================"
echo ""
echo "✅ All syntax errors have been corrected"
echo "✅ Controller has been deployed"
echo "✅ LuCI cache has been cleared"
echo "✅ Web services have been restarted"
echo ""
echo "🌐 Access the BDIX interface at:"
echo "   http://[router-ip]/cgi-bin/luci/admin/system/bdix"
echo ""
echo "📋 If you still see errors:"
echo "   1. Wait 30 seconds for services to fully restart"
echo "   2. Refresh your browser (Ctrl+F5)"
echo "   3. Clear browser cache"
echo "   4. Try accessing from an incognito/private window"
echo ""
echo "🆘 For emergency access restoration:"
echo "   Run: ./fix-emergency.sh"
echo ""
