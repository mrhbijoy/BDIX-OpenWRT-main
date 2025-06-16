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
opkg install lua luci-base-lua luci-mod-admin-full

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
echo "🔄 Restarting services..."

# Restart uhttpd with proper Lua support
/etc/init.d/uhttpd restart

# Clear LuCI cache
rm -rf /tmp/luci-*

echo ""
echo "🔍 Checking installation status..."

# Check if Lua is working
if lua -e "print('Lua is working')" 2>/dev/null; then
    echo "✅ Lua runtime: Working"
else
    echo "❌ Lua runtime: Still not working"
    echo "   Your OpenWRT version might need different Lua packages"
fi

# Check if LuCI controller is accessible
if [ -f "/usr/lib/lua/luci/controller/bdix.lua" ]; then
    echo "✅ BDIX controller: Installed"
else
    echo "❌ BDIX controller: Missing"
fi

# Check if redsocks is working
if redsocks -h >/dev/null 2>&1; then
    echo "✅ Redsocks: Available"
else
    echo "❌ Redsocks: Has issues"
fi

echo ""
echo "📋 Alternative Solutions:"
echo ""
echo "If redsocks continues to crash:"
echo "1. Try shadowsocks-libev instead:"
echo "   opkg install shadowsocks-libev-ss-redir"
echo ""
echo "2. Use manual iptables + SSH tunnel:"
echo "   ssh -D 1080 user@proxy-server"
echo ""
echo "If Lua runtime still missing:"
echo "1. Check OpenWRT version compatibility"
echo "2. Try installing from different feeds"
echo "3. Use command-line configuration only"
echo ""
echo "🌐 Try accessing: http://192.168.3.1/cgi-bin/luci/admin/services/bdix"
echo ""

exit 0
