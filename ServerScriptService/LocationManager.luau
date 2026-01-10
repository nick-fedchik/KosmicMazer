--[[
================================================================================
KOSMICMAZER — Location Manager (Module)
================================================================================

Purpose: Manages location switching and workspace organization with FSM
Version: 3.2

Features:
- Finite State Machine (FSM) for predictable location transitions
- Handles location transitions (Space Station ↔ Planet Locations)
- Manages workspace cleanup and loading
- Controls environment switching (Sky, Atmosphere, CloudLayers)
- Integrates with teleportation system
- Prevents concurrent transitions
- LocationModel hierarchical structure support

API:
- Initialize(): Initializes the location manager
- SwitchToSpaceStation(): Switches to Space Station location
- SwitchToPlanetLocation(planetId, locationId): Switches to specific planet location
- GetCurrentLocation(): Returns current location name
- GetState(): Returns current FSM state
- IsTransitioning(): Returns true if currently transitioning
- CleanupWorkspace(): Cleans up all location objects

Calls to:
- GameConfig: Reads planet and location configuration
- GameConfig.PlanetHelpers: GetLocation() helper function
- TweenService: Creates transition animations
- DebrisService: Manages object cleanup

Called from:
- GameInit (for initial setup via Initialize())
- TeleportationManager (for location switching via SwitchToSpaceStation/SwitchToPlanetLocation)

Dependencies:
- GameConfig module
- Workspace service
- ServerStorage service
- TweenService
- DebrisService

ChangeLog:
- Version 3.2: GAME RULES FIX - Hide SpawnLocation until first planet scan (2026-01-08)
- Version 3.2: SpawnLocation now starts fully invisible (Transparency=1, no collision, light off)
- Version 3.2: Will be revealed by TeleportationManager after PlanetSurfaceScanner scan
- Version 3.1: Removed PrimaryPart validation warning for static LocationModel (2026-01-08)
- Version 3.1: PrimaryPart not required for non-dynamic location containers
- Version 3.1: Updated for LocationModel hierarchical structure (ETAP 2)
- Version 3.1: clearWorkspaceLocations() now removes LocationModel objects
- Version 3.1: loadSpaceStation() updated to work with LocationModel attributes
- Version 3.1: Added LocationModel positioning and validation through attributes
- Version 3.0: MAJOR - Added FSM (Finite State Machine) for location transitions with state tracking, timeouts, model validation, and fallback
- Version 2.3: Added LoadOrder configuration support for custom loading sequences
- Version 2.2: FIXED - Updated Called from references to reflect TeleportationManager usage
- Version 2.1: CRITICAL - Fixed ModuleScript creation and loading issues
- Version 2.0: CRITICAL - Converted from Script to ModuleScript for better modularity and initialization control
- Version 2.0: ENHANCED - Added Initialize() method for explicit initialization
- Version 2.0: FIXED - Removed automatic initialization to prevent race conditions
- Version 1.1: Updated header format to comply with CODE CONVENTION section 14
- Version 1.0: Initial implementation for location management
- Added comprehensive workspace cleanup
- Integrated with GameConfig structure
- Added transition state management
- Fixed syntax error: Added missing 'end' for loadPlanet() function block
- Improved error handling and function structure

================================================================================
]]

local Workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local DebrisService = game:GetService("Debris")

-- Load dependencies
local GameConfig = require(game.ServerScriptService.GameConfig)

-- FSM States
local LocationState = {
	IDLE = "Idle",
	CLEANING = "Cleaning",
	VALIDATING = "Validating",
	LOADING_PLANET = "LoadingPlanet",
	LOADING_LOCATION = "LoadingLocation",
	VERIFYING = "Verifying",
	READY = "Ready",
	ERROR = "Error",
}

-- FSM Configuration
local STATE_TIMEOUT = {
	[LocationState.CLEANING] = 10,
	[LocationState.VALIDATING] = 5,
	[LocationState.LOADING_PLANET] = 30,
	[LocationState.LOADING_LOCATION] = 30,
	[LocationState.VERIFYING] = 10,
}

-- State management
local currentState = LocationState.IDLE
local currentLocation = "Dark Space"
local isTransitioning = false
local stateStartTime = 0

-- Active location modules
local currentLocationGameServer = nil
local currentPlanetConfig = nil

-- State transition function
local function transitionTo(newState, context)
	local oldState = currentState
	currentState = newState
	stateStartTime = tick()
	
	local contextStr = context and (" (" .. context .. ")") or ""
	print(string.format("[LocationFSM] %s → %s%s", oldState, newState, contextStr))
end

-- Check state timeout
local function checkStateTimeout()
	local timeout = STATE_TIMEOUT[currentState]
	if not timeout then return false end
	
	local elapsed = tick() - stateStartTime
	if elapsed > timeout then
		warn(string.format("[LocationFSM] ⚠️ Перевищено таймаут стану %s (%.1fs)", currentState, timeout))
		return true
	end
	return false
end

-- Validate model exists in ServerStorage
local function validateModel(path)
	local parts = {}
	for part in string.gmatch(path, "[^/]+") do
		table.insert(parts, part)
	end
	
	local current = ServerStorage
	for i, partName in ipairs(parts) do
		local child = current:FindFirstChild(partName)
		if not child then
			warn(string.format("[LocationFSM] ❌ Не знайдено модель: %s (відсутня: %s)", path, partName))
			return false
		end
		current = child
	end
	
	print(string.format("[LocationFSM] ✅ Перевірено модель: %s", path))
	return true
end

-- Helper function to get current planet based on loaded location
local function getCurrentPlanet()
	-- For now, default to Planet_1
	-- In future, this could be determined by player data or current location
	return "Planet_1"
end

-- Helper function to clean workspace
local function cleanupWorkspace()
	transitionTo(LocationState.CLEANING, "Clearing workspace")
	print("[Location] 🧹 Очищення, об'єктів:", #Workspace:GetChildren())
	
	-- Check timeout
	if checkStateTimeout() then
		transitionTo(LocationState.ERROR, "Cleanup timeout")
		return false
	end
	
	-- Cleanup current location game server before clearing workspace
	if currentLocationGameServer and currentLocationGameServer.Cleanup then
		local success = pcall(function()
			currentLocationGameServer.Cleanup()
		end)
		if not success then
			warn("[Location] ⚠️ Помилка при Cleanup LocationGameServer")
		end
		currentLocationGameServer = nil
	end
	
	-- Clear planet config
	currentPlanetConfig = nil

	local lighting = game:GetService("Lighting")
	print("[Location] 💡 Об'єктів освітлення:", #lighting:GetChildren())

	-- Remove all children except essential ones
	local essentialObjects = {
		"ClockTime",
		"GeographicLatitude", 
		"TimeOfDay",
		"Brightness",
		"ColorShift_Bottom",
		"ColorShift_Top",
		"EnvironmentDiffuseScale",
		"EnvironmentSpecularScale",
		"GlobalShadows",
		"OutdoorAmbient",
		"ShadowColor",
		"ShadowSoftness"
	}

	for _, child in ipairs(lighting:GetChildren()) do
		local isEssential = false
		for _, essentialName in ipairs(essentialObjects) do
			if child.Name == essentialName then
				isEssential = true
				break
			end
		end

		if not isEssential then
			child:Destroy()
			print("[Location] 🗑️ Видалено освітлення:", child.Name)
		end
	end

	-- Clean up any location objects that might be in workspace
	for _, child in ipairs(Workspace:GetChildren()) do
		if child.Name:match("^Location_") then
			child:Destroy()
			print("[Location] 🗑️ Видалено локацію:", child.Name)
		end
		if child.Name == "Planet" then
			child:Destroy()
			print("[Location] 🗑️ Видалено планету:", child.Name)
		end
		-- Clear LocationModel (new hierarchical structure)
		if child.Name == "LocationModel" then
			child:Destroy()
			print("[Location] 🗑️ Видалено LocationModel")
		end
		-- Clear old SpaceStation models (fallback compatibility)
		if child.Name == "SpaceStation" then
			child:Destroy()
			print("[Location] 🗑️ Видалено SpaceStation")
		end
	end

	print("[Location] ✅ Очищення завершено")
	return true
end

-- Load Space Station using new EnvironmentLoader
local function loadSpaceStation()
	print("[Location] 🚀 Loading Space Station using EnvironmentLoader")
	
	-- Load EnvironmentLoader module
	local EnvironmentLoader = require(script.Parent:FindFirstChild("EnvironmentLoader"))
	
	-- Try to load LoadOrder configuration
	local loadOrder = nil
	local spaceStationConfig = ServerStorage:FindFirstChild("Space")
	if spaceStationConfig then
		spaceStationConfig = spaceStationConfig:FindFirstChild("SpaceStation")
	end
	if spaceStationConfig then
		spaceStationConfig = spaceStationConfig:FindFirstChild("Configuration")
	end
	if spaceStationConfig then
		local loadOrderModule = spaceStationConfig:FindFirstChild("LoadOrder")
		if loadOrderModule then
			loadOrder = require(loadOrderModule)
			print("[Location] 📋 LoadOrder configuration loaded for SpaceStation")
		end
	end
	
	-- Use EnvironmentLoader to load space environment with optional load order
	local success = EnvironmentLoader.LoadSpaceEnvironment(getCurrentPlanet(), loadOrder)
	
	if success then
		-- Position LocationModel (this will move all children including SpawnLocation)
		local locationModel = Workspace:FindFirstChild("LocationModel")
		
		if locationModel then
			-- Validate LocationModel attributes
			local locationId = locationModel:GetAttribute("LocationId")
			local locationType = locationModel:GetAttribute("LocationType")
			
			if locationId == "SpaceStation" and locationType == "Space" then
				local primaryPart = locationModel.PrimaryPart
				if primaryPart then
					-- Position station at Y=-450
					locationModel:PivotTo(CFrame.new(0, -450, 0))
					print("[Location] ✅ LocationModel позиціоновано at Y=-450")
					print(string.format("  └─ LocationModel.PrimaryPart: %s", tostring(locationModel.PrimaryPart.Position)))
					
					-- Check SpawnLocation inside LocationModel/Gameplay
					local gameplayFolder = locationModel:FindFirstChild("Gameplay")
					local spawnLocation = gameplayFolder and gameplayFolder:FindFirstChild("SpawnLocation")
					if spawnLocation then
						print(string.format("  └─ SpawnLocation (inside LocationModel/Gameplay): %s", tostring(spawnLocation.Position)))
						
						-- CRITICAL: Hide SpawnLocation until first planet scan
						-- It will be revealed/activated by TeleportationManager after PlanetSurfaceScanner scan
						spawnLocation.Transparency = 1 -- Fully invisible
						spawnLocation.CanCollide = false -- No collision until activated
						local pointLight = spawnLocation:FindFirstChild("PointLight")
						if pointLight then
							pointLight.Enabled = false -- No light until activated
						end
						print("[Location] 🔒 SpawnLocation приховано до першого сканування планети")
					else
						warn("[Location] ⚠️ SpawnLocation не знайдено в LocationModel/Gameplay")
					end
					
					-- Check for equipment and other sections
					for _, section in ipairs(locationModel:GetChildren()) do
						if section:IsA("Folder") then
							local itemCount = #section:GetChildren()
							print(string.format("  └─ Section %s: %d items", section.Name, itemCount))
						end
					end

					-- Log PlanetSurfaceScanner position for diagnostics
					local equipmentFolder = locationModel:FindFirstChild("Equipment")
					if equipmentFolder then
						local scannerModel = equipmentFolder:FindFirstChild("PlanetSurfaceScanner")
						if scannerModel then
							print(string.format("  └─ PlanetSurfaceScanner (inside SpaceStation): %s", tostring(scannerModel:GetPivot().Position)))
						else
							warn("[Location] ⚠️ PlanetSurfaceScanner не знайдено всередині SpaceStation")
						end
					else
						warn("[Location] ⚠️ Equipment секцію не знайдено в SpaceStation LocationModel")
					end
				end
				-- PrimaryPart не обов'язковий для статичних LocationModel
			else
				warn("[Location] ⚠️ LocationModel має невірні attributes")
				warn("  └─ LocationId:", tostring(locationId), "(expected: SpaceStation)")
				warn("  └─ LocationType:", tostring(locationType), "(expected: Space)")
			end
		else
			warn("[Location] ⚠️ SpaceStation не знайдено в Workspace")
		end
		
		-- ServerScripts (including PlanetSurfaceScanner) are now loaded via EnvironmentLoader with LoadOrder
		
		print("[Location] ✅ Космічну станцію завантажено")
		return true
	else
		warn("[Location] ❌ Не вдалося завантажити Space Environment")
		return false
	end
end

-- Load Planet (now handled by EnvironmentLoader)
local function loadPlanet(planetId)
	print("[Location] 🪐 Planet loading now handled by EnvironmentLoader")
	-- This function is deprecated - planet loading is now part of EnvironmentLoader.LoadSpaceEnvironment()
	return true
end

-- Load specific location on planet using EnvironmentLoader
local function loadLocation(planetId, locationId)
	print("[Location] 📍 Loading planet location using EnvironmentLoader:", locationId, "на", planetId)
	
	-- Load EnvironmentLoader module
	local EnvironmentLoader = require(script.Parent:FindFirstChild("EnvironmentLoader"))
	
	-- Try to load LoadOrder configuration for this location
	local loadOrder = nil
	local locationConfig = ServerStorage:FindFirstChild("Planets")
	if locationConfig then
		locationConfig = locationConfig:FindFirstChild(planetId)
	end
	if locationConfig then
		locationConfig = locationConfig:FindFirstChild("Locations")
	end
	if locationConfig then
		locationConfig = locationConfig:FindFirstChild(locationId)
	end
	if locationConfig then
		locationConfig = locationConfig:FindFirstChild("Configuration")
	end
	if locationConfig then
		local loadOrderModule = locationConfig:FindFirstChild("LoadOrder")
		if loadOrderModule then
			loadOrder = require(loadOrderModule)
			print("[Location] 📋 LoadOrder configuration loaded for", locationId)
		end
	end
	
	-- Use EnvironmentLoader to load planet environment with optional load order
	local success = EnvironmentLoader.LoadPlanetEnvironment(planetId, locationId, loadOrder)
	
	if success then
		print("[Location] ✅ Локацію", locationId, "завантажено")
		
		-- Load PlanetConfig for this planet
		local planetConfigSuccess = pcall(function()
			local planetFolder = ServerStorage:WaitForChild("Planets"):WaitForChild(planetId)
			local configFolder = planetFolder:FindFirstChild("Configuration")
			if configFolder then
				local planetConfigModule = configFolder:FindFirstChild("PlanetConfig")
				if planetConfigModule and planetConfigModule:IsA("ModuleScript") then
					currentPlanetConfig = require(planetConfigModule)
					print("[Location] ✅ PlanetConfig завантажено для", planetId)
				end
			end
		end)
		
		if not planetConfigSuccess then
			warn("[Location] ⚠️ Не вдалося завантажити PlanetConfig для", planetId)
		end
		
		-- Load LocationGameServer for this location
		local locationServerSuccess = pcall(function()
			local planetFolder = ServerStorage:WaitForChild("Planets"):WaitForChild(planetId)
			local locationsFolder = planetFolder:WaitForChild("Locations")
			local locationFolder = locationsFolder:WaitForChild(locationId)
			local scriptsFolder = locationFolder:FindFirstChild("Scripts")
			if scriptsFolder then
				local serverFolder = scriptsFolder:FindFirstChild("Server")
				if serverFolder then
					local locationServerModule = serverFolder:FindFirstChild("LocationGameServer")
					if locationServerModule and locationServerModule:IsA("ModuleScript") then
						-- Cleanup previous location game server
						if currentLocationGameServer and currentLocationGameServer.Cleanup then
							currentLocationGameServer.Cleanup()
						end
						
						currentLocationGameServer = require(locationServerModule)
						
						-- Initialize with location model from Workspace
						local locationModel = Workspace:FindFirstChild("LocationModel")
						if locationModel then
							currentLocationGameServer.Initialize(locationModel)
							print("[Location] ✅ LocationGameServer ініціалізовано для", locationId)
						else
							warn("[Location] ⚠️ Location model not found in Workspace:", locationId)
						end
					end
				end
			end
		end)
		
		if not locationServerSuccess then
			warn("[Location] ⚠️ Не вдалося завантажити LocationGameServer для", locationId)
		end
		
		return true
	else
		warn("[Location] ❌ Не вдалося завантажити Planet Environment")
		return false
	end
end

-- Switch to Space Station
local function switchToSpaceStation(planetId, locationId)
	print("[Location] 🚀 Перехід з", locationId, "на SpaceStation, орбіта:", planetId)
	
	if isTransitioning then
		warn("[Location] ⚠️ Перехід вже виконується")
		return false
	end

	if locationId == "SpaceStation" then
		print("[Location] ℹ️ Вже на SpaceStation")
		return true
	end

	isTransitioning = true
	transitionTo(LocationState.IDLE, "Початок переходу на КС")
	
	-- Step 1: Validate models exist
	transitionTo(LocationState.VALIDATING, "Перевірка моделей КС")
	if not validateModel("Space/SpaceStation") then
		warn("[Location] ❌ SpaceStation model not found - fallback to safe state")
		transitionTo(LocationState.ERROR, "Помилка валідації моделі")
		isTransitioning = false
		return false
	end

	-- Step 2: Cleanup
	print("[Location] 🧹 Очищення Workspace...")
	if not cleanupWorkspace() then
		warn("[Location] ❌ Cleanup failed")
		isTransitioning = false
		return false
	end
	wait(0.5)
	
	-- Step 3: Load planet
	transitionTo(LocationState.LOADING_PLANET, "Завантаження планети " .. planetId)
	if checkStateTimeout() then
		warn("[Location] ❌ Planet loading timeout")
		transitionTo(LocationState.ERROR, "Таймаут завантаження планети")
		isTransitioning = false
		return false
	end
	
	print("[Location] 📦 Завантаження планети", planetId)
	if not loadPlanet(planetId) then
		transitionTo(LocationState.ERROR, "Помилка завантаження планети")
		isTransitioning = false
		return false
	end

	-- Step 4: Load SpaceStation
	transitionTo(LocationState.LOADING_LOCATION, "Завантаження КС")
	if checkStateTimeout() then
		warn("[Location] ❌ SpaceStation loading timeout")
		transitionTo(LocationState.ERROR, "Таймаут завантаження КС")
		isTransitioning = false
		return false
	end
	
	print("[Location] 📦 Завантаження SpaceStation...")
	if not loadSpaceStation() then
		transitionTo(LocationState.ERROR, "Помилка завантаження КС")
		isTransitioning = false
		return false
	end

	-- Step 5: Verify
	transitionTo(LocationState.VERIFYING, "Перевірка готовності КС")
	
	-- Find SpawnLocation (should be directly in Workspace after loading)
	local spawnLocation = Workspace:FindFirstChild("SpawnLocation", true)
	
	if not spawnLocation then
		warn("[Location] ❌ SpawnLocation not found in Workspace")
		warn("[Location]   └─ Expected: Workspace.SpawnLocation")
		transitionTo(LocationState.ERROR, "Відсутня точка появи")
		isTransitioning = false
		return false
	end
	
	-- Success!
	transitionTo(LocationState.READY, "КС готова")
	currentLocation = "SpaceStation"
	isTransitioning = false
	
	print("[Location] ✅ Перехід на SpaceStation завершено")
	return true
end

-- Switch to planet location
local function switchToPlanetLocation(planetId, locationId)
	if isTransitioning then
		warn("[Location] ⚠️ Перехід вже виконується")
		return false
	end

	if currentLocation == locationId then
		print("[Location] ℹ️ Вже на локації:", locationId)
		return true
	end

	isTransitioning = true
	transitionTo(LocationState.IDLE, "Початок переходу на локацію планети")
	print("[Location] 🔄 Перехід на", locationId, "на", planetId)
	
	-- Step 1: Validate models
	transitionTo(LocationState.VALIDATING, "Перевірка моделей планети/локації")
	local planetPath = "Planets/" .. planetId
	local locationPath = planetPath .. "/Locations/" .. locationId
	
	if not validateModel(planetPath) then
		warn("[Location] ❌ Planet model not found:", planetId)
		transitionTo(LocationState.ERROR, "Планету не знайдено")
		isTransitioning = false
		return false
	end
	
	if not validateModel(locationPath) then
		warn("[Location] ❌ Location model not found:", locationId)
		transitionTo(LocationState.ERROR, "Локацію не знайдено")
		isTransitioning = false
		return false
	end

	-- Step 2: Cleanup
	if not cleanupWorkspace() then
		warn("[Location] ❌ Cleanup failed")
		isTransitioning = false
		return false
	end

	-- Step 3: Load location
	transitionTo(LocationState.LOADING_LOCATION, "Завантаження " .. locationId)
	if checkStateTimeout() then
		warn("[Location] ❌ Location loading timeout")
		transitionTo(LocationState.ERROR, "Таймаут завантаження локації")
		isTransitioning = false
		return false
	end
	
	if not loadLocation(planetId, locationId) then
		transitionTo(LocationState.ERROR, "Помилка завантаження локації")
		isTransitioning = false
		return false
	end

	-- Step 4: Verify
	transitionTo(LocationState.VERIFYING, "Перевірка готовності " .. locationId)
	
	-- Find SpawnLocation (should be directly in Workspace after loading)
	local spawnLocation = Workspace:FindFirstChild("SpawnLocation", true)
	
	if not spawnLocation then
		warn("[Location] ❌ SpawnLocation not found in Workspace")
		warn("[Location]   └─ Expected: Workspace.SpawnLocation")
		warn("[Location]   └─ Location:", locationId, "Planet:", planetId)
		transitionTo(LocationState.ERROR, "Відсутня точка появи")
		isTransitioning = false
		return false
	end
	
	-- Success!
	transitionTo(LocationState.READY, locationId .. " готова")
	currentLocation = locationId
	isTransitioning = false

	print("[Location] ✅ Перехід на", locationId, "завершено")
	return true
end

-- Public API
local LocationManager = {
	Initialize = function()
		transitionTo(LocationState.IDLE, "Ініціалізація")
		print("[Location] ✅ Менеджер локацій ініціалізовано")
	end,
	SwitchToSpaceStation = switchToSpaceStation,
	SwitchToPlanetLocation = switchToPlanetLocation,
	GetCurrentLocation = function() 
		return currentLocation
	end,
	GetState = function()
		return currentState
	end,
	IsTransitioning = function() 
		return isTransitioning
	end,
	CleanupWorkspace = cleanupWorkspace,
	
	-- FSM States (exported for external use)
	LocationState = LocationState,
	
	-- New API for location modules
	GetCurrentPlanetConfig = function()
		return currentPlanetConfig
	end,
	GetCurrentLocationGameServer = function()
		return currentLocationGameServer
	end
}

return LocationManager