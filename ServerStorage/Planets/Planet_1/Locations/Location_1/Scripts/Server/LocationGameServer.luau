--[[
================================================================================
KOSMICMAZER — Location_1 Game Server
================================================================================

Purpose: Серверна логіка гри для Location_1 (Садочок) на Planet_1
Version: 2.0

Features:
- Правила гри специфічні для цієї локації
- Управління ресурсами локації
- Обробка подій гравців
- Міні-ігри локації
- Квести локації
- NPC логіка
- НОВИЙ: Підтримка LocationModel архітектури

Changelog:
v2.0 - LocationModel Architecture Support
- ✅ Оновлено Initialize() для роботи з LocationModel структурою  
- ✅ Додана ініціалізація Architecture/Equipment/Environment/Gameplay секцій
- ✅ Оновлено loadResources() для пошуку в нових секціях
- ✅ Оновлено initializeNPCs() для пошуку в Gameplay/NPCs
- ✅ Поліпшена діагностика структури LocationModel
- ✅ Оновлено Cleanup() для очищення нових змінних

v1.0 - Initial Implementation
- Базова функціональність локації

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
LocationGameServer.Version = "2.0"

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

-- LocationModel з новою архітектурою
local locationModel = nil
local architectureFolder = nil
local equipmentFolder = nil
local environmentFolder = nil
local gameplayFolder = nil

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
	print("[LocationGameServer 2.0] 📦 Завантаження ресурсів для", LocationGameServer.LOCATION_NAME)
	
	if not locationModel then
		warn("[LocationGameServer 2.0] ⚠️ LocationModel not set")
		return
	end
	
	-- Шукаємо ресурси в Architecture та Equipment секціях
	local resourceObjects = {}
	if architectureFolder then
		for _, obj in ipairs(architectureFolder:GetDescendants()) do
			if obj:GetAttribute("ResourceType") then
				table.insert(resourceObjects, obj)
			end
		end
	end
	
	for _, resourceObj in ipairs(resourceObjects) do
		table.insert(resources, {
			Object = resourceObj,
			Type = resourceObj:GetAttribute("ResourceType") or "Ore",
			Respawning = false,
			LastHarvested = 0
		})
	end
	
	print("[LocationGameServer 2.0] ✅ Завантажено ресурсів:", #resources)
end

--[[
Ініціалізує NPC в локації
]]
local function initializeNPCs()
	print("[LocationGameServer 2.0] 👥 Ініціалізація NPC для", LocationGameServer.LOCATION_NAME)
	
	if not locationModel then
		warn("[LocationGameServer 2.0] ⚠️ LocationModel not set")
		return
	end
	
	-- Шукаємо NPC в Gameplay секції
	if gameplayFolder then
		local npcsFolder = gameplayFolder:FindFirstChild("NPCs")
		if npcsFolder then
			for _, npc in ipairs(npcsFolder:GetChildren()) do
				if npc:IsA("Model") then
					-- TODO: Ініціалізувати NPC логіку
					print("[LocationGameServer 2.0] 👤 NPC знайдено:", npc.Name)
				end
			end
		else
			print("[LocationGameServer 2.0] ℹ️ Немає NPC в цій локації")
		end
	end
end

--[[
Ініціалізує квести локації
]]
local function initializeQuests()
	print("[LocationGameServer 2.0] 📜 Ініціалізація квестів для", LocationGameServer.LOCATION_NAME)
	
	-- TODO: Завантажити квести з конфігу
	-- TODO: Зареєструвати квести в QuestManager
end

--[[
Обробляє збір ресурсу гравцем
]]
local function onResourceHarvested(player, resource)
	print("[LocationGameServer 2.0] ⛏️ Гравець", player.Name, "зібрав ресурс:", resource.Type)
	
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
		warn("[LocationGameServer 2.0] ⚠️ Already initialized for", LocationGameServer.LOCATION_NAME)
		return false
	end
	
	print("[LocationGameServer 2.0] 🎮 Ініціалізація гри для локації:", LocationGameServer.LOCATION_NAME)
	
	locationModel = model
	
	-- Ініціалізуємо структуру LocationModel
	if locationModel then
		architectureFolder = locationModel:FindFirstChild("Architecture")
		equipmentFolder = locationModel:FindFirstChild("Equipment")
		environmentFolder = locationModel:FindFirstChild("Environment") 
		gameplayFolder = locationModel:FindFirstChild("Gameplay")
		
		-- Перевіряємо чи є необхідні секції
		if not architectureFolder then
			warn("[LocationGameServer 2.0] ⚠️ Architecture folder missing!")
		end
		if not gameplayFolder then
			warn("[LocationGameServer 2.0] ⚠️ Gameplay folder missing!")
		end
		
		print("[LocationGameServer 2.0] ✅ LocationModel структура ініціалізована")
		print("  Architecture:", architectureFolder and "✅" or "❌")
		print("  Equipment:", equipmentFolder and "✅" or "❌") 
		print("  Environment:", environmentFolder and "✅" or "❌")
		print("  Gameplay:", gameplayFolder and "✅" or "❌")
	end
	
	-- Завантажити компоненти локації
	loadResources()
	initializeNPCs()
	initializeQuests()
	
	-- Застосувати планетарні правила
	if PlanetConfig then
		PlanetConfig.ApplyPlanetPhysics()
		print("[LocationGameServer 2.0] ✅ Застосовано фізику планети")
	end
	
	isInitialized = true
	local scriptName = "LocationGameServer"
	local scriptVersion = LocationGameServer.Version
	print(string.format("[%s %s] ✅ Локація %s ініціалізована", scriptName, scriptVersion, LocationGameServer.LOCATION_NAME))

	return true
end

--[[
@function Cleanup
Очищає всі події та об'єкти

@return nil
]]
function LocationGameServer.Cleanup()
	print("[LocationGameServer 2.0] 🧹 Очищення локації:", LocationGameServer.LOCATION_NAME)
	
	-- Відключити всі події
	for _, connection in ipairs(connections) do
		connection:Disconnect()
	end
	connections = {}
	
	-- Очистити активних гравців
	activePlayers = {}
	
	-- Очистити ресурси
	resources = {}
	
	-- Очистити посилання на LocationModel структуру
	locationModel = nil
	architectureFolder = nil
	equipmentFolder = nil
	environmentFolder = nil
	gameplayFolder = nil
	isInitialized = false
	
	print("[LocationGameServer 2.0] ✅ Локацію очищено")
end

--[[
@function OnPlayerEnter
Викликається коли гравець входить в локацію

@param player Player - Гравець що входить
@return nil
]]
function LocationGameServer.OnPlayerEnter(player)
	print("[LocationGameServer 2.0] 👋 Гравець", player.Name, "увійшов в", LocationGameServer.LOCATION_NAME)
	
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
	print("[LocationGameServer 2.0] 👋 Гравець", player.Name, "покинув", LocationGameServer.LOCATION_NAME)
	
	local playerData = activePlayers[player.UserId]
	if playerData then
		-- TODO: Зберегти прогрес гравця
		-- TODO: Оновити статистику
		
		local timeSpent = tick() - playerData.EnterTime
		print("[LocationGameServer 2.0] ⏱️ Час в локації:", math.floor(timeSpent), "секунд")
		print("[LocationGameServer 2.0] 📊 Зібрано ресурсів:", playerData.ResourcesCollected)
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
