#!/bin/bash

# Script to create proper IPK package for OpenWRT
# This creates the correct tar.gz format that OpenWRT expects

PACKAGE_NAME="luci-app-bdix"
VERSION="1.0.0-1"
ARCH="all"

echo "Building proper IPK package for OpenWRT..."

# Create build directory
BUILD_DIR="build-proper"
rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR

# Copy files to build directory
cp -r CONTROL $BUILD_DIR/
cp -r data $BUILD_DIR/

# Create debian-binary
echo "2.0" > $BUILD_DIR/debian-binary

# Set proper permissions
chmod 755 $BUILD_DIR/CONTROL/postinst
chmod 755 $BUILD_DIR/CONTROL/prerm
chmod 755 $BUILD_DIR/CONTROL/postrm
chmod 755 $BUILD_DIR/data/etc/init.d/bdix

# Create proper tar.gz files
cd $BUILD_DIR

# Create control.tar.gz
tar -czf control.tar.gz -C CONTROL .

# Create data.tar.gz  
tar -czf data.tar.gz -C data .

# Create the IPK package using ar
ar rcs "../${PACKAGE_NAME}_${VERSION}_${ARCH}.ipk" debian-binary control.tar.gz data.tar.gz

cd ..

# Cleanup
rm -rf $BUILD_DIR

echo "✅ Proper IPK package created: ${PACKAGE_NAME}_${VERSION}_${ARCH}.ipk"
echo ""
echo "📦 Installation:"
echo "1. Upload this IPK file via System → Software → Upload Package"
echo "2. Or use: opkg install ${PACKAGE_NAME}_${VERSION}_${ARCH}.ipk"
echo ""
echo "🎯 Access via: Services → BDIX Proxy"
