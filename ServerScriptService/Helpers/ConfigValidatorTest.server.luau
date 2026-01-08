--[[
================================================================================
KOSMICMAZER — Config Validator Test Script
================================================================================

Purpose: Test ConfigValidator functionality
Version: 1.0
Type: Helper Script

Note: This is a one-time test script. Should be removed after validation testing.

================================================================================
]]

local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Load modules
local GameConfig = require(ServerScriptService:WaitForChild("GameConfig"))
local ConfigValidator = require(ServerScriptService:WaitForChild("ConfigValidator"))

print("\n" .. string.rep("=", 80))
print("STARTING CONFIG VALIDATOR TEST")
print(string.rep("=", 80))

-- Run validation
local success, result = pcall(function()
	local isValid, report = ConfigValidator.ValidateConfig(GameConfig, ServerStorage)
	
	if isValid then
		print("\n✅ Configuration is VALID!")
		print("Errors: " .. #report.errors)
		print("Warnings: " .. #report.warnings)
		print("Info: " .. #report.info)
	else
		print("\n❌ Configuration has CRITICAL ERRORS!")
		print("Errors: " .. #report.errors)
		print("Warnings: " .. #report.warnings)
		print("Info: " .. #report.info)
	end
	
	return isValid, report
end)

if not success then
	warn("❌ Test failed with error:", result)
else
	print("\n✅ Test completed successfully")
end

print("\n" .. string.rep("=", 80))
print("CONFIG VALIDATOR TEST COMPLETE")
print(string.rep("=", 80) .. "\n")
