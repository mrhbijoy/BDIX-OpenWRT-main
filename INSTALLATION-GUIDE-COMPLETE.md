# 🚀 BDIX OpenWRT Installation Guide

## 📋 Quick Information
- **Router IP**: 192.168.3.1
- **Username**: root
- **Password**: @bB420212
- **GitHub Repository**: https://github.com/mrhbijoy/BDIX-OpenWRT-main

## 🎯 Installation Methods (Try in Order)

### Method 1: IPK Package Upload (Recommended)
1. **Download IPK**: [luci-app-bdix_1.0.0-3_all.ipk](https://github.com/mrhbijoy/BDIX-OpenWRT-main/raw/main/luci-app-bdix/luci-app-bdix_1.0.0-3_all.ipk)
2. **Web Interface**: http://192.168.3.1 → System → Software
3. **Upload**: Click "Upload Package..." → Select IPK → Upload
4. **Access**: Services → BDIX Proxy

### Method 2: Automatic Test Script
SSH into your router and run the comprehensive test script:
```bash
ssh root@192.168.3.1
cd /tmp && wget https://github.com/mrhbijoy/BDIX-OpenWRT-main/raw/main/install-test.sh && chmod +x install-test.sh && ./install-test.sh
```

### Method 3: Manual Installation
If IPK fails, use manual installation:
```bash
ssh root@192.168.3.1
cd /tmp && wget https://github.com/mrhbijoy/BDIX-OpenWRT-main/raw/main/install-manual.sh && chmod +x install-manual.sh && ./install-manual.sh
```

### Method 4: Web Interface Auto-Install
```bash
ssh root@192.168.3.1
cd /tmp && wget https://github.com/mrhbijoy/BDIX-OpenWRT-main/raw/main/install-web.sh && chmod +x install-web.sh && ./install-web.sh
```

### Method 5: Original Command Line
```bash
ssh root@192.168.3.1
cd /tmp && wget https://github.com/mrhbijoy/BDIX-OpenWRT-main/raw/main/install.sh && chmod +x install.sh && ./install.sh
```

## 🔧 Configuration Steps

### 1. Access Web Interface
- Open: http://192.168.3.1
- Login: root / @bB420212
- Navigate: Services → BDIX Proxy

### 2. Configure Proxy Settings
- ✅ **Enable BDIX Proxy**: Check the box
- 🌐 **Proxy Server IP**: Enter your proxy IP
- 🔌 **Proxy Port**: Enter proxy port (usually 1080)
- 👤 **Username/Password**: Add if required
- 💾 **Save & Apply**: Save settings

### 3. Start Service
- Click **"Start"** button in the web interface
- Or via SSH: `service bdix start`

## 🎛️ Service Management

### Via Web Interface
- **Start**: Click Start button
- **Stop**: Click Stop button  
- **Restart**: Click Restart button
- **Status**: View real-time status

### Via SSH Commands
```bash
service bdix start    # Start service
service bdix stop     # Stop service
service bdix restart  # Restart service
service bdix enable   # Auto-start on boot
service bdix disable  # Disable auto-start
```

## 🔍 Troubleshooting

### If IPK Upload Fails:
1. **Check router storage**: `df -h`
2. **Update package lists**: `opkg update`
3. **Install dependencies manually**:
   ```bash
   opkg install luci-base redsocks iptables iptables-mod-nat-extra
   ```
4. **Try Method 2 (test script)**

### If Service Won't Start:
1. **Check proxy settings** in web interface
2. **Verify connectivity** to proxy server
3. **Check logs**: `logread | grep bdix`
4. **Restart web interface**: `service uhttpd restart`

### If Web Interface Missing:
1. **Clear browser cache** (Ctrl+F5)
2. **Clear LuCI cache**: `rm -rf /tmp/luci-*`
3. **Restart uhttpd**: `service uhttpd restart`
4. **Verify installation**: Use install-test.sh script

## 📱 What You Get

### ✨ Features
- 🖱️ **Point & Click Configuration**
- ⚡ **Real-time Status Monitoring**
- 🔄 **Automatic Config Generation**
- 🔐 **Secure Password Fields**
- 📝 **Input Validation**
- 🎨 **Professional Interface**

### 🛡️ Automatic Features
- 📦 **Dependency Installation**
- 🔧 **Service Management**
- 🧹 **Clean Setup Process**
- ✅ **Installation Verification**

## 🌐 Default Configuration

### Pre-configured Domains (Direct Connection)
- facebook.com
- messenger.com
- wise.com
- priyo.com
- upwork.com
- aibl.com.bd

## 🗑️ Uninstallation

### Via Web Interface
1. System → Software
2. Find "luci-app-bdix"
3. Click "Remove"

### Via SSH
```bash
opkg remove luci-app-bdix
# Or manual cleanup:
rm -rf /usr/lib/lua/luci/controller/bdix.lua
rm -rf /usr/lib/lua/luci/model/cbi/bdix.lua
rm -rf /usr/lib/lua/luci/view/bdix/
rm -rf /etc/init.d/bdix
rm -rf /etc/config/bdix
```

## 📞 Support

- 💬 **Contact**: https://fb.me/emoncontact
- 🐛 **Issues**: GitHub repository
- 📖 **Documentation**: README files
- 🔍 **Diagnostics**: Use install-test.sh script

---

**🎉 Success Indicator**: You should see "BDIX Proxy" under Services menu after installation!
