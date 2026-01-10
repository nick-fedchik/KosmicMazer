--[[
================================================================================
KOSMICMAZER — Planet_2 Configuration
================================================================================

Purpose: Конфігурація та правила гри для планети Zalizyaka (Planet_2)
Version: 1.0

Features:
- Загальні налаштування планети
- Фізичні властивості (гравітація, атмосфера)
- Правила гри спільні для всіх локацій планети
- Ресурси та економіка планети
- Прогресія та відкриття локацій

API:
- GetPlanetRules(): Повертає правила гри на планеті
- GetGravity(): Повертає гравітацію планети
- GetAtmosphere(): Повертає параметри атмосфери
- GetResourceRates(): Повертає швидкості регенерації ресурсів
- IsLocationUnlocked(locationId): Перевіряє чи відкрита локація

Calls to:
- GameConfig: Базові налаштування планети
- PlayerDataManager: Прогресія гравця

Called from:
- LocationManager: При завантаженні локації на планеті
- LocationGameServer: Для отримання планетарних правил
- ResourceController: Для отримання швидкостей регенерації

Dependencies:
- GameConfig module

ChangeLog:
- Version 1.0: Initial template for planet-specific configuration

================================================================================
]]

local PlanetConfig = {}

--============================================================================--
-- КОНСТАНТИ ПЛАНЕТИ / PLANET CONSTANTS
--============================================================================--

PlanetConfig.PLANET_ID = "Planet_2"
PlanetConfig.PLANET_NAME = "Zalizyaka"
PlanetConfig.DISPLAY_NAME = "Залізяка"

--============================================================================--
-- ЛОКАЦІЇ ПЛАНЕТИ / PLANET LOCATIONS
--============================================================================--

PlanetConfig.LOCATIONS = {
	Location_1 = {
		Name = "Location_1",
		DisplayName = "Манівці",
		Folder = "Location_1",
		SpawnPoint = "SpawnLocation",
		TeleportPoint = "SpawnLocation",
		isDiscovered = false,
		isVisited = false,
		TeleportTo = false,
	},
	Location_2 = {
		Name = "Location_2",
		DisplayName = "Обабіч",
		Folder = "Location_2",
		SpawnPoint = "SpawnLocation",
		TeleportPoint = "SpawnLocation",
		isDiscovered = false,
		isVisited = false,
		TeleportTo = false,
	},
	Location_3 = {
		Name = "Location_3",
		DisplayName = "Видноколо",
		Folder = "Location_3",
		SpawnPoint = "SpawnLocation",
		TeleportPoint = "SpawnLocation",
		isDiscovered = false,
		isVisited = false,
		TeleportTo = false,
	},
}
--============================================================================--
-- ФІЗИЧНІ ВЛАСТИВОСТІ / PHYSICAL PROPERTIES
--============================================================================--

-- Гравітація (множник відносно земної)
PlanetConfig.GRAVITY = 1.0

-- Атмосфера
PlanetConfig.ATMOSPHERE = {
	HasOxygen = true,
	Density = 1.0,
	Color = Color3.fromRGB(135, 206, 235), -- Блакитне небо
	Decay = 0.5,
	Glare = 0.2,
	Haze = 0.3,
	Offset = 0
}

-- Освітлення
PlanetConfig.LIGHTING = {
	ClockTime = 14, -- 14:00 за замовчуванням
	GeographicLatitude = 45,
	Brightness = 2,
	Ambient = Color3.fromRGB(138, 138, 138),
	OutdoorAmbient = Color3.fromRGB(127, 127, 127)
}

--============================================================================--
-- ПРАВИЛА ГРИ / GAME RULES
--============================================================================--

-- Загальні правила планети
PlanetConfig.GAME_RULES = {
	-- Ресурси
	AllowResourceCollection = true,
	ResourceRespawnTime = 60, -- секунди
	MaxResourcesPerPlayer = 100,

	-- PvP
	AllowPvP = false,

	-- Будівництво
	AllowBuilding = false,

	-- Міні-ігри
	AllowMinigames = true,

	-- Квести
	AllowQuests = true
}

-- Швидкості регенерації ресурсів (множники)
PlanetConfig.RESOURCE_RATES = {
	Ore = 1.0,
	Crystal = 0.8,
	Artifact = 0.5,
	Energy = 1.2
}

-- Економіка планети
PlanetConfig.ECONOMY = {
	Currency = "Credits",
	BasePrices = {
		Ore = 10,
		Crystal = 50,
		Artifact = 200,
		Energy = 5
	}
}

--============================================================================--
-- ПРОГРЕСІЯ / PROGRESSION
--============================================================================--

-- Умови відкриття локацій
PlanetConfig.LOCATION_UNLOCK_CONDITIONS = {
	Location_1 = {
		Unlocked = true, -- Завжди відкрита (стартова локація)
		RequiredLevel = 0
	},
	Location_2 = {
		Unlocked = false,
		RequiredLevel = 5,
		RequiredQuests = {"Location_1_Quest_1"}
	},
	Location_3 = {
		Unlocked = false,
		RequiredLevel = 10,
		RequiredQuests = {"Location_2_Quest_1", "Location_2_Quest_2"}
	}
}

--============================================================================--
-- ПУБЛІЧНІ ФУНКЦІЇ / PUBLIC API
--============================================================================--

--[[
@function GetPlanetRules
Повертає правила гри на планеті

@return table - Таблиця з правилами гри
]]
function PlanetConfig.GetPlanetRules()
	return PlanetConfig.GAME_RULES
end

--[[
@function GetGravity
Повертає гравітацію планети

@return number - Множник гравітації (1.0 = земна)
]]
function PlanetConfig.GetGravity()
	return PlanetConfig.GRAVITY
end

--[[
@function GetAtmosphere
Повертає параметри атмосфери

@return table - Налаштування атмосфери
]]
function PlanetConfig.GetAtmosphere()
	return PlanetConfig.ATMOSPHERE
end

--[[
@function GetResourceRates
Повертає швидкості регенерації ресурсів

@return table - Множники швидкості для кожного типу ресурсу
]]
function PlanetConfig.GetResourceRates()
	return PlanetConfig.RESOURCE_RATES
end

--[[
@function IsLocationUnlocked
Перевіряє чи відкрита локація для гравця

@param locationId string - ID локації
@param playerData table - Дані гравця (рівень, квести)
@return boolean - Чи відкрита локація
]]
function PlanetConfig.IsLocationUnlocked(locationId, playerData)
	local condition = PlanetConfig.LOCATION_UNLOCK_CONDITIONS[locationId]

	if not condition then
		return false
	end

	-- Перевірка завжди відкритих локацій
	if condition.Unlocked then
		return true
	end

	-- Перевірка рівня
	if playerData and playerData.Level and playerData.Level >= condition.RequiredLevel then
		-- Перевірка квестів
		if condition.RequiredQuests then
			for _, questId in ipairs(condition.RequiredQuests) do
				if not playerData.CompletedQuests or not playerData.CompletedQuests[questId] then
					return false
				end
			end
		end
		return true
	end

	return false
end

--[[
@function ApplyPlanetPhysics
Застосовує фізичні властивості планети до Workspace

@return nil
]]
function PlanetConfig.ApplyPlanetPhysics()
	local Workspace = game:GetService("Workspace")

	-- Застосувати гравітацію
	Workspace.Gravity = 196.2 * PlanetConfig.GRAVITY -- 196.2 - стандартна гравітація Roblox

	print("[PlanetConfig] ✅ Застосовано гравітацію:", PlanetConfig.GRAVITY, "(" .. Workspace.Gravity .. ")")
end

return PlanetConfig
