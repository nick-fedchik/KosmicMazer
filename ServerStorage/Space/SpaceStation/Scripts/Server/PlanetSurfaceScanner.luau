--[[
================================================================================
KOSMICMAZER — PlanetSurfaceScanner Module
================================================================================

Purpose: Manages planet scanning functionality with PlanetConfig integration
Version: 4.6 (ModuleScript version)

Features:
- Reads planet location data from ServerStorage/Planets/{PlanetId}/Configuration/PlanetConfig
- Activates when player stands on ScannerBaseplate
- Shows visual scanning effects with particles and animations
- Activates teleportation system when discovered locations exist
- Global state management for teleportation activation
- Surface GUI display for discovered locations
- LocationModel hierarchical structure compatibility

API:
- initializeScanner(): Initializes scanner system
- startScanEffect(player): Starts scanning animation for player
- getDiscoveredLocations(player): Gets player's discovered locations
- updateTeleportationState(): Updates global teleportation state
- activateScanner()/deactivateScanner(): Controls visual state

Calls to:
- PlanetConfigLoader: Loads planet configuration from ServerStorage
- GameConfig: Reads basic configuration (DEFAULT_PLANET, scanner settings)
- DataStoreManager: GetPlayerData() for player data
- RemoteEventsRegistry: Get() for PlanetSurfaceScanner_Results RemoteEvent
- TweenService: Creates scanning animations
- DebrisService: Manages effect cleanup
- SoundService: Handles scanning sound effects

Dependencies:
- PlanetConfigLoader module (v1.1+)
- GameConfig module
- DataStoreManager module
- TeleportationManager module
- Players service
- ReplicatedStorage service
- TweenService
- DebrisService
- SoundService

ChangeLog:
- Version 4.6 (2026-01-10): MIGRATED to PlanetConfigLoader (GameConfig → ServerStorage)
  - getDiscoveredLocations() now uses PlanetConfigLoader.GetCurrentPlanetConfig()
  - resolvePlanetNameForPlayer() now uses PlanetConfigLoader.LoadPlanetConfig()
  - Removed dependency on GameConfig.Planets (deprecated in v4.1)
  - Compatible with PlanetConfig.LOCATIONS structure
  - Scanner now shows ONLY current planet's locations (inter-planetary flight ready)
- Version 4.5: Planet name now set at scan activation using runtime planet info (2026-01-08)
- Version 4.5: ScanResults planetName used for display instead of DEFAULT_PLANET_NAME
- Version 4.4: Made ScannerScreen optional - only ScannerBaseplate required (2026-01-08)
- Version 4.4: Visual effects disabled gracefully when ScannerScreen missing
- Version 4.4: Added player monitoring diagnostics (distance logging every 3s)
- Version 4.4: Added monitorPlayers startup logging to confirm activation
- Version 4.3: Added detailed initialization logging for diagnostics (2026-01-08)
- Version 4.3: Enhanced component detection logging (baseplate, display, screen)
- Version 4.3: Added configuration values logging (SCAN_DURATION, INTERACTION_DISTANCE)
- Version 4.3: Added scanner model children listing when components not found
- Version 4.2: Updated for LocationModel hierarchical structure compatibility (ETAP 3)
- Version 4.2: Scanner now located in LocationModel.Equipment.PlanetSurfaceScanner path
- Version 4.2: Verified compatibility with new space station organizational structure
- Version 4.2: Integration tested with updated PlanetSurfaceScannerUI.local.luau v1.6
- Version 4.1: Enhanced scanner activation logic and improved error handling
- Version 4.0: REFACTORED - Converted from Script to ModuleScript for better modularity


================================================================================
]]

local PlanetSurfaceScanner = {}
PlanetSurfaceScanner.Version = "4.6"

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local DebrisService = game:GetService("Debris")
local SoundService = game:GetService("SoundService")

-- Module dependencies
local GameConfig = nil
local DataStoreManager = nil
local TeleportationManager = nil
local RemoteEventsRegistry = nil
local PlanetConfigLoader = nil

-- Scanner components (will be set during initialization)
local scannerModel = nil
local baseplate = nil
local display = nil
local scannerScreen = nil

-- Scanner state
local scannerState = {
    isInitialized = false,
    isScanning = false,
    isActive = false,
    playersOnBaseplate = {},
    scanProgress = 0,
    animationTime = 0,
    teleportationActive = false,
    playerHasUsedScanner = {} -- Track which players have used the scanner
}

-- RemoteEvents
local scanResultsEvent = nil

-- Visual effects configuration
local SCAN_DURATION = 0
local INTERACTION_DISTANCE = 0
local PULSE_COLOR = nil
local PULSE_SPEED = 0

-- Global teleportation activation state
local TELEPORTATION_ACTIVE = false
local teleportationInitialized = false

-- Initialize dependencies
local function initializeDependencies()
    local ServerScriptService = game:GetService("ServerScriptService")

    GameConfig = ServerScriptService:FindFirstChild("GameConfig")
    DataStoreManager = ServerScriptService:FindFirstChild("DataStoreManager")
    TeleportationManager = ServerScriptService:FindFirstChild("TeleportationManager")
    PlanetConfigLoader = ServerScriptService:FindFirstChild("PlanetConfigLoader")

    if not GameConfig then
        error("GameConfig not found in ServerScriptService!")
    end
    if not DataStoreManager then
        error("DataStoreManager not found in ServerScriptService!")
    end
    if not TeleportationManager then
        error("TeleportationManager not found in ServerScriptService!")
    end
    if not PlanetConfigLoader then
        error("PlanetConfigLoader not found in ServerScriptService!")
    end

    GameConfig = require(GameConfig)
    DataStoreManager = require(DataStoreManager)
    TeleportationManager = require(TeleportationManager)
    PlanetConfigLoader = require(PlanetConfigLoader)
    RemoteEventsRegistry = require(ReplicatedStorage:WaitForChild("RemoteEventsRegistry"))

    -- Load configuration
    SCAN_DURATION = GameConfig.PlanetSurfaceScanner.ScanDuration
    INTERACTION_DISTANCE = GameConfig.PlanetSurfaceScanner.InteractionDistance
    PULSE_COLOR = GameConfig.PULSE_EFFECT_COLOR
    PULSE_SPEED = GameConfig.PULSE_EFFECT_SPEED
end

-- Helper function to check if player is on baseplate
local function isPlayerOnBaseplate(player)
    if not player.Character or not baseplate then
        return false
    end
    
    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        return false
    end
    
    local distance = (humanoidRootPart.Position - baseplate.Position).Magnitude
    return distance <= INTERACTION_DISTANCE
end

-- Get discovered locations from current planet configuration and player data
-- MIGRATED v4.6: Uses PlanetConfigLoader instead of GameConfig.Planets
local function getDiscoveredLocations(player)
    local discoveredLocations = {}
    local playerData = DataStoreManager.GetPlayerData(player)

    if not playerData then
        return discoveredLocations
    end

    -- Get current planet configuration from ServerStorage
    local currentPlanet = PlanetConfigLoader.GetCurrentPlanetConfig()

    print(string.format("[PlanetSurfaceScanner] 📡 Loading locations from planet: %s (%s)",
        currentPlanet.PLANET_ID or "Unknown", currentPlanet.DISPLAY_NAME or "Unknown"))

    -- Check ONLY current planet's locations
    if currentPlanet.LOCATIONS then
        for locationId, location in pairs(currentPlanet.LOCATIONS) do
            -- Check if location is discovered in PlanetConfig or player data
            local isDiscovered = location.isDiscovered

            -- Also check player's discovered locations
            if playerData.DiscoveredLocations and playerData.DiscoveredLocations[locationId] then
                isDiscovered = true
            end

            if isDiscovered then
                -- Check if location is visited
                local isVisited = false
                if playerData.VisitedLocations and playerData.VisitedLocations[locationId] then
                    isVisited = true
                end

                table.insert(discoveredLocations, {
                    PlanetId = currentPlanet.PLANET_ID,
                    LocationId = locationId,
                    DisplayName = location.DisplayName,
                    PlanetName = currentPlanet.DISPLAY_NAME,
                    SpawnPoint = location.SpawnPoint,
                    TeleportPoint = location.TeleportPoint or location.SpawnPoint,
                    IsVisited = isVisited
                })

                print(string.format("[PlanetSurfaceScanner] ✅ Location added: %s (%s)",
                    location.DisplayName, locationId))
            end
        end
    end

    print(string.format("[PlanetSurfaceScanner] 📊 Total discovered locations: %d", #discoveredLocations))

    return discoveredLocations
end

-- Resolve planet name for a player using current runtime data
-- MIGRATED v4.6: Uses PlanetConfigLoader instead of GameConfig.Planets
local function resolvePlanetNameForPlayer(player)
    local planetId = GameConfig.DEFAULT_PLANET
    local playerData = DataStoreManager.GetPlayerData(player)
    if playerData and playerData.CurrentPlanet then
        planetId = playerData.CurrentPlanet
    end

    -- Load planet config from ServerStorage
    local success, planetConfig = pcall(function()
        return PlanetConfigLoader.LoadPlanetConfig(planetId)
    end)

    if success and planetConfig and planetConfig.DISPLAY_NAME then
        return planetConfig.DISPLAY_NAME
    end

    -- Fallback to GameConfig default name
    return GameConfig.DEFAULT_PLANET_NAME or planetId or "Unknown Planet"
end

-- Update ScannerScreen label with resolved planet name
local function updatePlanetNameLabel(planetName)
    if not scannerScreen then return end

    local scanIndicator = scannerScreen:FindFirstChild("ScanIndicator")
    if not scanIndicator then return end

    local indicatorFrame = scanIndicator:FindFirstChild("IndicatorFrame")
    if not indicatorFrame then return end

    local scanLabel = indicatorFrame:FindFirstChild("ScanLabel")
    if not scanLabel then return end

    scanLabel.Text = "?? " .. planetName
    scanLabel.TextColor3 = Color3.new(0.8, 0.8, 1)
    scanLabel.BackgroundTransparency = 0.5
    scanIndicator.Enabled = true
    print("[PlanetSurfaceScanner] ? Set planet name: " .. planetName)
end

-- Check if teleportation should be activated
local function shouldActivateTeleportation()
    -- Check if any player has discovered locations AND has used the scanner
    for _, player in ipairs(Players:GetPlayers()) do
        local discoveredLocations = getDiscoveredLocations(player)
        local hasUsedScanner = scannerState.playerHasUsedScanner[player.UserId]
        if #discoveredLocations > 0 and hasUsedScanner then
            return true
        end
    end
    return false
end

-- Initialize teleportation system (only once)
local function initializeTeleportationSystem()
    if teleportationInitialized then
        return
    end
    
    print("[PlanetSurfaceScanner] 🚀 Initializing TeleportationManager...")
    
    -- Get RemoteEvents from registry (already created by GameInit)
    local teleportEvent = RemoteEventsRegistry.Get("TeleportationEvent")
    local teleportStateEvent = RemoteEventsRegistry.Get("TeleportationStateEvent")
    
    if not teleportEvent or not teleportStateEvent then
        warn("[PlanetSurfaceScanner] ❌ RemoteEvents не знайдено в реєстрі!")
        return
    end
    
    print("[PlanetSurfaceScanner] ✅ RemoteEvents отримано з реєстру")
    
    local success, error = pcall(function()
        TeleportationManager.Initialize()
    end)
    
    if success then
        teleportationInitialized = true
        print("[PlanetSurfaceScanner] ✅ TeleportationManager initialized successfully")
        
        -- Notify clients that teleportation system is ready
        task.wait(1) -- Give clients time to connect
        teleportStateEvent:FireAllClients(true)
        print("[PlanetSurfaceScanner] 📡 Notified clients that teleportation system is ready")
    else
        warn("[PlanetSurfaceScanner] ❌ Failed to initialize TeleportationManager: " .. tostring(error))
    end
end

-- Update global teleportation state
local function updateTeleportationState()
    local shouldBeActive = shouldActivateTeleportation()
    
    if shouldBeActive ~= TELEPORTATION_ACTIVE then
        TELEPORTATION_ACTIVE = shouldBeActive
        
        if shouldBeActive then
            -- Initialize teleportation system first time it's needed
            initializeTeleportationSystem()
            
            print("[PlanetSurfaceScanner] 🚀 TELEPORTATION SYSTEM ACTIVATED - Discovered locations found")
            
            -- Activate teleportation through module
            if teleportationInitialized then
                -- Activate for all players (using first player as trigger)
                local players = Players:GetPlayers()
                if #players > 0 then
                    TeleportationManager.Activate(players[1], true)
                end
            end
            
            -- Fire RemoteEvent to activate teleportation UI for all clients
            if scanResultsEvent then
                scanResultsEvent:FireAllClients("TeleportationActivated", true)
            end
            
            -- Also notify SpawnLocation server controller
            local spawnLocationEvent = _G.SpawnLocationTeleportationEvent
            if spawnLocationEvent then
                spawnLocationEvent:Fire(true)
            end
        else
            print("[PlanetSurfaceScanner] ⏸️ Teleportation system deactivated")
            
            -- Deactivate teleportation through module
            if teleportationInitialized then
                local players = Players:GetPlayers()
                if #players > 0 then
                    TeleportationManager.Activate(players[1], false)
                end
            end
            
            if scanResultsEvent then
                scanResultsEvent:FireAllClients("TeleportationActivated", false)
            end
            
            -- Also notify SpawnLocation server controller
            local spawnLocationEvent = _G.SpawnLocationTeleportationEvent
            if spawnLocationEvent then
                spawnLocationEvent:Fire(false)
            end
        end
    end
end

-- Create scanning sound effect using existing ScanningSound
local function createScanSound()
    if not scannerScreen then return end
    
    -- Get the existing ScanningSound from PlanetSurfaceScanner model
    local scanningSound = scannerModel:FindFirstChild("ScanningSound")
    if not scanningSound then
        print("[PlanetSurfaceScanner] Warning: ScanningSound not found in PlanetSurfaceScanner model")
        return nil
    end
    
    -- Clone the sound to scannerScreen for playback
    local scanSound = scanningSound:Clone()
    scanSound.Name = "ActiveScanSound"
    scanSound.Looped = true
    scanSound.Parent = scannerScreen
    
    -- Play sound with fade in
    scanSound:Play()
    
    -- Fade out at the end
    task.spawn(function()
        task.wait(SCAN_DURATION - 1)
        local fadeOut = TweenService:Create(scanSound, TweenInfo.new(1), {
            Volume = 0
        })
        fadeOut:Play()
        fadeOut.Completed:Connect(function()
            scanSound:Stop()
            scanSound:Destroy()
        end)
    end)
    
    return scanSound
end

-- Create scanning visual effects
local function createScanEffects()
    if not scannerScreen then return end
    
    -- Create scanning sound
    createScanSound()
    
    -- Create scanning particles ONLY on ScannerScreen
    for i = 1, 8 do
        local angle = (i - 1) * (math.pi * 2 / 8)
        local particle = Instance.new("ParticleEmitter")
        particle.Name = "ScanParticle" .. i
        particle.Color = ColorSequence.new(PULSE_COLOR)
        particle.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.8),
            NumberSequenceKeypoint.new(1, 1)
        })
        particle.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 2),
            NumberSequenceKeypoint.new(1, 0.5)
        })
        particle.Lifetime = NumberRange.new(1, 2)
        particle.Rate = 5
        particle.Speed = NumberRange.new(5, 10)
        particle.SpreadAngle = Vector2.new(0, 30)
        particle.Acceleration = Vector3.new(0, 10, 0)
        particle.Parent = scannerScreen
    end
    
    -- Create scanning rings ONLY around ScannerScreen
    for i = 1, 3 do
        local ring = Instance.new("Part")
        ring.Name = "ScanRing" .. i
        ring.Size = Vector3.new(1, 0.1, 1)
        ring.Material = Enum.Material.Neon
        ring.Color = PULSE_COLOR
        ring.Transparency = 0.7
        ring.Anchored = true
        ring.CanCollide = false
        ring.CFrame = scannerScreen.CFrame * CFrame.new(0, i * 0.5, 0)
        ring.Parent = scannerScreen
        
        -- Animate ring expansion
        local tween = TweenService:Create(ring, TweenInfo.new(SCAN_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = Vector3.new(20 + i * 5, 0.1, 20 + i * 5),
            Transparency = 1
        })
        tween:Play()
        tween.Completed:Connect(function()
            ring:Destroy()
        end)
    end
    
    -- Create pulsing effect on baseplate
    if baseplate then
        local originalColor = baseplate.Color
        local originalMaterial = baseplate.Material
        
        -- Change baseplate material and color for scanning
        baseplate.Material = Enum.Material.Neon
        baseplate.Color = PULSE_COLOR
        baseplate.Transparency = 0.3
        
        -- Create pulsing effect
        local pulseCount = 0
        local pulseConnection
        pulseConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if pulseCount >= SCAN_DURATION * 20 then -- 20 pulses per second
                pulseConnection:Disconnect()
                return
            end
            
            local pulse = math.sin(pulseCount * 0.5) * 0.3 + 0.3
            baseplate.Transparency = pulse
            pulseCount = pulseCount + 1
        end)
        
        -- Restore original state after scan
        task.spawn(function()
            task.wait(SCAN_DURATION)
            if pulseConnection then
                pulseConnection:Disconnect()
            end
            baseplate.Material = originalMaterial
            baseplate.Color = originalColor
            baseplate.Transparency = 0
        end)
    end
end

-- Create scrolling location display on ScannerScreen
local function createLocationScrolling(locations)
    if not scannerScreen or #locations == 0 then return end
    
    -- Create SurfaceGui on ScannerScreen
    local surfaceGui = Instance.new("SurfaceGui")
    surfaceGui.Name = "LocationScrollGui"
    surfaceGui.Face = Enum.NormalId.Top
    surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    surfaceGui.PixelsPerStud = 50
    surfaceGui.Active = true
    surfaceGui.Parent = scannerScreen
    
    -- Create main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.8, 0, 0.8, 0)
    mainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
    mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = PULSE_COLOR
    mainFrame.Parent = surfaceGui
    
    -- Create scrolling frame
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "LocationScrollFrame"
    scrollFrame.Size = UDim2.new(1, -10, 1, -10)
    scrollFrame.Position = UDim2.new(0, 5, 0, 5)
    scrollFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    scrollFrame.BackgroundTransparency = 0.3
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = PULSE_COLOR
    scrollFrame.Parent = mainFrame
    
    -- Create layout
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 3)
    layout.Parent = scrollFrame
    
    -- Add location labels
    for i, location in ipairs(locations) do
        local locationLabel = Instance.new("TextLabel")
        locationLabel.Name = "LocationLabel" .. i
        locationLabel.Size = UDim2.new(1, -10, 0, 25)
        locationLabel.BackgroundTransparency = 0.5
        locationLabel.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
        locationLabel.BorderSizePixel = 1
        locationLabel.BorderColor3 = PULSE_COLOR
        locationLabel.Text = (location.IsVisited and "✅ " or "🆕 ") .. location.DisplayName
        locationLabel.TextColor3 = location.IsVisited and Color3.new(0, 1, 0) or Color3.new(1, 0.5, 0)
        locationLabel.TextScaled = false
        locationLabel.Font = Enum.Font.SourceSansBold
        locationLabel.TextSize = 14
        locationLabel.TextXAlignment = Enum.TextXAlignment.Left
        locationLabel.Parent = scrollFrame
    end
    
    -- Update canvas size
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #locations * 28)
    
    -- Auto-scroll animation
    local scrollPosition = 0
    local scrollDirection = 1
    local scrollConnection
    scrollConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not scrollFrame or not scrollFrame.Parent then
            if scrollConnection then
                scrollConnection:Disconnect()
            end
            return
        end
        
        scrollPosition = scrollPosition + (scrollDirection * 1)
        
        if scrollPosition >= scrollFrame.CanvasSize.Y.Offset - scrollFrame.AbsoluteSize.Y then
            scrollDirection = -1
        elseif scrollPosition <= 0 then
            scrollDirection = 1
        end
        
        scrollFrame.CanvasPosition = Vector2.new(0, scrollPosition)
    end)
    
    -- Clean up after scan
    task.spawn(function()
        task.wait(SCAN_DURATION)
        if scrollConnection then
            scrollConnection:Disconnect()
        end
        if surfaceGui then
            surfaceGui:Destroy()
        end
    end)
    
    return surfaceGui
end

-- Start scanning animation
local function startScanEffect(player)
    if scannerState.isScanning then return end
    
    scannerState.isScanning = true
    scannerState.scanProgress = 0

    local planetName = resolvePlanetNameForPlayer(player)
    updatePlanetNameLabel(planetName)

    -- Mark that this player has used the scanner
    scannerState.playerHasUsedScanner[player.UserId] = true
    print("[PlanetSurfaceScanner] 🔍 Starting scan for " .. player.Name .. " (first time scanner use: " .. tostring(not scannerState.playerHasUsedScanner[player.UserId]) .. ")")
    
    -- Get discovered locations for scrolling display
    local discoveredLocations = getDiscoveredLocations(player)
    
    -- Create visual effects
    createScanEffects()
    
    -- Create location scrolling display
    createLocationScrolling(discoveredLocations)
    
    -- Animate scanner display
    local startTime = tick()
    
    local function updateScan()
        if not scannerState.isScanning then return end
        
        local elapsed = tick() - startTime
        scannerState.scanProgress = math.min(elapsed / SCAN_DURATION, 1)
        
        -- Update display colors ONLY on ScannerScreen
        if scannerScreen then
            for _, part in ipairs(scannerScreen:GetDescendants()) do
                if part:IsA("BasePart") and part.Material == Enum.Material.Neon then
                    local pulse = 1 + math.sin(elapsed * 8) * 0.5
                    part.Color = Color3.new(0, pulse, pulse)
                    part.Transparency = 0.3 + math.sin(elapsed * 6) * 0.2
                end
                
                if part:IsA("PointLight") then
                    local pulse = 2 + math.sin(elapsed * 10) * 1.5
                    part.Brightness = pulse
                    part.Color = Color3.new(0, 1, scannerState.scanProgress)
                end
            end
        end
        
        if scannerState.scanProgress >= 1 then
            -- Scan completed
            scannerState.isScanning = false
            print("[PlanetSurfaceScanner] ✅ Scan completed for " .. player.Name)
            
            -- Send results to player
            if scanResultsEvent then
                scanResultsEvent:FireClient(player, "ScanResults", {
                    locations = discoveredLocations,
                    player = player.Name,
                    planetName = planetName,
                    scanTime = os.time()
                })
            end
            
            -- Update teleportation state
            updateTeleportationState()
            
            -- Clean up effects ONLY from ScannerScreen
            task.wait(1)
            if scannerScreen then
                for _, child in ipairs(scannerScreen:GetChildren()) do
                    if child.Name:match("ScanParticle") or child.Name:match("ScanRing") then
                        child:Destroy()
                    end
                end
            end
        else
            task.wait(0.05)
            updateScan()
        end
    end
    
    updateScan()
end

-- Activate scanner visual state
local function activateScanner()
    if scannerState.isActive then return end
    
    scannerState.isActive = true
    print("[PlanetSurfaceScanner] 🟢 Scanner activated")
    
    if scannerScreen then
        for _, part in ipairs(scannerScreen:GetDescendants()) do
            if part:IsA("BasePart") and part.Material == Enum.Material.Neon then
                part.Transparency = 0.2
                part.Color = PULSE_COLOR
            end
            
            if part:IsA("PointLight") then
                part.Brightness = 1.5
                part.Color = PULSE_COLOR
            end
        end
    end
end

-- Deactivate scanner visual state
local function deactivateScanner()
    if not scannerState.isActive then return end
    
    scannerState.isActive = false
    print("[PlanetSurfaceScanner] 🔴 Scanner deactivated")
    
    if scannerScreen then
        for _, part in ipairs(scannerScreen:GetDescendants()) do
            if part:IsA("BasePart") and part.Material == Enum.Material.Neon then
                part.Transparency = 0.7
                part.Color = Color3.new(0.3, 0.3, 0.3)
            end
            
            if part:IsA("PointLight") then
                part.Brightness = 0.3
                part.Color = Color3.new(0.3, 0.3, 0.3)
            end
        end
    end
end

-- Idle animation for inactive state
local function idleAnimation()
    while task.wait(0.1) do
        if not scannerState.isActive and not scannerState.isScanning then
            scannerState.animationTime = scannerState.animationTime + 0.1
            
            local pulse = 0.2 + math.sin(scannerState.animationTime * PULSE_SPEED * 0.3) * 0.1
            
            if scannerScreen then
                for _, part in ipairs(scannerScreen:GetDescendants()) do
                    if part:IsA("BasePart") and part.Material == Enum.Material.Neon then
                        part.Transparency = 0.7 - pulse
                    end
                end
                
                local baseLight = baseplate:FindFirstChild("BaseLight")
                if baseLight then
                    baseLight.Brightness = 0.2 + pulse
                end
            end
        end
    end
end

-- Monitor players on baseplate
local function monitorPlayers()
    print("[PlanetSurfaceScanner] 🔄 Player monitoring started")
    print("  └─ Checking for players every 0.3s")
    print("  └─ INTERACTION_DISTANCE:", INTERACTION_DISTANCE)
    print("  └─ ScannerBaseplate position:", baseplate and baseplate.Position or "nil")
    
    local debugCounter = 0
    while task.wait(0.3) do
        local anyPlayerOnBaseplate = false
        debugCounter = debugCounter + 1
        
        for _, player in ipairs(Players:GetPlayers()) do
            local isOnBaseplate = isPlayerOnBaseplate(player)
            local wasOnBaseplate = scannerState.playersOnBaseplate[player]
            
            -- Debug logging every 10 iterations (3 seconds)
            if debugCounter % 10 == 0 and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local distance = (hrp.Position - baseplate.Position).Magnitude
                    print(string.format("[PlanetSurfaceScanner] 🔍 %s distance: %.1f (threshold: %d)", 
                        player.Name, distance, INTERACTION_DISTANCE))
                end
            end
            
            if isOnBaseplate and not wasOnBaseplate then
                scannerState.playersOnBaseplate[player] = true
                print("[PlanetSurfaceScanner] 👤 " .. player.Name .. " entered scanner baseplate")
                anyPlayerOnBaseplate = true
                
                -- Start scan for this player
                task.spawn(function()
                    startScanEffect(player)
                end)
                
            elseif not isOnBaseplate and wasOnBaseplate then
                scannerState.playersOnBaseplate[player] = nil
                print("[PlanetSurfaceScanner] " .. player.Name .. " left scanner baseplate")
                
                -- Force close scanner GUI if it's still open
                if scanResultsEvent then
                    scanResultsEvent:FireClient(player, "ForceCloseGUI", {})
                end
            end
            
            if isOnBaseplate then
                anyPlayerOnBaseplate = true
            end
        end
        
        -- Activate or deactivate scanner based on player presence
        if anyPlayerOnBaseplate and not scannerState.isActive then
            activateScanner()
        elseif not anyPlayerOnBaseplate and scannerState.isActive then
            deactivateScanner()
        end
    end
end

-- Public API
function PlanetSurfaceScanner.Initialize(scannerModelRef)
    local scriptName = "PlanetSurfaceScanner"
    local scriptVersion = PlanetSurfaceScanner.Version

    if scannerState.isInitialized then
        print(string.format("[%s %s] ⚠️ Scanner already initialized", scriptName, scriptVersion))
        return true
    end

    print(string.format("[%s %s] 🚀 Initializing...", scriptName, scriptVersion))
    print(string.format("[%s %s] 📦 Scanner model reference received: %s", scriptName, scriptVersion, scannerModelRef and scannerModelRef.Name or "nil"))
    
    -- Initialize dependencies first
    initializeDependencies()

    print(string.format("[%s %s] 📋 Configuration loaded:", scriptName, scriptVersion))
    print("  └─ SCAN_DURATION:", SCAN_DURATION)
    print("  └─ INTERACTION_DISTANCE:", INTERACTION_DISTANCE)
    print("  └─ PULSE_SPEED:", PULSE_SPEED)

    -- Set scanner components
    scannerModel = scannerModelRef
    baseplate = scannerModel:FindFirstChild("ScannerBaseplate")
    display = scannerModel:FindFirstChild("ScannerDisplay")
    scannerScreen = display and display:FindFirstChild("ScannerScreen")

    print(string.format("[%s %s] 🔍 Looking for scanner components:", scriptName, scriptVersion))
    print("  └─ ScannerBaseplate:", baseplate and "✅ FOUND" or "❌ NOT FOUND")
    print("  └─ ScannerDisplay:", display and "✅ FOUND" or "❌ NOT FOUND")
    print("  └─ ScannerScreen:", scannerScreen and "✅ FOUND" or "⚠️ NOT FOUND (visual effects disabled)")

    if not baseplate then
        warn(string.format("[%s %s] ⚠️ Scanner model children:", scriptName, scriptVersion))
        for _, child in ipairs(scannerModel:GetChildren()) do
            warn("  └─", child.Name, "-", child.ClassName)
        end
        error(string.format("[%s %s] ❌ Required component ScannerBaseplate not found!", scriptName, scriptVersion))
    end
    
    if not scannerScreen then
        warn(string.format("[%s %s] ⚠️ ScannerScreen not found - visual effects will be disabled", scriptName, scriptVersion))
    end

    -- Get RemoteEvent for scan results from registry
    scanResultsEvent = RemoteEventsRegistry.Get("PlanetSurfaceScanner_Results")

    if not scanResultsEvent then
        error(string.format("[%s %s] ❌ RemoteEvent 'PlanetSurfaceScanner_Results' не знайдено в реєстрі!", scriptName, scriptVersion))
    end

    print(string.format("[%s %s] ✅ RemoteEvent отримано з реєстру: PlanetSurfaceScanner_Results", scriptName, scriptVersion))


    -- Initialize visual state
    deactivateScanner()

    -- Start monitoring
    task.spawn(monitorPlayers)
    task.spawn(idleAnimation)

    scannerState.isInitialized = true
    print(string.format("[%s %s] ✅ Initialized successfully", scriptName, scriptVersion))
    return true
end

function PlanetSurfaceScanner.GetDiscoveredLocations(player)
    return getDiscoveredLocations(player)
end

function PlanetSurfaceScanner.UpdateTeleportationState()
    updateTeleportationState()
end

function PlanetSurfaceScanner.ActivateScanner()
    activateScanner()
end

function PlanetSurfaceScanner.DeactivateScanner()
    deactivateScanner()
end

function PlanetSurfaceScanner.StartScanEffect(player)
    startScanEffect(player)
end

-- Handle player joining
local function onPlayerAdded(player)
    print("[PlanetSurfaceScanner] Player joined: " .. player.Name)
    -- NOTE: Teleportation will be activated only after player uses scanner
    task.wait(2) -- Wait for player data to load
    -- updateTeleportationState() -- REMOVED: No automatic activation on join
end

-- Connect events
Players.PlayerAdded:Connect(onPlayerAdded)

return PlanetSurfaceScanner