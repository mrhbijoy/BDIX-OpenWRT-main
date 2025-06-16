#!/bin/sh

# BDIX Installation Test Script
# This script will try multiple installation methods to ensure one works

echo "🚀 BDIX Installation Test Script"
echo "================================"
echo ""

# Function to check if BDIX is installed
check_installation() {
    if [ -f "/usr/lib/lua/luci/controller/bdix.lua" ] && [ -f "/etc/init.d/bdix" ]; then
        echo "✅ BDIX Web Interface is installed!"
        echo "🌐 Access via: http://192.168.3.1 → Services → BDIX Proxy"
        return 0
    else
        return 1
    fi
}

# Method 1: Try IPK installation
echo "📦 Method 1: Trying IPK installation..."
cd /tmp
if wget -q https://github.com/mrhbijoy/BDIX-OpenWRT-main/raw/main/luci-app-bdix/luci-app-bdix_1.0.0-3_all.ipk; then
    echo "✓ IPK downloaded successfully"
    if opkg install luci-app-bdix_1.0.0-3_all.ipk; then
        echo "✓ IPK installation successful!"
        check_installation && exit 0
    else
        echo "✗ IPK installation failed"
    fi
else
    echo "✗ Failed to download IPK"
fi

echo ""
echo "📥 Method 2: Trying manual installation..."

# Method 2: Manual installation
if wget -q https://github.com/mrhbijoy/BDIX-OpenWRT-main/raw/main/install-manual.sh; then
    echo "✓ Manual installer downloaded"
    chmod +x install-manual.sh
    if ./install-manual.sh; then
        echo "✓ Manual installation completed!"
        check_installation && exit 0
    else
        echo "✗ Manual installation failed"
    fi
else
    echo "✗ Failed to download manual installer"
fi

echo ""
echo "🔧 Method 3: Trying step-by-step installation..."

# Method 3: Step by step installation
echo "Installing dependencies..."
opkg update
opkg install luci-base redsocks iptables iptables-mod-nat-extra

echo "Creating directories..."
mkdir -p /usr/lib/lua/luci/controller
mkdir -p /usr/lib/lua/luci/model/cbi
mkdir -p /usr/lib/lua/luci/view/bdix
mkdir -p /etc/config

echo "Downloading files..."

# Download each file individually with error checking
files_to_download=(
    "/usr/lib/lua/luci/controller/bdix.lua|https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/luci-app-bdix/data/usr/lib/lua/luci/controller/bdix.lua"
    "/usr/lib/lua/luci/model/cbi/bdix.lua|https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/luci-app-bdix/data/usr/lib/lua/luci/model/cbi/bdix.lua"
    "/usr/lib/lua/luci/view/bdix/status.htm|https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/luci-app-bdix/data/usr/lib/lua/luci/view/bdix/status.htm"
    "/etc/init.d/bdix|https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/luci-app-bdix/data/etc/init.d/bdix"
    "/etc/config/bdix|https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/luci-app-bdix/data/etc/config/bdix"
)

success_count=0
for file_info in "${files_to_download[@]}"; do
    file_path="${file_info%|*}"
    file_url="${file_info#*|}"
    
    if wget -O "$file_path" "$file_url" 2>/dev/null; then
        echo "✓ Downloaded: $file_path"
        success_count=$((success_count + 1))
    else
        echo "✗ Failed: $file_path"
    fi
done

if [ $success_count -eq 5 ]; then
    echo "✓ All files downloaded successfully"
    
    # Set permissions
    chmod +x /etc/init.d/bdix
    chmod 644 /usr/lib/lua/luci/controller/bdix.lua
    chmod 644 /usr/lib/lua/luci/model/cbi/bdix.lua
    chmod 644 /usr/lib/lua/luci/view/bdix/status.htm
    chmod 644 /etc/config/bdix
    
    # Stop existing redsocks
    /etc/init.d/redsocks stop 2>/dev/null
    /etc/init.d/redsocks disable 2>/dev/null
    
    # Clear cache and restart web interface
    rm -rf /tmp/luci-*
    /etc/init.d/uhttpd restart
    
    echo "✓ Installation completed!"
    check_installation && exit 0
else
    echo "✗ Failed to download all required files"
fi

echo ""
echo "❌ All installation methods failed!"
echo ""
echo "🔍 Please check:"
echo "1. Internet connectivity"
echo "2. Available storage space"
echo "3. OpenWRT version compatibility"
echo ""
echo "📞 For support, contact: https://fb.me/emoncontact"

exit 1
