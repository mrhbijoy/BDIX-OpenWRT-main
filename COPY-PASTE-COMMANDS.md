# BDIX One-Line Auto-Fix Commands

Copy and paste any ONE of these commands on your OpenWRT router:

## Option 1: wget (Most Common)
```bash
wget -O - https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/quick-fix.sh | sh
```

## Option 2: curl (Alternative)
```bash
curl -k -s -L https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/quick-fix-curl.sh | sh
```

## Option 3: Manual Steps (If above fail)
```bash
wget -O /tmp/bdix-fix.lua https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/bdix-controller-simple.lua && /etc/init.d/bdix stop && cp /usr/lib/lua/luci/controller/bdix.lua /usr/lib/lua/luci/controller/bdix.lua.backup && cp /tmp/bdix-fix.lua /usr/lib/lua/luci/controller/bdix.lua && chmod 644 /usr/lib/lua/luci/controller/bdix.lua && rm -rf /tmp/luci-* && /etc/init.d/uhttpd restart && echo "✅ Fixed! Access: http://$(uci get network.lan.ipaddr)/cgi-bin/luci/admin/system/bdix"
```

**That's it! The runtime error will be fixed automatically.**
