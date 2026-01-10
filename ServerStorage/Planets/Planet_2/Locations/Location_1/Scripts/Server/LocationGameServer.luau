--[[
================================================================================
KOSMICMAZER — Location_1 Game Server
================================================================================

Purpose: Серверна логіка гри для Location_1 (Садочок) на Planet_1
Version: 1.0

Features:
- Правила гри специфічні для цієї локації
- Управління ресурсами локації
- Обробка подій гравців
- Міні-ігри локації
- Квести локації
- NPC логіка

API:
- Initialize(locationModel): Ініціалізує систему гри для локації
- Cleanup(): Очищає всі події та об'єкти
- OnPlayerEnter(player): Викликається коли гравець входить в локацію
- OnPlayerLeave(player): Викликається коли гравець покидає локацію
- GetLocationRules(): Повертає правила гри локації

Calls to:
- PlanetConfig: Отримання планетарних правил
- GameConfig: Загальні налаштування гри
- PlayerDataManager: Дані та прогресія гравця
- ResourceController: Управління ресурсами

Called from:
- LocationManager: При завантаженні локації
- EnvironmentLoader: При ініціалізації середовища

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
local CollectionService = game:GetService("CollectionService")

--============================================================================--
-- DEPENDENCIES
--============================================================================--
local GameConfig = require(game.ServerScriptService:WaitForChild("GameConfig"))

-- Load PlanetConfig from ServerStorage
local PlanetConfig
pcall(function()
	local planet1Folder = ServerStorage:WaitForChild("Planets"):WaitForChild("Planet_1")
	local configFolder = planet1Folder:WaitForChild("Configuration")
	PlanetConfig = require(configFolder:WaitForChild("PlanetConfig"))
end)

--============================================================================--
-- КОНСТАНТИ ЛОКАЦІЇ / LOCATION CONSTANTS
--============================================================================--

LocationGameServer.LOCATION_ID = "Location_1"
LocationGameServer.LOCATION_NAME = "Садочок"
LocationGameServer.PLANET_ID = "Planet_1"

--============================================================================--
-- СТАН ЛОКАЦІЇ / LOCATION STATE
--============================================================================--

-- Модель локації
local locationModel = nil

-- Активні гравці в локації
local activePlayers = {}

-- Ресурси локації
local resources = {}

-- Підключення подій
local connections = {}

-- Чи ініціалізована локація
local isInitialized = false

--============================================================================--
-- ПРАВИЛА ГРИ ЛОКАЦІЇ / LOCATION GAME RULES
--============================================================================--

LocationGameServer.LOCATION_RULES = {
	-- Назва та опис
	DisplayName = "Садочок",
	Description = "Стартова локація для знайомства з грою",

	-- Особливості локації
	Features = {
		HasResources = true,
		HasNPCs = true,
		HasQuests = true,
		HasMinigames = false,
		HasShop = true
	},

	-- Ліміти
	MaxPlayers = 10,
	ResourceDensity = 1.2, -- Більше ресурсів ніж на інших локаціях

	-- Безпека
	IsSafeZone = true, -- Не можна атакувати гравців

	-- Складність
	DifficultyLevel = 1, -- Легка локація
	RecommendedLevel = 1
}

--============================================================================--
-- ЛОКАЛЬНІ ФУНКЦІЇ / LOCAL FUNCTIONS
--============================================================================--

--[[
Завантажує ресурси локації
]]
local function loadResources()
	print("[LocationGameServer] 📦 Завантаження ресурсів для", LocationGameServer.LOCATION_NAME)

	if not locationModel then
		warn("[LocationGameServer] ⚠️ Location model not set")
		return
	end

	-- Знайти всі об'єкти з тегом "Resource"
	local resourceObjects = CollectionService:GetTagged("Location_1_Resource")

	for _, resourceObj in ipairs(resourceObjects) do
		table.insert(resources, {
			Object = resourceObj,
			Type = resourceObj:GetAttribute("ResourceType") or "Ore",
			Respawning = false,
			LastHarvested = 0
		})
	end

	print("[LocationGameServer] ✅ Завантажено ресурсів:", #resources)
end

--[[
Ініціалізує NPC в локації
]]
local function initializeNPCs()
	print("[LocationGameServer] 👥 Ініціалізація NPC для", LocationGameServer.LOCATION_NAME)

	if not locationModel then
		warn("[LocationGameServer] ⚠️ Location model not set")
		return
	end

	-- Знайти всіх NPC в локації
	local npcsFolder = locationModel:FindFirstChild("NPCs")
	if npcsFolder then
		for _, npc in ipairs(npcsFolder:GetChildren()) do
			if npc:IsA("Model") then
				-- TODO: Ініціалізувати NPC логіку
				print("[LocationGameServer] 👤 NPC знайдено:", npc.Name)
			end
		end
	end
end

--[[
Ініціалізує квести локації
]]
local function initializeQuests()
	print("[LocationGameServer] 📜 Ініціалізація квестів для", LocationGameServer.LOCATION_NAME)

	-- TODO: Завантажити квести з конфігу
	-- TODO: Зареєструвати квести в QuestManager
end

--[[
Обробляє збір ресурсу гравцем
]]
local function onResourceHarvested(player, resource)
	print("[LocationGameServer] ⛏️ Гравець", player.Name, "зібрав ресурс:", resource.Type)

	-- TODO: Додати ресурс в інвентар гравця
	-- TODO: Запустити респавн ресурсу
end

--============================================================================--
-- ПУБЛІЧНІ ФУНКЦІЇ / PUBLIC API
--============================================================================--

--[[
@function Initialize
Ініціалізує систему гри для локації

@param model Model - Модель локації в Workspace
@return boolean - Успішність ініціалізації
]]
function LocationGameServer.Initialize(model)
	if isInitialized then
		warn("[LocationGameServer] ⚠️ Already initialized for", LocationGameServer.LOCATION_NAME)
		return false
	end

	print("[LocationGameServer] 🎮 Ініціалізація гри для локації:", LocationGameServer.LOCATION_NAME)

	locationModel = model

	-- Завантажити компоненти локації
	loadResources()
	initializeNPCs()
	initializeQuests()

	-- Застосувати планетарні правила
	if PlanetConfig then
		PlanetConfig.ApplyPlanetPhysics()
		print("[LocationGameServer] ✅ Застосовано фізику планети")
	end

	isInitialized = true
	print("[LocationGameServer] ✅ Локація", LocationGameServer.LOCATION_NAME, "ініціалізована")

	return true
end

--[[
@function Cleanup
Очищає всі події та об'єкти

@return nil
]]
function LocationGameServer.Cleanup()
	print("[LocationGameServer] 🧹 Очищення локації:", LocationGameServer.LOCATION_NAME)

	-- Відключити всі події
	for _, connection in ipairs(connections) do
		connection:Disconnect()
	end
	connections = {}

	-- Очистити активних гравців
	activePlayers = {}

	-- Очистити ресурси
	resources = {}

	locationModel = nil
	isInitialized = false

	print("[LocationGameServer] ✅ Локацію очищено")
end

--[[
@function OnPlayerEnter
Викликається коли гравець входить в локацію

@param player Player - Гравець що входить
@return nil
]]
function LocationGameServer.OnPlayerEnter(player)
	print("[LocationGameServer] 👋 Гравець", player.Name, "увійшов в", LocationGameServer.LOCATION_NAME)

	activePlayers[player.UserId] = {
		Player = player,
		EnterTime = tick(),
		ResourcesCollected = 0
	}

	-- TODO: Показати повідомлення про локацію
	-- TODO: Активувати квести
	-- TODO: Завантажити стан локації для гравця
end

--[[
@function OnPlayerLeave
Викликається коли гравець покидає локацію

@param player Player - Гравець що виходить
@return nil
]]
function LocationGameServer.OnPlayerLeave(player)
	print("[LocationGameServer] 👋 Гравець", player.Name, "покинув", LocationGameServer.LOCATION_NAME)

	local playerData = activePlayers[player.UserId]
	if playerData then
		-- TODO: Зберегти прогрес гравця
		-- TODO: Оновити статистику

		local timeSpent = tick() - playerData.EnterTime
		print("[LocationGameServer] ⏱️ Час в локації:", math.floor(timeSpent), "секунд")
		print("[LocationGameServer] 📊 Зібрано ресурсів:", playerData.ResourcesCollected)
	end

	activePlayers[player.UserId] = nil
end

--[[
@function GetLocationRules
Повертає правила гри локації

@return table - Таблиця з правилами
]]
function LocationGameServer.GetLocationRules()
	return LocationGameServer.LOCATION_RULES
end

--[[
@function GetActivePlayersCount
Повертає кількість активних гравців в локації

@return number - Кількість гравців
]]
function LocationGameServer.GetActivePlayersCount()
	local count = 0
	for _ in pairs(activePlayers) do
		count = count + 1
	end
	return count
end

--[[
@function IsInitialized
Перевіряє чи ініціалізована локація

@return boolean - Статус ініціалізації
]]
function LocationGameServer.IsInitialized()
	return isInitialized
end

return LocationGameServer

