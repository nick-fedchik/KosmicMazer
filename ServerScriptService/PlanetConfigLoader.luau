--[[
================================================================================
KOSMICMAZER — Planet Config Loader
================================================================================

Purpose: Завантаження конфігурацій планет з ServerStorage
Version: 1.0

Features:
- Динамічне завантаження PlanetConfig з ServerStorage/Planets/{PlanetId}
- Кешування завантажених конфігів для оптимізації
- Отримання конфігу поточної планети з GameConfig.DEFAULT_PLANET
- Валідація існування PlanetConfig файлів

API:
- LoadPlanetConfig(planetId): Завантажує конфіг планети з ServerStorage
- GetCurrentPlanetConfig(): Повертає конфіг DEFAULT_PLANET
- ClearCache(planetId?): Очищує кеш для hot-reload

Calls to:
- GameConfig: Отримання DEFAULT_PLANET
- ServerStorage.Planets.{PlanetId}.Configuration.PlanetConfig

Called from:
- PlanetSurfaceScanner: Отримання локацій для сканування
- TeleportationManager: Фільтрація доступних локацій
- DataStoreManager: Додавання discovered locations
- ConfigValidator: Валідація структури планет

Dependencies:
- ServerStorage/Planets/{PlanetId}/Configuration/PlanetConfig.luau
- ServerScriptService/GameConfig.luau

ChangeLog:
- Version 1.0: Initial implementation (2026-01-10)
  - LoadPlanetConfig з кешуванням
  - GetCurrentPlanetConfig helper
  - ClearCache для hot-reload
  - Детальне логування та error handling

================================================================================
]]

--============================================================================--
-- SERVICES
--============================================================================--
local ServerStorage = game:GetService("ServerStorage")

--============================================================================--
-- MODULES
--============================================================================--
local module = {}
module.Version = "1.0"

--============================================================================--
-- ГЛОБАЛЬНІ ЗМІННІ / GLOBAL VARIABLES
--============================================================================--

-- @var table Кеш завантажених конфігів планет {[planetId]: PlanetConfig}
local loadedConfigs = {}

--============================================================================--
-- ПУБЛІЧНІ ФУНКЦІЇ / PUBLIC API
--============================================================================--

--[[
@function LoadPlanetConfig
Завантажує конфігурацію планети з ServerStorage

@param planetId string - ID планети (наприклад "Planet_1")
@return table - PlanetConfig module
@throws error якщо планета або конфіг не знайдені

@example
    local config = PlanetConfigLoader.LoadPlanetConfig("Planet_1")
    print("Planet name:", config.DISPLAY_NAME)
]]
function module.LoadPlanetConfig(planetId: string)
	-- Перевірка кешу
	if loadedConfigs[planetId] then
		return loadedConfigs[planetId]
	end

	-- Пошук папки Planets в ServerStorage
	local planetsFolder = ServerStorage:FindFirstChild("Planets")
	if not planetsFolder then
		error("[PlanetConfigLoader] ❌ ServerStorage.Planets folder not found")
	end

	-- Пошук папки планети
	local planetFolder = planetsFolder:FindFirstChild(planetId)
	if not planetFolder then
		error(string.format("[PlanetConfigLoader] ❌ Planet '%s' not found in ServerStorage.Planets", planetId))
	end

	-- Пошук папки Configuration
	local configFolder = planetFolder:FindFirstChild("Configuration")
	if not configFolder then
		error(string.format("[PlanetConfigLoader] ❌ Configuration folder not found for planet '%s'", planetId))
	end

	-- Пошук модуля PlanetConfig
	local configModule = configFolder:FindFirstChild("PlanetConfig")
	if not configModule then
		error(string.format("[PlanetConfigLoader] ❌ PlanetConfig module not found for planet '%s'", planetId))
	end

	-- Завантаження конфігу з обробкою помилок
	local success, config = pcall(require, configModule)
	if not success then
		error(string.format("[PlanetConfigLoader] ❌ Failed to load PlanetConfig for '%s': %s",
			planetId, tostring(config)))
	end

	-- Кешування конфігу
	loadedConfigs[planetId] = config

	-- Логування успішного завантаження
	print(string.format("[PlanetConfigLoader] ✅ Loaded PlanetConfig for '%s' (%s)",
		planetId, config.DISPLAY_NAME or config.PLANET_NAME or "Unknown"))

	return config
end

--[[
@function GetCurrentPlanetConfig
Повертає конфігурацію поточної планети з GameConfig.DEFAULT_PLANET

@return table - PlanetConfig для поточної планети
@throws error якщо DEFAULT_PLANET не налаштований або конфіг не знайдений

@example
    local currentConfig = PlanetConfigLoader.GetCurrentPlanetConfig()
    for locationId, location in pairs(currentConfig.LOCATIONS) do
        print("Location:", location.DisplayName)
    end
]]
function module.GetCurrentPlanetConfig()
	local GameConfig = require(script.Parent:FindFirstChild("GameConfig"))

	if not GameConfig.DEFAULT_PLANET then
		error("[PlanetConfigLoader] ❌ GameConfig.DEFAULT_PLANET is not set")
	end

	return module.LoadPlanetConfig(GameConfig.DEFAULT_PLANET)
end

--[[
@function ClearCache
Очищує кеш завантажених конфігів (для hot-reload під час розробки)

@param planetId string? - Опціонально, ID конкретної планети для очищення.
                          Якщо nil - очищає весь кеш.

@example
    -- Очистити конфіг конкретної планети
    PlanetConfigLoader.ClearCache("Planet_1")

    -- Очистити весь кеш
    PlanetConfigLoader.ClearCache()
]]
function module.ClearCache(planetId: string?)
	if planetId then
		loadedConfigs[planetId] = nil
		print(string.format("[PlanetConfigLoader] 🔄 Cache cleared for '%s'", planetId))
	else
		loadedConfigs = {}
		print("[PlanetConfigLoader] 🔄 All cache cleared")
	end
end

return module
