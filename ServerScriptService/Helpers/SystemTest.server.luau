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
    
    print("[SystemTest] === System Status ===")
    print("[SystemTest] Uptime:", string.format("%.1f", uptime), "seconds")
    print("[SystemTest] Total players:", #Players:GetPlayers())
    print("[SystemTest] Running in Studio:", RunService:IsStudio())
    print("[SystemTest] Errors detected:", systemStats.errors)
    print("[SystemTest] ====================")
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
    print("[SystemTest] Error detected:", message)
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
print("[SystemTest] System monitoring started")
logSystemStatus()

-- Test teleportation event communication
spawn(function()
    task.wait(5) -- Wait for system to initialize
    
    print("[SystemTest] 🧪 Testing teleportation event communication...")
    
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    
    local players = Players:GetPlayers()
    if #players > 0 then
        local testPlayer = players[1]
        print("[SystemTest] 👤 Testing with player: " .. testPlayer.Name)
        
        local teleportEvent = ReplicatedStorage:FindFirstChild("TeleportationEvent")
        if teleportEvent then
            print("[SystemTest] 📡 Sending test event to client...")
            
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
                print("[SystemTest] ✅ Test event sent successfully")
            else
                print("[SystemTest] ❌ Failed to send test event")
            end
        else
            print("[SystemTest] ❌ TeleportationEvent not found")
        end
    else
        print("[SystemTest] 📭 No players available for testing")
    end
end)