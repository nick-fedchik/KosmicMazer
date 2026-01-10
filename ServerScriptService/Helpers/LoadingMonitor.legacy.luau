--[[
================================================================================
KOSMICMAZER — Loading Monitor
================================================================================

Purpose: Tracks and debugs the loading process
Version: 1.0

Features:
- Monitors player loading states
- Tracks character addition timing
- Provides periodic status reports
- Logs player removal events

API:
- None (self-contained monitoring service)

Calls to:
- Players service: GetPlayers(), PlayerAdded

Called from:
- Game initialization system

Events:
- Player.CharacterAdded: Monitors character loading
- Player.Parent property change: Tracks player removal

Dependencies:
- Players service

ChangeLog:
- Initial implementation for loading state tracking

================================================================================
]]

local Players = game:GetService("Players")

local loadingStates = {}

local function monitorPlayer(player)
    local startTime = tick()
    loadingStates[player.UserId] = {
        startTime = startTime,
        currentStep = "Started"
    }
    
    print("[Loading] 👤 Моніторинг гравця:", player.Name)
    
    player.CharacterAdded:Connect(function(character)
        loadingStates[player.UserId].currentStep = "CharacterAdded"
        loadingStates[player.UserId].characterTime = tick()
        print("[Loading] ✅ Персонаж створено:", player.Name, "Час:", loadingStates[player.UserId].characterTime - startTime, "с")
    end)
    
    player:GetPropertyChangedSignal("Parent"):Connect(function()
        if not player.Parent then
            loadingStates[player.UserId].currentStep = "PlayerRemoved"
            loadingStates[player.UserId].removeTime = tick()
            print("[Loading] 👋 Гравець вийшов:", player.Name, "Час:", loadingStates[player.UserId].removeTime - startTime, "с")
        end
    end)
end

-- Connect to player events
Players.PlayerAdded:Connect(monitorPlayer)

-- Handle existing players
for _, player in ipairs(Players:GetPlayers()) do
    monitorPlayer(player)
end

-- Periodic status report
task.spawn(function()
    while true do
        task.wait(5)
        print("[Loading] === Статус завантаження ===")
        for userId, state in pairs(loadingStates) do
            local player = Players:GetPlayerByUserId(userId)
            if player then
                print("  -", player.Name, "Крок:", state.currentStep, "Час:", tick() - state.startTime, "с")
            end
        end
    end
end)

print("[Loading] 🚀 Монітор завантаження запущено")