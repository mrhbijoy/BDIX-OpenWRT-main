# 🌐 BDIX SOCKS5 Proxy Setup

## 🔧 Your SOCKS5 Configuration

**Server Details:**
- **Host:** `113.192.43.43`
- **Port:** `1080`
- **Username:** `bijoy2@itcnbd`
- **Password:** `89890`
- **Type:** SOCKS5 with authentication

## 🚀 Quick Installation

### One-Command Setup
Copy and paste this command on your OpenWRT router:

```bash
# Complete SOCKS5 setup with your credentials
wget -O - https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/install-socks5.sh | sh
```

### Manual Installation
```bash
# 1. Configure UCI with your SOCKS5 details
uci set bdix.bdix=bdix
uci set bdix.bdix.proxy_ip='113.192.43.43'
uci set bdix.bdix.proxy_port='1080'
uci set bdix.bdix.username='bijoy2@itcnbd'
uci set bdix.bdix.password='89890'
uci set bdix.bdix.local_port='1337'
uci commit bdix

# 2. Install the SOCKS5-enabled controller
wget -O /tmp/controller.lua https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/bdix-controller-simple.lua
cp /tmp/controller.lua /usr/lib/lua/luci/controller/bdix.lua
chmod 644 /usr/lib/lua/luci/controller/bdix.lua
rm -rf /tmp/luci-*
/etc/init.d/uhttpd restart
```

## 🎯 Features Included

### 🔐 Dual Authentication
1. **SOCKS5 Authentication**: Your proxy credentials (bijoy2@itcnbd / 89890)
2. **Web Interface Authentication**: Access control (admin / admin)

### 🌐 Web Interface
- **URL**: `http://[router-ip]/cgi-bin/luci/admin/system/bdix`
- **Login**: admin / admin
- **Features**: 
  - SOCKS5 proxy configuration
  - Service start/stop/restart
  - iptables management
  - Real-time status monitoring

### ⚙️ Configuration Management
- **SOCKS5 Settings**: Pre-configured with your details
- **Safety Features**: Local network exclusions built-in
- **Service Control**: Easy start/stop from web interface

## 📋 Usage Steps

1. **Install** using the one-command setup above
2. **Access** the web interface: `http://[router-ip]/cgi-bin/luci/admin/system/bdix`
3. **Login** with admin/admin
4. **Verify** your SOCKS5 settings are correct
5. **Start** the BDIX service
6. **Enable** iptables rules for traffic redirection

## 🔧 Advanced Configuration

### View Current Config
```bash
uci show bdix.bdix        # SOCKS5 proxy settings
uci show bdix.config      # Web interface settings
```

### Modify SOCKS5 Settings
```bash
uci set bdix.bdix.proxy_ip='NEW_IP'
uci set bdix.bdix.username='NEW_USER'
uci set bdix.bdix.password='NEW_PASS'
uci commit bdix
/etc/init.d/bdix restart
```

### Check Service Status
```bash
/etc/init.d/bdix status
ps | grep redsocks
iptables -t nat -L BDIX
```

## 🛡️ Security Features

- **Local Network Protection**: Private IPs automatically excluded
- **Session Management**: Secure web authentication
- **Credential Storage**: SOCKS5 auth stored in UCI config
- **Emergency Access**: SSH access always available

## 🆘 Troubleshooting

### Service Won't Start
```bash
# Check configuration
cat /etc/bdix.conf

# Check logs
logread | grep bdix
logread | grep redsocks
```

### Reset Configuration
```bash
# Reset to your SOCKS5 defaults
uci delete bdix.bdix
uci set bdix.bdix=bdix
uci set bdix.bdix.proxy_ip='113.192.43.43'
uci set bdix.bdix.username='bijoy2@itcnbd'
uci set bdix.bdix.password='89890'
uci commit bdix
```

**🎉 Your SOCKS5 proxy is ready to use with authentication!**
