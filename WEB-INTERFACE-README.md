# BDIX Proxy Web Interface for OpenWRT

This package provides a user-friendly web interface for configuring and managing BDIX proxy on OpenWRT routers through LuCI.

## Features

- 🌐 **Web-based Configuration** - Easy-to-use web interface
- ⚙️ **Complete Settings Management** - Configure all proxy settings through GUI
- 🔄 **Service Control** - Start, stop, restart services with one click
- 📋 **Domain Management** - Add/remove domains for direct connection
- 📊 **Real-time Status** - Monitor service status in real-time
- 🔧 **Auto-configuration** - Automatically generates config files from web settings

## Quick Installation

Run this command on your OpenWRT router to install the web interface:

```bash
cd /tmp && wget https://github.com/emonbhuiyan/BDIX-OpenWRT/raw/main/install-web.sh && chmod +x install-web.sh && sh install-web.sh && rm install-web.sh
```

## Manual Installation

If you prefer to install manually:

1. **Install dependencies:**
   ```bash
   opkg update
   opkg install iptables iptables-mod-nat-extra redsocks luci-base
   ```

2. **Download and install the LuCI package:**
   ```bash
   # Create directories
   mkdir -p /usr/lib/lua/luci/controller
   mkdir -p /usr/lib/lua/luci/model/cbi
   mkdir -p /usr/lib/lua/luci/view/bdix
   mkdir -p /etc/config
   
   # Download files (replace URLs with your repository)
   wget -O /usr/lib/lua/luci/controller/bdix.lua [URL_TO_CONTROLLER]
   wget -O /usr/lib/lua/luci/model/cbi/bdix.lua [URL_TO_MODEL]
   wget -O /usr/lib/lua/luci/view/bdix/status.htm [URL_TO_VIEW]
   wget -O /etc/init.d/bdix [URL_TO_INIT_SCRIPT]
   wget -O /etc/config/bdix [URL_TO_CONFIG]
   
   chmod +x /etc/init.d/bdix
   ```

3. **Restart web interface:**
   ```bash
   rm -rf /tmp/luci-*
   /etc/init.d/uhttpd restart
   ```

## Usage

### Accessing the Web Interface

1. Open your router's web interface (usually http://192.168.1.1)
2. Login with your admin credentials
3. Navigate to **Services** → **BDIX Proxy**

### Configuration

#### Basic Settings
- **Enable BDIX Proxy**: Turn the service on/off
- **Proxy Server IP**: Your SOCKS5 proxy server IP address
- **Proxy Port**: Proxy server port (usually 1080)
- **Username/Password**: Authentication credentials (if required)
- **Local Port**: Local port for the proxy service (default: 1337)

#### Advanced Settings
- **Log Level**: Enable/disable logging
- **Start on Boot**: Automatically start service when router boots

#### Domain Management
- **Direct Connection Domains**: Add domains that should bypass the proxy
- Default domains include: facebook.com, messenger.com, wise.com, etc.
- You can add or remove domains as needed

### Service Control

The web interface provides real-time service control:
- **Start**: Start the BDIX proxy service
- **Stop**: Stop the service
- **Restart**: Restart the service
- **Status**: View current service status

## File Structure

```
luci-app-bdix/
├── Makefile
├── luasrc/
│   ├── controller/
│   │   └── bdix.lua                 # Main controller
│   ├── model/
│   │   └── cbi/
│   │       └── bdix.lua            # Configuration form
│   └── view/
│       └── bdix/
│           └── status.htm          # Status display template
└── root/
    ├── etc/
    │   ├── config/
    │   │   └── bdix                # UCI configuration file
    │   └── init.d/
    │       └── bdix                # Service init script
    └── ...
```

## Configuration Files

### UCI Configuration (`/etc/config/bdix`)
```
config bdix 'bdix'
    option enabled '1'
    option proxy_ip '192.168.1.100'
    option proxy_port '1080'
    option username 'your_username'
    option password 'your_password'
    option local_port '1337'
    option auto_start '1'

config domain
    option name 'facebook.com'

config domain
    option name 'messenger.com'
```

### Generated Configuration (`/etc/bdix.conf`)
The web interface automatically generates the redsocks configuration file based on your settings.

## Troubleshooting

### Service Won't Start
1. Check if proxy settings are correct
2. Verify proxy server is reachable
3. Check system logs: `logread | grep bdix`

### Web Interface Not Showing
1. Clear browser cache
2. Restart uhttpd: `/etc/init.d/uhttpd restart`
3. Clear LuCI cache: `rm -rf /tmp/luci-*`

### Configuration Not Saving
1. Check file permissions
2. Ensure enough storage space
3. Verify UCI is working: `uci show bdix`

## Command Line Management

You can still use command line if needed:

```bash
# Service control
service bdix start
service bdix stop
service bdix restart
service bdix enable
service bdix disable

# Configuration
uci set bdix.bdix.proxy_ip='192.168.1.100'
uci set bdix.bdix.proxy_port='1080'
uci commit bdix
service bdix restart
```

## Uninstallation

To remove the web interface:

```bash
# Stop and disable service
service bdix stop
service bdix disable

# Remove files
rm -rf /usr/lib/lua/luci/controller/bdix.lua
rm -rf /usr/lib/lua/luci/model/cbi/bdix.lua
rm -rf /usr/lib/lua/luci/view/bdix/
rm -rf /etc/init.d/bdix
rm -rf /etc/config/bdix
rm -rf /etc/bdix.conf

# Clear cache and restart web interface
rm -rf /tmp/luci-*
/etc/init.d/uhttpd restart
```

## Contributing

Feel free to contribute improvements or report issues!

## License

This project is licensed under the GNU General Public License v2.

---

**Thanks for using BDIX Web Interface!** 
Follow for more updates: [https://fb.me/emoncontact](https://fb.me/emoncontact)
