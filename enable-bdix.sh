#!/bin/sh

# BDIX Service Enable Fix
echo "🔧 BDIX Service Enable Fix"
echo "=========================="
echo ""

echo "📋 Current BDIX status:"
uci get bdix.bdix.enabled 2>/dev/null || echo "Config not found"

echo ""
echo "🔧 Enabling BDIX service..."

# Enable the BDIX service in UCI config
uci set bdix.bdix.enabled='1'
uci commit bdix

echo "✅ BDIX service enabled in configuration"

# Also enable auto-start
uci set bdix.bdix.auto_start='1'
uci commit bdix

echo "✅ Auto-start enabled"

echo ""
echo "🔄 Starting BDIX service..."

# Start the service
/etc/init.d/bdix start

if [ $? -eq 0 ]; then
    echo "✅ BDIX service started successfully"
else
    echo "⚠️  BDIX service start attempted"
fi

echo ""
echo "🔍 Checking service status..."
sleep 2

# Check if redsocks is running
if pgrep redsocks > /dev/null; then
    echo "✅ Redsocks process is running"
    echo "   PID: $(pgrep redsocks)"
else
    echo "❌ Redsocks process not found"
    echo "   Checking logs..."
    logread | tail -10 | grep -i redsocks
fi

# Check iptables rules
if iptables -t nat -L | grep -q 1337; then
    echo "✅ iptables rules are active"
else
    echo "⚠️  iptables rules not found"
fi

echo ""
echo "📋 Configuration summary:"
echo "   Enabled: $(uci get bdix.bdix.enabled)"
echo "   Proxy: $(uci get bdix.bdix.proxy_ip):$(uci get bdix.bdix.proxy_port)"
echo "   Auth: $(uci get bdix.bdix.username)"
echo "   Local port: $(uci get bdix.bdix.local_port)"

echo ""
echo "🎯 If service still won't start:"
echo "   1. Check logs: logread | grep bdix"
echo "   2. Check config: cat /etc/bdix.conf"
echo "   3. Manual start: redsocks -c /etc/bdix.conf"
echo "   4. Use web interface: http://$(uci get network.lan.ipaddr)/cgi-bin/luci/admin/system/bdix"
