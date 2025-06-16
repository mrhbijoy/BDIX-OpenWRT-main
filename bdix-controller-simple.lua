-- Copyright (C) 2023 OpenWrt.org
-- Simple BDIX Controller without CBI dependency

module("luci.controller.bdix", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/bdix") then
		return
	end

	-- Register under System menu with simple form handler
	local page = entry({"admin", "system", "bdix"}, call("action_index"), _("BDIX Proxy"), 70)
	page.dependent = true

	-- Action handlers
	entry({"admin", "system", "bdix", "status"}, call("action_status"))
	entry({"admin", "system", "bdix", "start"}, call("action_start"))
	entry({"admin", "system", "bdix", "stop"}, call("action_stop"))
	entry({"admin", "system", "bdix", "restart"}, call("action_restart"))
	entry({"admin", "system", "bdix", "save"}, call("action_save"))
end

function action_index()
	local uci = require "luci.model.uci".cursor()
	local sys = require "luci.sys"
	local fs = require "nixio.fs"
	
	-- Load current configuration
	local enabled = uci:get("bdix", "config", "enabled") or "0"
	local proxy_server = uci:get("bdix", "config", "proxy_server") or ""
	local proxy_port = uci:get("bdix", "config", "proxy_port") or "1080"
	local local_port = uci:get("bdix", "config", "local_port") or "1337"
	
	-- Check service status
	local running = (sys.call("pgrep redsocks > /dev/null") == 0)
	
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
	</style>
</head>
<body>
	<div class="container">		<div class="header">
			<h1>BDIX Proxy Configuration</h1>
		</div>
		
		<div class="status ]] .. (running and "running" or "stopped") .. [[">
			<strong>Status:</strong> ]] .. (running and "Running" or "Stopped") .. [[
		</div>
				<div class="section">
			<h3>Service Control</h3>
			<button class="button success" onclick="location.href='/cgi-bin/luci/admin/system/bdix/start'">Start</button>
			<button class="button danger" onclick="location.href='/cgi-bin/luci/admin/system/bdix/stop'">Stop</button>
			<button class="button" onclick="location.href='/cgi-bin/luci/admin/system/bdix/restart'">Restart</button>
			<button class="button" onclick="location.reload()">Refresh Status</button>
		</div>
		
		<div class="section">
			<h3>Configuration</h3>
			<form method="post" action="/cgi-bin/luci/admin/system/bdix/save">
				<div class="form-group">
					<label for="enabled">Enable BDIX Proxy:</label>
					<select name="enabled" id="enabled">
						<option value="1"]] .. (enabled == "1" and " selected" or "") .. [[>Enabled</option>
						<option value="0"]] .. (enabled == "0" and " selected" or "") .. [[>Disabled</option>
					</select>
				</div>
				
				<div class="form-group">
					<label for="proxy_server">Proxy Server IP:</label>
					<input type="text" name="proxy_server" id="proxy_server" value="]] .. proxy_server .. [[" placeholder="e.g., 103.108.140.1">
					<div class="help">Enter the IP address of your BDIX proxy server</div>
				</div>
				
				<div class="form-group">
					<label for="proxy_port">Proxy Server Port:</label>
					<input type="number" name="proxy_port" id="proxy_port" value="]] .. proxy_port .. [[" placeholder="1080">
					<div class="help">Port number of the proxy server (usually 1080)</div>
				</div>
				
				<div class="form-group">
					<label for="local_port">Local Redirect Port:</label>
					<input type="number" name="local_port" id="local_port" value="]] .. local_port .. [[" placeholder="1337">
					<div class="help">Local port for traffic redirection (usually 1337)</div>
				</div>
				
				<button type="submit" class="button">Save Configuration</button>
			</form>
		</div>
		
		<div class="section">
			<h3>Quick Setup Guide</h3>
			<ol>
				<li>Enter your BDIX proxy server IP and port</li>
				<li>Enable the service</li>
				<li>Save configuration</li>
				<li>Start the service</li>
				<li>Your traffic will be routed through the BDIX proxy</li>
			</ol>
		</div>
	</div>
</body>
</html>
	]])
end

function action_save()
	local uci = require "luci.model.uci".cursor()
	local http = luci.http
	
	-- Get form data
	local enabled = http.formvalue("enabled") or "0"
	local proxy_server = http.formvalue("proxy_server") or ""
	local proxy_port = http.formvalue("proxy_port") or "1080"
	local local_port = http.formvalue("local_port") or "1337"
	
	-- Save to UCI
	uci:set("bdix", "config", "enabled", enabled)
	uci:set("bdix", "config", "proxy_server", proxy_server)
	uci:set("bdix", "config", "proxy_port", proxy_port)
	uci:set("bdix", "config", "local_port", local_port)
	uci:commit("bdix")
	
	-- Update configuration file
	local sys = require "luci.sys"
	sys.call("/etc/init.d/bdix reload")
	
	-- Redirect back to main page
	http.redirect(luci.dispatcher.build_url("admin", "system", "bdix") .. "?saved=1")
end

function action_status()
	local sys = require "luci.sys"
	local status = {}
	
	-- Check if bdix service is running
	if sys.call("pgrep redsocks > /dev/null") == 0 then
		status.running = true
	else
		status.running = false
	end
	
	-- Check configuration
	if nixio.fs.access("/etc/bdix.conf") then
		status.configured = true
	else
		status.configured = false
	end
	
	luci.http.prepare_content("application/json")
	luci.http.write_json(status)
end

function action_start()
	local sys = require "luci.sys"
	sys.call("/etc/init.d/bdix start")
	luci.http.redirect(luci.dispatcher.build_url("admin", "system", "bdix"))
end

function action_stop()
	local sys = require "luci.sys"
	sys.call("/etc/init.d/bdix stop")
	luci.http.redirect(luci.dispatcher.build_url("admin", "system", "bdix"))
end

function action_restart()
	local sys = require "luci.sys"
	sys.call("/etc/init.d/bdix restart")
	luci.http.redirect(luci.dispatcher.build_url("admin", "system", "bdix"))
end
