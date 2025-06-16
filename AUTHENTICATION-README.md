# BDIX Authentication Update

## 🔐 New Authentication Features Added!

The BDIX controller now includes username/password authentication for enhanced security.

### 🔑 Default Credentials
- **Username:** `admin`
- **Password:** `admin`

### 🚀 Quick Update Commands

Update your router with the new authentication-enabled controller:

```bash
# Option 1: Quick Update (wget)
wget -O - https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/quick-fix.sh | sh

# Option 2: Quick Update (curl)
curl -k -s -L https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/quick-fix-curl.sh | sh

# Option 3: Manual Update
wget -O /tmp/bdix-auth.lua https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/bdix-controller-simple.lua && /etc/init.d/bdix stop && cp /tmp/bdix-auth.lua /usr/lib/lua/luci/controller/bdix.lua && chmod 644 /usr/lib/lua/luci/controller/bdix.lua && rm -rf /tmp/luci-* && /etc/init.d/uhttpd restart && echo "✅ Authentication enabled! Login with admin/admin"
```

### 🛡️ Security Features

- **Session-based authentication** with 24-hour cookie expiration
- **Customizable credentials** through the web interface
- **Logout functionality** to clear sessions
- **All actions protected** - start, stop, restart, iptables management
- **Clean login page** with modern UI

### 📋 How to Use

1. **Access the interface** - You'll see a login page
2. **Enter credentials** - Default: admin/admin
3. **Change password** - Use the Authentication Settings section
4. **Logout safely** - Click the Logout button when done

### 🔧 Configuration

Credentials are stored in UCI config:
```bash
uci get bdix.config.username  # View username
uci get bdix.config.password  # View password
uci set bdix.config.username "newuser"     # Change username  
uci set bdix.config.password "newpass123"  # Change password
uci commit bdix
```

### 🆘 Emergency Access

If you forget credentials:
```bash
# Reset to defaults via SSH
uci set bdix.config.username "admin"
uci set bdix.config.password "admin" 
uci commit bdix
rm -rf /tmp/luci-*
/etc/init.d/uhttpd restart
```

**🎉 Your BDIX interface is now secured with authentication!**
