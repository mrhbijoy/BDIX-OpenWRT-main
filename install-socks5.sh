#!/bin/sh

# BDIX SOCKS5 Configuration Setup
echo "🔧 BDIX SOCKS5 Configuration Setup"
echo "=================================="
echo ""

echo "📋 Setting up your SOCKS5 proxy configuration..."

# Create the UCI configuration with your SOCKS5 details
uci -q delete bdix.bdix
uci set bdix.bdix=bdix
uci set bdix.bdix.enabled='0'
uci set bdix.bdix.proxy_ip='113.192.43.43'
uci set bdix.bdix.proxy_port='1080'
uci set bdix.bdix.username='bijoy2@itcnbd'
uci set bdix.bdix.password='89890'
uci set bdix.bdix.local_port='1337'
uci set bdix.bdix.log_level='on'
uci set bdix.bdix.auto_start='0'

# Set web interface authentication (separate from SOCKS5)
uci -q delete bdix.config
uci set bdix.config=config
uci set bdix.config.username='admin'
uci set bdix.config.password='admin'

# Commit the configuration
uci commit bdix

echo "✅ SOCKS5 Configuration Applied:"
echo "   Server: 113.192.43.43"
echo "   Port: 1080"
echo "   Username: bijoy2@itcnbd"
echo "   Password: 89890"
echo ""
echo "✅ Web Interface Authentication:"
echo "   Username: admin"
echo "   Password: admin"
echo ""
echo "🔄 Installing the updated controller..."

# Download and install the SOCKS5-enabled controller
if command -v wget >/dev/null 2>&1; then
    wget -q --no-check-certificate -O /tmp/bdix-socks5.lua "https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/bdix-controller-simple.lua"
elif command -v curl >/dev/null 2>&1; then
    curl -k -s -L -o /tmp/bdix-socks5.lua "https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/bdix-controller-simple.lua"
else
    echo "❌ No download tool available"
    exit 1
fi

if [ -f "/tmp/bdix-socks5.lua" ] && [ -s "/tmp/bdix-socks5.lua" ]; then
    # Backup current controller
    cp /usr/lib/lua/luci/controller/bdix.lua /usr/lib/lua/luci/controller/bdix.lua.backup 2>/dev/null
    
    # Install the new controller
    cp /tmp/bdix-socks5.lua /usr/lib/lua/luci/controller/bdix.lua
    chmod 644 /usr/lib/lua/luci/controller/bdix.lua
    rm -f /tmp/bdix-socks5.lua
    
    echo "✅ Controller installed successfully"
else
    echo "❌ Failed to download controller"
    exit 1
fi

# Clear LuCI cache
echo "🗑️ Clearing LuCI cache..."
rm -rf /tmp/luci-* >/dev/null 2>&1

# Restart web server
echo "🔄 Restarting web services..."
/etc/init.d/uhttpd restart >/dev/null 2>&1

echo ""
echo "🎉 SOCKS5 Setup Complete!"
echo "========================"
echo ""
echo "✅ Your SOCKS5 proxy details are configured"
echo "✅ Web interface is ready with authentication"
echo "✅ All services have been restarted"
echo ""
echo "🌐 Access the interface at:"
echo "   http://$(uci get network.lan.ipaddr 2>/dev/null || echo '[router-ip]')/cgi-bin/luci/admin/system/bdix"
echo ""
echo "🔑 Login with: admin / admin"
echo "🚀 Start the BDIX service from the web interface"
echo ""
echo "📋 Your SOCKS5 settings:"
echo "   Server: 113.192.43.43:1080"
echo "   Auth: bijoy2@itcnbd / 89890"
