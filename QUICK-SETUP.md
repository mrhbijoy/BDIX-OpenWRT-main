# 🚀 BDIX Quick Setup Guide

## 📦 Super Easy Installation (Recommended)

### Method 1: One-Click Web Upload
1. **Download**: [luci-app-bdix_1.0.0-3_all.ipk](https://github.com/mrhbijoy/BDIX-OpenWRT-main/raw/main/luci-app-bdix/luci-app-bdix_1.0.0-3_all.ipk)
2. **Go to**: http://192.168.3.1 → System → Software
3. **Click**: "Upload Package..." → Select IPK file → Upload
4. **Done!** 🎉 Dependencies install automatically!

### Method 2: One-Command Installation
```bash
cd /tmp && wget https://github.com/mrhbijoy/BDIX-OpenWRT-main/raw/main/install-web.sh && chmod +x install-web.sh && sh install-web.sh && rm install-web.sh
```

## ⚙️ Quick Configuration

### Access Web Interface
1. Open router web interface (usually http://192.168.1.1)
2. Navigate to: **Services** → **BDIX Proxy**
3. You'll see a clean, professional interface! 

### Basic Setup (2 minutes)
1. **✅ Enable BDIX Proxy**: Check the box
2. **🌐 Proxy Server IP**: Enter your proxy IP (e.g., 192.168.1.100)
3. **🔌 Proxy Port**: Enter port (usually 1080)
4. **👤 Credentials**: Add username/password if required
5. **💾 Save & Apply**: Click to save settings
6. **▶️ Start Service**: Click the "Start" button

### Advanced Options (Optional)
- **🚀 Start on Boot**: Auto-start service when router reboots
- **📋 Log Level**: Enable/disable detailed logging
- **🔗 Domain Management**: Add domains that bypass the proxy

## 🎛️ Service Control

### Real-Time Control Buttons
- **▶️ Start**: Start the BDIX proxy service
- **⏹️ Stop**: Stop the service
- **🔄 Restart**: Restart the service
- **📊 Status**: Live status indicator (Running/Stopped)

### Status Indicators
- **🟢 Running**: Service is active and working
- **🔴 Stopped**: Service is not running
- **🟠 Not Configured**: Needs configuration

## 🔧 Troubleshooting

### Service Won't Start?
1. **Check proxy settings**: Verify IP and port are correct
2. **Test connectivity**: Ensure proxy server is reachable
3. **Check logs**: `logread | grep bdix`

### Web Interface Missing?
1. **Clear browser cache**: Hard refresh (Ctrl+F5)
2. **Restart web server**: `service uhttpd restart`
3. **Verify installation**: Use our verification script

### Quick Health Check
```bash
cd /tmp && wget -O - https://raw.githubusercontent.com/mrhbijoy/BDIX-OpenWRT-main/main/verify-installation.sh | sh
```

## 📱 What You Get

### ✨ Features
- **🖱️ Point & Click Configuration**: No command line needed
- **⚡ Real-time Monitoring**: Live service status
- **🔄 Automatic Config Generation**: Creates proper files
- **🔐 Secure Input**: Password fields are protected
- **📝 Input Validation**: Prevents configuration errors
- **🎨 Professional UI**: Clean, modern interface

### 🛡️ Automatic Features
- **📦 Dependency Installation**: Installs required packages automatically
- **🔧 Service Management**: Handles existing installations
- **🧹 Clean Setup**: Removes conflicts during installation
- **✅ Installation Verification**: Confirms everything works

## 🎯 Default Configuration

### Pre-configured Domains (Direct Connection)
- facebook.com
- messenger.com  
- wise.com
- priyo.com
- upwork.com
- aibl.com.bd

You can add/remove domains as needed through the web interface!

## 🔄 Uninstallation

### Via Web Interface
1. Go to: System → Software
2. Find "luci-app-bdix"
3. Click "Remove"

### Via Command Line
```bash
opkg remove luci-app-bdix
```

## 🆘 Need Help?

### Quick Links
- 📋 [Detailed Installation Guide](IPK-INSTALLATION-GUIDE.md)
- 🌐 [Web Interface Documentation](WEB-INTERFACE-README.md)
- 📝 [Changelog](CHANGELOG.md)
- 🔍 [Verification Script](verify-installation.sh)

### Support
- 💬 Contact: https://fb.me/emoncontact
- 🐛 Issues: GitHub repository
- 📖 Documentation: README files

---

**🎉 Enjoy your new BDIX Web Interface!**

*Installation time: ~2 minutes | Configuration time: ~2 minutes | Total setup: ~5 minutes* ⏱️
