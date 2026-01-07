--[[
================================================================================
KOSMICMAZER — Player Data Manager
================================================================================

Purpose: Utility functions for managing player data throughout the game
Version: 1.0

Features:
- Provides easy-to-use functions for player data access
- Abstracts DataStoreManager complexity
- Player type detection (New vs Existing)
- Planet and location tracking
- Statistics management
- Settings management

API:
- GetPlayerData(player): Get current player data
- UpdatePlayerPlanet(player, planetId): Update player's current planet
- UnlockPlanet(player, planetId): Unlock a planet for player
- VisitLocation(player, locationId): Mark location as visited
- DiscoverLocation(player, locationId): Discover a new location
- UpdatePlayerStats(player, stats): Update player statistics
- GetPlayerSettings(player): Get player settings
- UpdatePlayerSettings(player, settings): Update player settings
- IncrementStat(player, statName, amount): Increment a stat by amount
- GetPlayerInfo(player): Get player type and statistics
- IsNewPlayer(player): Check if player is new
- GetUnlockedPlanets(player): Get all unlocked planets
- GetVisitedLocations(player): Get all visited locations
- GetDiscoveredLocations(player): Get all discovered locations
- HasUnlockedPlanet(player, planetId): Check if planet is unlocked
- HasVisitedLocation(player, locationId): Check if location is visited
- HasDiscoveredLocation(player, locationId): Check if location is discovered

Calls to:
- DataStoreManager: GetPlayerData(), UpdatePlayerData()

Called from:
- GameInit
- ScannerService
- TeleportationSystem
- LocationManager

Events:
- None

Dependencies:
- DataStoreManager module

ChangeLog:
- Initial implementation for player data abstraction
- Added comprehensive player tracking functions

================================================================================
]]

local DataStoreManager = require(script.Parent:FindFirstChild("DataStoreManager"))

local PlayerDataManager = {}

-- Get player data
function PlayerDataManager.GetPlayerData(player)
    return DataStoreManager.GetPlayerData(player)
end
-- Check if player is new (first time joining)
function PlayerDataManager.IsNewPlayer(player)
    local playerData = DataStoreManager.GetPlayerData(player)
    if not playerData then
        return false
    end
    
    -- Check if join date is very recent (within last 5 minutes)
    local joinTime = playerData.Stats.JoinDate or 0
    local currentTime = os.time()
    local timeDiff = currentTime - joinTime
    
    return timeDiff < 300 -- 5 minutes in seconds
end

-- Get player type information
function PlayerDataManager.GetPlayerInfo(player)
    local playerData = DataStoreManager.GetPlayerData(player)
    if not playerData then
        return {
            Type = "Unknown",
            IsNew = false,
            JoinDate = nil,
            LastLogin = nil,
            TotalPlayTime = 0
        }
    end
    
    local isNew = PlayerDataManager.IsNewPlayer(player)
    
    return {
        Type = isNew and "New" or "Existing",
        IsNew = isNew,
        JoinDate = playerData.Stats.JoinDate,
        LastLogin = playerData.Stats.LastLogin,
        TotalPlayTime = playerData.Stats.TotalPlayTime or 0,
        CurrentPlanet = playerData.CurrentPlanet,
        UnlockedPlanets = playerData.UnlockedPlanets,
        LocationsDiscovered = playerData.Stats.LocationsDiscovered or 0
    }
end

-- Update player's current planet
function PlayerDataManager.UpdatePlayerPlanet(player, planetId)
    local success = DataStoreManager.UpdatePlayerData(player, {
        CurrentPlanet = planetId
    })
    
    if success then
        print("[PlayerData] 🪐 Оновлено планету", player.Name, "->", planetId)
    else
        warn("[PlayerData] ❌ Не вдалося оновити планету:", player.Name)
    end
    
    return success
end

-- Unlock a planet for player
function PlayerDataManager.UnlockPlanet(player, planetId)
    local playerData = DataStoreManager.GetPlayerData(player)
    if not playerData then
        return false
    end
    
    -- Check if planet is already unlocked
    for _, unlockedPlanet in ipairs(playerData.UnlockedPlanets) do
        if unlockedPlanet == planetId then
            print("[PlayerData] ℹ️ Планета", planetId, "вже розблокована:", player.Name)
            return true
        end
    end
    
    -- Add planet to unlocked list
    table.insert(playerData.UnlockedPlanets, planetId)
    
    local success = DataStoreManager.UpdatePlayerData(player, {
        UnlockedPlanets = playerData.UnlockedPlanets
    })
    
    if success then
        print("[PlayerData] 🔓 Розблоковано планету", planetId, "для", player.Name)
    else
        warn("[PlayerData] ❌ Не вдалося розблокувати планету", planetId, "для", player.Name)
    end
    
    return success
end

-- Mark location as visited
function PlayerDataManager.VisitLocation(player, locationId)
    local playerData = DataStoreManager.GetPlayerData(player)
    if not playerData then
        return false
    end
    
    -- Add to visited locations if not already visited
    if not playerData.VisitedLocations[locationId] then
        playerData.VisitedLocations[locationId] = true
        
        local success = DataStoreManager.UpdatePlayerData(player, {
            VisitedLocations = playerData.VisitedLocations
        })
        
        if success then
            print("[PlayerData] 📍 Відвідано локацію:", player.Name, "->", locationId)
        else
            warn("[PlayerData] ❌ Не вдалося записати відвідини:", player.Name, "->", locationId)
        end
        
        return success
    else
        print("[PlayerData] ℹ️ Вже відвідано:", player.Name, "->", locationId)
        return true
    end
end

-- Discover a new location
function PlayerDataManager.DiscoverLocation(player, locationId)
    local playerData = DataStoreManager.GetPlayerData(player)
    if not playerData then
        return false
    end
    
    local isNewDiscovery = false
    
    -- Add to discovered locations if not already discovered
    if not playerData.DiscoveredLocations[locationId] then
        playerData.DiscoveredLocations[locationId] = true
        isNewDiscovery = true
        
        -- Increment discovery stat
        local currentCount = playerData.Stats.LocationsDiscovered or 0
        playerData.Stats.LocationsDiscovered = currentCount + 1
    end
    
    local success = DataStoreManager.UpdatePlayerData(player, {
        DiscoveredLocations = playerData.DiscoveredLocations,
        Stats = playerData.Stats
    })
    
    if success then
        if isNewDiscovery then
            print("[PlayerData] 🌟 Відкрито нову локацію:", player.Name, "->", locationId)
        else
            print("[PlayerData] ℹ️ Вже відкрито:", player.Name, "->", locationId)
        end
    else
        warn("[PlayerData] ❌ Не вдалося записати відкриття:", player.Name, "->", locationId)
    end
    
    return success
end

-- Update player statistics
function PlayerDataManager.UpdatePlayerStats(player, stats)
    local playerData = DataStoreManager.GetPlayerData(player)
    if not playerData then
        return false
    end
    
    -- Merge stats
    for statName, value in pairs(stats) do
        playerData.Stats[statName] = value
    end
    
    local success = DataStoreManager.UpdatePlayerData(player, {
        Stats = playerData.Stats
    })
    
    if success then
        print("[PlayerData] 📊 Оновлено статистику:", player.Name)
    else
        warn("[PlayerData] ❌ Не вдалося оновити статистику:", player.Name)
    end
    
    return success
end

-- Get player settings
function PlayerDataManager.GetPlayerSettings(player)
    local playerData = DataStoreManager.GetPlayerData(player)
    return playerData and playerData.Settings or nil
end

-- Update player settings
function PlayerDataManager.UpdatePlayerSettings(player, settings)
    local playerData = DataStoreManager.GetPlayerData(player)
    if not playerData then
        return false
    end
    
    -- Merge settings
    for settingName, value in pairs(settings) do
        playerData.Settings[settingName] = value
    end
    
    local success = DataStoreManager.UpdatePlayerData(player, {
        Settings = playerData.Settings
    })
    
    if success then
        print("[PlayerData] ⚙️ Оновлено налаштування:", player.Name)
    else
        warn("[PlayerData] ❌ Не вдалося оновити налаштування:", player.Name)
    end
    
    return success
end

-- Increment a stat by amount
function PlayerDataManager.IncrementStat(player, statName, amount)
    amount = amount or 1
    
    local playerData = DataStoreManager.GetPlayerData(player)
    if not playerData then
        return false
    end
    
    local currentValue = playerData.Stats[statName] or 0
    playerData.Stats[statName] = currentValue + amount
    
    local success = DataStoreManager.UpdatePlayerData(player, {
        Stats = playerData.Stats
    })
    
    if success then
        print("[PlayerData] ➕", statName, player.Name, "+" .. amount, "=", playerData.Stats[statName])
    else
        warn("[PlayerData] ❌ Не вдалося збільшити", statName, ":", player.Name)
    end
    
    return success
end

-- Get all unlocked planets for player
function PlayerDataManager.GetUnlockedPlanets(player)
    local playerData = DataStoreManager.GetPlayerData(player)
    return playerData and playerData.UnlockedPlanets or {}
end

-- Get all visited locations for player
function PlayerDataManager.GetVisitedLocations(player)
    local playerData = DataStoreManager.GetPlayerData(player)
    return playerData and playerData.VisitedLocations or {}
end

-- Get all discovered locations for player
function PlayerDataManager.GetDiscoveredLocations(player)
    local playerData = DataStoreManager.GetPlayerData(player)
    return playerData and playerData.DiscoveredLocations or {}
end

-- Check if player has unlocked a specific planet
function PlayerDataManager.HasUnlockedPlanet(player, planetId)
    local unlockedPlanets = PlayerDataManager.GetUnlockedPlanets(player)
    for _, unlockedPlanet in ipairs(unlockedPlanets) do
        if unlockedPlanet == planetId then
            return true
        end
    end
    return false
end

-- Check if player has visited a specific location
function PlayerDataManager.HasVisitedLocation(player, locationId)
    local visitedLocations = PlayerDataManager.GetVisitedLocations(player)
    return visitedLocations[locationId] == true
end

-- Check if player has discovered a specific location
function PlayerDataManager.HasDiscoveredLocation(player, locationId)
    local discoveredLocations = PlayerDataManager.GetDiscoveredLocations(player)
    return discoveredLocations[locationId] == true
end

return PlayerDataManager