-- Copyright (C) 2023 OpenWrt.org

local fs = require "nixio.fs"

m = Map("bdix", translate("BDIX Proxy"),
	translate("Configure BDIX proxy settings for bypassing restrictions in Bangladesh."))

-- Service Status Section
s = m:section(TypedSection, "status", translate("Service Status"))
s.anonymous = true
s.template = "bdix/status"

-- Basic Settings Section
s = m:section(TypedSection, "bdix", translate("Proxy Settings"))
s.anonymous = true
s.addremove = false

enabled = s:option(Flag, "enabled", translate("Enable BDIX Proxy"))
enabled.rmempty = false

-- Proxy Server Settings
proxy_ip = s:option(Value, "proxy_ip", translate("Proxy Server IP"))
proxy_ip.placeholder = "192.168.1.100"
proxy_ip.datatype = "ipaddr"
proxy_ip.rmempty = false

proxy_port = s:option(Value, "proxy_port", translate("Proxy Port"))
proxy_port.placeholder = "1080"
proxy_port.datatype = "port"
proxy_port.rmempty = false

-- Authentication
username = s:option(Value, "username", translate("Username"))
username.placeholder = "your_username"

password = s:option(Value, "password", translate("Password"))
password.placeholder = "your_password"
password.password = true

-- Local Settings
local_port = s:option(Value, "local_port", translate("Local Port"))
local_port.placeholder = "1337"
local_port.datatype = "port"
local_port.default = "1337"

-- Advanced Settings Section
s2 = m:section(TypedSection, "advanced", translate("Advanced Settings"))
s2.anonymous = true
s2.addremove = false

log_level = s2:option(ListValue, "log_level", translate("Log Level"))
log_level:value("off", translate("Off"))
log_level:value("on", translate("On"))
log_level.default = "on"

-- Direct Connection Domains Section
s3 = m:section(TypedSection, "domain", translate("Direct Connection Domains"),
	translate("Domains that will bypass the proxy and connect directly"))
s3.addremove = true
s3.anonymous = true
s3.template = "cbi/tblsection"

domain_name = s3:option(Value, "name", translate("Domain Name"))
domain_name.placeholder = "example.com"
domain_name.rmempty = false

-- Auto-start setting
auto_start = s:option(Flag, "auto_start", translate("Start on Boot"))
auto_start.rmempty = false

function m.on_commit(self)
	-- Generate bdix.conf from UCI config
	local uci = require "luci.model.uci".cursor()
	local bdix_config = uci:get_all("bdix", "bdix")
	
	if bdix_config then
		local conf_content = string.format([[
base {
	log_debug = off;
	log_info = %s;
	log = "syslog:local7";
	daemon = on;
	redirector = iptables;
}

redsocks {
	local_ip = 0.0.0.0;
	local_port = %s;
	ip = %s;
	port = %s;
	type = socks5;
	login = "%s";
	password = "%s";
}
]], 
		bdix_config.log_level or "on",
		bdix_config.local_port or "1337",
		bdix_config.proxy_ip or "127.0.0.1",
		bdix_config.proxy_port or "1080",
		bdix_config.username or "",
		bdix_config.password or ""
		)
		
		local file = io.open("/etc/bdix.conf", "w")
		if file then
			file:write(conf_content)
			file:close()
		end
		
		-- Update init script with domains
		update_init_script()
		
		-- Handle service state
		if bdix_config.enabled == "1" then
			os.execute("/etc/init.d/bdix restart")
			if bdix_config.auto_start == "1" then
				os.execute("/etc/init.d/bdix enable")
			end
		else
			os.execute("/etc/init.d/bdix stop")
			os.execute("/etc/init.d/bdix disable")
		end
	end
end

function update_init_script()
	local uci = require "luci.model.uci".cursor()
	local domains = {}
	
	-- Get direct connection domains from config
	uci:foreach("bdix", "domain", function(s)
		if s.name then
			table.insert(domains, s.name)
		end
	end)
	
	-- Default domains if none configured
	if #domains == 0 then
		domains = {
			"facebook.com",
			"messenger.com", 
			"wise.com",
			"priyo.com",
			"upwork.com",
			"aibl.com.bd"
		}
	end
	
	-- Read original init script
	local init_script = fs.readfile("/etc/init.d/bdix")
	if init_script then
		-- Replace domain rules section
		local domain_rules = ""
		for _, domain in ipairs(domains) do
			domain_rules = domain_rules .. string.format('    iptables -t nat -A BDIX -d %s -j RETURN\n', domain)
		end
		
		-- Update the script
		init_script = init_script:gsub(
			"    # Direct connections for specific domains.-\n    iptables %-t nat %-A BDIX %-d aibl%.com%.bd %-j RETURN\n",
			"    # Direct connections for specific domains\n" .. domain_rules
		)
		
		fs.writefile("/etc/init.d/bdix", init_script)
		os.execute("chmod +x /etc/init.d/bdix")
	end
end

return m
