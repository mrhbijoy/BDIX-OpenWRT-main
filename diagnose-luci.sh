#!/bin/sh

# BDIX LuCI Diagnostic Script - Specifically for 404 errors
# This script will diagnose and fix LuCI module registration issues

echo "🔍 BDIX LuCI Diagnostic Script"
echo "============================="
echo ""

echo "📂 Checking LuCI file locations..."

# Check if files exist
CONTROLLER="/usr/lib/lua/luci/controller/bdix.lua"
MODEL="/usr/lib/lua/luci/model/cbi/bdix.lua"
VIEW="/usr/lib/lua/luci/view/bdix/status.htm"

if [ -f "$CONTROLLER" ]; then
    echo "✅ Controller found: $CONTROLLER"
    echo "   Size: $(wc -c < $CONTROLLER) bytes"
    echo "   Permissions: $(ls -l $CONTROLLER | awk '{print $1}')"
else
    echo "❌ Controller missing: $CONTROLLER"
    MISSING_FILES=1
fi

if [ -f "$MODEL" ]; then
    echo "✅ Model found: $MODEL"
    echo "   Size: $(wc -c < $MODEL) bytes"
else
    echo "❌ Model missing: $MODEL"
    MISSING_FILES=1
fi

if [ -f "$VIEW" ]; then
    echo "✅ View found: $VIEW"
    echo "   Size: $(wc -c < $VIEW) bytes"
else
    echo "❌ View missing: $VIEW"
    MISSING_FILES=1
fi

echo ""
echo "🧪 Testing Lua syntax..."

if [ -f "$CONTROLLER" ]; then
    if lua -c "$CONTROLLER" 2>/dev/null; then
        echo "✅ Controller syntax: OK"
    else
        echo "❌ Controller syntax: Error"
        echo "   Syntax check output:"
        lua -c "$CONTROLLER"
    fi
fi

if [ -f "$MODEL" ]; then
    if lua -c "$MODEL" 2>/dev/null; then
        echo "✅ Model syntax: OK"
    else
        echo "❌ Model syntax: Error"
        echo "   Syntax check output:"
        lua -c "$MODEL"
    fi
fi

echo ""
echo "🗂️ Checking LuCI cache and index..."

echo "Removing all LuCI cache files..."
rm -rf /tmp/luci-*
rm -f /tmp/luci-indexcache

echo "LuCI cache files removed."

echo ""
echo "🔄 Restarting web services..."

/etc/init.d/uhttpd stop
sleep 3
/etc/init.d/uhttpd start

echo "uhttpd restarted."

echo ""
echo "📋 LuCI module structure check..."

# Check if the controller is structured correctly
if [ -f "$CONTROLLER" ]; then
    echo "Controller content preview:"
    head -10 "$CONTROLLER"
    echo ""
    
    # Check for required LuCI patterns
    if grep -q "module.*bdix" "$CONTROLLER"; then
        echo "✅ Module declaration found"
    else
        echo "❌ Module declaration missing"
    fi
    
    if grep -q "function index" "$CONTROLLER"; then
        echo "✅ Index function found"
    else
        echo "❌ Index function missing"
    fi
    
    if grep -q "services" "$CONTROLLER"; then
        echo "✅ Services reference found"
    else
        echo "❌ Services reference missing"
    fi
fi

echo ""
if [ "$MISSING_FILES" = "1" ]; then
    echo "❗ MISSING FILES DETECTED!"
    echo ""
    echo "🔧 Auto-fixing by reinstalling web files..."
    echo ""
    
    # Download and install the web files directly
    echo "Creating directories..."
    mkdir -p /usr/lib/lua/luci/controller
    mkdir -p /usr/lib/lua/luci/model/cbi
    mkdir -p /usr/lib/lua/luci/view/bdix
    
    echo "Downloading controller..."
    wget -O "$CONTROLLER" "https://github.com/mrhbijoy/BDIX-OpenWRT-main/raw/main/luci-app-bdix/luasrc/controller/bdix.lua"
    
    echo "Downloading model..."
    wget -O "$MODEL" "https://github.com/mrhbijoy/BDIX-OpenWRT-main/raw/main/luci-app-bdix/luasrc/model/cbi/bdix.lua"
    
    echo "Downloading view..."
    wget -O "$VIEW" "https://github.com/mrhbijoy/BDIX-OpenWRT-main/raw/main/luci-app-bdix/luasrc/view/bdix/status.htm"
    
    echo "Setting permissions..."
    chmod 644 "$CONTROLLER" "$MODEL" "$VIEW"
    
    echo "Clearing cache again..."
    rm -rf /tmp/luci-*
    
    echo "Restarting uhttpd..."
    /etc/init.d/uhttpd restart
    
    echo ""
    echo "✅ Files reinstalled! Wait 30 seconds then try:"
    echo "   http://192.168.3.1/cgi-bin/luci/admin/services/bdix"
else
    echo "📝 Manual steps to try:"
    echo ""
    echo "1. Wait 30 seconds for uhttpd to fully restart"
    echo "2. Try accessing: http://192.168.3.1/cgi-bin/luci/admin/services/bdix"
    echo "3. If still 404, try: http://192.168.3.1/cgi-bin/luci"
    echo "   Then navigate to Services > BDIX"
    echo ""
    echo "4. Alternative access via System > Services:"
    echo "   Look for 'bdix' service in the services list"
fi

echo ""
echo "🔍 Final verification..."
sleep 5

# Try to load the controller in Lua to see if it works
if lua -e "
package.path = '/usr/lib/lua/?.lua;/usr/lib/lua/?/init.lua;' .. package.path
require('luci.controller.bdix')
print('Controller loads successfully')
" 2>/dev/null; then
    echo "✅ Controller can be loaded by Lua"
else
    echo "❌ Controller cannot be loaded by Lua"
    echo "   This might indicate a syntax or dependency issue"
fi

echo ""
echo "🎯 Try these URLs:"
echo "   http://192.168.3.1/cgi-bin/luci/admin/services/bdix"
echo "   http://192.168.3.1/cgi-bin/luci (then navigate to Services)"
echo ""

exit 0
