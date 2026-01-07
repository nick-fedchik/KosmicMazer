--[[
================================================================================
KOSMICMAZER — Location Manager (Module)
================================================================================

Purpose: Manages location switching and workspace organization
Version: 2.1 (Fixed ModuleScript issue)

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

-- Helper function to get current planet based on loaded location
local function getCurrentPlanet()
	-- For now, default to Planet_1
	-- In future, this could be determined by player data or current location
	return "Planet_1"
end

-- Helper function to clean workspace
local function cleanupWorkspace()
	print("[LocationManager] 🧹 Cleanup current workspace, children count: " .. #Workspace:GetChildren())

	-- Clean up all lighting objects (comprehensive cleanup)
	local lighting = game:GetService("Lighting")
	print("[LocationManager] Current lighting children count: " .. #lighting:GetChildren())

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
			print("[LocationManager] 🗑️ Removed lighting object: " .. child.Name)
		end
	end

	-- Clean up any location objects that might be in workspace
	for _, child in ipairs(Workspace:GetChildren()) do
		if child.Name:match("^Location_") then
			child:Destroy()
			print("[LocationManager] 🗑️ Removed location: " .. child.Name)
		end
		if child.Name == "Planet" then
			child:Destroy()
			print("[LocationManager] 🗑️ Removed planet: " .. child.Name)
		end
		if child.Name == "SpaceStation" then
			child:Destroy()
			print("[LocationManager] 🗑️ Removed SpaceStation")
		end
	end

	print("[LocationManager] ✅ Cleanup completed")
end

-- Load Space Station
local function loadSpaceStation()

	-- Clone Space Station from ServerStorage/Space/SpaceStation
	local spaceStationFolder = ServerStorage:FindFirstChild("Space")
	if spaceStationFolder then
		print("[LocationManager] ✅ Space folder found")
		local spaceStationTemplate = spaceStationFolder:FindFirstChild("SpaceStation")
		if spaceStationTemplate then
			print("[LocationManager] ✅ SpaceStation template found")
			local spaceStation = spaceStationTemplate:Clone()
			spaceStation.Name = "SpaceStation"
			spaceStation.Parent = Workspace
			
			print("[LocationManager] ✅ SpaceStation cloned to workspace")

			-- Position Space Station
			local primaryPart = spaceStation:FindFirstChild("Landing pad") or spaceStation.PrimaryPart
			if primaryPart then
				spaceStation:PivotTo(CFrame.new(0, 10, 0))
				print("[LocationManager] ✅ SpaceStation positioned")
			else
				print("[LocationManager] ⚠️ No primary part found for positioning")
			end

			print("[LocationManager] ✅ Space Station loaded")
		else
			warn("[LocationManager] ⚠️ Space Station template not found")
		end
	else
		warn("[LocationManager] ⚠️ Space folder not found")
	end
	
end

-- Load Planet
local function loadPlanet(planetId)
	print("[LocationManager] 🪐 Loading planet: " .. planetId)

	local planetData = GameConfig.Planets[planetId]
	if not planetData then
		warn("[LocationManager] ⚠️ Planet data not found: " .. planetId)
		return false
	end

	-- Clone planet from ServerStorage/Planet_N/Planet
	local planetFolder = ServerStorage:FindFirstChild(planetId)
	if planetFolder then
		local planetTemplate = planetFolder:FindFirstChild("Planet")
		if planetTemplate then
			local planet = planetTemplate:Clone()
			 -- planet.Name = ""
			planet.Parent = Workspace
			
			-- check the Planet presence
			local object = Workspace:FindFirstChild("Planet")
			if not object then
				warn("(!) No Planet in Workspace!")
			else
				print("[LocationManager] ✅ Planet ".. planet.Name .." is cloned to workspace")
			end

			-- Load planet environment
			local lighting = game:GetService("Lighting")
			local planetLighting = planetFolder:FindFirstChild("Lighting")

			if planetLighting then
				-- Copy all lighting objects from planet
				for _, lightingObject in ipairs(planetLighting:GetChildren()) do
					lightingObject:Clone().Parent = lighting
					print("[LocationManager] ✅ Loaded " .. lightingObject.Name .. " for planet " .. planetId)
				end
			end

			print("[LocationManager] ✅ Planet " .. planetId .. " loaded")
			return true
		else
			warn("[LocationManager] ⚠️ Planet template not found: " .. planetId)
			return false
		end
	else
		warn("[LocationManager] ⚠️ Planet folder not found: " .. planetId)
		return false
	end
end

-- Load specific location on planet
local function loadLocation(planetId, locationId)
	print("[LocationManager] 📍 Loading location: " .. locationId .. " on " .. planetId)

	local locationData = GameConfig.PlanetHelpers.GetLocation(planetId, locationId)
	if not locationData then
		warn("[LocationManager] ⚠️ Location data not found: " .. locationId)
		return false
	end

	-- Clone location from ServerStorage/Planet_N/Locations/Location_M
	local planetFolder = ServerStorage:FindFirstChild(planetId)
	if not planetFolder then
		warn("[LocationManager] ⚠️ Planet folder not found: " .. planetId)
		return false
	end

	local locationsFolder = planetFolder:FindFirstChild("Locations")
	if not locationsFolder then
		warn("[LocationManager] ⚠️ Locations folder not found in: " .. planetId)
		return false
	end

	local locationTemplate = locationsFolder:FindFirstChild(locationId)
	if locationTemplate then
		local location = locationTemplate:Clone()
		location.Name = locationId
		location.Parent = Workspace

		-- Position location
		local spawnPart = location:FindFirstChild("SpawnLocation")
		if spawnPart then
			location:PivotTo(spawnPart.CFrame)
		end

		-- Load location-specific lighting
		local locationLighting = locationTemplate:FindFirstChild("Lighting")
		if locationLighting then
			-- Copy all lighting objects from location
			for _, lightingObject in ipairs(locationLighting:GetChildren()) do
				lightingObject:Clone().Parent = game.Lighting
				print("[LocationManager] ✅ Loaded " .. lightingObject.Name .. " for location " .. locationId)
			end
		end

		print("[LocationManager] ✅ Location " .. locationId .. " loaded")
		return true
	else
		warn("[LocationManager] ⚠️ Location template not found: " .. locationId)
		return false
	end
end

-- Switch to Space Station
local function switchToSpaceStation(planetId, locationId)
	print("[LocationManager] 🚀 Game switch from location " .. locationId .. "to Space Station on the planet orbit " .. planetId)
	
	if isTransitioning then
		warn("[LocationManager] ⚠️ Already transitioning")
		return false
	end

	if locationId == "SpaceStation" then
		print("[LocationManager] ℹ️ Already on Space Station")
		return true
	end

	isTransitioning = true
	print("[LocationManager] 🔄 Switching to Space Station...")

	print("[LocationManager] 🧹 Cleaning up Workspace...")
	-- Cleanup current location
	cleanupWorkspace()
	wait(0.5)
	
	print("[LocationManager] 📦 Loading Planet " .. planetId)
	-- Load planet
	if not loadPlanet(planetId) then
		isTransitioning = false
		return false
	end

	print("[LocationManager] 📦 Loading Space Station...")
	-- Load Space Station
	
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
	
	print("[LocationManager] ✅ Game switched to Space Station")
	return true
end

-- Switch to planet location
local function switchToPlanetLocation(planetId, locationId)
	if isTransitioning then
		warn("[LocationManager] ⚠️ Already transitioning")
		return false
	end

	if currentLocation == locationId then
		print("[LocationManager] ℹ️ Already at location: " .. locationId)
		return true
	end

	isTransitioning = true
	print("[LocationManager] 🔄 Game switching to " .. locationId .. " on " .. planetId)

	-- Cleanup current location
	cleanupWorkspace()



	-- Load specific location
	if not loadLocation(planetId, locationId) then
		isTransitioning = false
		return false
	end

	currentLocation = locationId
	isTransitioning = false

	print("[LocationManager] ✅ Game switched to " .. locationId)
	return true
end

-- Public API
local LocationManager = {
	Initialize = function()
		print("[LocationManager] ✅ Location Manager initialized")
	
	end,
	SwitchToSpaceStation = switchToSpaceStation,
	SwitchToPlanetLocation = switchToPlanetLocation,
	GetCurrentLocation = function() 
		return currentLocation
	end,
	IsTransitioning = function() 
		return isTransitioning
	end,
	CleanupWorkspace = cleanupWorkspace
}

return LocationManager