-- Copyright (C) 2023 OpenWrt.org

module("luci.controller.bdix", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/bdix") then
		return
	end

	-- Register under System menu instead of Services (which may not exist)
	local page = entry({"admin", "system", "bdix"}, cbi("bdix"), _("BDIX Proxy"), 70)
	page.dependent = true

	-- Also try to register under Services if it exists
	pcall(function()
		local services_page = entry({"admin", "services", "bdix"}, cbi("bdix"), _("BDIX Proxy"), 60)
		services_page.dependent = true
	end)

	-- Action handlers
	entry({"admin", "system", "bdix", "status"}, call("action_status"))
	entry({"admin", "system", "bdix", "start"}, call("action_start"))
	entry({"admin", "system", "bdix", "stop"}, call("action_stop"))
	entry({"admin", "system", "bdix", "restart"}, call("action_restart"))
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
