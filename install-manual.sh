#!/bin/sh

# Manual BDIX Web Interface Installation Script
# This bypasses IPK and installs files directly

echo "🚀 BDIX Manual Installation Script"
echo "=================================="

# Check if running as root
if [ "$(id -u)" != "0" ]; then
    echo "❌ This script must be run as root"
    exit 1
fi

echo "📦 Installing dependencies..."
opkg update
opkg install luci-base redsocks iptables iptables-mod-nat-extra

echo "📁 Creating directory structure..."
mkdir -p /usr/lib/lua/luci/controller
mkdir -p /usr/lib/lua/luci/model/cbi
mkdir -p /usr/lib/lua/luci/view/bdix
mkdir -p /etc/config

echo "📥 Downloading and installing files..."

# Download controller
wget -O /usr/lib/lua/luci/controller/bdix.lua \
  "https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/luci-app-bdix/data/usr/lib/lua/luci/controller/bdix.lua"

# Download model
wget -O /usr/lib/lua/luci/model/cbi/bdix.lua \
  "https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/luci-app-bdix/data/usr/lib/lua/luci/model/cbi/bdix.lua"

# Download view
wget -O /usr/lib/lua/luci/view/bdix/status.htm \
  "https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/luci-app-bdix/data/usr/lib/lua/luci/view/bdix/status.htm"

# Download init script
wget -O /etc/init.d/bdix \
  "https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/luci-app-bdix/data/etc/init.d/bdix"

# Download config
wget -O /etc/config/bdix \
  "https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/luci-app-bdix/data/etc/config/bdix"

echo "🔧 Setting permissions..."
chmod +x /etc/init.d/bdix
chmod 644 /usr/lib/lua/luci/controller/bdix.lua
chmod 644 /usr/lib/lua/luci/model/cbi/bdix.lua
chmod 644 /usr/lib/lua/luci/view/bdix/status.htm
chmod 644 /etc/config/bdix

# Stop existing redsocks if running
if [ -f "/etc/init.d/redsocks" ]; then
    echo "🛑 Stopping existing redsocks service..."
    /etc/init.d/redsocks stop 2>/dev/null
    /etc/init.d/redsocks disable 2>/dev/null
fi

echo "🧹 Clearing LuCI cache..."
rm -rf /tmp/luci-*

echo "🔄 Restarting web interface..."
/etc/init.d/uhttpd restart

echo ""
echo "✅ BDIX Web Interface installed successfully!"
echo ""
echo "🌐 Access it via:"
echo "   http://192.168.3.1 → Services → BDIX Proxy"
echo ""
echo "🔧 Next steps:"
echo "   1. Configure your proxy settings"
echo "   2. Enable the service"
echo "   3. Start the service"
echo ""
echo "🎉 Enjoy your BDIX proxy!"
