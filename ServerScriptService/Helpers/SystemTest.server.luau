--[[
================================================================================
KOSMICMAZER — System Test
================================================================================

Purpose: Monitors system health and performance
Version: 1.1

Features:
- Tracks system uptime
- Monitors player count
- Logs error occurrences
- Provides periodic status reports

API:
- None (self-contained monitoring service)

Calls to:
- Players service: GetPlayers()
- LogService: MessageOut event

Called from:
- Game initialization system

Events:
- LogService.MessageOut: Monitors error messages

Dependencies:
- Players service
- RunService (for Studio detection)
- LogService (for error monitoring)

ChangeLog:
- Initial implementation for system monitoring

================================================================================
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local systemStats = {
    startTime = tick(),
    totalPlayers = 0,
    loadingPlayers = 0,
    errors = 0
}

local function logSystemStatus()
    local currentTime = tick()
    local uptime = currentTime - systemStats.startTime
    
    print("[System] === Статус системи ===")
    print("[System] ⏱️ Час роботи:", string.format("%.1f", uptime), "секунд")
    print("[System] 👥 Гравців:", #Players:GetPlayers())
    print("[System] 🛠️ Studio:", RunService:IsStudio())
    print("[System] ❌ Помилок:", systemStats.errors)
    print("[System] =====================")
end

-- Log status every 30 seconds
task.spawn(function()
    while true do
        task.wait(30)
        logSystemStatus()
    end
end)

-- Monitor for errors
local function onError(message, stack)
    systemStats.errors = systemStats.errors + 1
    warn("[System] ❌ Помилка:", message)
end

-- Connect to error events (if available)
if game:GetService("LogService") then
    game:GetService("LogService").MessageOut:Connect(function(message, messageType)
        if messageType == Enum.MessageType.MessageError then
            onError(message, "")
        end
    end)
end

-- Initial status
print("[System] 🚀 Моніторинг системи запущено")
logSystemStatus()

-- Test teleportation event communication
spawn(function()
    task.wait(5) -- Wait for system to initialize
    
    print("[System] 🧪 Тест комунікації телепортації...")
    
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    
    local players = Players:GetPlayers()
    if #players > 0 then
        local testPlayer = players[1]
        print("[System] 👤 Тест з гравцем:", testPlayer.Name)
        
        local teleportEvent = ReplicatedStorage:FindFirstChild("TeleportationEvent")
        if teleportEvent then
            print("[System] 📡 Відправка тестової події...")
            
            local testData = {
                locations = {
                    {
                        PlanetId = "SpaceStation",
                        LocationId = "SpaceStation",
                        DisplayName = "🚀 Test Teleport",
                        PlanetName = "Space",
                        SpawnPoint = CFrame.new(0, 3, 0),
                        TeleportPoint = CFrame.new(0, 3, 0)
                    }
                },
                player = testPlayer.Name
            }
            
            local success = pcall(function()
                teleportEvent:FireClient(testPlayer, "ShowTeleportUI", testData)
            end)
            
            if success then
                print("[System] ✅ Тестову подію відправлено")
            else
                warn("[System] ❌ Не вдалося відправити тестову подію")
            end
        else
            warn("[System] ❌ TeleportationEvent не знайдено")
        end
    else
        print("[System] 📭 Немає гравців для тестування")
    end
end)