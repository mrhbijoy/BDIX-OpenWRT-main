# BDIX Web Interface - IPK Package Installation

## 📦 IPK Package Installation via Web Interface

You can now install the BDIX web interface directly through OpenWRT's package manager web interface!

### 🌐 Installation Steps

1. **Download the IPK Package**
   - Download `luci-app-bdix_1.0.0-2_all.ipk` from the repository

2. **Access OpenWRT Web Interface**
   - Open your router's web interface (usually http://192.168.1.1)
   - Login with your admin credentials

3. **Install via Package Manager**
   - Navigate to: **System** → **Software**
   - Click **"Upload Package..."** button
   - Select the `luci-app-bdix_1.0.0-2_all.ipk` file
   - Click **"Upload"** and wait for installation to complete
   - **Dependencies are installed automatically!** 🎉

4. **Access the Web Interface**
   - After installation, refresh your browser
   - Navigate to: **Services** → **BDIX Proxy**
   - Configure your proxy settings through the GUI

### 🔧 Configuration via Web Interface

#### Basic Settings
- **✅ Enable BDIX Proxy**: Turn the service on/off
- **🌐 Proxy Server IP**: Your SOCKS5 proxy server IP address
- **🔌 Proxy Port**: Proxy server port (usually 1080)
- **👤 Username/Password**: Authentication credentials (if required)
- **⚙️ Local Port**: Local port for the proxy service (default: 1337)

#### Advanced Settings
- **📋 Log Level**: Enable/disable detailed logging
- **🚀 Start on Boot**: Automatically start service when router boots

#### Domain Management
- **🔗 Direct Connection Domains**: Manage domains that bypass the proxy
- **➕ Add Domain**: Click "Add" to add new domains
- **❌ Remove Domain**: Delete domains from the list
- Default domains: facebook.com, messenger.com, wise.com, priyo.com, upwork.com, aibl.com.bd

### 🎛️ Service Control

Real-time service management through the web interface:
- **▶️ Start**: Start the BDIX proxy service
- **⏹️ Stop**: Stop the service  
- **🔄 Restart**: Restart the service
- **📊 Status**: View current service status (Running/Stopped)

### 📱 Features

- **🖱️ Point & Click Configuration** - No command line needed
- **⚡ Real-time Status Updates** - Live service monitoring
- **🔄 Automatic Config Generation** - Creates proper config files
- **🔐 Secure Settings** - Password fields are protected
- **📝 Input Validation** - Prevents configuration errors
- **🎨 Professional UI** - Clean, modern interface

## 🚀 Features of the New Version (1.0.0-2)

### ✨ **Automatic Dependency Installation**
- **🔄 Smart Dependency Detection**: Automatically checks for missing packages
- **📦 Auto-Installation**: Installs redsocks, iptables, and iptables-mod-nat-extra automatically
- **✅ Installation Verification**: Confirms successful dependency installation
- **⚠️ Graceful Fallback**: Provides manual installation instructions if auto-install fails

### 🛡️ **Enhanced Installation Process**
- **📋 Pre-Installation Checks**: Verifies system compatibility and storage space
- **🔧 Service Management**: Properly handles existing redsocks installations
- **🧹 Clean Installation**: Removes conflicting services before installation
- **📊 Detailed Feedback**: Provides clear installation progress messages

### 💡 **Installation Process Overview**
When you upload the IPK package, it automatically:

1. **Pre-Installation** (preinst):
   - ✓ Checks OpenWRT compatibility
   - ✓ Verifies available storage space
   - ✓ Updates package lists

2. **Dependency Installation** (postinst):
   - ✓ Detects missing dependencies
   - ✓ Automatically installs redsocks
   - ✓ Automatically installs iptables packages
   - ✓ Stops conflicting services

3. **Service Setup**:
   - ✓ Clears LuCI cache
   - ✓ Restarts web interface
   - ✓ Makes BDIX available in menu

### 🎯 **Zero-Configuration Installation**
No more manual dependency installation! Just upload and go!

### 🛠️ Manual Installation Alternative

If you prefer command line installation:

```bash
# Upload IPK to router first, then:
opkg install luci-app-bdix_1.0.0-2_all.ipk

# Or use the web-based installer script:
cd /tmp && wget https://github.com/emonbhuiyan/BDIX-OpenWRT/raw/main/install-web.sh && chmod +x install-web.sh && sh install-web.sh && rm install-web.sh
```

### 🗑️ Uninstallation

To remove the package:

**Via Web Interface:**
1. Go to: System → Software
2. Find "luci-app-bdix" in installed packages
3. Click "Remove"

**Via Command Line:**
```bash
opkg remove luci-app-bdix
```

### ❗ Troubleshooting

#### Package Won't Install
- **Check Dependencies**: Ensure redsocks and iptables packages are installed
- **Storage Space**: Verify sufficient storage space on router
- **Package Format**: Ensure IPK file isn't corrupted

#### Web Interface Not Showing
- **Clear Browser Cache**: Hard refresh (Ctrl+F5)
- **Restart Web Server**: `service uhttpd restart`
- **Check Installation**: Verify package is properly installed

#### Service Won't Start
- **Proxy Settings**: Verify proxy server IP and port are correct
- **Network Connectivity**: Ensure proxy server is reachable
- **Check Logs**: `logread | grep bdix`

### 📋 Package Details

- **Package Name**: luci-app-bdix
- **Version**: 1.0.0-2
- **Architecture**: all (universal)
- **Size**: ~6KB
- **Dependencies**: Automatically installs redsocks, iptables, iptables-mod-nat-extra

### 🚀 What's Next?

After installation, you'll have:
- ✅ Full web-based BDIX proxy management
- ✅ Real-time service control
- ✅ Easy domain whitelist management  
- ✅ Automatic configuration generation
- ✅ Professional, user-friendly interface

No more manual config file editing or command line complexity!

---

**🎉 Enjoy your new BDIX Web Interface!**  
Follow for more updates: [https://fb.me/emoncontact](https://fb.me/emoncontact)
