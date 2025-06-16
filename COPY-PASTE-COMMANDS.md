# BDIX One-Line Auto-Fix Commands

Copy and paste any ONE of these commands on your OpenWRT router to fix the table.insert runtime error:

## Option 1: Quick Fix (wget)
```bash
wget -O - https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/quick-fix.sh | sh
```

## Option 2: Quick Fix (curl)
```bash
curl -k -s -L https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/quick-fix-curl.sh | sh
```

## Option 3: Emergency Table Insert Fix
```bash
wget -O - https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/fix-table-insert.sh | sh
```

## Option 4: Manual One-Liner (wget)
```bash
wget -O /tmp/fix.lua https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/bdix-controller-simple.lua && /etc/init.d/bdix stop && cp /usr/lib/lua/luci/controller/bdix.lua /usr/lib/lua/luci/controller/bdix.lua.backup && cp /tmp/fix.lua /usr/lib/lua/luci/controller/bdix.lua && chmod 644 /usr/lib/lua/luci/controller/bdix.lua && rm -rf /tmp/luci-* && /etc/init.d/uhttpd restart && echo "✅ Fixed! Access: http://$(uci get network.lan.ipaddr)/cgi-bin/luci/admin/system/bdix"
```

## Option 5: Manual One-Liner (curl)
```bash
curl -k -s -L -o /tmp/fix.lua https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/bdix-controller-simple.lua && /etc/init.d/bdix stop && cp /usr/lib/lua/luci/controller/bdix.lua /usr/lib/lua/luci/controller/bdix.lua.backup && cp /tmp/fix.lua /usr/lib/lua/luci/controller/bdix.lua && chmod 644 /usr/lib/lua/luci/controller/bdix.lua && rm -rf /tmp/luci-* && /etc/init.d/uhttpd restart && echo "✅ Fixed! Access: http://$(uci get network.lan.ipaddr)/cgi-bin/luci/admin/system/bdix"
```

**✅ Any of these will fix the "bad argument #2 to 'insert'" error immediately!**
