# BDIX OpenWRT Changelog

## Version 1.0.0-2 (Latest) - June 16, 2025

### 🎉 Major Features Added
- **Automatic Dependency Installation**: Package now automatically installs redsocks, iptables, and iptables-mod-nat-extra
- **Enhanced Installation Scripts**: Added pre-installation and post-installation scripts for better user experience
- **Smart Package Management**: Handles existing installations gracefully
- **Installation Verification**: Built-in checks to ensure proper installation

### 🔧 Technical Improvements
- **Robust Error Handling**: Better error messages and fallback options
- **Storage Space Verification**: Checks available space before installation
- **Service Conflict Resolution**: Automatically handles existing redsocks installations
- **Package List Updates**: Automatically updates opkg package lists during installation

### 📦 Installation Methods
1. **IPK Upload** (Recommended): Direct upload via OpenWRT web interface
2. **Auto Web Installation**: One-command installation with web interface
3. **Manual CLI Installation**: Traditional command-line installation

### 🌐 Web Interface Features
- Point-and-click configuration
- Real-time service status monitoring
- Domain whitelist management
- Automatic configuration file generation
- Service control buttons (Start/Stop/Restart)
- Input validation and error prevention

---

## Version 1.0.0-1 - June 16, 2025

### 🚀 Initial Release Features
- **LuCI Web Interface**: Full web-based configuration interface
- **Service Management**: Web-based start/stop/restart controls
- **Domain Management**: Easy addition/removal of direct connection domains
- **Configuration Generation**: Automatic redsocks config file creation
- **Real-time Status**: Live service monitoring

### 📋 Package Components
- Controller module for request handling
- Configuration model with form validation
- Status view template with real-time updates
- Service init script with UCI integration
- Default configuration with common domains

### 🛠️ Installation Options
- IPK package for web upload
- Shell script for automatic installation
- Manual installation instructions

---

## Original CLI Version - Earlier

### ⌨️ Command Line Features
- **Manual Configuration**: Edit config files directly
- **Service Scripts**: Basic start/stop/restart functionality
- **Domain Rules**: Static iptables rules for direct connections
- **Proxy Support**: SOCKS5 proxy configuration

### 📁 Components
- `bdix` init script
- `bdix.conf` configuration file
- `install.sh` installation script
- Manual configuration instructions

---

## 🔄 Migration Guide

### From CLI to Web Interface
1. **Backup existing configuration** (if any):
   ```bash
   cp /etc/bdix.conf /etc/bdix.conf.backup
   ```

2. **Install web interface**:
   - Upload `luci-app-bdix_1.0.0-2_all.ipk` via web interface
   - Or use auto-installation script

3. **Configure via web**:
   - Access Services → BDIX Proxy
   - Enter your previous proxy settings
   - Add any custom domains

4. **Verify installation**:
   ```bash
   wget -O - https://raw.githubusercontent.com/emonbhuiyan/BDIX-OpenWRT/main/verify-installation.sh | sh
   ```

---

## 🎯 Roadmap

### Planned Features
- **Multi-proxy Support**: Configure multiple proxy servers
- **Load Balancing**: Distribute traffic across multiple proxies
- **Traffic Statistics**: Monitor bandwidth usage
- **Scheduled Rules**: Time-based proxy rules
- **Mobile App**: Companion mobile application
- **Backup/Restore**: Configuration backup and restore

### Possible Enhancements
- **VPN Integration**: Combine with VPN services
- **DNS Filtering**: Built-in DNS-based filtering
- **QoS Integration**: Traffic prioritization
- **Monitoring Dashboard**: Advanced statistics and monitoring

---

## 🐛 Known Issues & Solutions

### Common Issues
1. **Package won't install**: Ensure sufficient storage space and internet connectivity
2. **Dependencies missing**: Use version 1.0.0-2 for automatic dependency installation
3. **Web interface not showing**: Clear browser cache and restart uhttpd
4. **Service won't start**: Verify proxy server settings and connectivity

### Troubleshooting
- Check system logs: `logread | grep bdix`
- Verify installation: Use verification script
- Manual dependency install: `opkg install redsocks iptables iptables-mod-nat-extra`
- Reset configuration: Remove and reinstall package

---

## 📞 Support & Contributing

### Getting Help
- **GitHub Issues**: Report bugs and request features
- **Documentation**: Check README and installation guides
- **Community**: Join discussions and share experiences
- **Contact**: https://fb.me/emoncontact

### Contributing
- **Bug Reports**: Help identify and fix issues
- **Feature Requests**: Suggest new capabilities
- **Documentation**: Improve guides and tutorials
- **Testing**: Test on different OpenWRT versions and devices

---

**Thank you for using BDIX OpenWRT!** 🎉
