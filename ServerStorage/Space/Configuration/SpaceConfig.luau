--[[
================================================================================
KOSMICMAZER — Space Configuration
================================================================================

Purpose: Конфігурація та правила гри для планети Zalizyaka (Planet_1)
Version: 1.0

Features:
- Загальні налаштування Космосу
- Фізичні властивості (гравітація, атмосфера)
- Ресурси та економіка 


API:

Calls to:

Called from:

Dependencies:
- GameConfig module

ChangeLog:
- Version 1.0: Initial template for planet-specific configuration

================================================================================
]]


local SpaceConfig = {}

--============================================================================--
-- КОНСТАНТИ СТАНЦІЇ / STATION CONSTANTS
--============================================================================--

SpaceConfig.STATION_ID = "SpaceStation"
SpaceConfig.STATION_NAME = "Cosmic Research Station Discoverer-1"
SpaceConfig.DISPLAY_NAME = "Космічна Станція"

--============================================================================--
-- ФІЗИЧНІ ВЛАСТИВОСТІ / PHYSICAL PROPERTIES
--============================================================================--

SpaceConfig.GRAVITY = 0.8
SpaceConfig.ATMOSPHERE = {
	HasOxygen = true,
	Density = 0.7,
	Color = Color3.fromRGB(200, 220, 255),
}

--============================================================================--
-- GAME RULES / ПРАВИЛА ГРИ
--============================================================================--

SpaceConfig.RULES = {
	AllowTeleport = true,
	AllowResourceCollection = false,
	AllowNPCInteraction = true,
}

--============================================================================--
-- API
--============================================================================--

function SpaceConfig.GetStationRules()
	return SpaceConfig.RULES
end

function SpaceConfig.GetGravity()
	return SpaceConfig.GRAVITY
end

function SpaceConfig.GetAtmosphere()
	return SpaceConfig.ATMOSPHERE
end

function SpaceConfig.GetDisplayName()
	return SpaceConfig.DISPLAY_NAME
end

function SpaceConfig.GetStationName()
	return SpaceConfig.STATION_NAME
end

--============================================================================--
-- RETURN MODULE
--============================================================================--

return SpaceConfig
