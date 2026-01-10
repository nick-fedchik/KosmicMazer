--[[
================================================================================
KOSMICMAZER — Space Load Order Configuration
================================================================================

Purpose: Defines the loading order for Space-level content
Version: 1.0

Features:
- Priority-based loading for Workspace objects
- Planet-wide server scripts loading order
- Planet-wide client scripts loading order
- Configurable timeout and verification settings

API:

Calls to:

Called from:


--[[
================================================================================
KOSMICMAZER — SpaceStation Load Order Configuration
================================================================================

Purpose: Priority-based loading for SpaceStation and other space models
Version: 1.1

Features:
- Priority-based loading for all Workspace models (SpaceStation, future Planets)
- Server/client scripts loading order
- Configurable timeouts and verification

ChangeLog:
- Version 1.1: Refactored for multi-model support (2026-01-10)
- Version 1.0: Initial implementation
================================================================================
]]

local LoadOrder = {}

-- Workspace models to load (can be extended for more stations/planets)
LoadOrder.WorkspaceObjects = {
	{
		Name = "LocationModel", -- Standard model name
		Type = "SpaceStation",  -- or "Planet" in future
		Priority = 1,
		Timeout = 10,
		VerifyAttributes = {
			"LocationId",
			"LocationType",
			"DisplayName"
		}
	}
	-- Add more models here as needed
}

-- Server scripts loading order
LoadOrder.ServerScripts = {
	"GameInit.server.luau",
	"EnvironmentLoader.luau",
	"SpaceStationManager.luau"
	-- Add more as needed
}

-- Client scripts loading order
LoadOrder.ClientScripts = {
	"PlanetSurfaceScannerUI.local.luau",
	"SpaceStationUI.local.luau"
	-- Add more as needed
}

-- Timeout and verification settings
LoadOrder.Timeouts = {
	WorkspaceModel = 10,
	ScriptLoad = 5
}



 --[[
📝 ЯК НАЛАШТУВАТИ:

1. WorkspaceObjects:
   {name = "Planet", priority = 1, description = "Модель планети"}

2. ServerScripts:
   {name = "PlanetConfig", priority = 1, action = "require", description = "Конфігурація планети"}

3. ClientScripts:
   {name = "PlanetUI", priority = 1, description = "UI планети"}

⚠️ ВАЖЛИВО:
- Пріоритет ServerScripts має враховувати залежності між модулями
- Якщо LocationGameServer потребує PlanetConfig, дайте PlanetConfig нижчий пріоритет

📚 Детальна документація: ReplicatedStorage/Docs/LoadOrderSystem.luau

================================================================================
]]


LoadOrder.Version = "1.0"

-- Порядок копіювання об'єктів з SpaceStation/Workspace/ → game.Workspace
-- TODO зробити по аналогії до Planet_1/Configuration/loadOrder



return LoadOrder
