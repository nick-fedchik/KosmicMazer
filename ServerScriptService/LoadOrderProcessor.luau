--[[
================================================================================
KOSMICMAZER — Load Order Processor
================================================================================

Purpose: Utility for processing LoadOrder configurations
Version: 1.0

Description:
This module provides utilities for reading and processing LoadOrder.luau
configurations from SpaceStation, Planet, and Location Configuration folders.

Supports LoadOrder v1.0 (legacy) and v2.0 (current) formats.

API:
- LoadOrderProcessor.LoadConfig(configFolder) → LoadOrderConfig or nil
- LoadOrderProcessor.SortWorkspaceObjects(objects, config) → sorted array
- LoadOrderProcessor.SortServerScripts(scripts, config) → sorted array
- LoadOrderProcessor.SortClientScripts(scripts, config) → sorted array
- LoadOrderProcessor.GetScriptAction(scriptName, config) → "require" or "clone"

Usage Example:
```lua
local processor = require(ServerScriptService.LoadOrderProcessor)
local config = processor.LoadConfig(spaceStation.Configuration)

if config then
    local sortedObjects = processor.SortWorkspaceObjects(workspace:GetChildren(), config)
    for _, obj in ipairs(sortedObjects) do
        -- Process objects in priority order
    end
end
```

================================================================================
]]

local LoadOrderProcessor = {}

-- Load LoadOrder configuration from a Configuration folder
function LoadOrderProcessor.LoadConfig(configFolder: Folder)
	if not configFolder or not configFolder:IsA("Folder") then
		return nil
	end
	
	local loadOrderModule = configFolder:FindFirstChild("LoadOrder")
	if not loadOrderModule or not loadOrderModule:IsA("ModuleScript") then
		return nil
	end
	
	local success, config = pcall(require, loadOrderModule)
	if not success then
		warn("[LoadOrderProcessor] ❌ Failed to load LoadOrder config: " .. tostring(config))
		return nil
	end
	
	return config
end

-- Sort Workspace objects by priority
function LoadOrderProcessor.SortWorkspaceObjects(objects: {Instance}, config)
	if not config then
		return objects
	end
	
	local sorted = {}
	for _, obj in ipairs(objects) do
		table.insert(sorted, obj)
	end
	
	table.sort(sorted, function(a, b)
		local priorityA = LoadOrderProcessor.GetWorkspacePriority(a.Name, config)
		local priorityB = LoadOrderProcessor.GetWorkspacePriority(b.Name, config)
		return priorityA < priorityB
	end)
	
	return sorted
end

-- Sort Server scripts by priority
function LoadOrderProcessor.SortServerScripts(scripts: {Instance}, config)
	if not config then
		return scripts
	end
	
	local sorted = {}
	for _, script in ipairs(scripts) do
		table.insert(sorted, script)
	end
	
	table.sort(sorted, function(a, b)
		local priorityA = LoadOrderProcessor.GetServerScriptPriority(a.Name, config)
		local priorityB = LoadOrderProcessor.GetServerScriptPriority(b.Name, config)
		return priorityA < priorityB
	end)
	
	return sorted
end

-- Sort Client scripts by priority
function LoadOrderProcessor.SortClientScripts(scripts: {Instance}, config)
	if not config then
		return scripts
	end
	
	local sorted = {}
	for _, script in ipairs(scripts) do
		table.insert(sorted, script)
	end
	
	table.sort(sorted, function(a, b)
		local priorityA = LoadOrderProcessor.GetClientScriptPriority(a.Name, config)
		local priorityB = LoadOrderProcessor.GetClientScriptPriority(b.Name, config)
		return priorityA < priorityB
	end)
	
	return sorted
end

-- Get priority for a Workspace object
function LoadOrderProcessor.GetWorkspacePriority(objectName: string, config): number
	if not config then
		return 500
	end
	
	-- Try v2.0 method
	if config.GetWorkspacePriority then
		return config.GetWorkspacePriority(objectName)
	end
	
	-- Fallback to v1.0 method (legacy compatibility)
	if config.GetPriority then
		return config.GetPriority(objectName)
	end
	
	-- Manual search in WorkspaceObjects or ORDER
	local list = config.WorkspaceObjects or config.ORDER
	if list then
		for _, entry in ipairs(list) do
			if entry.name == objectName then
				return entry.priority or 500
			end
		end
	end
	
	return 500
end

-- Get priority for a Server script
function LoadOrderProcessor.GetServerScriptPriority(scriptName: string, config): number
	if not config then
		return 500
	end
	
	-- Try v2.0 method
	if config.GetServerScriptPriority then
		return config.GetServerScriptPriority(scriptName)
	end
	
	-- Manual search in ServerScripts
	if config.ServerScripts then
		for _, entry in ipairs(config.ServerScripts) do
			if entry.name == scriptName then
				return entry.priority or 500
			end
		end
	end
	
	return 500
end

-- Get priority for a Client script
function LoadOrderProcessor.GetClientScriptPriority(scriptName: string, config): number
	if not config then
		return 500
	end
	
	-- Try v2.0 method
	if config.GetClientScriptPriority then
		return config.GetClientScriptPriority(scriptName)
	end
	
	-- Manual search in ClientScripts
	if config.ClientScripts then
		for _, entry in ipairs(config.ClientScripts) do
			if entry.name == scriptName then
				return entry.priority or 500
			end
		end
	end
	
	return 500
end

-- Get action for a Server script ("require" or "clone")
function LoadOrderProcessor.GetScriptAction(scriptName: string, config): string
	if not config then
		return "require"
	end
	
	-- Try v2.0 method
	if config.GetServerScriptAction then
		return config.GetServerScriptAction(scriptName)
	end
	
	-- Manual search in ServerScripts
	if config.ServerScripts then
		for _, entry in ipairs(config.ServerScripts) do
			if entry.name == scriptName then
				return entry.action or "require"
			end
		end
	end
	
	return "require"
end

-- Get LoadOrder settings (v2.0 only)
function LoadOrderProcessor.GetSettings(config)
	if not config then
		return {
			LoadTimeout = 10,
			EnableParallelLoading = false,
			VerifyAfterLoad = true,
		}
	end
	
	return config.Settings or {
		LoadTimeout = 10,
		EnableParallelLoading = false,
		VerifyAfterLoad = true,
	}
end

-- Validate LoadOrder configuration
function LoadOrderProcessor.ValidateConfig(config): (boolean, string?)
	if not config then
		return false, "Config is nil"
	end
	
	-- Check version
	local version = config.Version or "1.0"
	if version ~= "1.0" and version ~= "2.0" then
		return false, "Unknown LoadOrder version: " .. tostring(version)
	end
	
	-- Check for required fields based on version
	if version == "2.0" then
		if not config.WorkspaceObjects or type(config.WorkspaceObjects) ~= "table" then
			return false, "Missing or invalid WorkspaceObjects in v2.0 config"
		end
		if not config.ServerScripts or type(config.ServerScripts) ~= "table" then
			return false, "Missing or invalid ServerScripts in v2.0 config"
		end
		if not config.ClientScripts or type(config.ClientScripts) ~= "table" then
			return false, "Missing or invalid ClientScripts in v2.0 config"
		end
	elseif version == "1.0" then
		if not config.ORDER or type(config.ORDER) ~= "table" then
			return false, "Missing or invalid ORDER in v1.0 config"
		end
	end
	
	return true, nil
end

-- Print LoadOrder configuration for debugging
function LoadOrderProcessor.PrintConfig(config, prefix: string?)
	prefix = prefix or "[LoadOrderProcessor]"
	
	if not config then
		print(prefix .. " No LoadOrder config")
		return
	end
	
	local version = config.Version or "1.0"
	print(prefix .. " LoadOrder v" .. version)
	
	if version == "2.0" then
		print(prefix .. " WorkspaceObjects: " .. #config.WorkspaceObjects .. " entries")
		print(prefix .. " ServerScripts: " .. #config.ServerScripts .. " entries")
		print(prefix .. " ClientScripts: " .. #config.ClientScripts .. " entries")
		
		local settings = LoadOrderProcessor.GetSettings(config)
		print(prefix .. " Settings:")
		print(prefix .. "   LoadTimeout: " .. settings.LoadTimeout)
		print(prefix .. "   EnableParallelLoading: " .. tostring(settings.EnableParallelLoading))
		print(prefix .. "   VerifyAfterLoad: " .. tostring(settings.VerifyAfterLoad))
	elseif version == "1.0" then
		print(prefix .. " ORDER: " .. #config.ORDER .. " entries")
	end
end

return LoadOrderProcessor
