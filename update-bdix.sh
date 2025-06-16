#!/bin/ash
# BDIX Proxy Configuration Menu Script for OpenWrt

# Function to update Redsocks configuration
update_proxy_config() {
    echo "Enter new proxy details:"
    read -p "  Proxy IP: " new_ip
    read -p "  Proxy Port: " new_port
    read -p "  SOCKS5 Username: " new_username
    read -p "  SOCKS5 Password: " new_password

    # Update /etc/bdix.conf
    sed -i "s/\(ip = \).*/\1${new_ip};/" /etc/bdix.conf
    sed -i "s/\(port = \).*/\1${new_port};/" /etc/bdix.conf
    sed -i "s/\(login = \).*/\1\"${new_username}\";/" /etc/bdix.conf
    sed -i "s/\(password = \).*/\1\"${new_password}\";/" /etc/bdix.conf

    echo "Proxy configuration updated in /etc/bdix.conf."
}

# Function to add a direct connection bypass rule
add_direct_connection() {
    read -p "Enter domain or CIDR to bypass proxy: " direct_conn
    # Insert before the last safety exclusion (240.0.0.0/4)
    sed -i "/iptables -t nat -A BDIX -d 240\.0\.0\.0\/4 -j RETURN/i \\    iptables -t nat -A BDIX -d ${direct_conn} -j RETURN" /etc/init.d/bdix
    echo "Direct connection added: ${direct_conn}"
}

# Display menu
echo "BDIX Proxy Configuration Menu:"
echo "1) Update proxy IP, Port, Username & Password"
echo "2) Start BDIX proxy service"
echo "3) Stop BDIX proxy service"
echo "4) Restart BDIX proxy service"
echo "5) Enable BDIX auto-start"
echo "6) Disable BDIX auto-start"
echo "7) Edit BDIX init script (direct connections)"
echo "8) Add a direct connection bypass rule"
echo "0) Exit"

echo
read -p "Enter choice [0-8]: " choice

echo
case "$choice" in
    1)
        update_proxy_config
        ;;
    2)
        /etc/init.d/bdix start
        echo "BDIX service started."
        ;;
    3)
        /etc/init.d/bdix stop
        echo "BDIX service stopped."
        ;;
    4)
        /etc/init.d/bdix restart
        echo "BDIX service restarted."
        ;;
    5)
        /etc/init.d/bdix enable
        echo "BDIX auto-start enabled."
        ;;
    6)
        /etc/init.d/bdix disable
        echo "BDIX auto-start disabled."
        ;;
    7)
        echo "Opening init script in vi..."
        vi /etc/init.d/bdix
        ;;
    8)
        add_direct_connection
        ;;
    0)
        echo "Exiting."
        exit 0
        ;;
    *)
        echo "Invalid choice."
        ;;
esac
