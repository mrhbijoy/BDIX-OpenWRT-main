#!/bin/sh

# BDIX Auto-Fix (curl version) - For systems without wget
echo "⚡ BDIX Auto-Fix (curl) - Downloading and installing..."

# Download and install using curl
curl -k -s -L -o /tmp/bdix-fix.lua "https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/bdix-controller-simple.lua" && \
/etc/init.d/bdix stop 2>/dev/null && \
cp /usr/lib/lua/luci/controller/bdix.lua /usr/lib/lua/luci/controller/bdix.lua.backup 2>/dev/null && \
cp /tmp/bdix-fix.lua /usr/lib/lua/luci/controller/bdix.lua && \
chmod 644 /usr/lib/lua/luci/controller/bdix.lua && \
rm -rf /tmp/luci-* && \
rm -f /tmp/bdix-fix.lua && \
/etc/init.d/uhttpd restart && \
echo "✅ BDIX Auto-Fix Complete! Access: http://$(uci get network.lan.ipaddr 2>/dev/null || echo 'router-ip')/cgi-bin/luci/admin/system/bdix" || \
echo "❌ Auto-fix failed. Try manual installation."
