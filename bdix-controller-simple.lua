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

	-- Check authentication first
	local authenticated, auth_error = check_authentication()
	if not authenticated then
		show_login_page(auth_error)
		return
	end

	-- Handle form submission
	if http.formvalue("action") then
		if http.formvalue("action") == "save" then
			action_save()
			return
		elseif http.formvalue("action") == "logout" then
			http.header("Set-Cookie", "bdix_session=; Path=/; Max-Age=0")
			show_login_page("Logged out successfully")
			return
		end
	end

	-- Load configuration
	local proxy_server = uci:get("bdix", "config", "proxy_server") or ""
	local proxy_port = uci:get("bdix", "config", "proxy_port") or "1080"
	local local_port = uci:get("bdix", "config", "local_port") or "1337"

	-- Check service status
	local running = (sys.call("pgrep redsocks > /dev/null") == 0)

	-- Check iptables rules
	local iptables_active = (sys.call("iptables -t nat -L | grep -q '1337'") == 0)
	local iptables_rules = {}
	if iptables_active then
		local rules_output = sys.exec("iptables -t nat -L PREROUTING -n --line-numbers | grep 1337")
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
				<h3>Proxy Settings</h3>
				
				<div class="form-group">
					<label for="proxy_server">Proxy Server:</label>
					<input type="text" id="proxy_server" name="proxy_server" value="]] .. proxy_server .. [[" placeholder="103.108.140.116">
					<div class="help">Enter the IP address of your BDIX proxy server</div>
				</div>
				
				<div class="form-group">
					<label for="proxy_port">Proxy Port:</label>
					<input type="text" id="proxy_port" name="proxy_port" value="]] .. proxy_port .. [[" placeholder="1080">
					<div class="help">SOCKS5 proxy port (usually 1080)</div>
				</div>
				
				<div class="form-group">
					<label for="local_port">Local Port:</label>
					<input type="text" id="local_port" name="local_port" value="]] .. local_port .. [[" placeholder="1337">					<div class="help">Local port for traffic redirection (usually 1337)</div>
				</div>
			</div>

			<div class="section">
				<h3>🔐 Authentication Settings</h3>
				
				<div class="form-group">
					<label for="username">Username:</label>
					<input type="text" id="username" name="username" value="]] .. (uci:get("bdix", "config", "username") or "admin") .. [[" placeholder="admin">
					<div class="help">Username for accessing this interface</div>
				</div>
				
				<div class="form-group">
					<label for="password">Password:</label>
					<input type="password" id="password" name="password" value="]] .. (uci:get("bdix", "config", "password") or "admin") .. [[" placeholder="Enter new password">
					<div class="help">Password for accessing this interface</div>
				</div>
			</div>

			<div class="section">
				<button type="submit" class="button">Save Configuration</button>
				<button type="button" class="button danger" onclick="if(confirm('Are you sure you want to logout?')) { var form = document.createElement('form'); form.method = 'post'; var input = document.createElement('input'); input.type = 'hidden'; input.name = 'action'; input.value = 'logout'; form.appendChild(input); document.body.appendChild(form); form.submit(); }">Logout</button>
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

	-- Check authentication first
	local authenticated, auth_error = check_authentication()
	if not authenticated then
		show_login_page(auth_error)
		return
	end

	-- Get form values
	local proxy_server = http.formvalue("proxy_server") or ""
	local proxy_port = http.formvalue("proxy_port") or "1080"
	local local_port = http.formvalue("local_port") or "1337"
	local username = http.formvalue("username") or "admin"
	local password = http.formvalue("password") or "admin"

	-- Save to UCI
	uci:set("bdix", "config", "proxy_server", proxy_server)
	uci:set("bdix", "config", "proxy_port", proxy_port)
	uci:set("bdix", "config", "local_port", local_port)
	uci:set("bdix", "config", "username", username)
	uci:set("bdix", "config", "password", password)
	uci:commit("bdix")

	-- If password was changed, invalidate current session
	local current_user = http.getcookie("bdix_session")
	if current_user and string.find(current_user, username) then
		-- Update session with new credentials
		http.header("Set-Cookie", "bdix_session=authenticated_" .. username .. "; Path=/; Max-Age=86400")
	end

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
	-- Check authentication
	local authenticated, auth_error = check_authentication()
	if not authenticated then
		show_login_page(auth_error)
		return
	end
	
	luci.sys.call("/etc/init.d/bdix start")
	luci.http.redirect(luci.dispatcher.build_url("admin", "system", "bdix"))
end

function action_stop()
	-- Check authentication
	local authenticated, auth_error = check_authentication()
	if not authenticated then
		show_login_page(auth_error)
		return
	end
	
	luci.sys.call("/etc/init.d/bdix stop")
	luci.http.redirect(luci.dispatcher.build_url("admin", "system", "bdix"))
end

function action_restart()
	-- Check authentication
	local authenticated, auth_error = check_authentication()
	if not authenticated then
		show_login_page(auth_error)
		return
	end
	
	luci.sys.call("/etc/init.d/bdix restart")
	luci.http.redirect(luci.dispatcher.build_url("admin", "system", "bdix"))
end

function action_iptables_start()
	-- Check authentication
	local authenticated, auth_error = check_authentication()
	if not authenticated then
		show_login_page(auth_error)
		return
	end
	
	local sys = require "luci.sys"
	local uci = require "luci.model.uci".cursor()
	
	-- Get configuration
	local local_port = uci:get("bdix", "config", "local_port") or "1337"
	
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
	-- Check authentication
	local authenticated, auth_error = check_authentication()
	if not authenticated then
		show_login_page(auth_error)
		return
	end
	
	local sys = require "luci.sys"
	
	-- Remove and clean up BDIX chain
	sys.call("iptables -t nat -D PREROUTING -i br-lan -p tcp -j BDIX 2>/dev/null")
	sys.call("iptables -t nat -F BDIX 2>/dev/null")
	sys.call("iptables -t nat -X BDIX 2>/dev/null")
	
	luci.http.redirect(luci.dispatcher.build_url("admin", "system", "bdix"))
end

function check_authentication()
	local http = require "luci.http"
	local uci = require "luci.model.uci".cursor()
	
	-- Get stored credentials from UCI
	local stored_username = uci:get("bdix", "config", "username") or "admin"
	local stored_password = uci:get("bdix", "config", "password") or "admin"
	
	-- Check if credentials are provided
	local auth_user = http.formvalue("auth_user")
	local auth_pass = http.formvalue("auth_pass")
	
	-- Check session
	local session_token = http.getcookie("bdix_session")
	local valid_session = (session_token == "authenticated_" .. stored_username)
	
	if valid_session then
		return true
	end
	
	if auth_user and auth_pass then
		if auth_user == stored_username and auth_pass == stored_password then
			-- Set session cookie (valid for 24 hours)
			http.header("Set-Cookie", "bdix_session=authenticated_" .. stored_username .. "; Path=/; Max-Age=86400")
			return true
		else
			return false, "Invalid username or password"
		end
	end
	
	return false, "Authentication required"
end

function show_login_page(error_msg)
	local http = require "luci.http"
	
	http.prepare_content("text/html")
	http.write([[
<!DOCTYPE html>
<html>
<head>
	<title>BDIX Proxy - Login</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<style>
		body { font-family: Arial, sans-serif; margin: 0; padding: 0; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; display: flex; align-items: center; justify-content: center; }
		.login-container { background: white; padding: 40px; border-radius: 10px; box-shadow: 0 10px 25px rgba(0,0,0,0.2); max-width: 400px; width: 100%; }
		.login-header { text-align: center; margin-bottom: 30px; }
		.login-header h1 { color: #333; margin: 0; }
		.login-header p { color: #666; margin: 10px 0 0 0; }
		.form-group { margin-bottom: 20px; }
		.form-group label { display: block; margin-bottom: 8px; font-weight: bold; color: #333; }
		.form-group input { width: 100%; padding: 12px; border: 2px solid #ddd; border-radius: 6px; box-sizing: border-box; font-size: 14px; }
		.form-group input:focus { border-color: #667eea; outline: none; }
		.login-button { width: 100%; padding: 12px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border: none; border-radius: 6px; font-size: 16px; font-weight: bold; cursor: pointer; }
		.login-button:hover { opacity: 0.9; }
		.error { background: #f8d7da; color: #721c24; padding: 10px; border-radius: 4px; margin-bottom: 20px; text-align: center; }
		.footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }
	</style>
</head>
<body>
	<div class="login-container">
		<div class="login-header">
			<h1>🔐 BDIX Proxy</h1>
			<p>Authentication Required</p>
		</div>
		
		]] .. (error_msg and '<div class="error">' .. error_msg .. '</div>' or '') .. [[
		
		<form method="post">
			<div class="form-group">
				<label for="auth_user">Username:</label>
				<input type="text" id="auth_user" name="auth_user" required autocomplete="username">
			</div>
			
			<div class="form-group">
				<label for="auth_pass">Password:</label>
				<input type="password" id="auth_pass" name="auth_pass" required autocomplete="current-password">
			</div>
			
			<button type="submit" class="login-button">Login</button>
		</form>
		
		<div class="footer">
			<p>Default credentials: admin / admin</p>
		</div>
	</div>
</body>
</html>
]])
end
