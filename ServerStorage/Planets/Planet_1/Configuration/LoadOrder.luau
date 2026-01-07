--[[
================================================================================
KOSMICMAZER — Planet Load Order Configuration
================================================================================

Purpose: Defines the loading order for Planet-level content
Version: 2.0
Planet: Planet_1 (Залізяка)

Description:
This module defines the loading order for:
- Workspace objects (copied to game.Workspace)
- Planet-wide server scripts (loaded as modules)
- Planet-wide client scripts (copied to StarterPlayerScripts)

Loading is done in the specified priority order (lower numbers load first).

Structure:
- WorkspaceObjects: Objects from Planet/Workspace/
- ServerScripts: Scripts from Planet/Scripts/Server/
- ClientScripts: Scripts from Planet/Scripts/Client/

Priority Rules:
- 1-100: Core infrastructure (Planet model, atmosphere)
- 101-500: Standard objects and scripts
- 501-998: Optional/secondary content
- 999: Reserved for critical finalizers
- Default (unlisted): 500

Usage:
LoadOrder is read by EnvironmentLoader during LoadPlanetEnvironment().
Objects/scripts not listed will be loaded with default priority (500).

Note:
Planet-level LoadOrder is processed BEFORE Location-level LoadOrder.
This ensures planet-wide scripts are available to all locations.

================================================================================
]]

local LoadOrder = {}

LoadOrder.Version = "2.0"

-- Порядок копіювання об'єктів з Planet/Workspace/ → game.Workspace
LoadOrder.WorkspaceObjects = {
	{name = "Planet", priority = 1, description = "Planet visual model"},
	-- Add more planet-level objects here
}

-- Порядок обробки серверних скриптів з Planet/Scripts/Server/
LoadOrder.ServerScripts = {
	{name = "PlanetConfig", priority = 1, action = "require", description = "Planet game rules & resources"},
	{name = "PlanetManager", priority = 2, action = "require", description = "Planet controller"},
	-- ModuleScripts: action = "require" (loaded as modules)
	-- Scripts: action = "clone" (copied to Workspace)
	-- Add more scripts here
}

-- Порядок копіювання клієнтських скриптів з Planet/Scripts/Client/ → StarterPlayerScripts
LoadOrder.ClientScripts = {
	{name = "PlanetUI", priority = 1, description = "Planet-wide UI controller"},
	{name = "PlanetEffects", priority = 2, description = "Planet-specific visual effects"},
	-- Add more client scripts here
}

-- Загальні налаштування завантаження
LoadOrder.Settings = {
	LoadTimeout = 10,  -- Maximum time to wait for loading (seconds)
	EnableParallelLoading = false,  -- Load items in parallel (experimental)
	VerifyAfterLoad = true,  -- Verify all objects loaded successfully
}

-- Helper function to get priority for a Workspace object
function LoadOrder.GetWorkspacePriority(objectName: string): number
	for _, entry in ipairs(LoadOrder.WorkspaceObjects) do
		if entry.name == objectName then
			return entry.priority
		end
	end
	return 500  -- Default priority for unlisted objects
end

-- Helper function to get priority for a Server script
function LoadOrder.GetServerScriptPriority(scriptName: string): number
	for _, entry in ipairs(LoadOrder.ServerScripts) do
		if entry.name == scriptName then
			return entry.priority
		end
	end
	return 500
end

-- Helper function to get priority for a Client script
function LoadOrder.GetClientScriptPriority(scriptName: string): number
	for _, entry in ipairs(LoadOrder.ClientScripts) do
		if entry.name == scriptName then
			return entry.priority
		end
	end
	return 500
end

-- Helper function to get script action (require/clone)
function LoadOrder.GetServerScriptAction(scriptName: string): string
	for _, entry in ipairs(LoadOrder.ServerScripts) do
		if entry.name == scriptName then
			return entry.action or "require"  -- Default to require
		end
	end
	return "require"
end

-- Helper function to sort objects by load order
function LoadOrder.SortObjects(objects: {Instance}): {Instance}
	local sorted = {}
	for _, obj in ipairs(objects) do
		table.insert(sorted, obj)
	end
	
	table.sort(sorted, function(a, b)
		return LoadOrder.GetWorkspacePriority(a.Name) < LoadOrder.GetWorkspacePriority(b.Name)
	end)
	
	return sorted
end

-- Legacy compatibility: alias for WorkspaceObjects
LoadOrder.ORDER = LoadOrder.WorkspaceObjects
LoadOrder.GetPriority = LoadOrder.GetWorkspacePriority

return LoadOrder
