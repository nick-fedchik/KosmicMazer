--[[
================================================================================
KOSMICMAZER — Config Validator Test Script
================================================================================

Purpose: Test ConfigValidator functionality
Version: 1.1
Type: Helper Script

Note: This is a one-time test script. Should be removed after validation testing.

ChangeLog:
- v1.1: Updated to follow LoggingConvention v3.6
- v1.1: Disabled by default - validation now runs in GameInit

================================================================================
]]

-- 🔒 DISABLED: Validation now runs automatically in GameInit
-- To enable this test, set ENABLE_TEST = true
local ENABLE_TEST = false

if not ENABLE_TEST then
	return
end

local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Load modules
local GameConfig = require(ServerScriptService:WaitForChild("GameConfig"))
local ConfigValidator = require(ServerScriptService:WaitForChild("ConfigValidator"))

print("[ConfigValidatorTest] 🚀 Running validation test...")

-- Run validation
local success, result = pcall(function()
	local isValid, report = ConfigValidator.ValidateConfig(GameConfig, ServerStorage)
	
	if isValid then
		print("[ConfigValidatorTest] ✅ Valid (E:" .. #report.errors .. " W:" .. #report.warnings .. " I:" .. #report.info .. ")")
	else
		warn("[ConfigValidatorTest] ❌ Failed (E:" .. #report.errors .. " W:" .. #report.warnings .. " I:" .. #report.info .. ")")
	end
	
	return isValid, report
end)

if not success then
	warn("[ConfigValidatorTest] 💀 Test error:", result)
else
	print("[ConfigValidatorTest] ✅ Test complete")
end
