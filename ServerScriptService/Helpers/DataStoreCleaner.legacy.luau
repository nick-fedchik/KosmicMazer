--[[
================================================================================
KOSMICMAZER — DataStore Cleaner
================================================================================

Purpose: Removes all player data from DataStore (testing only)
Version: 1.1

Features:
- Removes player data from DataStore
- Provides safety warnings
- Designed for testing environments only
- Includes comprehensive error handling

API:
- cleanAllPlayerData(): Removes all player data

Calls to:
- DataStoreService: GetDataStore(), RemoveAsync()
- Players service: GetPlayers()

Called from:
- Manual execution for testing

Events:
- None (manual execution)

Dependencies:
- DataStoreService
- Players service

ChangeLog:
- Version 1.1: Added DEBUG_MODE check for production safety
- Version 1.0: Initial implementation for testing cleanup
- Added comprehensive safety warnings
- Enhanced with error handling and logging

================================================================================

WARNING: This script will delete ALL player data!
Only use in testing environment
--]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

-- Load GameConfig
local ServerScriptService = game:GetService("ServerScriptService")
local GameConfig = require(ServerScriptService:WaitForChild("GameConfig"))

-- Check if DEBUG_MODE is enabled
if not GameConfig.DEBUG_MODE then
    print("[DataCleaner] 🔒 DEBUG_MODE вимкнено - скрипт неактивний (продакшен)")
    return
end

print("[DataCleaner] 🧪 DEBUG_MODE активний - очищувач доступний")

-- WARNING: This will delete ALL player data!
-- Only use in testing environment
local function cleanAllPlayerData()
    print("[DataCleaner] ⚠️ УВАГА: Очищення всіх даних гравців!")
    
    local playerDataStore = DataStoreService:GetDataStore("PlayerData")
    
    for _, player in ipairs(Players:GetPlayers()) do
        local userId = tostring(player.UserId)
        
        local success, result = pcall(function()
            return playerDataStore:RemoveAsync(userId)
        end)
        
        if success then
            print("[DataCleaner] 🗑️ Видалено дані:", player.Name, "ID:", userId)
        else
            warn("[DataCleaner] ❌ Не вдалося видалити:", player.Name, "-", tostring(result))
        end
    end
    
    print("[DataCleaner] ✅ Очищення завершено")
end

-- Uncomment the line below to clean data (use with caution!)
-- cleanAllPlayerData()

print("[DataCleaner] 🛠️ Очищувач завантажено (закоментовано)")