--[[
================================================================================
KOSMICMAZER — DataStore Manager
================================================================================

Purpose: Simple and reliable data storage using DataStoreService
Version: 2.0

Features:
- Automatic data loading and saving
- Error handling and retry logic
- Player data management
- Settings management
- Session tracking
- JSON serialization for data integrity
- Schema versioning and automatic data migration

API:
- LoadPlayerData(player): Loads player data from DataStore
- SavePlayerData(player, data): Saves player data to DataStore
- GetPlayerData(player): Gets current player data from memory
- UpdatePlayerData(player, updates): Updates specific fields in player data
- AutoSavePlayer(player): Forces immediate save of player data
- Initialize(): Initializes the DataStore Manager

Calls to:
- DataStoreService: GetDataStore(), GetAsync(), SetAsync()
- HttpService: JSONEncode(), JSONDecode()
- GameConfig: Reads default values

Called from:
- GameInit
- ScannerService
- TeleportationSystem
- PlayerDataManager

Events:
- Players.PlayerRemoving: Triggers data save on player leave
- game.BindToClose: Triggers shutdown save

Dependencies:
- DataStoreService (Roblox service)
- HttpService (for JSON serialization)
- GameConfig (for default values)

ChangeLog:
- Version 2.0: Added schema versioning and automatic migration system
- Version 1.2: Updated header format to comply with CODE CONVENTION section 14
- Version 1.1: Fixed Studio compatibility and JSON serialization
- Initial implementation for reliable data storage

================================================================================
]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

-- Load GameConfig for default values
local GameConfig = require(script.Parent:FindFirstChild("GameConfig"))

local DataStoreManager = {}

-- DataStore for player data
local playerDataStore = DataStoreService:GetDataStore("PlayerData")

-- In-memory cache for player data
local playerDataCache = {}

-- Auto-save configuration
local AUTO_SAVE_INTERVAL = 60 -- seconds
local MAX_RETRIES = 3
local RETRY_DELAY = 1 -- seconds

-- Default player data structure
local function getDefaultPlayerData(player)
    return {
        SchemaVersion = GameConfig.DATA_SCHEMA_VERSION,
        PlayerId = player.UserId,
        PlayerName = player.Name,
        CurrentPlanet = GameConfig.DEFAULT_PLANET,
        UnlockedPlanets = {GameConfig.DEFAULT_PLANET},
        VisitedLocations = {},
        DiscoveredLocations = {},
        Settings = {
            GraphicsQuality = "Medium",
            SoundVolume = 0.5,
            MusicVolume = 0.3,
            CameraShake = true,
            AutoTeleport = false
        },
        Stats = {
            JoinDate = os.time(),
            PlayTime = 0,
            LastLogin = os.time(),
            TotalPlayTime = 0,
            TeleportsUsed = 0,
            LocationsDiscovered = 0
        },
        Session = {
            LoginTime = os.time(),
            SessionPlayTime = 0
        }
    }
end

-- Add discovered locations from default planet
local function addDefaultDiscoveries(playerData)
    local defaultPlanet = GameConfig.Planets[GameConfig.DEFAULT_PLANET]
    if defaultPlanet then
        for locationId, location in pairs(defaultPlanet.Locations) do
            if location.isDiscovered then
                playerData.DiscoveredLocations[locationId] = true
            end
        end
    end
end

-- Safe DataStore call with retry logic and JSON serialization
local function safeDataStoreCall(dataStore, method, key, value)
    local retries = 0
    
    while retries < MAX_RETRIES do
        local success, result
        
        if value then
            -- For SetAsync calls - serialize to JSON
            local serializedValue
            success, serializedValue = pcall(function()
                return game:GetService("HttpService"):JSONEncode(value)
            end)
            
            if not success then
                warn("[DataStore] ❌ Не вдалося серіалізувати дані:", tostring(serializedValue))
                return false, nil
            end
            
            success, result = pcall(function()
                return dataStore[method](dataStore, key, serializedValue)
            end)
        else
            -- For GetAsync calls - deserialize from JSON
            success, result = pcall(function()
                return dataStore[method](dataStore, key)
            end)
            
            if success and result then
                -- Check if result is already a table (Studio mock data) or a string (JSON)
                if type(result) == "table" then
                    -- Already a table, no need to deserialize
                elseif type(result) == "string" then
                    -- Need to deserialize from JSON
                    local deserialized
                    local decodeSuccess, deserialized = pcall(function()
                        return game:GetService("HttpService"):JSONDecode(result)
                    end)
                    
                    if decodeSuccess then
                        result = deserialized
                    else
                        warn("[DataStore] ❌ Не вдалося десеріалізувати дані:", tostring(deserialized))
                        return false, nil
                    end
                else
                    warn("[DataStore] ❌ Неочікуваний тип даних:", type(result))
                    return false, nil
                end
            end
        end
        
        if success then
            return true, result
        else
            retries = retries + 1
            
            -- Check if it's a Studio access error
            if string.find(tostring(result), "StudioAccessToApisNotAllowed") or string.find(tostring(result), "Studio access to APIs is not allowed") then
                warn("[DataStore] ⚠️ Studio доступ заборонено - використовуються мок-дані")
                if method == "GetAsync" then
                    return true, nil -- No existing data in Studio
                else
                    return true, true -- Pretend save succeeded in Studio
                end
            end
            
            warn(string.format("[DataStore] ⚠️ %s не вдалося (спроба %d/%d)", method, retries, MAX_RETRIES))
            
            if retries < MAX_RETRIES then
                task.wait(RETRY_DELAY * retries)
            end
        end
    end
    
    return false, nil
end
-- Migrate player data from old schema to new schema
local function migratePlayerData(playerData, player)
	local currentSchema = GameConfig.DATA_SCHEMA_VERSION
	local dataSchema = playerData.SchemaVersion or 1
	
	if dataSchema == currentSchema then
		return playerData -- No migration needed
	end
	
	print(string.format("[DataStore] 🔄 Міграція даних з версії %d до %d", dataSchema, currentSchema))
	
	-- Migration from v1 to v2
	if dataSchema < 2 then
		-- Consolidate stats into single Stats table
		local newStats = {
			JoinDate = playerData.Stats and playerData.Stats.JoinDate or os.time(),
			LastLogin = os.time(),
			TotalPlayTime = playerData.Stats and playerData.Stats.TotalPlayTime or 0,
			TotalTeleports = playerData.Stats and playerData.Stats.TeleportsUsed or 0,
			LocationsDiscovered = playerData.Stats and playerData.Stats.LocationsDiscovered or 0,
		}
		
		-- Add Settings table if missing
		if not playerData.Settings or type(playerData.Settings) ~= "table" then
			playerData.Settings = {
				MusicVolume = 1.0,
				SFXVolume = 1.0,
			}
		end
		
		-- Update structure
		playerData.Stats = newStats
		playerData.SchemaVersion = 2
		
		print("[DataStore] ✅ Міграція v1→v2 завершена")
	end
	
	-- Future migrations can be added here
	-- if dataSchema < 3 then
	--     -- Migration v2 to v3
	-- end
	
	playerData.SchemaVersion = currentSchema
	return playerData
end
-- Load player data from DataStore
function DataStoreManager.LoadPlayerData(player)
    local userId = tostring(player.UserId)
    
    print("[DataStore] 💾 Завантаження даних гравця:", player.Name, "(ID:", userId, ")")
    
    local success, data = safeDataStoreCall(playerDataStore, "GetAsync", userId)
    
    if success and data then
        print("[DataStore] ✅ Знайдено існуючі дані для:", player.Name)
        local joinDate = data.Stats and data.Stats.JoinDate
        if joinDate and type(joinDate) == "number" and joinDate > 0 then
            print("[DataStore] ℹ️ Дата приєднання:", os.date("%Y-%m-%d %H:%M:%S", joinDate))
        end
        
        -- Migrate data if needed
        local playerData = migratePlayerData(data, player)
        
        -- Ensure required fields exist (backwards compatibility)
        if not playerData.PlayerId then
            playerData.PlayerId = player.UserId
        end
        
        if not playerData.PlayerName then
            playerData.PlayerName = player.Name
        end
        
        if not playerData.CurrentPlanet then
            playerData.CurrentPlanet = GameConfig.DEFAULT_PLANET
        end
        
        if not playerData.UnlockedPlanets or type(playerData.UnlockedPlanets) ~= "table" then
            playerData.UnlockedPlanets = {GameConfig.DEFAULT_PLANET}
        end
        
        if not playerData.VisitedLocations or type(playerData.VisitedLocations) ~= "table" then
            playerData.VisitedLocations = {}
        end
        
        if not playerData.DiscoveredLocations or type(playerData.DiscoveredLocations) ~= "table" then
            playerData.DiscoveredLocations = {}
        end
        
        if not playerData.Settings or type(playerData.Settings) ~= "table" then
            playerData.Settings = {
                GraphicsQuality = "Medium",
                SoundVolume = 0.5,
                MusicVolume = 0.3,
                CameraShake = true,
                AutoTeleport = false
            }
        end
        
        if not playerData.Session or type(playerData.Session) ~= "table" then
            playerData.Session = {
                LoginTime = os.time(),
                SessionPlayTime = 0
            }
        end
        
        if not playerData.Stats or type(playerData.Stats) ~= "table" then
            playerData.Stats = {
                JoinDate = os.time(),
                PlayTime = 0,
                LastLogin = os.time(),
                TotalPlayTime = 0,
                TeleportsUsed = 0,
                LocationsDiscovered = 0
            }
        end
        
        -- Update session info for existing player
        playerData.Session.LoginTime = os.time()
        playerData.Session.SessionPlayTime = 0
        playerData.Stats.LastLogin = os.time()
        
        -- Cache the data
        playerDataCache[userId] = playerData
        return playerData
    else
        print("[DataStore] 📝 Створення нового профілю для:", player.Name)
        
        local playerData = getDefaultPlayerData(player)
        addDefaultDiscoveries(playerData)
        
        playerData.Stats.JoinDate = os.time()
        playerData.Stats.LastLogin = os.time()
        playerData.Session.LoginTime = os.time()
        
        print("[DataStore] ✅ Профіль створено для:", player.Name)
        
        playerDataCache[userId] = playerData
        DataStoreManager.SavePlayerData(player, playerData)
        
        return playerData
    end
end

-- Clean data for JSON serialization
local function cleanDataForSerialization(data)
    if type(data) ~= "table" then
        return data
    end
    
    local cleaned = {}
    for key, value in pairs(data) do
        -- Skip functions and userdata
        if type(value) ~= "function" and type(value) ~= "userdata" then
            if type(value) == "table" then
                cleaned[key] = cleanDataForSerialization(value)
            else
                cleaned[key] = value
            end
        end
    end
    
    return cleaned
end

-- Save player data to DataStore
function DataStoreManager.SavePlayerData(player, data)
    local userId = tostring(player.UserId)
    
    if not data then
        data = playerDataCache[userId]
    end
    
    if not data then
        warn("[DataStore] ⚠️ Немає даних для збереження:", player.Name)
        return false
    end
    
    -- Update session play time before saving
    if data.Session then
        data.Session.SessionPlayTime = os.time() - data.Session.LoginTime
        data.Stats.PlayTime = data.Session.SessionPlayTime
        data.Stats.TotalPlayTime = (data.Stats.TotalPlayTime or 0) + data.Session.SessionPlayTime
    end
    
    -- Clean data for serialization
    local cleanData = cleanDataForSerialization(data)
    
    local success = safeDataStoreCall(playerDataStore, "SetAsync", userId, cleanData)
    
    if success then
        print("[DataStore] ✅ Дані збережено для:", player.Name)
        return true
    else
        warn("[DataStore] ❌ Не вдалося зберегти дані для:", player.Name)
        return false
    end
end

-- Get player data from cache
function DataStoreManager.GetPlayerData(player)
    local userId = tostring(player.UserId)
    return playerDataCache[userId]
end

-- Update specific fields in player data
function DataStoreManager.UpdatePlayerData(player, updates)
    local userId = tostring(player.UserId)
    local playerData = playerDataCache[userId]
    
    if not playerData then
        warn("[DataStore] ⚠️ Дані не знайдено для:", player.Name)
        return false
    end
    
    -- Apply updates
    for key, value in pairs(updates) do
        if type(value) == "table" and type(playerData[key]) == "table" then
            -- Merge tables
            for subKey, subValue in pairs(value) do
                playerData[key][subKey] = subValue
            end
        else
            playerData[key] = value
        end
    end
    
    -- Update cache
    playerDataCache[userId] = playerData
    
    return true
end

-- Force immediate save of player data
function DataStoreManager.AutoSavePlayer(player)
    return DataStoreManager.SavePlayerData(player)
end

-- Auto-save loop
local function startAutoSave()
    while true do
        task.wait(AUTO_SAVE_INTERVAL)
        
        -- Save data for all online players
        for _, player in ipairs(Players:GetPlayers()) do
            local playerData = DataStoreManager.GetPlayerData(player)
            if playerData then
                DataStoreManager.SavePlayerData(player, playerData)
            end
        end
        
        print("[DataStore] 💾 Автозбереження для", #Players:GetPlayers(), "гравців")
    end
end

-- Handle player leaving
local function onPlayerRemoving(player)
    local userId = tostring(player.UserId)
    
    -- Check if we already processed this player
    if not playerDataCache[userId] then
        return
    end
    
    print("[DataStore] 👤 Гравець виходить:", player.Name)
    
    local success = DataStoreManager.SavePlayerData(player)
    playerDataCache[userId] = nil
    
    if success then
        print("[DataStore] ✅ Дані збережено при виході:", player.Name)
    else
        warn("[DataStore] ❌ Не вдалося зберегти при виході:", player.Name)
    end
end

-- Initialize the DataStore Manager
function DataStoreManager.Initialize()
    print("[DataStore] 🚀 Ініціалізація менеджера даних...")
    
    Players.PlayerRemoving:Connect(onPlayerRemoving)
    task.spawn(startAutoSave)
    
    print("[DataStore] ✅ Менеджер даних ініціалізовано")
end

-- Game shutdown handling
local function onShutdown()
    print("[DataStore] 🔄 Завершення роботи, збереження всіх даних...")
    
    local playersToSave = {}
    for _, player in ipairs(Players:GetPlayers()) do
        local userId = tostring(player.UserId)
        if playerDataCache[userId] then
            table.insert(playersToSave, player)
        end
    end
    
    for _, player in ipairs(playersToSave) do
        local userId = tostring(player.UserId)
        if playerDataCache[userId] then
            DataStoreManager.SavePlayerData(player)
            playerDataCache[userId] = nil
        end
    end
    
    print("[DataStore] ✅ Всі дані збережено")
end

-- Connect shutdown event
game:BindToClose(onShutdown)

return DataStoreManager