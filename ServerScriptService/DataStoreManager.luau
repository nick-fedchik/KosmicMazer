--[[
================================================================================
KOSMICMAZER — DataStore Manager
================================================================================

Purpose: Simple and reliable data storage using DataStoreService
Version: 1.1 (Fixed)

Features:
- Automatic data loading and saving
- Error handling and retry logic
- Player data management
- Settings management
- Session tracking
- JSON serialization for data integrity

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
                warn(string.format("[DataStoreManager] Failed to serialize data for %s: %s", method, tostring(serializedValue)))
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
                    print("[DataStoreManager] Data is already a table, skipping JSON decode")
                elseif type(result) == "string" then
                    -- Need to deserialize from JSON
                    local deserialized
                    local decodeSuccess, deserialized = pcall(function()
                        return game:GetService("HttpService"):JSONDecode(result)
                    end)
                    
                    if decodeSuccess then
                        result = deserialized
                    else
                        warn(string.format("[DataStoreManager] Failed to deserialize data for %s: %s", method, tostring(deserialized)))
                        return false, nil
                    end
                else
                    warn(string.format("[DataStoreManager] Unexpected data type for %s: %s", method, type(result)))
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
                warn(string.format("[DataStoreManager] Studio access denied for %s - using mock data", method))
                -- Return mock success for Studio
                if method == "GetAsync" then
                    return true, nil -- No existing data in Studio
                else
                    return true, true -- Pretend save succeeded in Studio
                end
            end
            
            warn(string.format("[DataStoreManager] %s failed (attempt %d/%d): %s", 
                method, retries, MAX_RETRIES, tostring(result)))
            
            if retries < MAX_RETRIES then
                task.wait(RETRY_DELAY * retries)
            end
        end
    end
    
    return false, nil
end

-- Load player data from DataStore
function DataStoreManager.LoadPlayerData(player)
    local userId = tostring(player.UserId)
    
    print(string.format("[DataStoreManager] Loading data for player: %s (ID: %s)", player.Name, userId))
    
    -- Load main player data
    local success, data = safeDataStoreCall(playerDataStore, "GetAsync", userId)
    
    if success and data then
        print("[DataStoreManager] Found existing data for player:", player.Name)
        local joinDate = data.Stats and data.Stats.JoinDate
        if joinDate and type(joinDate) == "number" and joinDate > 0 then
            print("[DataStoreManager] Player joined on:", os.date("%Y-%m-%d %H:%M:%S", joinDate))
        else
            print("[DataStoreManager] Player joined on: Unknown")
        end
        
        -- Validate and migrate data if needed
        local playerData = data
        
        -- Ensure required fields exist
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
        print("[DataStoreManager] No existing data found, creating NEW profile for:", player.Name)
        
        -- Create new player data
        local playerData = getDefaultPlayerData(player)
        addDefaultDiscoveries(playerData)
        
        -- Mark as new player
        playerData.Stats.JoinDate = os.time()
        playerData.Stats.LastLogin = os.time()
        playerData.Session.LoginTime = os.time()
        
        if playerData.Stats.JoinDate and type(playerData.Stats.JoinDate) == "number" and playerData.Stats.JoinDate > 0 then
            print(string.format("[DataStoreManager] Created new profile for %s on %s", 
                player.Name, os.date("%Y-%m-%d %H:%M:%S", playerData.Stats.JoinDate)))
        else
            print(string.format("[DataStoreManager] Created new profile for %s on Unknown", player.Name))
        end
        
        -- Cache the data
        playerDataCache[userId] = playerData
        
        -- Save the new data immediately
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
        warn(string.format("[DataStoreManager] No data to save for player: %s", player.Name))
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
    
    print(string.format("[DataStoreManager] Saving data for player: %s", player.Name))
    
    local success = safeDataStoreCall(playerDataStore, "SetAsync", userId, cleanData)
    
    if success then
        print(string.format("[DataStoreManager] Successfully saved data for: %s", player.Name))
        return true
    else
        warn(string.format("[DataStoreManager] Failed to save data for: %s", player.Name))
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
        warn(string.format("[DataStoreManager] No data found for player: %s", player.Name))
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
        
        print(string.format("[DataStoreManager] Auto-saved data for %d players", #Players:GetPlayers()))
    end
end

-- Handle player leaving
local function onPlayerRemoving(player)
    local userId = tostring(player.UserId)
    
    -- Check if we already processed this player
    if not playerDataCache[userId] then
        return -- Already processed
    end
    
    print(string.format("[DataStoreManager] Player leaving: %s", player.Name))
    
    local success = DataStoreManager.SavePlayerData(player)
    
    -- Clean up cache IMMEDIATELY to prevent double processing
    playerDataCache[userId] = nil
    
    if success then
        print(string.format("[DataStoreManager] Successfully saved data for leaving player: %s", player.Name))
    else
        warn(string.format("[DataStoreManager] Failed to save data for leaving player: %s", player.Name))
    end
end

-- Initialize the DataStore Manager
function DataStoreManager.Initialize()
    print("[DataStoreManager] Initializing DataStore Manager...")
    
    -- Connect player events
    Players.PlayerRemoving:Connect(onPlayerRemoving)
    
    -- Start auto-save loop
    task.spawn(startAutoSave)
    
    print("[DataStoreManager] DataStore Manager initialized successfully")
end

-- Game shutdown handling
local function onShutdown()
    print("[DataStoreManager] Game shutting down, saving all player data...")
    
    -- Create a list of players to process
    local playersToSave = {}
    for _, player in ipairs(Players:GetPlayers()) do
        local userId = tostring(player.UserId)
        if playerDataCache[userId] then
            table.insert(playersToSave, player)
        end
    end
    
    -- Save each player only once
    for _, player in ipairs(playersToSave) do
        local userId = tostring(player.UserId)
        if playerDataCache[userId] then
            local success = DataStoreManager.SavePlayerData(player)
            playerDataCache[userId] = nil -- Clean up immediately
            
            if success then
                print(string.format("[DataStoreManager] Saved shutdown data for: %s", player.Name))
            else
                warn(string.format("[DataStoreManager] Failed to save shutdown data for: %s", player.Name))
            end
        end
    end
    
    print("[DataStoreManager] All player data saved")
end

-- Connect shutdown event
game:BindToClose(onShutdown)

return DataStoreManager