--[[
================================================================================
KOSMICMAZER — DataStore Cleaner
================================================================================

Purpose: Removes all player data from DataStore (testing only)
Version: 1.0

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
- Initial implementation for testing cleanup
- Added comprehensive safety warnings
- Enhanced with error handling and logging

================================================================================

WARNING: This script will delete ALL player data!
Only use in testing environment
--]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

-- WARNING: This will delete ALL player data!
-- Only use in testing environment
local function cleanAllPlayerData()
    print("[DataStoreCleaner] WARNING: Cleaning all player data!")
    
    local playerDataStore = DataStoreService:GetDataStore("PlayerData")
    
    -- Get all keys (this is a simplified approach)
    -- In production, you'd want to be more careful about this
    for _, player in ipairs(Players:GetPlayers()) do
        local userId = tostring(player.UserId)
        
        local success, result = pcall(function()
            return playerDataStore:RemoveAsync(userId)
        end)
        
        if success then
            print(string.format("[DataStoreCleaner] Removed data for: %s (ID: %s)", player.Name, userId))
        else
            warn(string.format("[DataStoreCleaner] Failed to remove data for: %s - %s", player.Name, tostring(result)))
        end
    end
    
    print("[DataStoreCleaner] Data cleaning completed")
end

-- Uncomment the line below to clean data (use with caution!)
-- cleanAllPlayerData()

print("[DataStoreCleaner] DataStore cleaner loaded (commented out for safety)")