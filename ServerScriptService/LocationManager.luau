--[[
================================================================================
KOSMICMAZER — Location Manager (Module)
================================================================================

Purpose: Manages location switching and workspace organization
Version: 2.3

Features:
- Handles location transitions (Space Station ↔ Planet Locations)
- Manages workspace cleanup and loading
- Controls environment switching (Sky, Atmosphere, CloudLayers)
- Integrates with teleportation system
- Prevents concurrent transitions

API:
- Initialize(): Initializes the location manager
- SwitchToSpaceStation(): Switches to Space Station location
- SwitchToPlanetLocation(planetId, locationId): Switches to specific planet location
- GetCurrentLocation(): Returns current location name
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

-- State management
local currentLocation = "Dark Space"
local isTransitioning = false

-- Active location modules
local currentLocationGameServer = nil
local currentPlanetConfig = nil

-- Helper function to get current planet based on loaded location
local function getCurrentPlanet()
	-- For now, default to Planet_1
	-- In future, this could be determined by player data or current location
	return "Planet_1"
end

-- Helper function to clean workspace
local function cleanupWorkspace()
	print("[Location] 🧹 Очищення, об'єктів:", #Workspace:GetChildren())
	
	-- Cleanup current location game server before clearing workspace
	if currentLocationGameServer and currentLocationGameServer.Cleanup then
		currentLocationGameServer.Cleanup()
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
		if child.Name == "SpaceStation" then
			child:Destroy()
			print("[Location] 🗑️ Видалено SpaceStation")
		end
	end

	print("[Location] ✅ Очищення завершено")
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
		-- Position Space Station
		local spaceStation = Workspace:FindFirstChild("SpaceStation")
		if spaceStation then
			local primaryPart = spaceStation:FindFirstChild("Landing pad") or spaceStation.PrimaryPart
			if primaryPart then
				-- Position station higher to avoid spawn underground
				spaceStation:PivotTo(CFrame.new(0, -450, 0))
				print("[Location] ✅ SpaceStation позиціоновано at Y=-450")
			else
				warn("[Location] ⚠️ PrimaryPart не знайдено")
			end
		end
		
		-- Initialize PlanetSurfaceScanner when Space Station is loaded
		local planetSurfaceScanner = Workspace:FindFirstChild("PlanetSurfaceScanner")
		if planetSurfaceScanner then
			-- Load PlanetSurfaceScanner module from SpaceStation scripts folder
			local spaceStationScripts = ServerStorage:FindFirstChild("Space")
			if spaceStationScripts then
				spaceStationScripts = spaceStationScripts:FindFirstChild("SpaceStation")
			end
			if spaceStationScripts then
				spaceStationScripts = spaceStationScripts:FindFirstChild("Scripts")
			end
			if spaceStationScripts then
				spaceStationScripts = spaceStationScripts:FindFirstChild("Server")
			end
			
			local PlanetSurfaceScannerModule = spaceStationScripts and spaceStationScripts:FindFirstChild("PlanetSurfaceScanner")
			if PlanetSurfaceScannerModule then
				local success, result = pcall(function()
					local PlanetSurfaceScanner = require(PlanetSurfaceScannerModule)
					return PlanetSurfaceScanner.Initialize(planetSurfaceScanner)
				end)
				
				if success and result then
					print("[Location] ✅ PlanetSurfaceScanner ініціалізовано при завантаженні Space Station")
				else
					-- Scanner is optional, show warning instead of error
					local reason = if success then "компоненти не знайдено" else tostring(result)
					warn("[Location] ⚠️ PlanetSurfaceScanner не ініціалізовано: " .. reason)
				end
			else
				-- Scanner module is optional, don't warn if missing
				print("[Location] ℹ️ PlanetSurfaceScanner модуль не знайдено (опціонально)")
			end
		else
			-- Scanner model is optional, don't warn if missing
			print("[Location] ℹ️ PlanetSurfaceScanner модель не знайдено в Workspace (опціонально)")
		end
		
		print("[Location] ✅ Космічну станцію завантажено")
	else
		warn("[Location] ❌ Не вдалося завантажити Space Environment")
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
						local locationModel = Workspace:FindFirstChild(locationId)
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
	print("[Location] 🔄 Перехід на SpaceStation...")

	print("[Location] 🧹 Очищення Workspace...")
	cleanupWorkspace()
	wait(0.5)
	
	print("[Location] 📦 Завантаження планети", planetId)
	-- Load planet
	if not loadPlanet(planetId) then
		isTransitioning = false
		return false
	end

	print("[Location] 📦 Завантаження SpaceStation...")
	
	if not loadSpaceStation() then
		isTransitioning = false
		return false
	end

	currentLocation = "SpaceStation"
	isTransitioning = false
	
	-- Find spawn location on Space Station
	local spawnLocation = game.Workspace:FindFirstChild("SpaceStation")
	if spawnLocation then
		spawnLocation = spawnLocation:FindFirstChild("SpawnLocation")
	end
	
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
	print("[Location] 🔄 Перехід на", locationId, "на", planetId)

	cleanupWorkspace()



	-- Load specific location
	if not loadLocation(planetId, locationId) then
		isTransitioning = false
		return false
	end

	currentLocation = locationId
	isTransitioning = false

	print("[Location] ✅ Перехід на", locationId, "завершено")
	return true
end

-- Public API
local LocationManager = {
	Initialize = function()
		print("[Location] ✅ Менеджер локацій ініціалізовано")
	end,
	SwitchToSpaceStation = switchToSpaceStation,
	SwitchToPlanetLocation = switchToPlanetLocation,
	GetCurrentLocation = function() 
		return currentLocation
	end,
	IsTransitioning = function() 
		return isTransitioning
	end,
	CleanupWorkspace = cleanupWorkspace,
	
	-- New API for location modules
	GetCurrentPlanetConfig = function()
		return currentPlanetConfig
	end,
	GetCurrentLocationGameServer = function()
		return currentLocationGameServer
	end
}

return LocationManager