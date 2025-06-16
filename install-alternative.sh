#!/bin/sh

# Alternative BDIX Installation using Shadowsocks instead of Redsocks
# This avoids the segmentation fault issue with redsocks

echo "🚀 BDIX Alternative Installation (Shadowsocks-based)"
echo "=================================================="
echo ""

echo "📦 Installing dependencies..."
opkg update

# Install Lua runtime for LuCI
opkg install lua luci-base-lua luci-mod-admin-full luci-lib-base luci-lib-nixio luci-lib-jsonc

# Install shadowsocks instead of redsocks (more stable)
opkg install shadowsocks-libev-ss-redir

echo ""
echo "📁 Creating directory structure..."
mkdir -p /usr/lib/lua/luci/controller
mkdir -p /usr/lib/lua/luci/model/cbi
mkdir -p /usr/lib/lua/luci/view/bdix
mkdir -p /etc/config
mkdir -p /etc/shadowsocks

echo ""
echo "📝 Creating shadowsocks-based configuration..."

# Create a shadowsocks-based init script instead of redsocks
cat > /etc/init.d/bdix << 'EOF'
#!/bin/sh /etc/rc.common
# BDIX Proxy Service using Shadowsocks (Alternative to Redsocks)

START=90
USE_PROCD=1

INTERFACE=br-lan
CONFIG_FILE="/etc/shadowsocks/bdix.json"

start_service() {
    config_load bdix
    
    local enabled
    config_get enabled bdix enabled 0
    
    [ "$enabled" -eq 1 ] || {
        echo "BDIX is disabled"
        return 1
    }
    
    # Generate shadowsocks configuration
    generate_config
    
    # Start iptables rules
    iptable_start
    
    # Start ss-redir with procd
    procd_open_instance
    procd_set_param command /usr/bin/ss-redir -c "$CONFIG_FILE" -v
    procd_set_param respawn
    procd_set_param stdout 1
    procd_set_param stderr 1
    procd_close_instance
}

stop_service() {
    iptable_stop
    echo "Restarting firewall..."
    /etc/init.d/firewall restart &> /dev/null
}

generate_config() {
    local proxy_ip proxy_port username password local_port
    
    config_get proxy_ip bdix proxy_ip "127.0.0.1"
    config_get proxy_port bdix proxy_port "1080"
    config_get username bdix username ""
    config_get password bdix password ""
    config_get local_port bdix local_port "1337"
    
    # Create shadowsocks config for SOCKS5 proxy
    cat > "$CONFIG_FILE" << EOFCONFIG
{
    "server": "$proxy_ip",
    "server_port": $proxy_port,
    "local_address": "0.0.0.0",
    "local_port": $local_port,
    "password": "$password",
    "method": "none",
    "timeout": 60,
    "fast_open": false
}
EOFCONFIG
}

iptable_start() {
    echo "Starting BDIX iptables..."
    
    local local_port
    config_get local_port bdix local_port "1337"
    
    # Create BDIX chain
    iptables -t nat -N BDIX 2>/dev/null
    
    # Add direct connection rules for configured domains
    add_domain_rules
    
    # Private IP ranges bypass
    iptables -t nat -A BDIX -d 0.0.0.0/8 -j RETURN
    iptables -t nat -A BDIX -d 10.0.0.0/8 -j RETURN
    iptables -t nat -A BDIX -d 127.0.0.0/8 -j RETURN
    iptables -t nat -A BDIX -d 169.254.0.0/16 -j RETURN
    iptables -t nat -A BDIX -d 172.16.0.0/12 -j RETURN
    iptables -t nat -A BDIX -d 192.168.0.0/16 -j RETURN
    iptables -t nat -A BDIX -d 224.0.0.0/4 -j RETURN
    iptables -t nat -A BDIX -d 240.0.0.0/4 -j RETURN
    
    # Redirect to ss-redir
    iptables -t nat -A BDIX -p tcp -j REDIRECT --to-ports $local_port
    
    # Apply to traffic
    iptables -t nat -A PREROUTING -i $INTERFACE -p tcp -j BDIX
    iptables -A INPUT -i $INTERFACE -p tcp --dport $local_port -j ACCEPT
    
    echo "BDIX iptables started"
}

add_domain_rules() {
    config_foreach add_single_domain domain
}

add_single_domain() {
    local domain_name
    config_get domain_name "$1" name
    
    [ -n "$domain_name" ] && {
        echo "Adding direct rule for: $domain_name"
        iptables -t nat -A BDIX -d "$domain_name" -j RETURN
    }
}

iptable_stop() {
    echo "Cleaning BDIX iptables..."
    iptables -t nat -F BDIX 2>/dev/null
    iptables -t nat -X BDIX 2>/dev/null
    echo "BDIX iptables cleaned"
}

service_triggers() {
    procd_add_reload_trigger "bdix"
}

reload_service() {
    stop
    start
}
EOF

chmod +x /etc/init.d/bdix

echo ""
echo "📥 Downloading LuCI interface files..."

# Download the web interface files
wget -O /usr/lib/lua/luci/controller/bdix.lua \
  "https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/luci-app-bdix/data/usr/lib/lua/luci/controller/bdix.lua"

wget -O /usr/lib/lua/luci/model/cbi/bdix.lua \
  "https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/luci-app-bdix/data/usr/lib/lua/luci/model/cbi/bdix.lua"

wget -O /usr/lib/lua/luci/view/bdix/status.htm \
  "https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/luci-app-bdix/data/usr/lib/lua/luci/view/bdix/status.htm"

wget -O /etc/config/bdix \
  "https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/luci-app-bdix/data/etc/config/bdix"

echo ""
echo "🔧 Setting permissions..."
chmod 644 /usr/lib/lua/luci/controller/bdix.lua
chmod 644 /usr/lib/lua/luci/model/cbi/bdix.lua
chmod 644 /usr/lib/lua/luci/view/bdix/status.htm
chmod 644 /etc/config/bdix

echo ""
echo "🧹 Clearing cache and restarting services..."
rm -rf /tmp/luci-*
/etc/init.d/uhttpd restart

echo ""
echo "✅ BDIX Alternative Installation Complete!"
echo ""
echo "🌐 Access via: http://192.168.3.1 → Services → BDIX Proxy"
echo ""
echo "📋 This version uses:"
echo "   - Shadowsocks instead of Redsocks (more stable)"
echo "   - Better error handling"
echo "   - Improved compatibility"
echo ""
echo "🎉 Configure your proxy settings and enjoy!"
