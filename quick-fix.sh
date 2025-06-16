#!/bin/sh

# BDIX Quick Auto-Fix - One Command Solution
echo "⚡ BDIX Quick Auto-Fix - Downloading and installing..."

# Download and install in one go
wget -q --no-check-certificate -O /tmp/bdix-fix.lua "https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/bdix-controller-simple.lua" && \
/etc/init.d/bdix stop 2>/dev/null && \
cp /usr/lib/lua/luci/controller/bdix.lua /usr/lib/lua/luci/controller/bdix.lua.backup 2>/dev/null && \
cp /tmp/bdix-fix.lua /usr/lib/lua/luci/controller/bdix.lua && \
chmod 644 /usr/lib/lua/luci/controller/bdix.lua && \
rm -rf /tmp/luci-* && \
rm -f /tmp/bdix-fix.lua && \
/etc/init.d/uhttpd restart && \
echo "✅ BDIX Auto-Fix Complete! Access: http://$(uci get network.lan.ipaddr 2>/dev/null || echo 'router-ip')/cgi-bin/luci/admin/system/bdix" || \
echo "❌ Auto-fix failed. Try manual installation."
