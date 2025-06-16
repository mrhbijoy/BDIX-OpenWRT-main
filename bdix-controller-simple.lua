-- Copyright (C) 2023 OpenWrt.org
-- Simple BDIX Controller without CBI dependency

module("luci.controller.bdix", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/bdix") then
		return
	end

	-- Register ONLY under System menu (remove Services registration)
	local page = entry({"admin", "system", "bdix"}, call("action_index"), _("BDIX Proxy"), 70)
	page.dependent = true

	-- Action handlers (all under system path)
	entry({"admin", "system", "bdix", "status"}, call("action_status"))
	entry({"admin", "system", "bdix", "start"}, call("action_start"))
	entry({"admin", "system", "bdix", "stop"}, call("action_stop"))
	entry({"admin", "system", "bdix", "restart"}, call("action_restart"))
	entry({"admin", "system", "bdix", "save"}, call("action_save"))
	entry({"admin", "system", "bdix", "iptables_start"}, call("action_iptables_start"))
	entry({"admin", "system", "bdix", "iptables_stop"}, call("action_iptables_stop"))
end

function action_index()
	local sys = require "luci.sys"
	local uci = require "luci.model.uci".cursor()
	local http = require "luci.http"

	-- Handle form submission
	if http.formvalue("action") then
		if http.formvalue("action") == "save" then
			action_save()
			return
		end
	end	-- Load configuration
	local proxy_server = uci:get("bdix", "bdix", "proxy_ip") or ""
	local proxy_port = uci:get("bdix", "bdix", "proxy_port") or "1080"
	local local_port = uci:get("bdix", "bdix", "local_port") or "1337"

	-- Check service status
	local running = (sys.call("pgrep redsocks > /dev/null") == 0)

	-- Check iptables rules
	local iptables_active = (sys.call("iptables -t nat -L | grep -q '".. local_port .."'") == 0)
	local iptables_rules = {}
	if iptables_active then
		local rules_output = sys.exec("iptables -t nat -L PREROUTING -n --line-numbers | grep " .. local_port)
		for line in rules_output:gmatch("[^\r\n]+") do
			iptables_rules[#iptables_rules + 1] = line
		end
	end

	-- Generate HTML page
	luci.http.prepare_content("text/html")
	luci.http.write([[
<!DOCTYPE html>
<html>
<head>
	<title>BDIX Proxy Configuration</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<style>
		body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
		.container { max-width: 800px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
		.header { background: #0066cc; color: white; padding: 15px; margin: -20px -20px 20px -20px; border-radius: 8px 8px 0 0; }
		.status { padding: 10px; margin: 10px 0; border-radius: 4px; }
		.status.running { background: #d4edda; border: 1px solid #c3e6cb; color: #155724; }
		.status.stopped { background: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; }
		.form-group { margin-bottom: 15px; }
		.form-group label { display: block; margin-bottom: 5px; font-weight: bold; }
		.form-group input, .form-group select { width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; }
		.button { background: #0066cc; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; margin-right: 10px; }
		.button:hover { background: #0052a3; }
		.button.danger { background: #dc3545; }
		.button.danger:hover { background: #c82333; }
		.button.success { background: #28a745; }
		.button.success:hover { background: #218838; }
		.section { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 4px; }
		.help { font-size: 0.9em; color: #666; margin-top: 5px; }
		.iptables-rules { background: #f8f9fa; padding: 10px; border-radius: 4px; font-family: monospace; font-size: 0.9em; margin-top: 10px; }
		.iptables-rules pre { margin: 0; white-space: pre-wrap; }
		.status-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin: 15px 0; }
		@media (max-width: 768px) { .status-grid { grid-template-columns: 1fr; } }
	</style>
</head>
<body>
	<div class="container">
		<div class="header">
			<h1>BDIX Proxy Configuration</h1>
			<p>Simple and secure BDIX proxy management</p>
		</div>

		<div class="status-grid">
			<div class="status ]] .. (running and "running" or "stopped") .. [[">
				<strong>Service Status:</strong> ]] .. (running and "Running ✓" or "Stopped ✗") .. [[
			</div>
			<div class="status ]] .. (iptables_active and "running" or "stopped") .. [[">
				<strong>iptables Rules:</strong> ]] .. (iptables_active and "Active ✓" or "Inactive ✗") .. [[
			</div>
		</div>

		<div class="section">
			<h3>Service Control</h3>
			<button class="button success" onclick="location.href=']] .. luci.dispatcher.build_url("admin", "system", "bdix", "start") .. [['">Start Service</button>
			<button class="button danger" onclick="location.href=']] .. luci.dispatcher.build_url("admin", "system", "bdix", "stop") .. [['">Stop Service</button>
			<button class="button" onclick="location.href=']] .. luci.dispatcher.build_url("admin", "system", "bdix", "restart") .. [['">Restart Service</button>
		</div>

		<div class="section">
			<h3>iptables Control</h3>
			<p>Manage traffic redirection rules</p>
			<button class="button success" onclick="location.href=']] .. luci.dispatcher.build_url("admin", "system", "bdix", "iptables_start") .. [['">Enable iptables</button>
			<button class="button danger" onclick="location.href=']] .. luci.dispatcher.build_url("admin", "system", "bdix", "iptables_stop") .. [['">Disable iptables</button>
		</div>

		<form method="post" action="]] .. luci.dispatcher.build_url("admin", "system", "bdix") .. [[">
			<input type="hidden" name="action" value="save">
					<div class="section">
				<h3>🌐 SOCKS5 Proxy Settings</h3>
				
				<div class="form-group">
					<label for="proxy_server">Proxy Server:</label>
					<input type="text" id="proxy_server" name="proxy_server" value="]] .. proxy_server .. [[" placeholder="113.192.43.43">
					<div class="help">Enter the IP address of your BDIX SOCKS5 proxy server</div>
				</div>
				
				<div class="form-group">
					<label for="proxy_port">Proxy Port:</label>
					<input type="text" id="proxy_port" name="proxy_port" value="]] .. proxy_port .. [[" placeholder="1080">
					<div class="help">SOCKS5 proxy port (usually 1080)</div>
				</div>
				
				<div class="form-group">
					<label for="socks_user">SOCKS5 Username:</label>
					<input type="text" id="socks_user" name="socks_user" value="]] .. socks_user .. [[" placeholder="bijoy2@itcnbd">
					<div class="help">Username for SOCKS5 authentication</div>
				</div>
				
				<div class="form-group">
					<label for="socks_pass">SOCKS5 Password:</label>
					<input type="password" id="socks_pass" name="socks_pass" value="]] .. socks_pass .. [[" placeholder="Enter SOCKS5 password">
					<div class="help">Password for SOCKS5 authentication</div>
				</div>
				
				<div class="form-group">
					<label for="local_port">Local Port:</label>
					<input type="text" id="local_port" name="local_port" value="]] .. local_port .. [[" placeholder="1337">
					<div class="help">Local port for traffic redirection (usually 1337)</div>
				</div>
			</div>

			<div class="section">
				<button type="submit" class="button">Save Configuration</button>
			</div>
		</form>
]])

	if iptables_active and #iptables_rules > 0 then
		luci.http.write([[
		<div class="section">
			<h3>Active iptables Rules</h3>
			<div class="iptables-rules">
				<pre>]])
		for _, rule in ipairs(iptables_rules) do
			luci.http.write(rule .. "\n")
		end
		luci.http.write([[</pre>
			</div>
		</div>
]])
	end

	luci.http.write([[
		<div class="section">
			<h3>Safety Information</h3>
			<p><strong>Built-in Safety Features:</strong></p>
			<ul>
				<li>Local network traffic (192.168.x.x, 10.x.x.x, 172.16-31.x.x) is automatically excluded</li>
				<li>Router management interface is protected</li>
				<li>Emergency access is always available</li>
			</ul>
			<p><strong>Note:</strong> If you lose web access, run the emergency script via SSH</p>
		</div>
	</div>
</body>
</html>
]])
end

function action_save()
	local uci = require "luci.model.uci".cursor()
	local http = require "luci.http"

	-- Get form values
	local proxy_server = http.formvalue("proxy_server") or "113.192.43.43"
	local proxy_port = http.formvalue("proxy_port") or "1080"
	local local_port = http.formvalue("local_port") or "1337"
	local socks_user = http.formvalue("socks_user") or ""
	local socks_pass = http.formvalue("socks_pass") or ""
	-- Save to UCI
	uci:set("bdix", "bdix", "proxy_ip", proxy_server)
	uci:set("bdix", "bdix", "proxy_port", proxy_port)
	uci:set("bdix", "bdix", "local_port", local_port)
	uci:set("bdix", "bdix", "username", socks_user)
	uci:set("bdix", "bdix", "password", socks_pass)
	uci:commit("bdix")

	-- Redirect back to main page
	http.redirect(luci.dispatcher.build_url("admin", "system", "bdix"))
end

function action_status()
	local sys = require "luci.sys"
	local running = (sys.call("pgrep redsocks > /dev/null") == 0)
	luci.http.prepare_content("application/json")
	luci.http.write('{"running":' .. (running and "true" or "false") .. '}')
end

function action_start()
	luci.sys.call("/etc/init.d/bdix start")
	luci.http.redirect(luci.dispatcher.build_url("admin", "system", "bdix"))
end

function action_stop()
	luci.sys.call("/etc/init.d/bdix stop")
	luci.http.redirect(luci.dispatcher.build_url("admin", "system", "bdix"))
end

function action_restart()
	luci.sys.call("/etc/init.d/bdix restart")
	luci.http.redirect(luci.dispatcher.build_url("admin", "system", "bdix"))
end

function action_iptables_start()
	local sys = require "luci.sys"
	local uci = require "luci.model.uci".cursor()
		-- Get configuration
	local local_port = uci:get("bdix", "bdix", "local_port") or "1337"
	
	-- Safety exclusions (built-in)
	local safety_ranges = {
		"192.168.0.0/16",
		"172.16.0.0/12", 
		"10.0.0.0/8",
		"127.0.0.0/8",
		"169.254.0.0/16",
		"224.0.0.0/4",
		"240.0.0.0/4"
	}

	-- Create BDIX chain
	sys.call("iptables -t nat -N BDIX 2>/dev/null")
	sys.call("iptables -t nat -F BDIX")
	
	-- Add safety exclusions
	for _, range in ipairs(safety_ranges) do
		sys.call("iptables -t nat -A BDIX -d " .. range .. " -j RETURN")
	end
	
	-- Add redirect rule
	sys.call("iptables -t nat -A BDIX -p tcp -j REDIRECT --to-ports " .. local_port)
	
	-- Insert main rule
	sys.call("iptables -t nat -I PREROUTING -i br-lan -p tcp -j BDIX")
	
	luci.http.redirect(luci.dispatcher.build_url("admin", "system", "bdix"))
end

function action_iptables_stop()
	local sys = require "luci.sys"
	
	-- Remove and clean up BDIX chain
	sys.call("iptables -t nat -D PREROUTING -i br-lan -p tcp -j BDIX 2>/dev/null")
	sys.call("iptables -t nat -F BDIX 2>/dev/null")
	sys.call("iptables -t nat -X BDIX 2>/dev/null")
	
	luci.http.redirect(luci.dispatcher.build_url("admin", "system", "bdix"))
end
