# BDIX SOCKS5 One-Line Setup Commands

Copy and paste any ONE of these commands on your OpenWRT router:

## 🌐 Complete SOCKS5 Setup (Recommended)
**Includes your SOCKS5 credentials (113.192.43.43:1080 / bijoy2@itcnbd)**
```bash
wget -O - https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/install-socks5.sh | sh
```

## 🔧 Quick Controller Update Only
```bash
wget -O - https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/quick-fix.sh | sh
```

## 🚨 Emergency Fix (if having issues)
```bash
wget -O - https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/fix-table-insert.sh | sh
```

## 🔄 Manual Setup (if automatic fails)
```bash
# Download and install
wget -O /tmp/socks5.lua https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/bdix-controller-simple.lua && cp /tmp/socks5.lua /usr/lib/lua/luci/controller/bdix.lua && chmod 644 /usr/lib/lua/luci/controller/bdix.lua && rm -rf /tmp/luci-* && /etc/init.d/uhttpd restart

# Configure your SOCKS5 details
uci set bdix.bdix=bdix && uci set bdix.bdix.proxy_ip='113.192.43.43' && uci set bdix.bdix.proxy_port='1080' && uci set bdix.bdix.username='bijoy2@itcnbd' && uci set bdix.bdix.password='89890' && uci commit bdix

echo "✅ Setup complete! Access: http://$(uci get network.lan.ipaddr)/cgi-bin/luci/admin/system/bdix"
```

## 🎯 What You Get:

✅ **SOCKS5 Authentication**: Your credentials pre-configured (bijoy2@itcnbd / 89890)  
✅ **Web Authentication**: Secure login (admin / admin)  
✅ **Complete Interface**: Service control, iptables management, status monitoring  
✅ **Safety Features**: Local network protection built-in  

**🚀 Use the first command for complete automated setup!**
