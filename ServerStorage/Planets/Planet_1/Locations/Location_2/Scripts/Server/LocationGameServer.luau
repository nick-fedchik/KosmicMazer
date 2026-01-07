--[[
================================================================================
KOSMICMAZER — Location_2 Game Server
================================================================================

Purpose: Серверна логіка гри для Location_2 на Planet_1
Version: 1.0

Features:
- Правила гри специфічні для цієї локації
- Управління ресурсами локації
- Обробка подій гравців
- Міні-ігри локації
- Квести локації

API:
- Initialize(locationModel): Ініціалізує систему гри для локації
- Cleanup(): Очищає всі події та об'єкти
- OnPlayerEnter(player): Викликається коли гравець входить в локацію
- OnPlayerLeave(player): Викликається коли гравець покидає локацію
- GetLocationRules(): Повертає правила гри локації

Dependencies:
- PlanetConfig module (Planet_1)
- GameConfig module
- PlayerDataManager module

ChangeLog:
- Version 1.0: Initial template for location-specific game logic

================================================================================
]]

local LocationGameServer = {}

--============================================================================--
-- SERVICES
--============================================================================--
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

--============================================================================--
-- КОНСТАНТИ ЛОКАЦІЇ / LOCATION CONSTANTS
--============================================================================--

LocationGameServer.LOCATION_ID = "Location_2"
LocationGameServer.LOCATION_NAME = "Location_2"
LocationGameServer.PLANET_ID = "Planet_1"

--============================================================================--
-- ПРАВИЛА ГРИ ЛОКАЦІЇ / LOCATION GAME RULES
--============================================================================--

LocationGameServer.LOCATION_RULES = {
	DisplayName = "Location_2",
	Description = "TODO: Add description",
	DifficultyLevel = 2,
	RecommendedLevel = 5
}

--============================================================================--
-- СТАН / STATE
--============================================================================--

local isInitialized = false
local locationModel = nil

--============================================================================--
-- ПУБЛІЧНІ ФУНКЦІЇ / PUBLIC API
--============================================================================--

function LocationGameServer.Initialize(model)
	if isInitialized then return false end
	
	print("[LocationGameServer] 🎮 Ініціалізація гри для:", LocationGameServer.LOCATION_NAME)
	locationModel = model
	isInitialized = true
	
	-- TODO: Implement location-specific logic
	
	return true
end

function LocationGameServer.Cleanup()
	print("[LocationGameServer] 🧹 Очищення локації:", LocationGameServer.LOCATION_NAME)
	isInitialized = false
	locationModel = nil
end

function LocationGameServer.OnPlayerEnter(player)
	print("[LocationGameServer] 👋 Гравець", player.Name, "увійшов в", LocationGameServer.LOCATION_NAME)
	-- TODO: Implement player enter logic
end

function LocationGameServer.OnPlayerLeave(player)
	print("[LocationGameServer] 👋 Гравець", player.Name, "покинув", LocationGameServer.LOCATION_NAME)
	-- TODO: Implement player leave logic
end

function LocationGameServer.GetLocationRules()
	return LocationGameServer.LOCATION_RULES
end

function LocationGameServer.IsInitialized()
	return isInitialized
end

return LocationGameServer
