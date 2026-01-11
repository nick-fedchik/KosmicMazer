--[[
================================================================================
KOSMICMAZER — Teleportation Manager (Module)
================================================================================

Purpose: Complete teleportation system that activates after planet scanning
Version: 5.0

Features:
- Manages teleportation activation state
- Handles location switching (Space Station ↔ Planet Locations)
- Controls SpawnLocation visual states with pulsing effects
- Manages teleportation UI and visual effects
- Integrates with PlanetSurfaceScanner and LocationManager
- Includes cooldown management and player tracking
- LocationModel hierarchical structure support

API:
- Initialize(): Initializes the system
- Activate(player, isActive): Activates/deactivates teleportation
- GetDiscoveredLocations(player): Gets player discovered locations
- SwitchLocation(player, targetLocation): Teleports player to location
- IsActive(): Returns current activation state

Calls to:
- GameConfig: Reads location and teleportation settings
- DataStoreManager: GetPlayerData(), UpdatePlayerData()
- LocationManager: SwitchToSpaceStation(), SwitchToPlanetLocation()
- TweenService: Creates teleportation animations
- DebrisService: Manages effect cleanup

Called from:
- GameInit (for initialization via Initialize())
- ScannerService (for activation via Activate() after scanning)

Dependencies:
- GameConfig module
- DataStoreManager module
- LocationManager module
- Players service
- ReplicatedStorage service
- TweenService
- DebrisService

ChangeLog:
- Version 5.0: CRITICAL FIX - Fixed player spawning below Baseplate (root cause in EnvironmentLoader) (2026-01-11)
- Version 5.0: Enhanced diagnostic logging for spawn position tracking
- Version 5.0: Fallback logic for origin (0,0,0) detection remains as safety measure
- Version 4.9: MIGRATION - Use PlanetConfigLoader instead of GameConfig.Planets (2026-01-10)
- Version 4.9: Filter locations ONLY from current planet (DEFAULT_PLANET)
- Version 4.9: Enhanced logging for planet/location filtering
- Version 4.8: Fixed planet template path from ServerStorage/Planet_1 to ServerStorage/Planets/Planet_1
- Version 4.7: GAME RULES FIX - SpawnLocation hidden until first planet scan (2026-01-08)
- Version 4.7: Added hasBeenActivatedOnce flag to track first activation
- Version 4.7: setInactiveState() keeps Transparency=1 until first scan completion
- Version 4.7: setActiveState() reveals SpawnLocation and enables collision on first activation
- Version 4.6: Updated for LocationModel hierarchical structure (ETAP 3)
- Version 4.6: findSpawnLocation() now searches LocationModel/Gameplay/SpawnLocation
- Version 4.6: Added LocationModel attribute validation for current location detection
- Version 4.6: Enhanced fallback system for SpawnLocation discovery across structures
- Version 4.6: Updated ServerStorage fallback paths for new hierarchy
- Version 4.5: Enhanced UI responsiveness and animation smoothness
- Version 4.4: CRITICAL FIX - Added comprehensive event communication debugging




================================================================================
]]

local TeleportationSystem = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local DebrisService = game:GetService("Debris")

-- Load dependencies with error handling
local GameConfig = require(game.ServerScriptService.GameConfig)
local PlanetConfigLoader = require(game.ServerScriptService.PlanetConfigLoader)

-- Safe loading of DataStoreManager with fallback
local DataStoreManager
local success, result = pcall(function()
    return require(game.ServerScriptService.DataStoreManager)
end)

if success then
    DataStoreManager = result
    print("[Teleport] ✅ DataStoreManager завантажено")
else
    warn("[Teleport] ⚠️ DataStoreManager не вдалося завантажити:", tostring(result))
    warn("[Teleport] ⚠️ Використовується fallback")
    
    -- Create fallback DataStoreManager
    DataStoreManager = {
        GetPlayerData = function(player)
            return {
                DiscoveredLocations = {},
                Stats = {
                    TotalTeleports = 0
                }
            }
        end,
        UpdatePlayerData = function(player, updates)
            print("[TeleportationManager] ⚠️ Fallback DataStoreManager - UpdatePlayerData called")
        end
    }
end

local LocationManager = require(game.ServerScriptService.LocationManager)
local RemoteEventsRegistry = require(ReplicatedStorage:WaitForChild("RemoteEventsRegistry"))

-- Load teleportation effects (lazy loading)
local function getTeleportParticle()
    local effectsFolder = game.ServerStorage:FindFirstChild("Effects")
    if not effectsFolder then
        warn("[TeleportationManager] TeleportParticle not found")
        warn("  └─ Очікуваний шлях: ServerStorage/Effects/TeleportAnimation/TeleportParticle")
        warn("  └─ Проблема: Effects folder not found")
        return nil
    end
    
    local teleportAnim = effectsFolder:FindFirstChild("TeleportAnimation")
    if not teleportAnim then
        warn("[TeleportationManager] TeleportParticle not found")
        warn("  └─ Очікуваний шлях: ServerStorage/Effects/TeleportAnimation/TeleportParticle")
        warn("  └─ Проблема: TeleportAnimation folder not found")
        return nil
    end
    
    local particle = teleportAnim:FindFirstChild("TeleportParticle")
    if particle then
        return particle:Clone()
    else
        warn("[TeleportationManager] TeleportParticle not found")
        warn("  └─ Очікуваний шлях: ServerStorage/Effects/TeleportAnimation/TeleportParticle")
        warn("  └─ Проблема: TeleportParticle об'єкт not found")
        return nil
    end
end

-- Services and objects
local function getCurrentSpawnLocation()
    -- Find the current active SpawnLocation based on player's location
    -- This will be the SpawnLocation in the currently loaded location
    
    print("[TeleportationManager] 🔍 Searching for SpawnLocation...")
    
    -- Check SpaceStation first (direct in Workspace)
    local spawn = workspace:FindFirstChild("SpawnLocation")
    if spawn and spawn:IsA("SpawnLocation") then
        print("[TeleportationManager] ✅ Found SpawnLocation in Workspace: " .. spawn:GetFullName())
        return spawn
    end
    
    -- Check inside LocationModel (new hierarchical structure)
    local locationModel = workspace:FindFirstChild("LocationModel")
    if locationModel then
        -- Validate it's the correct LocationModel
        local locationId = locationModel:GetAttribute("LocationId")
        local locationType = locationModel:GetAttribute("LocationType")
        
        if locationId and locationType then
            local gameplayFolder = locationModel:FindFirstChild("Gameplay")
            if gameplayFolder then
                spawn = gameplayFolder:FindFirstChild("SpawnLocation")
                if spawn then
                    print("[TeleportationManager] ✅ Found SpawnLocation in LocationModel/Gameplay: " .. spawn:GetFullName())
                    return spawn
                end
            end
        end
    end
    
    -- Fallback: Check inside old SpaceStation model for compatibility
    local spaceStation = workspace:FindFirstChild("SpaceStation")
    if spaceStation then
        spawn = spaceStation:FindFirstChild("SpawnLocation")
        if spawn then
            print("[TeleportationManager] ✅ Found SpawnLocation in SpaceStation (fallback): " .. spawn:GetFullName())
            return spawn
        end
    end
    
    -- Check all Location_* models
    for _, child in ipairs(workspace:GetChildren()) do
        if child.Name:match("^Location_") then
            spawn = child:FindFirstChild("SpawnLocation")
            if spawn then
                print("[TeleportationManager] ✅ Found SpawnLocation in " .. child.Name .. ": " .. spawn:GetFullName())
                return spawn
            end
        end
    end
    
    -- Fallback to original in ServerStorage (new hierarchical structure)
    local fallback = game.ServerStorage.Space.SpaceStation.Workspace.LocationModel.Gameplay:FindFirstChild("SpawnLocation")
    if not fallback then
        -- Final fallback to old structure
        fallback = game.ServerStorage.Space.SpaceStation.Workspace:FindFirstChild("SpawnLocation")
    end
    
    if fallback then
        print("[TeleportationManager] ⚠️ Using fallback SpawnLocation: " .. fallback:GetFullName())
        return fallback
    else
        warn("[TeleportationManager] ❌ No SpawnLocation found anywhere!")
        return nil
    end
end

-- State management
local isTeleportationActive = false
local hasBeenActivatedOnce = false  -- Track if teleportation was activated at least once
local pulseAnimation = nil
local playersOnSpawn = {}
local teleportCooldowns = {}
local touchDebounce = {}
local uiStateDebounce = {} -- Separate debounce for UI state changes
local teleportationInitialized = false
local spawnLocation = nil  -- Will be initialized dynamically
local pointLight = nil

-- RemoteEvents (module-level variables)
local teleportEvent
local teleportStateEvent

-- Initialize SpawnLocation reference (called after environment is loaded)
local function initializeSpawnLocation()
    spawnLocation = getCurrentSpawnLocation()
    if spawnLocation then
        pointLight = spawnLocation:FindFirstChild("PointLight")
        print("[TeleportationManager] ✅ SpawnLocation initialized: " .. spawnLocation:GetFullName())
        return true
    else
        warn("[TeleportationManager] ⚠️ Failed to initialize SpawnLocation")
        return false
    end
end

-- Update spawn location reference
local function updateSpawnLocation()
    local newSpawn = getCurrentSpawnLocation()
    print("[TeleportationManager] 🔍 Checking spawn location - current: " .. (spawnLocation and spawnLocation:GetFullName() or "nil") .. ", new: " .. newSpawn:GetFullName())
    
    if newSpawn ~= spawnLocation then
        print("[TeleportationManager] 🔄 SpawnLocation changing from: " .. (spawnLocation and spawnLocation:GetFullName() or "nil") .. " to: " .. newSpawn:GetFullName())
        spawnLocation = newSpawn
        pointLight = spawnLocation:FindFirstChild("PointLight")
        print("[TeleportationManager] ✅ SpawnLocation reference updated to: " .. spawnLocation:GetFullName())
        
        -- CRITICAL: Reconnect events to new spawn location
        if spawnLocation then
            -- Define local event handlers for this spawn location
            local function onSpawnTouched(otherPart)
                -- print("[TeleportationManager] 🔗 Touched event connected to: " .. spawnLocation:GetFullName())
                return TeleportationSystem.OnSpawnTouched(otherPart)
            end
            
            local function onSpawnTouchEnded(otherPart)
               -- print("[TeleportationManager] 🔗 TouchEnded event connected to: " .. spawnLocation:GetFullName())
                return TeleportationSystem.OnSpawnTouchEnded(otherPart)
            end
            
            spawnLocation.Touched:Connect(onSpawnTouched)
            spawnLocation.TouchEnded:Connect(onSpawnTouchEnded)
            print("[TeleportationManager] 🔗 Reconnected Touched/TouchEnded events to new SpawnLocation")
        else
            print("[TeleportationManager] ❌ ERROR: newSpawn is nil!")
        end
    else
        print("[TeleportationManager] ℹ️ SpawnLocation unchanged: " .. spawnLocation:GetFullName())
    end
end

-- Colors for different states
local INACTIVE_COLOR = Color3.new(0.3, 0.3, 0.3)  -- Gray
local ACTIVE_COLOR = Color3.new(0, 0.498, 1)       -- Blue
local HOVER_COLOR = Color3.new(0.2, 0.7, 1)       -- Light blue

-- Set inactive state
local function setInactiveState()
    isTeleportationActive = false
    
    -- Update spawn location reference
    updateSpawnLocation()
    
    -- Stop any running animations
    if pulseAnimation then
        pulseAnimation:Cancel()
        pulseAnimation = nil
    end
    
    -- Set gray color
    spawnLocation.Color = INACTIVE_COLOR
    
    -- CRITICAL: Keep SpawnLocation hidden until first activation (planet scan)
    if not hasBeenActivatedOnce then
        spawnLocation.Transparency = 1  -- Fully invisible until first scan
        spawnLocation.CanCollide = false
        print("[Teleport] 🔒 Телепортація прихована до першого сканування планети")
    else
        spawnLocation.Transparency = 0.3  -- Semi-visible when deactivated after use
        spawnLocation.CanCollide = true
        print("[Teleport] 🔴 Телепортація НЕАКТИВНА")
    end
    
    -- Set dim light
    if pointLight then
        pointLight.Color = INACTIVE_COLOR
        pointLight.Brightness = 0.2
        pointLight.Enabled = not hasBeenActivatedOnce  -- Only disable if never activated
    end
end

-- Set active state with pulsing
local function setActiveState()
    isTeleportationActive = true
    hasBeenActivatedOnce = true  -- Mark as activated at least once
    
    -- Update spawn location reference
    updateSpawnLocation()
    
    -- CRITICAL: Reconnect events to ensure they work with updated spawn location
    if spawnLocation then
        -- Define local event handlers for this spawn location
        local function onSpawnTouched(otherPart)
            return TeleportationSystem.OnSpawnTouched(otherPart)
        end
        
        local function onSpawnTouchEnded(otherPart)
            return TeleportationSystem.OnSpawnTouchEnded(otherPart)
        end
        
        spawnLocation.Touched:Connect(onSpawnTouched)
        spawnLocation.TouchEnded:Connect(onSpawnTouchEnded)
        print("[TeleportationManager] 🔗 Reconnected Touched/TouchEnded events during activation")
    end
    
    -- Reveal SpawnLocation on first activation
    spawnLocation.CanCollide = true
    
    -- Set blue color
    spawnLocation.Color = ACTIVE_COLOR
    spawnLocation.Transparency = 0
    
    -- Enable and configure light
    if pointLight then
        pointLight.Color = ACTIVE_COLOR
        pointLight.Brightness = 1.5
        pointLight.Enabled = true
        
        -- Create pulsing animation for light
        local pulseInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
        pulseAnimation = TweenService:Create(pointLight, pulseInfo, {
            Brightness = 3
        })
        pulseAnimation:Play()
    end
    
    -- Create pulsing animation for spawn location
    local spawnPulseInfo = TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    local spawnPulse = TweenService:Create(spawnLocation, spawnPulseInfo, {
        Transparency = 0.2
    })
    spawnPulse:Play()
    
    print("[Teleport] 🟢 Телепортація АКТИВНА")
end

-- Get discovered locations for player
local function getDiscoveredLocations(player)
    local discoveredLocations = {}
    
    -- Safe DataStoreManager access
    local playerData
    local success, result = pcall(function()
        return DataStoreManager.GetPlayerData(player)
    end)
    
    if success then
        playerData = result
    else
        warn("[TeleportationManager] ⚠️ Failed to get player data: " .. tostring(result))
        playerData = {
            DiscoveredLocations = {},
            Stats = {
                TotalTeleports = 0
            }
        }
    end
    
    if not playerData then
        return discoveredLocations
    end

    -- Get current planet configuration from ServerStorage
    local currentPlanet = PlanetConfigLoader.GetCurrentPlanetConfig()

    print(string.format("[TeleportationManager] 📡 Loading locations from planet: %s (%s)",
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

            if isDiscovered and location.TeleportTo then
                table.insert(discoveredLocations, {
                    PlanetId = currentPlanet.PLANET_ID,
                    LocationId = locationId,
                    DisplayName = location.DisplayName,
                    PlanetName = currentPlanet.DISPLAY_NAME,
                    SpawnPoint = location.SpawnPoint,
                    TeleportPoint = location.TeleportPoint or location.SpawnPoint
                })

                print(string.format("[TeleportationManager] ✅ Location added: %s (%s)",
                    location.DisplayName, locationId))
            end
        end
    end

    print(string.format("[TeleportationManager] 📊 Total discovered locations from %s: %d",
        currentPlanet.PLANET_ID or "Unknown", #discoveredLocations))

    return discoveredLocations
end

-- Switch location (Space Station ↔ Planet)
local function switchLocation(player, targetLocation)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return false, "Character not ready"
    end
    
    -- Check cooldown
    if teleportCooldowns[player.UserId] and teleportCooldowns[player.UserId] > tick() then
        return false, "Teleportation on cooldown"
    end
    
    -- Check if LocationManager is available
    if not LocationManager then
        warn("[TeleportationManager] LocationManager not available - cannot switch locations")
        return false, "Location system not ready"
    end
    
    local humanoidRootPart = player.Character.HumanoidRootPart
    local currentLocation = player:GetAttribute("CurrentLocation") or "SpaceStation"
    
    -- Create teleportation effect at current position using TeleportParticle
    local teleportEffect = Instance.new("Part")
    teleportEffect.Size = Vector3.new(8, 8, 8)
    teleportEffect.Material = Enum.Material.Neon
    teleportEffect.Color = Color3.new(0, 0.5, 1)
    teleportEffect.Anchored = true
    teleportEffect.CanCollide = false
    teleportEffect.Transparency = 0.3
    teleportEffect.CFrame = humanoidRootPart.CFrame
    teleportEffect.Parent = workspace
    
    -- Add TeleportParticle to the effect part
    local particle = getTeleportParticle()
    if particle then
        particle.Parent = teleportEffect
        particle.Enabled = true
    end
    
    -- Animate effect
    local expandTween = TweenService:Create(teleportEffect, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(20, 20, 20),
        Transparency = 1
    })
    expandTween:Play()
    
    -- Wait for animation
    task.wait(0.5)
    
    -- Switch location using LocationManager
    local success = false
    local targetCFrame
    
    if targetLocation.LocationId == "SpaceStation" then
        print("[Teleport] 🚀 Перехід на SpaceStation")
        print("[Teleport] Виклик LocationManager.SwitchToSpaceStation()...")
		success = LocationManager.SwitchToSpaceStation(targetLocation.PlanetId, targetLocation.LocationId)
        print("[TeleportationManager] 📊 SwitchToSpaceStation result: " .. tostring(success))
        if success then
            -- Wait for location to load and update spawn location reference
            print("[TeleportationManager] Waiting for location to load...")
            task.wait(0.5)
            print("[TeleportationManager] Updating spawn location reference...")
            updateSpawnLocation()
            if spawnLocation then
                targetCFrame = spawnLocation.CFrame * CFrame.new(0, 3, 0)
                print("[TeleportationManager] 📍 Target CFrame set for Space Station: " .. tostring(targetCFrame))
            else
                print("[TeleportationManager] ❌ ERROR: spawnLocation is nil after updateSpawnLocation()")
                return false, "SpawnLocation not found after location switch"
            end
        else
            print("[TeleportationManager] ❌ ERROR: SwitchToSpaceStation failed")
            return false, "Failed to switch to Space Station"
        end
    else
        print("[Teleport] 🪐 Перехід на планету:", targetLocation.PlanetId, "локація:", targetLocation.LocationId)
        print("[Teleport] Виклик LocationManager.SwitchToPlanetLocation()...")
        success = LocationManager.SwitchToPlanetLocation(targetLocation.PlanetId, targetLocation.LocationId)
        print("[TeleportationManager] 📊 SwitchToPlanetLocation result: " .. tostring(success))
        if success then
            -- Wait for location to load and update spawn location reference
            print("[TeleportationManager] Waiting for location to load...")
            task.wait(0.5)
            print("[TeleportationManager] Updating spawn location reference...")
            updateSpawnLocation()
            if spawnLocation then
                -- Debug: Print SpawnLocation details
                print("[TeleportationManager] 🔍 SpawnLocation found: " .. spawnLocation:GetFullName())
                print("[TeleportationManager] 🔍 SpawnLocation.CFrame: " .. tostring(spawnLocation.CFrame))
                print("[TeleportationManager] 🔍 SpawnLocation.Position: " .. tostring(spawnLocation.Position))

                -- CRITICAL FIX: Wait a frame to ensure SpawnLocation has updated position after being cloned
                task.wait()

                -- Re-check position after wait
                print("[TeleportationManager] 🔍 After wait - SpawnLocation.Position: " .. tostring(spawnLocation.Position))

                -- Verify the position is not at origin (0, 0, 0) which indicates a problem
                local spawnPos = spawnLocation.Position
                if spawnPos.X == 0 and spawnPos.Y == 0 and spawnPos.Z == 0 then
                    warn("[TeleportationManager] ⚠️ SpawnLocation is at origin! Trying to find LocationModel...")
                    -- Fallback: Use LocationModel position
                    local locationModel = workspace:FindFirstChild("LocationModel")
                    if locationModel then
                        local gameplay = locationModel:FindFirstChild("Gameplay")
                        if gameplay then
                            local spawnLoc = gameplay:FindFirstChild("SpawnLocation")
                            if spawnLoc then
                                spawnLocation = spawnLoc
                                print("[TeleportationManager] ✅ Found SpawnLocation via LocationModel: " .. tostring(spawnLocation.Position))
                            end
                        end
                    end
                end

                targetCFrame = spawnLocation.CFrame * CFrame.new(0, 5, 0)  -- Increased height from 3 to 5 for safety
                print("[TeleportationManager] 📍 Target CFrame calculated: " .. tostring(targetCFrame))
                print("[TeleportationManager] 📍 Target Position: " .. tostring(targetCFrame.Position))
            else
                print("[TeleportationManager] ❌ ERROR: spawnLocation is nil after updateSpawnLocation()")
                return false, "SpawnLocation not found after location switch"
            end
        else
            print("[TeleportationManager] ❌ ERROR: SwitchToPlanetLocation failed")
            return false, "Failed to switch to planet location"
        end
    end
    
    if not success or not targetCFrame then
        print("[TeleportationManager] ❌ ERROR: Failed to switch location or targetCFrame is nil")
        print("[TeleportationManager] success: " .. tostring(success) .. ", targetCFrame: " .. tostring(targetCFrame))
        return false, "Failed to switch location"
    end
    
    print("[TeleportationManager] 📍 Teleporting player to target position...")
    print("[TeleportationManager] Old position: " .. tostring(humanoidRootPart.CFrame))
    
    -- Teleport player to new location
    humanoidRootPart.CFrame = targetCFrame
    
    print("[TeleportationManager] New position: " .. tostring(humanoidRootPart.CFrame))

    -- Update player's current location using LocationManager (Single Source of Truth)
    local planetId = targetLocation.PlanetId or GameConfig.DEFAULT_PLANET
    LocationManager.SetPlayerLocation(player, planetId, targetLocation.LocationId)
    print("[TeleportationManager] ✅ Updated player location via LocationManager: " .. planetId .. "/" .. targetLocation.LocationId)
    
    -- Create arrival effect with TeleportParticle
    local arrivalEffect = Instance.new("Part")
    arrivalEffect.Size = Vector3.new(20, 20, 20)
    arrivalEffect.Material = Enum.Material.Neon
    arrivalEffect.Color = Color3.new(0, 0.5, 1)
    arrivalEffect.Anchored = true
    arrivalEffect.CanCollide = false
    arrivalEffect.Transparency = 1
    arrivalEffect.CFrame = targetCFrame
    arrivalEffect.Parent = workspace
    
    -- Add TeleportParticle to arrival effect
    local arrivalParticle = getTeleportParticle()
    if arrivalParticle then
        arrivalParticle.Parent = arrivalEffect
        arrivalParticle.Enabled = true
    end
    
    -- Animate arrival
    local shrinkTween = TweenService:Create(arrivalEffect, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = Vector3.new(1, 1, 1),
        Transparency = 0.5
    })
    shrinkTween:Play()
    
    -- Clean up effects
    DebrisService:AddItem(teleportEffect, 2)
    DebrisService:AddItem(arrivalEffect, 2)
    
    -- Set cooldown (3 seconds after successful teleport)
    teleportCooldowns[player.UserId] = tick() + 3.0
    
    -- Update player stats
    local playerData = DataStoreManager.GetPlayerData(player)
    local successUpdate, error = pcall(function()
        DataStoreManager.UpdatePlayerData(player, {
            TotalTeleports = (playerData and playerData.Stats and playerData.Stats.TotalTeleports or 0) + 1,
            LastTeleport = os.time()
        })
    end)
    
    if not successUpdate then
        warn("[Teleport] ⚠️ Не вдалося оновити статистику:", tostring(error))
    end
    
    print("[Teleport] ✅", player.Name, "телепортовано на", targetLocation.DisplayName)
    print("[Teleport] === SWITCH LOCATION END ===")
    return true, "Teleported successfully"
end

-- Handle player touching spawn location
local function onTouched(otherPart)
	-- print("[TeleportationManager] 👆 SpawnLocation Touched by: " .. (otherPart.Name))
	local character = otherPart.Parent
	if not character then 
		print("[TeleportationManager] ❌ No character parent")
		return 
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then 
		print("[TeleportationManager] ❌ No humanoid found in character")
		return 
	end

	local player = Players:GetPlayerFromCharacter(character)
	if not player then 
		print("[TeleportationManager] ❌ No player found from character")
		return 
	end

	-- print("[TeleportationManager] ✅ Player " .. player.Name .. " touched SpawnLocation at: " .. spawnLocation:GetFullName())

	-- Enhanced debounce to prevent rapid fire events
	if touchDebounce[player] then 
		--    print("[TeleportationManager] ⏱️ Touch debounce active for " .. player.Name)
		return 
	end
	touchDebounce[player] = true
	-- print("[TeleportationManager] ⏱️ Setting touch debounce for " .. player.Name)
	task.spawn(function()
		task.wait(0.5) -- Reduced debounce to 0.5 seconds
		touchDebounce[player] = nil
		--print("[TeleportationManager] ⏱️ Touch debounce cleared for " .. player.Name)
	end)

	-- Ensure player has CurrentLocation attribute
	if not player:GetAttribute("CurrentLocation") then
		-- Determine current location based on workspace
		local locationModel = workspace:FindFirstChild("LocationModel")
		if locationModel then
			local locationId = locationModel:GetAttribute("LocationId")
			if locationId then
				player:SetAttribute("CurrentLocation", locationId)
			end
		elseif workspace:FindFirstChild("SpaceStation") then
			-- Fallback for old structure
			player:SetAttribute("CurrentLocation", "SpaceStation")
		else
			-- Check for Location_* models
			for _, child in ipairs(workspace:GetChildren()) do
				if child.Name:match("^Location_") then
					player:SetAttribute("CurrentLocation", child.Name)
					break
				end
			end
		end
	end

	-- print("[TeleportationManager] 🔍 Checking playersOnSpawn for " .. player.Name .. ": " .. tostring(playersOnSpawn[player]))

	--if not playersOnSpawn[player] then
	if not playersOnSpawn[player] then
		playersOnSpawn[player] = true
		print("[TeleportationManager] " .. player.Name .. " entered SpawnLocation - first time")
	end        
	-- Only show UI if teleportation is active
	if isTeleportationActive then
		print("[TeleportationManager] ✅ Teleportation is active - showing UI for " .. player.Name)
		
		-- Check if player has TeleportationClient script
		local playerScripts = player:FindFirstChild("PlayerScripts")
		if playerScripts then
			local clientScript = playerScripts:FindFirstChild("TeleportationClient")
			if clientScript then
				print("[TeleportationManager] ✅ TeleportationClient found for " .. player.Name)
				print("[TeleportationManager] 📋 Script enabled: " .. tostring(clientScript.Enabled))
			else
				warn("[TeleportationManager] ❌ TeleportationClient NOT found for " .. player.Name)
				warn("  └─ Очікуваний шлях: Players/" .. player.Name .. "/PlayerScripts/TeleportationClient")
				warn("  └─ Скрипт має бути в StarterPlayerScripts/TeleportationClient.luau")
			end
		else
			--[[
			warn("[TeleportationManager] ❌ PlayerScripts NOT found for " .. player.Name)
			warn("  └─ Очікуваний шлях: Players/" .. player.Name .. "/PlayerScripts")
			warn("  └─ Гравець можливо ще не повністю завантажився")
			]]
		end

		-- UI state debounce to prevent flickering
		-- print("[TeleportationManager] 🔍 Checking uiStateDebounce for " .. player.Name .. ": " .. tostring(uiStateDebounce[player]))
		if uiStateDebounce[player] then 
			print("[TeleportationManager] ⏱️ UI debounce active for " .. player.Name)
			return 
		end
		uiStateDebounce[player] = true
		-- print("[TeleportationManager] ⏱️ Setting UI debounce for " .. player.Name)
		task.spawn(function()
			task.wait(0.3)
			uiStateDebounce[player] = nil
			print("[TeleportationManager] ⏱️ UI debounce cleared for " .. player.Name)
		end)

		local currentLocation = player:GetAttribute("CurrentLocation") or "SpaceStation"

		-- Always include Space Station as return option if not current location
		local availableLocations = {}

		-- Always include Space Station if player is not there (CRITICAL FIX)
		if currentLocation ~= "SpaceStation" then
			print("[TeleportationManager] 🚀 Adding Space Station to available locations")
			table.insert(availableLocations, {
				PlanetId = "SpaceStation",
				LocationId = "SpaceStation",
				DisplayName = "🚀 Космічна Станція",
				PlanetName = "Space",
				SpawnPoint = spawnLocation.CFrame,
				TeleportPoint = spawnLocation.CFrame
			})
		else
			print("[TeleportationManager] ℹ️ Player is on Space Station - not adding to available locations")
		end

		-- Add discovered planet locations
		local discoveredLocations = getDiscoveredLocations(player)
		print("[TeleportationManager] 📋 Discovered locations count: " .. #discoveredLocations)
		for _, location in ipairs(discoveredLocations) do
			print("[TeleportationManager] 📋 Checking location: " .. location.DisplayName .. " (" .. location.LocationId .. ")")
			
			-- CRITICAL FIX: Check if location template exists in ServerStorage
			local planetsFolder = game.ServerStorage:FindFirstChild("Planets")
			local planetId = location.PlanetId or GameConfig.DEFAULT_PLANET
			local locationTemplate = planetsFolder and planetsFolder:FindFirstChild(planetId)
			if locationTemplate then
				local locationFolder = locationTemplate:FindFirstChild("Locations")
				if locationFolder then
					local locationModel = locationFolder:FindFirstChild(location.LocationId)
					if locationModel then
						print("[TeleportationManager] ✅ Location template found: " .. location.LocationId)
						
						-- Filter out current location to prevent teleporting to same place
						if location.LocationId ~= currentLocation then
							table.insert(availableLocations, location)
							print("[TeleportationManager] ✅ Added to available locations: " .. location.DisplayName)
						else
							print("[TeleportationManager] ℹ️ Skipping current location: " .. location.DisplayName)
						end
					else
						warn("[TeleportationManager] ❌ Location template NOT found: " .. location.LocationId)
						warn("  └─ Очікуваний шлях: ServerStorage/Planets/" .. tostring(planetId) .. "/Locations/" .. location.LocationId)
						warn("  └─ Телепортацію заблоковано")
					end
				else
					warn("[TeleportationManager] ❌ Locations folder not found")
					warn("  └─ Очікуваний шлях: ServerStorage/Planets/" .. tostring(planetId) .. "/Locations")
				end
			else
				warn("[TeleportationManager] ❌ Planet template not found: " .. tostring(planetId))
				warn("  └─ Очікуваний шлях: ServerStorage/Planets/" .. tostring(planetId))
			end
		end

		if #availableLocations > 0 then
			-- Send locations to client for UI display
			print("[TeleportationManager] 📡 Sending ShowTeleportUI to " .. player.Name .. " with " .. #availableLocations .. " locations")
			if teleportEvent then
				print("[TeleportationManager] 📡 PREPARING TO SEND EVENT TO " .. player.Name)
				print("[TeleportationManager] 📡 Available locations: " .. #availableLocations)
				for i, loc in ipairs(availableLocations) do
					print("[TeleportationManager] 📡   - " .. loc.DisplayName .. " (" .. loc.LocationId .. ")")
				end
				
				local eventData = {
					locations = availableLocations,
					player = player.Name
				}
				
				print("[TeleportationManager] 📡 EVENT DATA PREPARED: " .. tostring(eventData))
				
				local success = pcall(function()
					teleportEvent:FireClient(player, "ShowTeleportUI", eventData)
				end)
				

			else
				print("[TeleportationManager] ❌ ERROR: teleportEvent is nil!")
			end
		else
			-- Fallback: Always show Space Station as option
			local fallbackLocations = {{
				PlanetId = "SpaceStation",
				LocationId = "SpaceStation",
				DisplayName = "🚀 Космічна Станція",
				PlanetName = "Space",
				SpawnPoint = spawnLocation.CFrame,
				TeleportPoint = spawnLocation.CFrame
			}}

			if teleportEvent then
				teleportEvent:FireClient(player, "ShowTeleportUI", {
					locations = fallbackLocations,
					player = player.Name
				})
			end
		end

		local hoverTween = TweenService:Create(spawnLocation, TweenInfo.new(0.3), {
			Color = HOVER_COLOR
		})
		hoverTween:Play()
	end

end

local function onTouchEnded(otherPart)
    local character = otherPart.Parent
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    local player = Players:GetPlayerFromCharacter(character)
    if not player then return end
    
    -- Enhanced debounce to prevent rapid fire events
    if touchDebounce[player] then return end
    touchDebounce[player] = true
    task.spawn(function()
        task.wait(1.0) -- Increased debounce to 1 second
        touchDebounce[player] = nil
    end)
    
    -- CRITICAL FIX: Use proper spatial detection instead of distance check
    -- Check if player is actually still on the spawn location platform
    if playersOnSpawn[player] then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            -- Get spawn location boundaries
            local spawnSize = spawnLocation.Size
            local spawnPos = spawnLocation.Position
            local playerPos = humanoidRootPart.Position
            
            -- Check if player is within the bounds of the spawn location
            local halfWidth = spawnSize.X / 2
            local halfLength = spawnSize.Z / 2
            local heightThreshold = spawnSize.Y / 2 + 5 -- Allow 5 studs above platform
            
            local isWithinBounds = 
                math.abs(playerPos.X - spawnPos.X) <= halfWidth and
                math.abs(playerPos.Z - spawnPos.Z) <= halfLength and
                playerPos.Y >= spawnPos.Y - heightThreshold and
                playerPos.Y <= spawnPos.Y + heightThreshold
            
            -- Only consider player left if they're outside the platform bounds
            if not isWithinBounds then
                playersOnSpawn[player] = nil
                print("[TeleportationManager] " .. player.Name .. " left SpawnLocation (outside platform bounds)")
                
                -- Always hide UI when player leaves SpawnLocation
                if teleportEvent then
                    teleportEvent:FireClient(player, "HideTeleportUI")
                end
                
                -- Clear UI state debounce when player leaves
                uiStateDebounce[player] = nil
                
                -- Restore original color if teleportation is active
                if isTeleportationActive then
                    local restoreTween = TweenService:Create(spawnLocation, TweenInfo.new(0.3), {
                        Color = ACTIVE_COLOR
                    })
                    restoreTween:Play()
                end
            end
        end
    end
end

-- Handle teleportation requests from client
local function onTeleportRequest(player, action, data)
    -- Handle PING/PONG for connection testing
    if action == "PONG" then
        print("[TeleportationManager] 🏓 PONG received from " .. player.Name)
        print("[TeleportationManager] 🏓 Original timestamp: " .. tostring(data.originalTimestamp))
        print("[TeleportationManager] 🏓 Response time: " .. tostring(data.timestamp))
        print("[TeleportationManager] 🏓 Round-trip time: " .. tostring(data.timestamp - data.originalTimestamp) .. " seconds")
        return
    end
    
    -- Handle regular teleportation requests
    local locationId = action
    print("[TeleportationManager] 🚀 onTeleportRequest CALLED ===")
    print("[TeleportationManager] 📡 RAW locationId received: " .. tostring(locationId))
    print("[TeleportationManager] 👤 Player: " .. player.Name)
    print("[TeleportationManager] 🚀 TELEPORT REQUEST START ===")
    print("[TeleportationManager] " .. player.Name .. " requested teleport to " .. tostring(locationId))
    
    local currentLocation = player:GetAttribute("CurrentLocation") or "SpaceStation"
    print("[TeleportationManager] Player current location: " .. currentLocation)
    
    -- Prevent teleporting to the same location
    if locationId == currentLocation then
        print("[TeleportationManager] ❌ ERROR: Player trying to teleport to same location")
        teleportEvent:FireClient(player, "TeleportError", "Ви вже знаходитесь на цій локації")
        return
    end
    
    local discoveredLocations = getDiscoveredLocations(player)
    print("[TeleportationManager] Discovered locations count: " .. #discoveredLocations)
    for _, loc in ipairs(discoveredLocations) do
        print("[TeleportationManager]   - " .. loc.DisplayName .. " (" .. loc.LocationId .. ")")
    end
    
    -- Always include Space Station as return option if not current location
    local availableLocations = {}
    
    -- Add Space Station if player is not there
    if currentLocation ~= "SpaceStation" then
        print("[TeleportationManager] Adding SpaceStation to available locations")
        table.insert(availableLocations, {
            PlanetId = "SpaceStation",
            LocationId = "SpaceStation",
            DisplayName = "🚀 Космічна Станція",
            PlanetName = "Space",
            SpawnPoint = spawnLocation.CFrame,
            TeleportPoint = spawnLocation.CFrame
        })
    end
    
    -- Add discovered planet locations (filter out current location)
    for _, location in ipairs(discoveredLocations) do
        print("[TeleportationManager] 📋 Checking location for teleport: " .. location.DisplayName .. " (" .. location.LocationId .. ")")
        
        -- CRITICAL FIX: Check if location template exists in ServerStorage
        local planetsFolder = game.ServerStorage:FindFirstChild("Planets")
        local planetId = location.PlanetId or GameConfig.DEFAULT_PLANET
        local locationTemplate = planetsFolder and planetsFolder:FindFirstChild(planetId)
        if locationTemplate then
            local locationFolder = locationTemplate:FindFirstChild("Locations")
            if locationFolder then
                local locationModel = locationFolder:FindFirstChild(location.LocationId)
                if locationModel then
                    print("[TeleportationManager] ✅ Location template found: " .. location.LocationId)
                    
                    if location.LocationId ~= currentLocation then
                        print("[TeleportationManager] Adding planet location: " .. location.DisplayName)
                        table.insert(availableLocations, location)
                    else
                        print("[TeleportationManager] ℹ️ Skipping current location: " .. location.DisplayName)
                    end
                else
                    warn("[TeleportationManager] ❌ Location template NOT found: " .. location.LocationId)
                    warn("  └─ Очікуваний шлях: ServerStorage/Planets/" .. tostring(planetId) .. "/Locations/" .. location.LocationId)
                    warn("  └─ Телепортацію заблоковано")
                end
            else
                warn("[TeleportationManager] ❌ Locations folder not found")
                warn("  └─ Очікуваний шлях: ServerStorage/Planets/" .. tostring(planetId) .. "/Locations")
            end
        else
            warn("[TeleportationManager] ❌ Planet template not found: " .. tostring(planetId))
            warn("  └─ Очікуваний шлях: ServerStorage/Planets/" .. tostring(planetId))
        end
    end
    
    print("[TeleportationManager] Available locations count: " .. #availableLocations)
    for _, loc in ipairs(availableLocations) do
        print("[TeleportationManager]   - " .. loc.DisplayName .. " (" .. loc.LocationId .. ")")
    end
    
    local targetLocation = nil
    
    for _, location in ipairs(availableLocations) do
        if location.LocationId == locationId then
            targetLocation = location
            break
        end
    end
    
    if not targetLocation then
        warn("[TeleportationManager] ❌ Target location not found: " .. locationId)
        warn("  └─ Локація не в списку доступних (не відкрита або не існує)")
        warn("  └─ Доступні локації: " .. #availableLocations)
        teleportEvent:FireClient(player, "TeleportError", "Локація не знайдена або не відкрита")
        return
    end
    
    print("[TeleportationManager] ✅ Target location found: " .. targetLocation.DisplayName)
    print("[TeleportationManager] 🔄 Calling switchLocation...")
    
    local success, message = switchLocation(player, targetLocation)
    print("[TeleportationManager] 📊 switchLocation result: " .. tostring(success) .. ", message: " .. tostring(message))
    
    if success then
        print("[TeleportationManager] ✅ Teleportation successful, notifying client")
        teleportEvent:FireClient(player, "TeleportSuccess", message)
    else
        print("[TeleportationManager] ❌ Teleportation failed, notifying client: " .. tostring(message))
        teleportEvent:FireClient(player, "TeleportError", message)
    end
    
    print("[TeleportationManager] === TELEPORT REQUEST END ===")
end

-- Handle teleportation activation from scanner
local function onTeleportationActivation(player, isActive)
    print("[Teleport] 🔄 Телепортацію", (isActive and "АКТИВОВАНО" or "ДЕАКТИВОВАНО"), ":", player.Name)
    
    if isActive then
        setActiveState()
        print("[TeleportationManager] ✅ SpawnLocation should now be BLUE and PULSING")
    else
        setInactiveState()
        print("[TeleportationManager] ✅ SpawnLocation should now be GRAY")
    end
    
    -- Notify all players of the state change
    for _, p in ipairs(Players:GetPlayers()) do
        if teleportStateEvent then
            teleportStateEvent:FireClient(p, isActive)
            print("[TeleportationManager] 📡 Sent state change to " .. p.Name .. ": " .. tostring(isActive))
        end
    end
end

-- Public API
function TeleportationSystem.Initialize()
    print("[TeleportationManager] 🚀 Initializing Teleportation System...")
    print("[TeleportationManager] 📋 Initial workspace state:")
    for _, child in ipairs(workspace:GetChildren()) do
        if child.Name:match("^Location_") or child.Name == "SpaceStation" then
            print("[TeleportationManager]   - " .. child.Name .. " (has SpawnLocation: " .. tostring(child:FindFirstChild("SpawnLocation") ~= nil) .. ")")
        end
    end
    
    -- Initialize spawn location reference
    initializeSpawnLocation()
    
    -- Get RemoteEvents from registry (created by GameInit)
    print("[TeleportationManager] Отримання RemoteEvents з реєстру...")
    teleportEvent = RemoteEventsRegistry.Get("TeleportationEvent")
    teleportStateEvent = RemoteEventsRegistry.Get("TeleportationStateEvent")
    
    if not teleportEvent or not teleportStateEvent then
        error("[TeleportationManager] ❌ RemoteEvents не ініціалізовані! Переконайтеся що GameInit.Initialize() викликано перед TeleportationManager.Initialize()")
    end
    
    print("[TeleportationManager] ✅ RemoteEvents отримано з реєстру")
    print("[TeleportationManager]   - TeleportationEvent: " .. tostring(teleportEvent ~= nil))
    print("[TeleportationManager]   - TeleportationStateEvent: " .. tostring(teleportStateEvent ~= nil))
    
    -- Connect events with spawn location update
    workspace.DescendantAdded:Connect(function(descendant)
        if descendant.Name == "SpawnLocation" then
            task.wait(0.2) -- Wait for spawn to be ready
            updateSpawnLocation()
        end
    end)
    
    -- Also monitor for location changes
    workspace.ChildAdded:Connect(function(child)
        if child.Name:match("^Location_") or child.Name == "SpaceStation" then
            -- Wait a bit for the model to fully load
            task.wait(0.5)
            updateSpawnLocation()
        end
    end)
    
    -- Also monitor for location removal
    workspace.ChildRemoved:Connect(function(child)
        if child.Name:match("^Location_") or child.Name == "SpaceStation" then
            task.wait(0.2)
            updateSpawnLocation()
        end
    end)
    
    -- Connect initial events
    if spawnLocation then
        spawnLocation.Touched:Connect(function(otherPart)
            return TeleportationSystem.OnSpawnTouched(otherPart)
        end)
        spawnLocation.TouchEnded:Connect(function(otherPart)
            return TeleportationSystem.OnSpawnTouchEnded(otherPart)
        end)
        print("[TeleportationManager] Connected initial events to SpawnLocation: " .. spawnLocation:GetFullName())
    end
    if teleportEvent then
        teleportEvent.OnServerEvent:Connect(onTeleportRequest)
        print("[TeleportationManager] ✅ RemoteEvent OnServerEvent CONNECTED to onTeleportRequest")
    else
        warn("[TeleportationManager] ❌ ERROR: teleportEvent is nil - cannot connect OnServerEvent!")
    end
    
    -- Initialize in inactive state
    setInactiveState()
    
    print("[Teleport] ✅ Систему телепортації ініціалізовано")
end

function TeleportationSystem.Activate(player, isActive)
    onTeleportationActivation(player, isActive)
end

function TeleportationSystem.GetDiscoveredLocations(player)
    return getDiscoveredLocations(player)
end

function TeleportationSystem.SwitchLocation(player, targetLocation)
    return switchLocation(player, targetLocation)
end

function TeleportationSystem.IsActive()
    return isTeleportationActive
end

-- Public event handlers for dynamic connection
function TeleportationSystem.OnSpawnTouched(otherPart)
    return onTouched(otherPart)
end

function TeleportationSystem.OnSpawnTouchEnded(otherPart)
    return onTouchEnded(otherPart)
end

function TeleportationSystem.GetState()
    local state = {
        isActive = isTeleportationActive,
        currentLocation = spawnLocation and spawnLocation:GetFullName() or "Unknown",
        teleportationInitialized = teleportationInitialized or false,
        workspaceChildren = {}
    }
    
    -- Log current workspace state for debugging
    for _, child in ipairs(workspace:GetChildren()) do
        if child.Name:match("^Location_") or child.Name == "SpaceStation" then
            local spawn = child:FindFirstChild("SpawnLocation")
            table.insert(state.workspaceChildren, {
                name = child.Name,
                hasSpawnLocation = spawn ~= nil,
                spawnPath = spawn and spawn:GetFullName() or "None"
            })
        end
    end
    
    return state
end

return TeleportationSystem
