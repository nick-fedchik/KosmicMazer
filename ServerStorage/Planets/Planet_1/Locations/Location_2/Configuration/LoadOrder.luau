--[[
================================================================================
KOSMICMAZER — Location_2 Load Order Configuration
================================================================================

Purpose: Defines the loading order for Location_2 content
Version: 2.0
Location: Planet_1 / Location_2 (Садочок)

Features:
- Priority-based loading for Location Workspace objects
- Location-specific server scripts loading order
- Location-specific client scripts loading order
- Configurable timeout and verification settings

API:
- LoadOrder.GetWorkspacePriority(objectName): Returns priority for object
- LoadOrder.GetServerScriptPriority(scriptName): Returns priority for script
- LoadOrder.GetClientScriptPriority(scriptName): Returns priority for script
- LoadOrder.GetServerScriptAction(scriptName): Returns "require" or "clone"
- LoadOrder.SortObjects(objects): Returns sorted array by priority

Calls to:
- EnvironmentLoader: Reads this config during LoadPlanetEnvironment()
- LoadOrderProcessor: Processes this configuration

Called from:
- EnvironmentLoader.LoadPlanetEnvironment()

Dependencies:
- ServerStorage.Planets.Planet_1.Locations.Location_2.Workspace
- ServerStorage.Planets.Planet_1.Locations.Location_2.Scripts
- ServerStorage.Planets.Planet_1.Scripts (Planet-level scripts)

ChangeLog:
- Version 2.0: Added ServerScripts, ClientScripts, Settings sections
- Version 1.0: Initial implementation (WorkspaceObjects only)

================================================================================
]]

local LoadOrder = {}

LoadOrder.Version = "2.0"

-- Порядок копіювання об'єктів з Location/Workspace/ → game.Workspace
LoadOrder.WorkspaceObjects = {
	{name = "Baseplate", priority = 1, description = "Ground/terrain"},
	{name = "Buildings", priority = 2, description = "Location buildings"},
	{name = "Props", priority = 3, description = "Decorative objects"},
	{name = "NPCs", priority = 4, description = "NPC characters"},
	{name = "SpawnLocation", priority = 999, description = "Player spawn point (must load last)"},
	-- Add more objects here with their priorities
}

-- Порядок обробки серверних скриптів з Location/Scripts/Server/
LoadOrder.ServerScripts = {
	{name = "LocationGameServer", priority = 1, action = "require", description = "Location game logic"},
	{name = "ResourceController", priority = 2, action = "require", description = "Resource management"},
	-- ModuleScripts: action = "require" (loaded as modules)
	-- Scripts: action = "clone" (copied to Workspace)
	-- Add more scripts here
}

-- Порядок копіювання клієнтських скриптів з Location/Scripts/Client/ → StarterPlayerScripts
LoadOrder.ClientScripts = {
	{name = "LocationUI", priority = 1, description = "Location UI controller"},
	{name = "DialogSystem", priority = 2, description = "NPC dialogs"},
	{name = "InteractionPrompts", priority = 3, description = "Object interaction prompts"},
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