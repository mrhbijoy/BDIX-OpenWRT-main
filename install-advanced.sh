#!/bin/sh

# BDIX Advanced Manager - IP/Domain Add/Remove Interface
echo "🎯 BDIX Advanced Manager - IP/Domain Controls"
echo "============================================="
echo ""

# First run emergency cleanup if needed
echo "🔧 Running emergency cleanup first..."
/etc/init.d/bdix stop 2>/dev/null
iptables -t nat -F BDIX 2>/dev/null
iptables -t nat -D PREROUTING -i br-lan -p tcp -j BDIX 2>/dev/null
iptables -t nat -X BDIX 2>/dev/null
/etc/init.d/firewall restart

echo "✅ Emergency cleanup completed"

# Download the advanced controller with add/remove functionality
echo "📥 Downloading advanced controller..."
wget -O /tmp/bdix-controller-advanced.lua "https://github.com/mrhbijoy/BDIX-OpenWRT-main/raw/main/bdix-controller-simple.lua"

if [ ! -f "/tmp/bdix-controller-advanced.lua" ]; then
    echo "❌ Failed to download advanced controller"
    exit 1
fi

echo "✅ Downloaded advanced controller"

# Backup current controller
echo "💾 Backing up current controller..."
cp /usr/lib/lua/luci/controller/bdix.lua /usr/lib/lua/luci/controller/bdix.lua.backup 2>/dev/null

# Install the advanced controller
echo "📋 Installing advanced controller..."
cp /tmp/bdix-controller-advanced.lua /usr/lib/lua/luci/controller/bdix.lua
chmod 644 /usr/lib/lua/luci/controller/bdix.lua

echo "✅ Advanced controller installed"

# Initialize custom exclusions config if not exists
echo "🔧 Setting up configuration..."
uci -q get bdix.config >/dev/null || uci set bdix.config=section
uci -q get bdix.config.custom_ips >/dev/null || uci set bdix.config.custom_ips=""
uci -q get bdix.config.custom_domains >/dev/null || uci set bdix.config.custom_domains=""
uci -q get bdix.config.safety_ips >/dev/null || uci set bdix.config.safety_ips="192.168.0.0/16,172.16.0.0/12,10.0.0.0/8,127.0.0.0/8,169.254.0.0/16,224.0.0.0/4,240.0.0.0/4"
uci commit bdix

# Clear cache and restart
echo "🗂️ Clearing LuCI cache..."
rm -rf /tmp/luci-*

echo "🔄 Restarting uhttpd..."
/etc/init.d/uhttpd restart

echo ""
echo "✅ Advanced BDIX Manager installed!"
echo ""
echo "📍 Access: http://192.168.3.1/cgi-bin/luci/admin/system/bdix"
echo ""

# Test the controller
echo "🧪 Testing advanced controller..."
if lua -e "
package.path = '/usr/lib/lua/?.lua;/usr/lib/lua/?/init.lua;' .. package.path
require('luci.controller.bdix')
print('Advanced controller loads successfully')
" 2>/dev/null; then
    echo "✅ Controller test: PASSED"
else
    echo "❌ Controller test: FAILED"
    echo "   Restoring backup..."
    cp /usr/lib/lua/luci/controller/bdix.lua.backup /usr/lib/lua/luci/controller/bdix.lua 2>/dev/null
fi

echo ""
echo "🎯 NEW ADVANCED FEATURES:"
echo ""
echo "✅ DYNAMIC IP EXCLUSIONS:"
echo "• Add any IP or IP range (e.g., 203.76.120.0/24)"
echo "• Remove exclusions with one click"
echo "• Live exclusion list display"
echo ""
echo "✅ DYNAMIC DOMAIN EXCLUSIONS:"
echo "• Add domains (e.g., facebook.com, wise.com)"
echo "• Automatic domain-to-IP resolution"
echo "• Remove domains easily"
echo ""
echo "✅ SAFETY FEATURES:"
echo "• Built-in local network exclusions (192.168.x.x)"
echo "• Cannot accidentally lock yourself out"
echo "• Web interface always accessible"
echo ""
echo "✅ ADVANCED IPTABLES CONTROL:"
echo "• View active iptables rules"
echo "• Manual enable/disable traffic redirection"
echo "• Separate service and iptables controls"
echo ""
echo "📋 HOW TO USE:"
echo ""
echo "1. 🌐 Go to: System > BDIX Proxy"
echo "2. 📝 Configure proxy server settings"
echo "3. ➕ Add custom IP/domain exclusions:"
echo "   • Type IP/domain in input field"
echo "   • Click 'Add IP' or 'Add Domain'"
echo "4. ❌ Remove exclusions by clicking 'Remove'"
echo "5. 🚀 Start service and enable traffic redirection"
echo ""
echo "⚠️  SAFETY GUARANTEE:"
echo "• Router management IPs are always excluded"
echo "• Cannot lose access to web interface"
echo "• Emergency cleanup included in this installer"
echo ""

exit 0
