--[[
================================================================================
KOSMICMAZER — Configuration Validator
================================================================================

Purpose: Validates GameConfig structure at startup to prevent runtime errors
Version: 1.1

Features:
- Validates required GameConfig fields
- Checks planet and location configurations
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
- GameConfig module (validated)
- ServerStorage service (checked)

================================================================================
]]

local ConfigValidator = {}
ConfigValidator.Version = "1.1"

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
	
	-- Check planets table
	if not config.Planets then
		addError("RequiredFields", "Planets table is missing")
	elseif type(config.Planets) ~= "table" then
		addError("RequiredFields", "Planets must be a table")
	elseif next(config.Planets) == nil then
		addError("RequiredFields", "Planets table is empty - at least one planet required")
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

-- Validate a single location configuration
local function validateLocation(planetId: string, locationId: string, location: any)
	local category = string.format("Location:%s.%s", planetId, locationId)
	
	-- Check location name
	if not location.Name or location.Name == "" then
		addError(category, "Location.Name is missing or empty")
	elseif location.Name ~= locationId then
		addWarning(category, string.format("Location.Name '%s' doesn't match locationId '%s'", 
			location.Name, locationId))
	end
	
	-- Check display name
	if not location.DisplayName or location.DisplayName == "" then
		addWarning(category, "Location.DisplayName is missing (used for UI display)")
	end
	
	-- Check folder
	if not location.Folder or location.Folder == "" then
		addError(category, "Location.Folder is missing or empty")
	end
	
	-- Check spawn point
	if not location.SpawnPoint or location.SpawnPoint == "" then
		addError(category, "Location.SpawnPoint is missing or empty - players won't be able to spawn")
	end
	
	-- Check teleport point
	if not location.TeleportPoint or location.TeleportPoint == "" then
		addWarning(category, "Location.TeleportPoint is missing (used for teleportation UI)")
	end
	
	-- Check discovery flags
	if location.isDiscovered == nil then
		addWarning(category, "Location.isDiscovered not specified (defaults to false)")
	end
	if location.isVisited == nil then
		addWarning(category, "Location.isVisited not specified (defaults to false)")
	end
	if location.TeleportTo == nil then
		addWarning(category, "Location.TeleportTo not specified (defaults to false)")
	end
end

-- Validate a single planet configuration
local function validatePlanet(planetId: string, planet: any)
	local category = "Planet:" .. planetId
	
	-- Check planet name
	if not planet.Name or planet.Name == "" then
		addError(category, "Planet.Name is missing or empty")
	elseif planet.Name ~= planetId then
		addWarning(category, string.format("Planet.Name '%s' doesn't match planetId '%s'", planet.Name, planetId))
	end
	
	-- Check display name
	if not planet.DisplayName or planet.DisplayName == "" then
		addWarning(category, "Planet.DisplayName is missing (used for UI display)")
	end
	
	-- Check folder
	if not planet.Folder or planet.Folder == "" then
		addError(category, "Planet.Folder is missing or empty")
	end
	
	-- Check availability
	if planet.IsAvailable == nil then
		addWarning(category, "Planet.IsAvailable not specified (defaults to false)")
	end
	
	-- Check locations
	if not planet.Locations then
		addError(category, "Planet.Locations table is missing")
	elseif type(planet.Locations) ~= "table" then
		addError(category, "Planet.Locations must be a table")
	elseif next(planet.Locations) == nil then
		addWarning(category, "Planet has no locations defined")
	else
		-- Validate each location
		local discoveredCount = 0
		for locationId, location in pairs(planet.Locations) do
			validateLocation(planetId, locationId, location)
			if location.isDiscovered then
				discoveredCount = discoveredCount + 1
			end
		end
		
		-- Check if at least one location is discovered
		if discoveredCount == 0 then
			addWarning(category, "No locations are marked as discovered - players won't be able to spawn here")
		end
		
		addInfo(category, string.format("Planet has %d locations, %d discovered", 
			#planet.Locations, discoveredCount))
	end
end

-- Validate all planets
local function validatePlanets(config)
	addInfo("Planets", "Validating planet configurations...")
	
	if not config.Planets then
		return -- Already reported in required fields
	end
	
	local planetCount = 0
	local availablePlanets = 0
	
	for planetId, planet in pairs(config.Planets) do
		validatePlanet(planetId, planet)
		planetCount = planetCount + 1
		if planet.IsAvailable then
			availablePlanets = availablePlanets + 1
		end
	end
	
	-- Check if default planet exists
	if config.DEFAULT_PLANET then
		if not config.Planets[config.DEFAULT_PLANET] then
			addError("Planets", string.format("DEFAULT_PLANET '%s' not found in Planets table", 
				config.DEFAULT_PLANET))
		elseif not config.Planets[config.DEFAULT_PLANET].IsAvailable then
			addWarning("Planets", string.format("DEFAULT_PLANET '%s' is not marked as available", 
				config.DEFAULT_PLANET))
		end
	end
	
	-- Check if at least one planet is available
	if availablePlanets == 0 then
		addError("Planets", "No planets are marked as available - players won't be able to play")
	end
	
	addInfo("Planets", string.format("Validated %d planets, %d available", planetCount, availablePlanets))
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
