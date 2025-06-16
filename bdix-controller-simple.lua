-- Copyright (C) 2023 OpenWrt.org
-- Simple BDIX Controller without CBI dependency

module("luci.controller.bdix", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/bdix") then
		return
	end

	-- Register ONLY under System menu (remove Services registration)
	local page = entry({"admin", "system", "bdix"}, call("action_index"), _("BDIX Proxy"), 70)
	page.dependent = true	-- Action handlers (all under system path)
	entry({"admin", "system", "bdix", "status"}, call("action_status"))
	entry({"admin", "system", "bdix", "start"}, call("action_start"))
	entry({"admin", "system", "bdix", "stop"}, call("action_stop"))
	entry({"admin", "system", "bdix", "restart"}, call("action_restart"))
	entry({"admin", "system", "bdix", "save"}, call("action_save"))
	entry({"admin", "system", "bdix", "iptables_start"}, call("action_iptables_start"))
	entry({"admin", "system", "bdix", "iptables_stop"}, call("action_iptables_stop"))	entry({"admin", "system", "bdix", "add_ip"}, call("action_add_ip"))
	entry({"admin", "system", "bdix", "remove_ip"}, call("action_remove_ip"))
	entry({"admin", "system", "bdix", "add_domain"}, call("action_add_domain"))
	entry({"admin", "system", "bdix", "remove_domain"}, call("action_remove_domain"))
	entry({"admin", "system", "bdix", "add_safety_ip"}, call("action_add_safety_ip"))
	entry({"admin", "system", "bdix", "remove_safety_ip"}, call("action_remove_safety_ip"))
	entry({"admin", "system", "bdix", "edit_safety_ip"}, call("action_edit_safety_ip"))
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
		-- Load custom exclusions
	local custom_ips = uci:get("bdix", "config", "custom_ips") or ""
	local custom_domains = uci:get("bdix", "config", "custom_domains") or ""
	local safety_ips = uci:get("bdix", "config", "safety_ips") or "192.168.0.0/16,172.16.0.0/12,10.0.0.0/8,127.0.0.0/8,169.254.0.0/16,224.0.0.0/4,240.0.0.0/4"
		-- Convert to tables for display
	local ip_list = {}
	local domain_list = {}
	local safety_list = {}
		if custom_ips ~= "" then
		for ip in string.gmatch(custom_ips, "([^,]+)") do
			local clean_ip = string.gsub(ip, "^%s*(.-)%s*$", "%1")
			table.insert(ip_list, clean_ip)
		end
	end
	
	if custom_domains ~= "" then
		for domain in string.gmatch(custom_domains, "([^,]+)") do
			local clean_domain = string.gsub(domain, "^%s*(.-)%s*$", "%1")
			table.insert(domain_list, clean_domain)
		end
	end
	
	if safety_ips ~= "" then
		for ip in string.gmatch(safety_ips, "([^,]+)") do
			local clean_ip = string.gsub(ip, "^%s*(.-)%s*$", "%1")
			table.insert(safety_list, clean_ip)
		end
	end
	
	-- Check service status
	local running = (sys.call("pgrep redsocks > /dev/null") == 0)
	
	-- Check iptables rules
	local iptables_active = (sys.call("iptables -t nat -L | grep -q '1337'") == 0)
	local iptables_rules = {}
	if iptables_active then
		local rules_output = sys.exec("iptables -t nat -L PREROUTING -n --line-numbers | grep 1337")
		for line in rules_output:gmatch("[^\r\n]+") do
			table.insert(iptables_rules, line)
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
		.button.success { background: #28a745; }		.button.success:hover { background: #218838; }
		.section { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 4px; }
		.help { font-size: 0.9em; color: #666; margin-top: 5px; }
		.iptables-rules { background: #f8f9fa; padding: 10px; border-radius: 4px; font-family: monospace; font-size: 0.9em; margin-top: 10px; }		.iptables-rules pre { margin: 0; white-space: pre-wrap; }
		.status-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin: 15px 0; }
		@media (max-width: 768px) { .status-grid { grid-template-columns: 1fr; } }
		.exclusion-item { display: flex; justify-content: space-between; align-items: center; padding: 8px; margin: 5px 0; background: #f8f9fa; border: 1px solid #dee2e6; border-radius: 4px; }
		.exclusion-item .remove-btn { background: #dc3545; color: white; border: none; padding: 4px 8px; border-radius: 3px; cursor: pointer; font-size: 0.8em; }
		.exclusion-item .remove-btn:hover { background: #c82333; }
		.add-exclusion { display: flex; gap: 10px; margin-top: 10px; }		.add-exclusion input { flex: 1; padding: 6px; border: 1px solid #ddd; border-radius: 3px; }
		.add-exclusion button { padding: 6px 12px; border: none; background: #28a745; color: white; border-radius: 3px; cursor: pointer; }
		.add-exclusion button:hover { background: #218838; }
		.safety-warning { background: #fff3cd; border: 1px solid #ffeaa7; color: #856404; padding: 10px; border-radius: 4px; margin: 10px 0; }
		.safety-item { display: flex; justify-content: space-between; align-items: center; padding: 8px; margin: 5px 0; background: #fff3cd; border: 1px solid #ffeaa7; border-radius: 4px; }
		.safety-item .edit-btn { background: #ffc107; color: #212529; border: none; padding: 4px 8px; border-radius: 3px; cursor: pointer; font-size: 0.8em; margin-right: 5px; }
		.safety-item .remove-btn { background: #dc3545; color: white; border: none; padding: 4px 8px; border-radius: 3px; cursor: pointer; font-size: 0.8em; }
		.safety-item .edit-btn:hover { background: #e0a800; }
		.safety-item .remove-btn:hover { background: #c82333; }
	</style>
</head>
<body>
	<div class="container">		<div class="header">
			<h1>BDIX Proxy Configuration</h1>
		</div>
		
		<div class="status-grid">
			<div class="status ]] .. (running and "running" or "stopped") .. [[">
				<strong>Service Status:</strong> ]] .. (running and "Running" or "Stopped") .. [[
			</div>
			<div class="status ]] .. (iptables_active and "running" or "stopped") .. [[">
				<strong>Traffic Redirection:</strong> ]] .. (iptables_active and "Active" or "Inactive") .. [[
			</div>
		</div>
		<div class="section">
			<h3>Service Control</h3>
			<button class="button success" onclick="location.href='/cgi-bin/luci/admin/system/bdix/start'">Start</button>
			<button class="button danger" onclick="location.href='/cgi-bin/luci/admin/system/bdix/stop'">Stop</button>
			<button class="button" onclick="location.href='/cgi-bin/luci/admin/system/bdix/restart'">Restart</button>
			<button class="button" onclick="location.reload()">Refresh Status</button>
		</div>
		
		<div class="section">
			<h3>Traffic Redirection Status</h3>
			<p><strong>IPTables Rules Status:</strong> ]] .. (iptables_active and "Active - Traffic is being redirected" or "Inactive - No traffic redirection") .. [[</p>
			]] .. (iptables_active and [[
			<div class="iptables-rules">
				<strong>Active IPTables Rules:</strong>
				<pre>]] .. table.concat(iptables_rules, "\n") .. [[</pre>
			</div>
			]] or [[
			<p style="color: #666;">No iptables rules found. Traffic redirection is not active.</p>
			]]) .. [[			<div class="help">
				<strong>What this means:</strong><br>
				• <strong>Service Running + Traffic Active:</strong> BDIX proxy is working<br>
				• <strong>Service Running + Traffic Inactive:</strong> Service started but traffic rules not applied<br>
				• <strong>Service Stopped:</strong> BDIX proxy is not running
			</div>
			<div style="margin-top: 10px;">
				<button class="button success" onclick="location.href='/cgi-bin/luci/admin/system/bdix/iptables_start'">Enable Traffic Redirection</button>
				<button class="button danger" onclick="location.href='/cgi-bin/luci/admin/system/bdix/iptables_stop'">Disable Traffic Redirection</button>
			</div>
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
				
				<button type="submit" class="button">Save Configuration</button>			</form>
		</div>
		<div class="section">
			<h3>IP/Domain Exclusions</h3>
			<p>These IPs and domains will <strong>NOT</strong> go through the BDIX proxy (direct connection):</p>
			
			<h4>Safety Network Exclusions (Editable with Caution):</h4>
			<div class="safety-warning">
				<strong>⚠️ WARNING:</strong> Removing safety exclusions can lock you out of the router's web interface. Only modify if you understand the risks!
			</div>
			<div id="safety-ips">
				]] .. (function()
					local html = ""
					for i, ip in ipairs(safety_list) do
						local is_router_range = (string.find(ip, "192.168") == 1)
						local warning = is_router_range and " (ROUTER ACCESS - BE CAREFUL!)" or ""
						html = html .. '<div class="safety-item"><span>' .. ip .. warning .. '</span><div><button class="edit-btn" onclick="editSafetyIP(\'' .. ip .. '\')">Edit</button><button class="remove-btn" onclick="removeSafetyIP(\'' .. ip .. '\')">Remove</button></div></div>'
					end
					return html
				end)() .. [[
			</div>
			<div class="add-exclusion">
				<input type="text" id="new-safety-ip" placeholder="Add safety IP range (e.g., 172.16.50.4)" />
				<button onclick="addSafetyIP()">Add Safety IP</button>
			</div>
			
			<h4>Custom IP Exclusions:</h4>
			<div id="custom-ips">
				]] .. (function()
					local html = ""
					for i, ip in ipairs(ip_list) do
						html = html .. '<div class="exclusion-item"><span>' .. ip .. '</span><button class="remove-btn" onclick="removeIP(\'' .. ip .. '\')">Remove</button></div>'
					end
					if #ip_list == 0 then
						html = '<p style="color: #666; font-style: italic;">No custom IP exclusions added</p>'
					end
					return html
				end)() .. [[
			</div>
			<div class="add-exclusion">
				<input type="text" id="new-ip" placeholder="Enter IP or IP range (e.g., 203.76.120.0/24)" />
				<button onclick="addIP()">Add IP</button>
			</div>
			
			<h4>Custom Domain Exclusions:</h4>
			<div id="custom-domains">
				]] .. (function()
					local html = ""
					for i, domain in ipairs(domain_list) do
						html = html .. '<div class="exclusion-item"><span>' .. domain .. '</span><button class="remove-btn" onclick="removeDomain(\'' .. domain .. '\')">Remove</button></div>'
					end
					if #domain_list == 0 then
						html = '<p style="color: #666; font-style: italic;">No custom domain exclusions added</p>'
					end
					return html
				end)() .. [[
			</div>
			<div class="add-exclusion">
				<input type="text" id="new-domain" placeholder="Enter domain (e.g., facebook.com)" />
				<button onclick="addDomain()">Add Domain</button>
			</div>
					<div class="help">
				<strong>💡 Understanding Exclusions:</strong><br>
				• <strong>Safety IPs:</strong> Network ranges that should usually stay excluded<br>
				• <strong>Custom IPs:</strong> Specific IPs/ranges you want to exclude<br>
				• <strong>Domains:</strong> Websites that should bypass the proxy<br>
				• <strong>Warning:</strong> Removing 192.168.x.x can lock you out!
			</div>
		</div>
		
		<script>
		function addSafetyIP() {
			const input = document.getElementById('new-safety-ip');
			const ip = input.value.trim();
			if (ip) {
				if (confirm('Are you sure you want to add this as a safety exclusion? Safety exclusions affect core network access.')) {
					window.location.href = '/cgi-bin/luci/admin/system/bdix/add_safety_ip?ip=' + encodeURIComponent(ip);
				}
			}
		}
		
		function editSafetyIP(ip) {
			const newIp = prompt('Edit safety IP range (BE CAREFUL!):', ip);
			if (newIp && newIp !== ip) {
				if (confirm('WARNING: Editing safety IPs can lock you out of the router!\\n\\nOld: ' + ip + '\\nNew: ' + newIp + '\\n\\nContinue?')) {
					window.location.href = '/cgi-bin/luci/admin/system/bdix/edit_safety_ip?old_ip=' + encodeURIComponent(ip) + '&new_ip=' + encodeURIComponent(newIp);
				}
			}
		}
		
		function removeSafetyIP(ip) {
			const isRouterRange = ip.indexOf('192.168') === 0;
			const warningMsg = isRouterRange ? 
				'⚠️ DANGER: This IP range likely includes your router access!\\n\\nRemoving "' + ip + '" may lock you out of the web interface!\\n\\nAre you absolutely sure?' :
				'Remove safety IP exclusion "' + ip + '"?\\n\\nThis may affect network connectivity.';
			
			if (confirm(warningMsg)) {
				if (isRouterRange && !confirm('FINAL WARNING: You may lose web access!\\n\\nLast chance to cancel...')) {
					return;
				}
				window.location.href = '/cgi-bin/luci/admin/system/bdix/remove_safety_ip?ip=' + encodeURIComponent(ip);
			}
		}
		
		function addIP() {
			const input = document.getElementById('new-ip');
			const ip = input.value.trim();
			if (ip) {
				window.location.href = '/cgi-bin/luci/admin/system/bdix/add_ip?ip=' + encodeURIComponent(ip);
			}
		}
		
		function removeIP(ip) {
			window.location.href = '/cgi-bin/luci/admin/system/bdix/remove_ip?ip=' + encodeURIComponent(ip);
		}
		
		function addDomain() {
			const input = document.getElementById('new-domain');
			const domain = input.value.trim();
			if (domain) {
				window.location.href = '/cgi-bin/luci/admin/system/bdix/add_domain?domain=' + encodeURIComponent(domain);
			}
		}
		
		function removeDomain(domain) {
			window.location.href = '/cgi-bin/luci/admin/system/bdix/remove_domain?domain=' + encodeURIComponent(domain);
		}
				// Enter key support
		document.getElementById('new-safety-ip').addEventListener('keypress', function(e) {
			if (e.key === 'Enter') addSafetyIP();
		});
		
		document.getElementById('new-ip').addEventListener('keypress', function(e) {
			if (e.key === 'Enter') addIP();
		});
		
		document.getElementById('new-domain').addEventListener('keypress', function(e) {
			if (e.key === 'Enter') addDomain();
		});
		</script>
		
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

function action_iptables_start()
	local sys = require "luci.sys"
	local uci = require "luci.model.uci".cursor()
	
	-- Get configuration
	local local_port = uci:get("bdix", "config", "local_port") or "1337"
	local custom_ips = uci:get("bdix", "config", "custom_ips") or ""
	local custom_domains = uci:get("bdix", "config", "custom_domains") or ""
	local safety_ips = uci:get("bdix", "config", "safety_ips") or "192.168.0.0/16,172.16.0.0/12,10.0.0.0/8,127.0.0.0/8,169.254.0.0/16,224.0.0.0/4,240.0.0.0/4"
	
	-- Create BDIX chain with safety rules
	sys.call("iptables -t nat -N BDIX 2>/dev/null")
	
	-- Add safety exclusions (configurable but with warnings)
	if safety_ips ~= "" then
		for ip in string.gmatch(safety_ips, "([^,]+)") do
			local clean_ip = string.gsub(ip, "^%s*(.-)%s*$", "%1")
			if clean_ip ~= "" then
				sys.call("iptables -t nat -A BDIX -d " .. clean_ip .. " -j RETURN")
			end
		end
	end
	
	-- Add custom IP exclusions
	if custom_ips ~= "" then
		for ip in string.gmatch(custom_ips, "([^,]+)") do
			local clean_ip = string.gsub(ip, "^%s*(.-)%s*$", "%1")
			if clean_ip ~= "" then
				sys.call("iptables -t nat -A BDIX -d " .. clean_ip .. " -j RETURN")
			end
		end
	end
	
	-- Add custom domain exclusions (resolve to IP if possible)
	if custom_domains ~= "" then
		for domain in string.gmatch(custom_domains, "([^,]+)") do
			local clean_domain = string.gsub(domain, "^%s*(.-)%s*$", "%1")
			if clean_domain ~= "" then
				-- Try to resolve domain to IP for iptables rule
				local ip_result = sys.exec("nslookup " .. clean_domain .. " | grep -A1 'Name:' | tail -1 | awk '{print $2}' 2>/dev/null")
				if ip_result and ip_result ~= "" then
					local clean_ip = string.gsub(ip_result, "%s+", "")
					if clean_ip ~= "" then
						sys.call("iptables -t nat -A BDIX -d " .. clean_ip .. " -j RETURN")
					end
				end
			end
		end
	end
	
	-- Redirect remaining traffic to proxy
	sys.call("iptables -t nat -A BDIX -p tcp -j REDIRECT --to-ports " .. local_port)
	
	-- Apply the chain to PREROUTING
	sys.call("iptables -t nat -A PREROUTING -i br-lan -p tcp -j BDIX")
	
	-- Allow access to proxy port
	sys.call("iptables -A INPUT -i br-lan -p tcp --dport " .. local_port .. " -j ACCEPT")
	
	luci.http.redirect(luci.dispatcher.build_url("admin", "system", "bdix"))
end

function action_iptables_stop()
	local sys = require "luci.sys"
	
	-- Clean up BDIX iptables rules (based on your init script)
	sys.call("iptables -t nat -F BDIX 2>/dev/null")
	sys.call("iptables -t nat -D PREROUTING -i br-lan -p tcp -j BDIX 2>/dev/null")
	sys.call("iptables -t nat -X BDIX 2>/dev/null")
	
	-- Remove INPUT rule
	sys.call("iptables -D INPUT -i br-lan -p tcp --dport 1337 -j ACCEPT 2>/dev/null")
	
	-- Restart firewall to restore normal rules
	sys.call("/etc/init.d/firewall restart")
	
	luci.http.redirect(luci.dispatcher.build_url("admin", "system", "bdix"))
end

function action_add_ip()
	local uci = require "luci.model.uci".cursor()
	local http = luci.http
	
	local new_ip = http.formvalue("ip")
	if new_ip and new_ip ~= "" then
		local current_ips = uci:get("bdix", "config", "custom_ips") or ""
		
		-- Check if IP already exists
		local exists = false
		if current_ips ~= "" then
			for ip in string.gmatch(current_ips, "([^,]+)") do
				if string.gsub(ip, "^%s*(.-)%s*$", "%1") == new_ip then
					exists = true
					break
				end
			end
		end
		
		if not exists then
			local updated_ips = current_ips == "" and new_ip or current_ips .. "," .. new_ip
			uci:set("bdix", "config", "custom_ips", updated_ips)
			uci:commit("bdix")
		end
	end
	
	http.redirect(luci.dispatcher.build_url("admin", "system", "bdix"))
end

function action_remove_ip()
	local uci = require "luci.model.uci".cursor()
	local http = luci.http
	
	local remove_ip = http.formvalue("ip")
	if remove_ip and remove_ip ~= "" then
		local current_ips = uci:get("bdix", "config", "custom_ips") or ""
		local new_ips = {}
		
		if current_ips ~= "" then
			for ip in string.gmatch(current_ips, "([^,]+)") do
				local clean_ip = string.gsub(ip, "^%s*(.-)%s*$", "%1")
				if clean_ip ~= remove_ip then
					table.insert(new_ips, clean_ip)
				end
			end
		end
		
		uci:set("bdix", "config", "custom_ips", table.concat(new_ips, ","))
		uci:commit("bdix")
	end
	
	http.redirect(luci.dispatcher.build_url("admin", "system", "bdix"))
end

function action_add_domain()
	local uci = require "luci.model.uci".cursor()
	local http = luci.http
	
	local new_domain = http.formvalue("domain")
	if new_domain and new_domain ~= "" then
		local current_domains = uci:get("bdix", "config", "custom_domains") or ""
		
		-- Check if domain already exists
		local exists = false
		if current_domains ~= "" then
			for domain in string.gmatch(current_domains, "([^,]+)") do
				if string.gsub(domain, "^%s*(.-)%s*$", "%1") == new_domain then
					exists = true
					break
				end
			end
		end
		
		if not exists then
			local updated_domains = current_domains == "" and new_domain or current_domains .. "," .. new_domain
			uci:set("bdix", "config", "custom_domains", updated_domains)
			uci:commit("bdix")
		end
	end
	
	http.redirect(luci.dispatcher.build_url("admin", "system", "bdix"))
end

function action_remove_domain()
	local uci = require "luci.model.uci".cursor()
	local http = luci.http
	
	local remove_domain = http.formvalue("domain")
	if remove_domain and remove_domain ~= "" then
		local current_domains = uci:get("bdix", "config", "custom_domains") or ""
		local new_domains = {}
		
		if current_domains ~= "" then
			for domain in string.gmatch(current_domains, "([^,]+)") do
				local clean_domain = string.gsub(domain, "^%s*(.-)%s*$", "%1")
				if clean_domain ~= remove_domain then
					table.insert(new_domains, clean_domain)
				end
			end
		end
		
		uci:set("bdix", "config", "custom_domains", table.concat(new_domains, ","))
		uci:commit("bdix")
	end
	
	http.redirect(luci.dispatcher.build_url("admin", "system", "bdix"))
end

function action_add_safety_ip()
	local uci = require "luci.model.uci".cursor()
	local http = luci.http
	
	local new_ip = http.formvalue("ip")
	if new_ip and new_ip ~= "" then
		local current_safety = uci:get("bdix", "config", "safety_ips") or "192.168.0.0/16,172.16.0.0/12,10.0.0.0/8,127.0.0.0/8,169.254.0.0/16,224.0.0.0/4,240.0.0.0/4"
		
		-- Check if IP already exists
		local exists = false
		if current_safety ~= "" then
			for ip in string.gmatch(current_safety, "([^,]+)") do
				if string.gsub(ip, "^%s*(.-)%s*$", "%1") == new_ip then
					exists = true
					break
				end
			end
		end
		
		if not exists then
			local updated_safety = current_safety == "" and new_ip or current_safety .. "," .. new_ip
			uci:set("bdix", "config", "safety_ips", updated_safety)
			uci:commit("bdix")
		end
	end
	
	http.redirect(luci.dispatcher.build_url("admin", "system", "bdix"))
end

function action_remove_safety_ip()
	local uci = require "luci.model.uci".cursor()
	local http = luci.http
	
	local remove_ip = http.formvalue("ip")
	if remove_ip and remove_ip ~= "" then
		local current_safety = uci:get("bdix", "config", "safety_ips") or "192.168.0.0/16,172.16.0.0/12,10.0.0.0/8,127.0.0.0/8,169.254.0.0/16,224.0.0.0/4,240.0.0.0/4"
		local new_safety = {}
		
		if current_safety ~= "" then
			for ip in string.gmatch(current_safety, "([^,]+)") do
				local clean_ip = string.gsub(ip, "^%s*(.-)%s*$", "%1")
				if clean_ip ~= remove_ip then
					table.insert(new_safety, clean_ip)
				end
			end
		end
		
		uci:set("bdix", "config", "safety_ips", table.concat(new_safety, ","))
		uci:commit("bdix")
	end
	
	http.redirect(luci.dispatcher.build_url("admin", "system", "bdix"))
end

function action_edit_safety_ip()
	local uci = require "luci.model.uci".cursor()
	local http = luci.http
	
	local old_ip = http.formvalue("old_ip")
	local new_ip = http.formvalue("new_ip")
	
	if old_ip and new_ip and old_ip ~= "" and new_ip ~= "" then
		local current_safety = uci:get("bdix", "config", "safety_ips") or "192.168.0.0/16,172.16.0.0/12,10.0.0.0/8,127.0.0.0/8,169.254.0.0/16,224.0.0.0/4,240.0.0.0/4"
		local updated_safety = {}
		
		if current_safety ~= "" then
			for ip in string.gmatch(current_safety, "([^,]+)") do
				local clean_ip = string.gsub(ip, "^%s*(.-)%s*$", "%1")
				if clean_ip == old_ip then
					table.insert(updated_safety, new_ip)
				else
					table.insert(updated_safety, clean_ip)
				end
			end
		end
		
		uci:set("bdix", "config", "safety_ips", table.concat(updated_safety, ","))
		uci:commit("bdix")
	end
	
	http.redirect(luci.dispatcher.build_url("admin", "system", "bdix"))
end
