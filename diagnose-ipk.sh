#!/bin/sh

# BDIX IPK Package Diagnostic Script
# Run this on your OpenWRT router to diagnose IPK issues

echo "============================================="
echo "BDIX IPK Package Diagnostic Tool"
echo "============================================="
echo ""

# Check basic system info
echo "📋 System Information:"
echo "Router Model: $(cat /tmp/sysinfo/model 2>/dev/null || echo 'Unknown')"
echo "OpenWRT Version: $(cat /etc/openwrt_release | grep DISTRIB_DESCRIPTION | cut -d'"' -f2 2>/dev/null || echo 'Unknown')"
echo "Architecture: $(uname -m)"
echo "Free Space: $(df -h /tmp | tail -1 | awk '{print $4}') available in /tmp"
echo ""

# Check if required tools exist
echo "🔧 Required Tools Check:"
for tool in opkg ar tar gzip; do
    if command -v $tool >/dev/null 2>&1; then
        echo "✓ $tool: Available"
    else
        echo "✗ $tool: Missing"
    fi
done
echo ""

# Test IPK package structure
if [ -f "/tmp/upload.ipk" ]; then
    echo "📦 Testing uploaded IPK package:"
    
    # Check file size
    size=$(ls -lh /tmp/upload.ipk | awk '{print $5}')
    echo "File size: $size"
    
    # Check if it's an ar archive
    if command -v file >/dev/null 2>&1; then
        file_type=$(file /tmp/upload.ipk)
        echo "File type: $file_type"
    fi
    
    # Try to list contents
    echo "Attempting to list IPK contents:"
    if ar -t /tmp/upload.ipk 2>/dev/null; then
        echo "✓ IPK structure looks valid"
        
        # Extract and check each component
        cd /tmp
        mkdir -p ipk_test
        cd ipk_test
        
        if ar -x ../upload.ipk 2>/dev/null; then
            echo "✓ Successfully extracted IPK"
            
            for file in debian-binary control.tar.gz data.tar.gz; do
                if [ -f "$file" ]; then
                    echo "✓ Found: $file"
                    case $file in
                        debian-binary)
                            echo "  Version: $(cat $file)"
                            ;;
                        *.tar.gz)
                            echo "  Contents: $(tar -tzf $file 2>/dev/null | wc -l) files"
                            if ! tar -tzf $file >/dev/null 2>&1; then
                                echo "  ✗ Error: Corrupted tar.gz file"
                            fi
                            ;;
                    esac
                else
                    echo "✗ Missing: $file"
                fi
            done
        else
            echo "✗ Failed to extract IPK - Archive is corrupted"
        fi
        
        # Cleanup
        cd /tmp
        rm -rf ipk_test
    else
        echo "✗ IPK structure is invalid - not a proper ar archive"
    fi
else
    echo "📦 No uploaded IPK found at /tmp/upload.ipk"
fi

echo ""

# Check dependencies
echo "📋 Dependency Check:"
for pkg in luci-base redsocks iptables iptables-mod-nat-extra; do
    if opkg list-installed | grep -q "^$pkg "; then
        version=$(opkg list-installed | grep "^$pkg " | awk '{print $3}')
        echo "✓ $pkg: $version"
    else
        echo "✗ $pkg: Not installed"
    fi
done

echo ""

# Check LuCI installation
echo "🌐 LuCI Web Interface Check:"
if [ -d "/usr/lib/lua/luci" ]; then
    echo "✓ LuCI is installed"
    if [ -f "/usr/lib/lua/luci/controller/admin/services.lua" ]; then
        echo "✓ Services menu available"
    else
        echo "⚠ Services menu might not be available"
    fi
else
    echo "✗ LuCI not found"
fi

echo ""

# Memory and storage check
echo "💾 System Resources:"
echo "RAM Usage: $(free | grep Mem | awk '{printf "%.1f%%", $3/$2 * 100.0}')"
echo "Root FS: $(df -h / | tail -1 | awk '{print $5}') used"
echo "Tmp FS: $(df -h /tmp | tail -1 | awk '{print $5}') used"

echo ""

# OpenWRT package format check
echo "📝 Package Format Test:"
echo "Creating test IPK to verify format requirements..."

cd /tmp
mkdir -p test_ipk/CONTROL
mkdir -p test_ipk/data

cat > test_ipk/CONTROL/control << 'EOF'
Package: test-package
Version: 1.0.0
Architecture: all
Description: Test package
EOF

echo "2.0" > test_ipk/debian-binary

cd test_ipk
tar --numeric-owner --group=0 --owner=0 -czf control.tar.gz -C CONTROL .
tar --numeric-owner --group=0 --owner=0 -czf data.tar.gz -C data .
ar r ../test.ipk debian-binary control.tar.gz data.tar.gz

cd /tmp
if opkg install --force-depends test.ipk 2>/dev/null; then
    echo "✓ Test IPK format is accepted by this system"
    opkg remove test-package 2>/dev/null
else
    echo "✗ This system has strict IPK format requirements"
fi

rm -rf test_ipk test.ipk

echo ""
echo "============================================="
echo "🔍 Diagnostic Complete!"
echo ""
echo "If you see issues above, try:"
echo "1. Check IPK file integrity"
echo "2. Install missing dependencies manually"
echo "3. Use the command line installation method"
echo "============================================="
