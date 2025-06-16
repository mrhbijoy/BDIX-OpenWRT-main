#!/bin/sh

# BDIX Fix Script - Addresses segfault and missing Lua runtime issues
# Run this after the initial installation to fix common issues

echo "🔧 BDIX Fix Script"
echo "=================="
echo ""

echo "📦 Installing missing Lua runtime and fixing dependencies..."

# Update package lists
opkg update

# Install Lua runtime for LuCI
echo "Installing Lua runtime..."
opkg install lua liblua5.1.5 luci-mod-admin-full

# Alternative redsocks package that might be more stable
echo "Checking redsocks installation..."
opkg remove redsocks --force-removal-of-dependent-packages 2>/dev/null
opkg install redsocks

# Install additional dependencies that might be missing
echo "Installing additional LuCI dependencies..."
opkg install luci-lib-base luci-lib-nixio luci-lib-jsonc luci-lib-ip

# Check if we have a working Lua interpreter
if ! lua -v >/dev/null 2>&1; then
    echo "⚠️  Lua still not working, trying alternative packages..."
    opkg install lua5.1 luci-lua-runtime
fi

echo ""
echo "🛠️  Fixing redsocks segmentation fault..."

# Stop any running redsocks processes
killall redsocks 2>/dev/null

# Create a simple test config to verify redsocks works
cat > /tmp/test-redsocks.conf << 'EOF'
base {
    log_debug = off;
    log_info = on;
    log = "syslog:local7";
    daemon = off;
    redirector = iptables;
}

redsocks {
    local_ip = 0.0.0.0;
    local_port = 1337;
    ip = 127.0.0.1;
    port = 1080;
    type = socks5;
}
EOF

echo "Testing redsocks with minimal config..."
if timeout 5 redsocks -c /tmp/test-redsocks.conf; then
    echo "✅ Redsocks test passed"
else
    echo "❌ Redsocks still has issues"
    echo "   This might be due to your router's architecture or OpenWRT version"
    echo "   Consider using shadowsocks-libev as an alternative"
fi

rm /tmp/test-redsocks.conf

echo ""
echo "🔄 Restarting services and clearing cache..."

# Clear LuCI cache - this is critical for new modules
rm -rf /tmp/luci-*
rm -f /tmp/luci-indexcache

# Restart uhttpd with proper Lua support
/etc/init.d/uhttpd restart

# Force LuCI to rebuild its module cache
/etc/init.d/uhttpd stop
sleep 2
/etc/init.d/uhttpd start

echo ""
echo "🔍 Checking installation status..."

# Check if Lua is working
if lua -e "print('Lua is working')" 2>/dev/null; then
    echo "✅ Lua runtime: Working"
else
    echo "❌ Lua runtime: Still not working"
    echo "   Your OpenWRT version might need different Lua packages"
fi

# Check if LuCI files are properly installed
echo ""
echo "📂 Checking LuCI file installation:"
if [ -f "/usr/lib/lua/luci/controller/bdix.lua" ]; then
    echo "✅ Controller: /usr/lib/lua/luci/controller/bdix.lua"
    # Verify the controller content
    if grep -q "module.*bdix" /usr/lib/lua/luci/controller/bdix.lua; then
        echo "   Controller content looks correct"
    else
        echo "   ⚠️  Controller content might be corrupted"
    fi
else
    echo "❌ Controller: Missing - need to reinstall web files"
fi

if [ -f "/usr/lib/lua/luci/model/cbi/bdix.lua" ]; then
    echo "✅ Model: /usr/lib/lua/luci/model/cbi/bdix.lua"
else
    echo "❌ Model: Missing"
fi

if [ -f "/usr/lib/lua/luci/view/bdix/status.htm" ]; then
    echo "✅ View: /usr/lib/lua/luci/view/bdix/status.htm"
else
    echo "❌ View: Missing"
fi

# Check file permissions
echo ""
echo "🔐 Checking file permissions:"
ls -la /usr/lib/lua/luci/controller/bdix.lua 2>/dev/null || echo "❌ Controller file not found"
ls -la /usr/lib/lua/luci/model/cbi/bdix.lua 2>/dev/null || echo "❌ Model file not found"

# Check if redsocks is working
if redsocks -h >/dev/null 2>&1; then
    echo "✅ Redsocks: Available"
else
    echo "❌ Redsocks: Has issues"
fi

echo ""
echo "📋 Next Steps:"
echo ""
if [ ! -f "/usr/lib/lua/luci/controller/bdix.lua" ]; then
    echo "❗ LuCI files are missing! Please run the manual installation:"
    echo "   wget -O - https://github.com/mrhbijoy/BDIX-OpenWRT-main/raw/main/install-manual.sh | sh"
    echo ""
fi

echo "🔧 If BDIX page still shows 404:"
echo "1. Clear cache manually: rm -rf /tmp/luci-*"
echo "2. Restart web server: /etc/init.d/uhttpd restart" 
echo "3. Wait 30 seconds, then try again"
echo ""
echo "If redsocks continues to crash:"
echo "1. Try shadowsocks-libev instead:"
echo "   opkg install shadowsocks-libev-ss-redir"
echo ""
echo "2. Use manual iptables + SSH tunnel:"
echo "   ssh -D 1080 user@proxy-server"
echo ""
echo "🌐 Try accessing: http://192.168.3.1/cgi-bin/luci/admin/services/bdix"
echo "   (Wait 30 seconds after restarting uhttpd)"
echo ""

exit 0
