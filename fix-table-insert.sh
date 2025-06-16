#!/bin/sh

# BDIX Table Insert Error Emergency Fix
echo "🚨 BDIX Table Insert Emergency Fix"
echo "=================================="
echo ""

echo "🔧 Fixing the specific table.insert runtime error..."

# Stop services
/etc/init.d/bdix stop >/dev/null 2>&1
killall redsocks >/dev/null 2>&1

# Create backup
cp /usr/lib/lua/luci/controller/bdix.lua /usr/lib/lua/luci/controller/bdix.lua.table-insert-backup 2>/dev/null

# Download latest fixed version
echo "📡 Downloading table.insert fix..."
if command -v wget >/dev/null 2>&1; then
    wget -q --no-check-certificate -O /tmp/bdix-table-fix.lua "https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/bdix-controller-simple.lua"
elif command -v curl >/dev/null 2>&1; then
    curl -k -s -L -o /tmp/bdix-table-fix.lua "https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/bdix-controller-simple.lua"
else
    echo "❌ Download failed. Creating minimal fix..."
    exit 1
fi

# Install fix
if [ -f "/tmp/bdix-table-fix.lua" ] && [ -s "/tmp/bdix-table-fix.lua" ]; then
    cp /tmp/bdix-table-fix.lua /usr/lib/lua/luci/controller/bdix.lua
    chmod 644 /usr/lib/lua/luci/controller/bdix.lua
    rm -f /tmp/bdix-table-fix.lua
    echo "✅ Table.insert fix applied"
else
    echo "❌ Fix failed"
    exit 1
fi

# Clear cache
rm -rf /tmp/luci-* >/dev/null 2>&1

# Restart web
/etc/init.d/uhttpd restart >/dev/null 2>&1

echo ""
echo "🎉 Table Insert Error Fixed!"
echo "============================"
echo ""
echo "✅ The runtime error should be resolved"
echo "🌐 Access: http://$(uci get network.lan.ipaddr 2>/dev/null || echo 'router-ip')/cgi-bin/luci/admin/system/bdix"
