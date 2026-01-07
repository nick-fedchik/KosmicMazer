--[[
================================================================================
KOSMICMAZER — Simple Teleportation System
================================================================================

Purpose: Simple teleportation system for debugging and testing
Version: 1.0

Features:
- Basic teleportation between Space Station and Planet locations
- Simple UI for location selection
- Debug logging for troubleshooting

================================================================================
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local DebrisService = game:GetService("Debris")

-- Load dependencies
local GameConfig = require(game.ServerScriptService.GameConfig)
local LocationManager = require(game.ServerScriptService.LocationManager)

-- Create RemoteEvents
local teleportEvent = ReplicatedStorage:FindFirstChild("TeleportationEvent")
if not teleportEvent then
    teleportEvent = Instance.new("RemoteEvent")
    teleportEvent.Name = "TeleportationEvent"
    teleportEvent.Parent = ReplicatedStorage
end

local teleportStateEvent = ReplicatedStorage:FindFirstChild("TeleportationStateEvent")
if not teleportStateEvent then
    teleportStateEvent = Instance.new("RemoteEvent")
    teleportStateEvent.Name = "TeleportationStateEvent"
    teleportStateEvent.Parent = ReplicatedStorage
end

-- State
local isTeleportationActive = false
local teleportCooldowns = {}

-- Get current spawn location
local function getCurrentSpawnLocation()
    -- Check SpaceStation first
    local spaceStation = workspace:FindFirstChild("SpaceStation")
    if spaceStation then
        local spawn = spaceStation:FindFirstChild("SpawnLocation")
        if spawn then
            return spawn
        end
    end
    
    -- Check all Location_* models
    for _, child in ipairs(workspace:GetChildren()) do
        if child.Name:match("^Location_") then
            local spawn = child:FindFirstChild("SpawnLocation")
            if spawn then
                return spawn
            end
        end
    end
    
    return nil
end

-- Get discovered locations for player
local function getDiscoveredLocations(player)
    local discoveredLocations = {}
    
    -- Check each planet for discovered locations
    for planetId, planet in pairs(GameConfig.Planets) do
        if planet.Locations then
            for locationId, location in pairs(planet.Locations) do
                if location.isDiscovered then
                    table.insert(discoveredLocations, {
                        PlanetId = planetId,
                        LocationId = locationId,
                        DisplayName = location.DisplayName,
                        PlanetName = planet.DisplayName,
                        SpawnPoint = location.SpawnPoint,
                        TeleportPoint = location.TeleportPoint
                    })
                end
            end
        end
    end
    
    return discoveredLocations
end

-- Switch location
local function switchLocation(player, targetLocation)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return false, "Character not ready"
    end
    
    -- Check cooldown
    if teleportCooldowns[player.UserId] and teleportCooldowns[player.UserId] > tick() then
        return false, "Teleportation on cooldown"
    end
    
    local humanoidRootPart = player.Character.HumanoidRootPart
    local currentLocation = player:GetAttribute("CurrentLocation") or "SpaceStation"
    
    print("[SimpleTeleport] Switching from " .. currentLocation .. " to " .. targetLocation.LocationId)
    
    -- Create teleportation effect
    local teleportEffect = Instance.new("Part")
    teleportEffect.Size = Vector3.new(8, 8, 8)
    teleportEffect.Material = Enum.Material.Neon
    teleportEffect.Color = Color3.new(0, 0.5, 1)
    teleportEffect.Anchored = true
    teleportEffect.CanCollide = false
    teleportEffect.Transparency = 0.3
    teleportEffect.CFrame = humanoidRootPart.CFrame
    teleportEffect.Parent = workspace
    
    -- Animate effect
    local expandTween = TweenService:Create(teleportEffect, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(20, 20, 20),
        Transparency = 1
    })
    expandTween:Play()
    
    task.wait(0.5)
    
    -- Switch location using LocationManager
    local success = false
    local targetCFrame
    
    if targetLocation.LocationId == "SpaceStation" then
        -- Switch to Space Station
        print("[SimpleTeleport] Switching to Space Station")
        success = LocationManager.SwitchToSpaceStation(targetLocation.PlanetId, targetLocation.LocationId)
        if success then
            task.wait(0.5)
            local spawnLocation = getCurrentSpawnLocation()
            if spawnLocation then
                targetCFrame = spawnLocation.CFrame * CFrame.new(0, 3, 0)
            end
        end
    else
        -- Switch to planet location
        print("[SimpleTeleport] Switching to planet: " .. targetLocation.PlanetId .. ", location: " .. targetLocation.LocationId)
        success = LocationManager.SwitchToPlanetLocation(targetLocation.PlanetId, targetLocation.LocationId)
        if success then
            task.wait(0.5)
            local spawnLocation = getCurrentSpawnLocation()
            if spawnLocation then
                targetCFrame = spawnLocation.CFrame * CFrame.new(0, 3, 0)
            end
        end
    end
    
    if not success or not targetCFrame then
        print("[SimpleTeleport] Failed to switch location")
        return false, "Failed to switch location"
    end
    
    -- Teleport player
    humanoidRootPart.CFrame = targetCFrame
    
    -- Update player's current location
    player:SetAttribute("CurrentLocation", targetLocation.LocationId)
    
    -- Create arrival effect
    local arrivalEffect = Instance.new("Part")
    arrivalEffect.Size = Vector3.new(20, 20, 20)
    arrivalEffect.Material = Enum.Material.Neon
    arrivalEffect.Color = Color3.new(0, 0.5, 1)
    arrivalEffect.Anchored = true
    arrivalEffect.CanCollide = false
    arrivalEffect.Transparency = 1
    arrivalEffect.CFrame = targetCFrame
    arrivalEffect.Parent = workspace
    
    -- Animate arrival
    local shrinkTween = TweenService:Create(arrivalEffect, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = Vector3.new(1, 1, 1),
        Transparency = 0.5
    })
    shrinkTween:Play()
    
    -- Clean up effects
    DebrisService:AddItem(teleportEffect, 2)
    DebrisService:AddItem(arrivalEffect, 2)
    
    -- Set cooldown
    teleportCooldowns[player.UserId] = tick() + 3.0
    
    print("[SimpleTeleport] " .. player.Name .. " teleported to " .. targetLocation.DisplayName)
    return true, "Teleported successfully"
end

-- Handle player touching spawn location
local function onSpawnTouched(otherPart)
    local character = otherPart.Parent
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    local player = Players:GetPlayerFromCharacter(character)
    if not player then return end
    
    if not isTeleportationActive then return end
    
    print("[SimpleTeleport] Player " .. player.Name .. " touched spawn location")
    
    local currentLocation = player:GetAttribute("CurrentLocation") or "SpaceStation"
    
    -- Get available locations
    local availableLocations = {}
    
    -- Add Space Station if player is not there
    if currentLocation ~= "SpaceStation" then
        table.insert(availableLocations, {
            PlanetId = "SpaceStation",
            LocationId = "SpaceStation",
            DisplayName = "🚀 Космічна Станція",
            PlanetName = "Space",
            SpawnPoint = getCurrentSpawnLocation() and getCurrentSpawnLocation().CFrame or CFrame.new(),
            TeleportPoint = getCurrentSpawnLocation() and getCurrentSpawnLocation().CFrame or CFrame.new()
        })
    end
    
    -- Add discovered planet locations
    local discoveredLocations = getDiscoveredLocations(player)
    for _, location in ipairs(discoveredLocations) do
        if location.LocationId ~= currentLocation then
            table.insert(availableLocations, location)
        end
    end
    
    if #availableLocations > 0 then
        print("[SimpleTeleport] Sending " .. #availableLocations .. " locations to " .. player.Name)
        teleportEvent:FireClient(player, "ShowTeleportUI", {
            locations = availableLocations,
            player = player.Name
        })
    end
end

-- Handle teleportation requests
local function onTeleportRequest(player, locationId)
    print("[SimpleTeleport] " .. player.Name .. " requested teleport to " .. tostring(locationId))
    
    local currentLocation = player:GetAttribute("CurrentLocation") or "SpaceStation"
    
    -- Prevent teleporting to the same location
    if locationId == currentLocation then
        teleportEvent:FireClient(player, "TeleportError", "Ви вже знаходитесь на цій локації")
        return
    end
    
    -- Find target location
    local targetLocation = nil
    
    -- Check if it's Space Station
    if locationId == "SpaceStation" then
        targetLocation = {
            PlanetId = "SpaceStation",
            LocationId = "SpaceStation",
            DisplayName = "🚀 Космічна Станція",
            PlanetName = "Space",
            SpawnPoint = getCurrentSpawnLocation() and getCurrentSpawnLocation().CFrame or CFrame.new(),
            TeleportPoint = getCurrentSpawnLocation() and getCurrentSpawnLocation().CFrame or CFrame.new()
        }
    else
        -- Check discovered locations
        local discoveredLocations = getDiscoveredLocations(player)
        for _, location in ipairs(discoveredLocations) do
            if location.LocationId == locationId then
                targetLocation = location
                break
            end
        end
    end
    
    if not targetLocation then
        teleportEvent:FireClient(player, "TeleportError", "Локація не знайдена або не відкрита")
        return
    end
    
    -- Perform teleportation
    local success, message = switchLocation(player, targetLocation)
    
    if success then
        teleportEvent:FireClient(player, "TeleportSuccess", message)
    else
        teleportEvent:FireClient(player, "TeleportError", message)
    end
end

-- Activate teleportation
local function activateTeleportation(isActive)
    isTeleportationActive = isActive
    
    local spawnLocation = getCurrentSpawnLocation()
    if spawnLocation then
        if isActive then
            spawnLocation.Color = Color3.new(0, 0.498, 1) -- Blue
            spawnLocation.Transparency = 0
            
            -- Enable light
            local pointLight = spawnLocation:FindFirstChild("PointLight")
            if pointLight then
                pointLight.Color = Color3.new(0, 0.498, 1)
                pointLight.Brightness = 1.5
                pointLight.Enabled = true
            end
            
            print("[SimpleTeleport] Teleportation ACTIVATED")
        else
            spawnLocation.Color = Color3.new(0.3, 0.3, 0.3) -- Gray
            spawnLocation.Transparency = 0.3
            
            -- Disable light
            local pointLight = spawnLocation:FindFirstChild("PointLight")
            if pointLight then
                pointLight.Enabled = false
            end
            
            print("[SimpleTeleport] Teleportation DEACTIVATED")
        end
    end
    
    -- Notify all players
    for _, player in ipairs(Players:GetPlayers()) do
        teleportStateEvent:FireClient(player, isActive)
    end
end

-- Connect events
local spawnLocation = getCurrentSpawnLocation()
if spawnLocation then
    spawnLocation.Touched:Connect(onSpawnTouched)
    print("[SimpleTeleport] Connected to spawn location: " .. spawnLocation:GetFullName())
end

teleportEvent.OnServerEvent:Connect(onTeleportRequest)

-- Initialize in inactive state
activateTeleportation(false)

-- Auto-activate after 2 seconds for testing
task.wait(2)
activateTeleportation(true)

print("[SimpleTeleport] Simple teleportation system initialized")