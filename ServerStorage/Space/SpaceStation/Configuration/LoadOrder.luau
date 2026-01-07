--[[
================================================================================
KOSMICMAZER — Space Station Load Order Configuration
================================================================================

Purpose: Defines the order in which Space Station objects are loaded
Version: 1.0

Description:
This module defines the loading order for Space Station environment objects.
Objects are loaded in the specified order to avoid geometric conflicts and
ensure proper initialization of dependencies.

Default Order:
1. SpaceStation - Main station model
2. Planet - Planet visual model
3. PlanetSurfaceScanner - Scanner tool
4. SpawnLocation - Player spawn point (loaded last)

Usage:
The LoadOrder is read by LocationManager and passed to EnvironmentLoader.
Objects not listed in LoadOrder will be loaded after all specified objects
in their natural folder order.

To customize:
Simply reorder the entries or add new object names. The priority value
determines the loading sequence (lower numbers load first).

================================================================================
]]

local LoadOrder = {}

-- Define loading order (lower priority = loads first)
LoadOrder.ORDER = {
	{name = "SpaceStation", priority = 1},
	{name = "Planet", priority = 2},
	{name = "PlanetSurfaceScanner", priority = 3},
	{name = "SpawnLocation", priority = 999},  -- Always load last by default
}

-- Helper function to get priority for an object
function LoadOrder.GetPriority(objectName: string): number
	for _, entry in ipairs(LoadOrder.ORDER) do
		if entry.name == objectName then
			return entry.priority
		end
	end
	-- Objects not in the list get default priority (loaded after specified objects)
	return 500
end

-- Helper function to sort objects by load order
function LoadOrder.SortObjects(objects: {Instance}): {Instance}
	local sorted = {}
	for _, obj in ipairs(objects) do
		table.insert(sorted, obj)
	end
	
	table.sort(sorted, function(a, b)
		return LoadOrder.GetPriority(a.Name) < LoadOrder.GetPriority(b.Name)
	end)
	
	return sorted
end

return LoadOrder
