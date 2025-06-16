-- Copyright (C) 2023 OpenWrt.org

module("luci.controller.bdix", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/bdix") then
		return
	end

	local page = entry({"admin", "services", "bdix"}, cbi("bdix"), _("BDIX Proxy"), 60)
	page.dependent = true
	page.acl_depends = { "luci-app-bdix" }

	entry({"admin", "services", "bdix", "status"}, call("action_status"))
	entry({"admin", "services", "bdix", "start"}, call("action_start"))
	entry({"admin", "services", "bdix", "stop"}, call("action_stop"))
	entry({"admin", "services", "bdix", "restart"}, call("action_restart"))
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
	
	-- Check if configuration exists
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
	local result = sys.call("/etc/init.d/bdix start")
	luci.http.prepare_content("application/json")
	luci.http.write_json({success = result == 0})
end

function action_stop()
	local sys = require "luci.sys"
	local result = sys.call("/etc/init.d/bdix stop")
	luci.http.prepare_content("application/json")
	luci.http.write_json({success = result == 0})
end

function action_restart()
	local sys = require "luci.sys"
	local result = sys.call("/etc/init.d/bdix restart")
	luci.http.prepare_content("application/json")
	luci.http.write_json({success = result == 0})
end
