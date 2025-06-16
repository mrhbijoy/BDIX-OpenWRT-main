#!/bin/bash

echo "==================================="
echo "BDIX Proxy Web Interface Installer"
echo "==================================="

# Update package list
echo "Updating package list..."
opkg update

# Install required packages
echo "Installing required packages..."
opkg install iptables iptables-mod-nat-extra redsocks luci-base

# Stop existing redsocks service
echo "Stopping existing redsocks service..."
service redsocks stop 2>/dev/null

# Backup existing configuration
echo "Backing up existing configuration..."
[ -f /etc/redsocks.conf ] && mv /etc/redsocks.conf /etc/redsocks.conf.bkp
[ -f /etc/init.d/redsocks ] && mv /etc/init.d/redsocks /etc/init.d/redsocks.bkp

# Create directories
mkdir -p /usr/lib/lua/luci/controller
mkdir -p /usr/lib/lua/luci/model/cbi
mkdir -p /usr/lib/lua/luci/view/bdix
mkdir -p /etc/config

# Download and install LuCI files
echo "Installing LuCI web interface files..."

# Controller
cd /usr/lib/lua/luci/controller
wget -O bdix.lua https://github.com/mrhbijoy/BDIX-OpenWRT-main/raw/main/luci-app-bdix/luasrc/controller/bdix.lua

# Model
cd /usr/lib/lua/luci/model/cbi
wget -O bdix.lua https://github.com/mrhbijoy/BDIX-OpenWRT-main/raw/main/luci-app-bdix/luasrc/model/cbi/bdix.lua

# View
cd /usr/lib/lua/luci/view/bdix
wget -O status.htm https://github.com/mrhbijoy/BDIX-OpenWRT-main/raw/main/luci-app-bdix/luasrc/view/bdix/status.htm

# Init script
cd /etc/init.d
wget -O bdix https://github.com/mrhbijoy/BDIX-OpenWRT-main/raw/main/luci-app-bdix/root/etc/init.d/bdix
chmod +x bdix

# Configuration
cd /etc/config
wget -O bdix https://github.com/mrhbijoy/BDIX-OpenWRT-main/raw/main/luci-app-bdix/root/etc/config/bdix

# Clear LuCI cache
echo "Clearing LuCI cache..."
rm -rf /tmp/luci-*

# Restart web interface
echo "Restarting web interface..."
/etc/init.d/uhttpd restart

clear

echo "====================================="
echo "✅ BDIX Web Interface Installed!"
echo "====================================="
echo ""
echo "🌐 Access the web interface:"
echo "   1. Open your router's web interface"
echo "   2. Go to: Services → BDIX Proxy"
echo "   3. Configure your proxy settings"
echo ""
echo "📝 Configuration:"
echo "   - Enter your proxy server IP and port"
echo "   - Add username/password if required"
echo "   - Manage direct connection domains"
echo "   - Enable/disable the service"
echo ""
echo "🔧 Manual configuration (if needed):"
echo "   - Config file: /etc/config/bdix"
echo "   - Service: /etc/init.d/bdix"
echo ""
echo "Thanks for installing! Follow for updates:"
echo "https://fb.me/emoncontact"
echo "====================================="
