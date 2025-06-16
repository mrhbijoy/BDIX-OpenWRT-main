# 🚀 BDIX Auto-Fix - GitHub Automated Installation

## Quick Fix (Choose One Method)

### Method 1: Auto-Fix with wget
```bash
wget -O - https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/quick-fix.sh | sh
```

### Method 2: Auto-Fix with curl  
```bash
curl -k -s -L https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/quick-fix-curl.sh | sh
```

### Method 3: Download and Run
```bash
# Download the auto-fix script
wget https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/auto-fix-github.sh
chmod +x auto-fix-github.sh
./auto-fix-github.sh
```

### Method 4: Manual Download
```bash
# Download fixed controller
wget -O /tmp/bdix-fix.lua https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/bdix-controller-simple.lua

# Install manually
/etc/init.d/bdix stop
cp /usr/lib/lua/luci/controller/bdix.lua /usr/lib/lua/luci/controller/bdix.lua.backup
cp /tmp/bdix-fix.lua /usr/lib/lua/luci/controller/bdix.lua
chmod 644 /usr/lib/lua/luci/controller/bdix.lua
rm -rf /tmp/luci-*
/etc/init.d/uhttpd restart
```

## What Gets Fixed

✅ **Runtime Error**: "bad argument #2 to 'insert'" - RESOLVED  
✅ **Syntax Errors**: Malformed end statements - FIXED  
✅ **Web Interface**: Will load without errors  
✅ **All Features**: Service control, exclusions, safety IPs - WORKING  

## Access the Interface

After running any method above, access:
```
http://[your-router-ip]/cgi-bin/luci/admin/system/bdix
```

## Emergency Restore

If something goes wrong:
```bash
cp /usr/lib/lua/luci/controller/bdix.lua.backup /usr/lib/lua/luci/controller/bdix.lua
/etc/init.d/uhttpd restart
```

---

**🎯 The automated scripts download the latest fixed version directly from GitHub and deploy it instantly!**
