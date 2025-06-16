#!/bin/sh

# Remove 172.16.0.0/12 from BDIX exclusions
echo "🔧 Removing 172.16.0.0/12 from BDIX exclusions"
echo "=============================================="
echo ""

echo "📋 This will allow 172.16.0.0/12 traffic to go through SOCKS5 proxy"
echo ""

# Stop BDIX service first
echo "🛑 Stopping BDIX service..."
/etc/init.d/bdix stop

# Check current iptables rules
echo "📋 Current BDIX iptables rules:"
iptables -t nat -L BDIX -n --line-numbers 2>/dev/null | grep "172.16.0.0/12" && echo "Found 172.16.0.0/12 exclusion" || echo "No 172.16.0.0/12 exclusion found"

# Clear existing BDIX chain
echo "🗑️ Clearing existing BDIX rules..."
iptables -t nat -D PREROUTING -i br-lan -p tcp -j BDIX 2>/dev/null
iptables -t nat -F BDIX 2>/dev/null
iptables -t nat -X BDIX 2>/dev/null

# Get configuration
local_port=$(uci get bdix.bdix.local_port 2>/dev/null || echo "1337")

echo "🔧 Creating new BDIX chain without 172.16.0.0/12..."

# Create BDIX chain
iptables -t nat -N BDIX 2>/dev/null

# Add safety exclusions (WITHOUT 172.16.0.0/12)
echo "   Adding exclusion: 192.168.0.0/16"
iptables -t nat -A BDIX -d 192.168.0.0/16 -j RETURN

echo "   Adding exclusion: 10.0.0.0/8"
iptables -t nat -A BDIX -d 10.0.0.0/8 -j RETURN

echo "   Adding exclusion: 127.0.0.0/8"
iptables -t nat -A BDIX -d 127.0.0.0/8 -j RETURN

echo "   Adding exclusion: 169.254.0.0/16"
iptables -t nat -A BDIX -d 169.254.0.0/16 -j RETURN

echo "   Adding exclusion: 224.0.0.0/4"
iptables -t nat -A BDIX -d 224.0.0.0/4 -j RETURN

echo "   Adding exclusion: 240.0.0.0/4"
iptables -t nat -A BDIX -d 240.0.0.0/4 -j RETURN

echo "   ✅ SKIPPING 172.16.0.0/12 - Traffic will go through SOCKS5!"

# Add redirect rule
echo "🔄 Adding redirect rule to port $local_port..."
iptables -t nat -A BDIX -p tcp -j REDIRECT --to-ports $local_port

# Insert main rule
echo "📌 Inserting main BDIX rule..."
iptables -t nat -I PREROUTING -i br-lan -p tcp -j BDIX

echo "✅ iptables rules updated"

# Start BDIX service
echo "🚀 Starting BDIX service..."
/etc/init.d/bdix start

if [ $? -eq 0 ]; then
    echo "✅ BDIX service started successfully"
else
    echo "⚠️  BDIX service start attempted"
fi

echo ""
echo "🔍 Verification:"
echo "==============="

# Show current BDIX rules
echo "📋 Current BDIX rules:"
iptables -t nat -L BDIX -n --line-numbers

echo ""
echo "🎯 Result:"
echo "========="
echo "✅ 172.16.0.0/12 traffic will now go through SOCKS5 proxy"
echo "✅ Other private ranges still excluded for safety"
echo "✅ Your SOCKS5: 113.192.43.43:1080"
echo ""
echo "🧪 Test with:"
echo "   ping 172.16.1.1"
echo "   curl -I http://172.16.1.1"
echo ""
echo "🔄 To restore exclusion later:"
echo "   iptables -t nat -I BDIX 3 -d 172.16.0.0/12 -j RETURN"
