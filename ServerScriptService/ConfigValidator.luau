--[[
================================================================================
KOSMICMAZER — Configuration Validator
================================================================================

Purpose: Validates GameConfig structure at startup to prevent runtime errors
Version: 1.3

Features:
- Validates required GameConfig fields
- Checks planet configurations from ServerStorage via PlanetConfigLoader
- Validates ServerStorage model existence with LocationModel hierarchy support
- Provides detailed error messages and warnings
- Fail-fast on critical configuration issues
- Non-blocking warnings for optional components
- LocationModel/Gameplay/SpawnLocation validation with fallback

API:
- ValidateConfig(config, serverStorage): Validates entire configuration
- ValidateRequiredFields(config): Validates critical config fields
- ValidatePlanets(config, serverStorage): Validates planet configurations
- ValidateSpaceStation(config, serverStorage): Validates space station config
- ValidateServerStorageModels(config, serverStorage): Checks model existence
- GetValidationReport(): Returns detailed validation report

Calls to:
- None (standalone validator)

Called by:
- GameInit.server.luau: During game initialization

Dependencies:
- PlanetConfigLoader module (v1.1+)
- GameConfig module (validated)
- ServerStorage service (checked)

ChangeLog:
- Version 1.3 (2026-01-10): Removed legacy GameConfig.Planets validators
  - Removed validateLocation() function (old structure)
  - Removed validatePlanet() function (old structure)
  - validatePlanets() now exclusively uses PlanetConfigLoader
  - Compatible with PlanetConfig.LOCATIONS structure

================================================================================
]]

--============================================================================--
-- MODULES
--============================================================================--
local ServerScriptService = game:GetService("ServerScriptService")
local PlanetConfigLoader = require(ServerScriptService:FindFirstChild("PlanetConfigLoader"))

local ConfigValidator = {}
ConfigValidator.Version = "1.3"

-- Validation results storage
local validationReport = {
	errors = {},
	warnings = {},
	info = {},
	criticalFailure = false
}

--------------------------------------------------------------------------------
-- SECTION 1: VALIDATION REPORT
--------------------------------------------------------------------------------

-- Add error to report
local function addError(category: string, message: string)
	table.insert(validationReport.errors, {
		category = category,
		message = message,
		timestamp = os.time()
	})
	validationReport.criticalFailure = true
end

-- Add warning to report
local function addWarning(category: string, message: string)
	table.insert(validationReport.warnings, {
		category = category,
		message = message,
		timestamp = os.time()
	})
end

-- Add info to report
local function addInfo(category: string, message: string)
	table.insert(validationReport.info, {
		category = category,
		message = message,
		timestamp = os.time()
	})
end

-- Print validation report
local function printReport()
	print("\n" .. string.rep("=", 80))
	print("CONFIG VALIDATION REPORT")
	print(string.rep("=", 80))
	
	-- Print errors
	if #validationReport.errors > 0 then
		print("\n❌ ERRORS (" .. #validationReport.errors .. "):")
		for i, err in ipairs(validationReport.errors) do
			print(string.format("  %d. [%s] %s", i, err.category, err.message))
		end
	end
	
	-- Print warnings
	if #validationReport.warnings > 0 then
		print("\n⚠️  WARNINGS (" .. #validationReport.warnings .. "):")
		for i, warn in ipairs(validationReport.warnings) do
			print(string.format("  %d. [%s] %s", i, warn.category, warn.message))
		end
	end
	
	-- Print info
	if #validationReport.info > 0 then
		print("\nℹ️  INFO (" .. #validationReport.info .. "):")
		for i, info in ipairs(validationReport.info) do
			print(string.format("  %d. [%s] %s", i, info.category, info.message))
		end
	end
	
	print("\n" .. string.rep("=", 80))
	print("VALIDATION RESULT: " .. (validationReport.criticalFailure and "❌ FAILED" or "✅ PASSED"))
	print(string.rep("=", 80) .. "\n")
end

--------------------------------------------------------------------------------
-- SECTION 2: REQUIRED FIELDS VALIDATION
--------------------------------------------------------------------------------

-- Validate critical GameConfig fields
local function validateRequiredFields(config)
	addInfo("RequiredFields", "Validating critical GameConfig fields...")
	
	-- Check game metadata
	if not config.GameName or config.GameName == "" then
		addError("RequiredFields", "GameName is missing or empty")
	end
	
	if not config.GameVersion or config.GameVersion == "" then
		addError("RequiredFields", "GameVersion is missing or empty")
	end
	
	-- Check data schema version
	if not config.DATA_SCHEMA_VERSION then
		addError("RequiredFields", "DATA_SCHEMA_VERSION is missing")
	elseif type(config.DATA_SCHEMA_VERSION) ~= "number" then
		addError("RequiredFields", "DATA_SCHEMA_VERSION must be a number")
	elseif config.DATA_SCHEMA_VERSION < 1 then
		addError("RequiredFields", "DATA_SCHEMA_VERSION must be >= 1")
	end
	
	-- Check default planet configuration
	if not config.DEFAULT_PLANET or config.DEFAULT_PLANET == "" then
		addError("RequiredFields", "DEFAULT_PLANET is missing or empty")
	end
	
	if not config.DEFAULT_PLANET_NAME or config.DEFAULT_PLANET_NAME == "" then
		addWarning("RequiredFields", "DEFAULT_PLANET_NAME is missing (used for UI display)")
	end
	
	-- Check teleportation settings
	if not config.Teleportation then
		addError("RequiredFields", "Teleportation table is missing")
	else
		if not config.Teleportation.Delay then
			addWarning("RequiredFields", "Teleportation.Delay is missing")
		end
		if not config.Teleportation.Cooldown then
			addWarning("RequiredFields", "Teleportation.Cooldown is missing")
		end
	end
	
	-- Check spawn settings
	if not config.Spawn then
		addWarning("RequiredFields", "Spawn table is missing")
	end

	-- Check DEFAULT_PLANET (v4.1: Planets migrated to ServerStorage)
	if not config.DEFAULT_PLANET then
		addError("RequiredFields", "DEFAULT_PLANET is missing")
	elseif type(config.DEFAULT_PLANET) ~= "string" or config.DEFAULT_PLANET == "" then
		addError("RequiredFields", "DEFAULT_PLANET must be a non-empty string")
	end

	-- Check space station configuration
	if not config.SpaceStation then
		addError("RequiredFields", "SpaceStation table is missing")
	else
		if not config.SpaceStation.Name or config.SpaceStation.Name == "" then
			addError("RequiredFields", "SpaceStation.Name is missing or empty")
		end
		if not config.SpaceStation.DisplayName or config.SpaceStation.DisplayName == "" then
			addWarning("RequiredFields", "SpaceStation.DisplayName is missing (used for UI)")
		end
	end
	
	addInfo("RequiredFields", "Required fields validation completed")
end

--------------------------------------------------------------------------------
-- SECTION 3: PLANET CONFIGURATION VALIDATION
--------------------------------------------------------------------------------

-- REMOVED v4.6 (2026-01-10): validateLocation() and validatePlanet() functions
-- These functions validated the old GameConfig.Planets.{PlanetId}.Locations structure
-- Now replaced by validatePlanets() which uses PlanetConfigLoader from ServerStorage
-- The new validator checks PlanetConfig.LOCATIONS from ServerStorage/Planets/{PlanetId}/Configuration/

-- REMOVED v4.6 (2026-01-10): validatePlanet() function (legacy GameConfig.Planets validator)
-- This function was used to validate the old GameConfig.Planets structure
-- Now replaced by validatePlanets() which uses PlanetConfigLoader from ServerStorage

-- Validate all planets (Updated v4.6: Uses PlanetConfigLoader exclusively)
local function validatePlanets(config)
	addInfo("Planets", "Validating PlanetConfig from ServerStorage...")

	-- Check DEFAULT_PLANET is set
	if not config.DEFAULT_PLANET then
		addError("Planets", "GameConfig.DEFAULT_PLANET is not set")
		return
	end

	-- Try to load DEFAULT_PLANET config from ServerStorage
	local success, planetConfig = pcall(function()
		return PlanetConfigLoader.LoadPlanetConfig(config.DEFAULT_PLANET)
	end)

	if not success then
		addError("Planets", string.format("Failed to load DEFAULT_PLANET '%s': %s",
			config.DEFAULT_PLANET, tostring(planetConfig)))
		return
	end

	-- Validate LOCATIONS structure
	if not planetConfig.LOCATIONS or type(planetConfig.LOCATIONS) ~= "table" then
		addError("Planets", "PlanetConfig.LOCATIONS missing or invalid")
		return
	end

	-- Count locations and check for discovered
	local locationCount = 0
	local discoveredCount = 0

	for locationId, location in pairs(planetConfig.LOCATIONS) do
		locationCount = locationCount + 1

		if location.isDiscovered then
			discoveredCount = discoveredCount + 1
		end

		-- Validate location structure
		if not location.DisplayName then
			addWarning("Planets", string.format("Location '%s' missing DisplayName", locationId))
		end
		if not location.SpawnPoint then
			addWarning("Planets", string.format("Location '%s' missing SpawnPoint", locationId))
		end
	end

	-- Check if at least one location is discovered
	if discoveredCount == 0 then
		addWarning("Planets", string.format("Planet '%s' has 0 discovered locations - players won't be able to spawn",
			config.DEFAULT_PLANET))
	end

	addInfo("Planets", string.format("✅ PlanetConfig validated for %s (%s) - %d locations, %d discovered",
		planetConfig.PLANET_ID or "Unknown",
		planetConfig.DISPLAY_NAME or "Unknown",
		locationCount,
		discoveredCount))
end

--------------------------------------------------------------------------------
-- SECTION 4: SPACE STATION VALIDATION
--------------------------------------------------------------------------------

-- Validate space station configuration
local function validateSpaceStation(config, serverStorage)
	addInfo("SpaceStation", "Validating Space Station configuration...")
	
	if not config.SpaceStation then
		return -- Already reported in required fields
	end
	
	local station = config.SpaceStation
	
	-- Check spawn point
	if not station.SpawnPoint or station.SpawnPoint == "" then
		addError("SpaceStation", "SpawnPoint is missing - players won't be able to spawn at station")
	end
	
	-- Check teleport point
	if not station.TeleportPoint or station.TeleportPoint == "" then
		addWarning("SpaceStation", "TeleportPoint is missing (used for return to station)")
	end
	
	-- Check ServerStorage structure
	if serverStorage then
		local spacePath = serverStorage:FindFirstChild("Space")
		if not spacePath then
			addError("SpaceStation", "ServerStorage/Space folder not found")
		else
			local stationPath = spacePath:FindFirstChild("SpaceStation")
			if not stationPath then
				addError("SpaceStation", "ServerStorage/Space/SpaceStation folder not found")
			else
				-- Check for Workspace folder
				local workspaceFolder = stationPath:FindFirstChild("Workspace")
				if not workspaceFolder then
					addWarning("SpaceStation", "SpaceStation/Workspace folder not found")
				else
					-- Check for LocationModel (new hierarchical structure)
					local locationModel = workspaceFolder:FindFirstChild("LocationModel")
					if locationModel then
						-- NEW: Validate LocationModel attributes
						local locationId = locationModel:GetAttribute("LocationId")
						local locationType = locationModel:GetAttribute("LocationType")
						
						if locationId ~= "SpaceStation" or locationType ~= "Space" then
							addWarning("SpaceStation", string.format(
								"LocationModel attributes incorrect (LocationId: %s, LocationType: %s)", 
								tostring(locationId), tostring(locationType)))
						end
						
						-- Check SpawnPoint inside LocationModel/Gameplay/
						if station.SpawnPoint then
							local gameplayFolder = locationModel:FindFirstChild("Gameplay")
							local spawnLocation = gameplayFolder and gameplayFolder:FindFirstChild(station.SpawnPoint)
							
							if not spawnLocation then
								addError("SpaceStation", string.format(
									"SpawnPoint '%s' not found in LocationModel/Gameplay", 
									station.SpawnPoint))
							elseif spawnLocation.ClassName ~= "SpawnLocation" then
								addError("SpaceStation", string.format(
									"'%s' exists but is not a SpawnLocation (found: %s)", 
									station.SpawnPoint, spawnLocation.ClassName))
							else
								addInfo("SpaceStation", string.format(
									"✅ SpawnPoint '%s' found in LocationModel/Gameplay", station.SpawnPoint))
							end
						end
						
						-- Check for optional PlanetSurfaceScanner in Equipment/
						local equipmentFolder = locationModel:FindFirstChild("Equipment")
						local scanner = equipmentFolder and equipmentFolder:FindFirstChild("PlanetSurfaceScanner")
						if scanner then
							addInfo("SpaceStation", "✅ PlanetSurfaceScanner found in LocationModel/Equipment")
						else
							addInfo("SpaceStation", "PlanetSurfaceScanner not found (optional feature)")
						end
					else
						-- Fallback: old structure validation
						if station.SpawnPoint then
							local spawnLocation = workspaceFolder:FindFirstChild(station.SpawnPoint)
							if not spawnLocation then
								addInfo("SpaceStation", string.format(
									"SpawnPoint '%s' not found (LocationModel structure missing)", 
									station.SpawnPoint))
							elseif spawnLocation.ClassName ~= "SpawnLocation" then
								addError("SpaceStation", string.format(
									"'%s' exists but is not a SpawnLocation (found: %s)", 
									station.SpawnPoint, spawnLocation.ClassName))
							else
								addInfo("SpaceStation", string.format(
									"SpawnPoint '%s' found (old structure)", station.SpawnPoint))
							end
						end
						
						-- Check for optional PlanetSurfaceScanner (old structure)
						local scanner = workspaceFolder:FindFirstChild("PlanetSurfaceScanner")
						if scanner then
							addInfo("SpaceStation", "PlanetSurfaceScanner found (optional)")
						else
							addInfo("SpaceStation", "PlanetSurfaceScanner not found (optional feature)")
						end
					end
				end
				
				-- Check for Configuration folder
				local configFolder = stationPath:FindFirstChild("Configuration")
				if not configFolder then
					addWarning("SpaceStation", "SpaceStation/Configuration folder not found")
				end
				
				-- Check for Scripts folder
				local scriptsFolder = stationPath:FindFirstChild("Scripts")
				if not scriptsFolder then
					addWarning("SpaceStation", "SpaceStation/Scripts folder not found")
				end
			end
		end
	end
	
	addInfo("SpaceStation", "Space Station validation completed")
end

--------------------------------------------------------------------------------
-- SECTION 5: SERVERSTORAGE MODEL VALIDATION
--------------------------------------------------------------------------------

-- Validate ServerStorage structure and models
local function validateServerStorageModels(config, serverStorage)
	addInfo("ServerStorage", "Validating ServerStorage models...")
	
	if not serverStorage then
		addError("ServerStorage", "ServerStorage service not accessible")
		return
	end
	
	-- Check Planets folder
	local planetsFolder = serverStorage:FindFirstChild("Planets")
	if not planetsFolder then
		addError("ServerStorage", "ServerStorage/Planets folder not found")
	else
		-- Validate each planet from config exists in ServerStorage
		if config.Planets then
			for planetId, planet in pairs(config.Planets) do
				local planetPath = planetsFolder:FindFirstChild(planetId)
				if not planetPath then
					addError("ServerStorage", string.format("Planet folder '%s' not found in ServerStorage/Planets", 
						planetId))
				else
					-- Check for Workspace folder
					local workspaceFolder = planetPath:FindFirstChild("Workspace")
					if not workspaceFolder then
						addWarning("ServerStorage", string.format("Planet '%s': Workspace folder not found", 
							planetId))
					else
						-- Check for planet model
						if planet.Folder then
							local planetModel = workspaceFolder:FindFirstChild(planet.Folder)
							if not planetModel then
								addWarning("ServerStorage", string.format(
									"Planet '%s': Model '%s' not found in Workspace", planetId, planet.Folder))
							end
						end
					end
					
					-- Check for Lighting folder
					local lightingFolder = planetPath:FindFirstChild("Lighting")
					if not lightingFolder then
						addWarning("ServerStorage", string.format("Planet '%s': Lighting folder not found", 
							planetId))
					end
					
					-- Check for Locations folder
					local locationsFolder = planetPath:FindFirstChild("Locations")
					if not locationsFolder then
						addError("ServerStorage", string.format("Planet '%s': Locations folder not found", 
							planetId))
					else
						-- Validate each location exists
						if planet.Locations then
							for locationId, location in pairs(planet.Locations) do
								local locationPath = locationsFolder:FindFirstChild(locationId)
								if not locationPath then
									addError("ServerStorage", string.format(
										"Planet '%s': Location '%s' folder not found", planetId, locationId))
								else
									-- Check for location Workspace
									local locWorkspace = locationPath:FindFirstChild("Workspace")
									if not locWorkspace then
										addWarning("ServerStorage", string.format(
											"Planet '%s', Location '%s': Workspace folder not found", 
											planetId, locationId))
									else
										-- Check for LocationModel (new hierarchical structure)
										local locationModel = locWorkspace:FindFirstChild("LocationModel")
										if locationModel then
											-- NEW: Check SpawnPoint inside LocationModel/Gameplay/
											if location.SpawnPoint then
												local gameplayFolder = locationModel:FindFirstChild("Gameplay")
												local spawn = gameplayFolder and gameplayFolder:FindFirstChild(location.SpawnPoint)
												
												if not spawn then
													addError("ServerStorage", string.format(
														"Planet '%s', Location '%s': SpawnPoint '%s' not found in LocationModel/Gameplay", 
														planetId, locationId, location.SpawnPoint))
												elseif spawn.ClassName ~= "SpawnLocation" then
													addError("ServerStorage", string.format(
														"Planet '%s', Location '%s': '%s' is not a SpawnLocation (found: %s)", 
														planetId, locationId, location.SpawnPoint, spawn.ClassName))
												else
													addInfo("ServerStorage", string.format(
														"Planet '%s', Location '%s': ✅ SpawnPoint found in LocationModel/Gameplay", 
														planetId, locationId))
												end
											end
										else
											-- Fallback: old structure (direct in Workspace)
											if location.SpawnPoint then
												local spawn = locWorkspace:FindFirstChild(location.SpawnPoint)
												if not spawn then
													addWarning("ServerStorage", string.format(
														"Planet '%s', Location '%s': SpawnPoint '%s' not found (LocationModel structure missing)", 
														planetId, locationId, location.SpawnPoint))
												elseif spawn.ClassName ~= "SpawnLocation" then
													addError("ServerStorage", string.format(
														"Planet '%s', Location '%s': '%s' is not a SpawnLocation (found: %s)", 
														planetId, locationId, location.SpawnPoint, spawn.ClassName))
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
	
	addInfo("ServerStorage", "ServerStorage model validation completed")
end

--------------------------------------------------------------------------------
-- SECTION 6: MAIN VALIDATION FUNCTION
--------------------------------------------------------------------------------

-- Main validation function
function ConfigValidator.ValidateConfig(config, serverStorage)
	print("\n[ConfigValidator] 🔍 Starting configuration validation...")
	
	-- Reset validation report
	validationReport = {
		errors = {},
		warnings = {},
		info = {},
		criticalFailure = false
	}
	
	-- Run all validations
	validateRequiredFields(config)
	validatePlanets(config)
	validateSpaceStation(config, serverStorage)
	validateServerStorageModels(config, serverStorage)
	
	-- Print report
	printReport()
	
	-- Return validation result
	return not validationReport.criticalFailure, validationReport
end

-- Get validation report
function ConfigValidator.GetValidationReport()
	return validationReport
end

-- Export module
return ConfigValidator
