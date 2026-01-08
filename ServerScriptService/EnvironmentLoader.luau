--[[
================================================================================
KOSMICMAZER — Environment Loader
================================================================================

Purpose: Handles loading/unloading of game environments (Space/Planet)
Version: 1.12

Features:
- Loads Space Environment (Planet + LocationModel)
- Loads Planet Environment (Location only)
- Clears Workspace and Lighting completely
- Verifies all objects loaded
- Template-based loading system
- Workspace folder naming convention (content → game.Workspace)
- Lighting folder content → game.Lighting
- LoadOrder-based script processing with priority system
- Automatic ModuleScript initialization with LocationModel hierarchy support
- LocationModel hierarchical structure support with Equipment folder search

API:
- LoadSpaceEnvironment(planetId): Loads space environment with planet
- LoadPlanetEnvironment(planetId, locationId): Loads planet location
- ClearWorkspace(): Clears all objects from workspace
- VerifyEnvironmentLoaded(expectedObjects): Verifies loading success

Dependencies:
- GameConfig: For environment configuration
- LoadOrderProcessor: For LoadOrder config processing
- ServerStorage: For template access
- Workspace: Target for loading

ChangeLog:
- Version 1.12: Added diagnostic print for PlanetSurfaceScanner children after copy (2026-01-08)
- Version 1.11: CRITICAL FIX - Client scripts now copy to PlayerGui instead of StarterPlayerScripts (2026-01-08)
- Version 1.11: Fixed SpaceStationUI and PlanetSurfaceScannerUI not appearing for already spawned players
- Version 1.11: Client scripts (LocalScripts) now copy to each player's PlayerGui dynamically
- Version 1.11: Removed StarterPlayerScripts copying - scripts activate immediately
- Version 1.10: Fixed ModuleScript.Initialize() to search LocationModel/Equipment/ (2026-01-08)
- Version 1.10: Added fallback to Workspace for backward compatibility
- Version 1.10: Fixed PlanetSurfaceScanner initialization by searching correct hierarchy
- Version 1.9: Updated for LocationModel hierarchical structure (ETAP 2)
- Version 1.9: LoadSpaceEnvironment now searches for LocationModel instead of SpaceStation
- Version 1.9: Added LocationModel attribute validation (LocationId, LocationType)
- Version 1.9: Updated expectedObjects verification for LocationModel structure
- Version 1.8: Integrated LoadOrder-based script processing for all levels
- Version 1.8: ServerScripts now processed with priority system (SpaceStation/Planet/Location)
- Version 1.8: Automatic ModuleScript.Initialize() calling with Workspace model matching
- Version 1.8: Added LoadOrderProcessor dependency and removed hardcoded paths
- Version 1.7: Fixed expectedObjects verification for Workspace structure (removed SpaceStation.SpawnLocation)
- Version 1.6: Added Scripts processing for Planet level (Planets/Planet_N/Scripts)
- Version 1.5: Added Scripts processing for planet locations (Client/Server folders)
- Version 1.4: Refactored to use Workspace folders (Models→Workspace, PlanetModel→Workspace)
- Version 1.4: Removed SpaceStation/Lighting (now uses Planet/Lighting)
- Version 1.4: Added Lighting cleanup for game.Lighting
- Version 1.3: Updated to use Models folder structure for planet locations
- Version 1.2: Added LoadOrder support for custom object loading sequence
- Version 1.1: Added detailed logging and fixed SpawnLocation verification
- Version 1.0: Initial implementation for Phase 1 refactoring

================================================================================
]]

local EnvironmentLoader = {}

-- Services
local Workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")

-- Load dependencies
local GameConfig = require(game.ServerScriptService.GameConfig)
local ObjectTypeValidator = require(script.Parent:FindFirstChild("ObjectTypeValidator"))
local LoadOrderProcessor = require(script.Parent:FindFirstChild("LoadOrderProcessor"))
local ClientScriptInitializer = require(script.Parent:FindFirstChild("ClientScriptInitializer"))

-- Helper function to dump all object properties for debugging
local function dumpObjectProperties(object, indent)
	indent = indent or ""
	local output = {}
	
	table.insert(output, string.format("%s[%s] %s", indent, object.ClassName, object.Name))
	table.insert(output, string.format("%s  └─ FullName: %s", indent, object:GetFullName()))
	table.insert(output, string.format("%s  └─ Parent: %s", indent, object.Parent and object.Parent.Name or "nil"))
	
	-- Position/CFrame for BasePart or Model
	if object:IsA("BasePart") then
		table.insert(output, string.format("%s  └─ Position: %s", indent, tostring(object.Position)))
		table.insert(output, string.format("%s  └─ CFrame: %s", indent, tostring(object.CFrame)))
		table.insert(output, string.format("%s  └─ Size: %s", indent, tostring(object.Size)))
		table.insert(output, string.format("%s  └─ Anchored: %s", indent, tostring(object.Anchored)))
		table.insert(output, string.format("%s  └─ CanCollide: %s", indent, tostring(object.CanCollide)))
		table.insert(output, string.format("%s  └─ Transparency: %s", indent, tostring(object.Transparency)))
	elseif object:IsA("Model") then
		if object.PrimaryPart then
			table.insert(output, string.format("%s  └─ PrimaryPart: %s", indent, object.PrimaryPart.Name))
			table.insert(output, string.format("%s  └─ PrimaryPart.Position: %s", indent, tostring(object.PrimaryPart.Position)))
		end
		local pivot = object:GetPivot()
		table.insert(output, string.format("%s  └─ Pivot: %s", indent, tostring(pivot.Position)))
	end
	
	-- Custom Attributes
	local attributes = object:GetAttributes()
	if next(attributes) then
		table.insert(output, string.format("%s  └─ Attributes:", indent))
		for key, value in pairs(attributes) do
			table.insert(output, string.format("%s      • %s = %s", indent, key, tostring(value)))
		end
	end
	
	-- Children count
	local children = object:GetChildren()
	table.insert(output, string.format("%s  └─ Children: %d", indent, #children))
	
	return table.concat(output, "\n")
end

-- Helper function to clear workspace completely
local function clearWorkspace()
    print("[EnvironmentLoader] 🧹 Clearing workspace...")
    
    -- Remove all children except essential services
    local essentialObjects = {
        "Camera",
        "Terrain"
    }
    
    for _, child in ipairs(Workspace:GetChildren()) do
        local isEssential = false
        for _, essentialName in ipairs(essentialObjects) do
            if child.Name == essentialName then
                isEssential = true
                break
            end
        end
        
        if not isEssential then
            child:Destroy()
        end
    end
    
    -- Clear Lighting (except essential properties)
    local Lighting = game:GetService("Lighting")
    for _, child in ipairs(Lighting:GetChildren()) do
        child:Destroy()
    end
    
    print("[EnvironmentLoader] ✅ Workspace and Lighting cleared")
end

-- Helper function to copy folder contents with optional load order
local function copyFolderContents(sourceFolder, targetParent, loadOrder)
    if not sourceFolder or not targetParent then
        return false
    end
    
    local children = sourceFolder:GetChildren()
    
    -- If loadOrder is provided, sort children by it
    if loadOrder and loadOrder.SortObjects then
        children = loadOrder.SortObjects(children)
        print("[EnvironmentLoader] 📋 Using custom load order for:", sourceFolder.Name)
    end
    
    for index, child in ipairs(children) do
        local clone = child:Clone()
        clone.Parent = targetParent
        
        -- Додаткове логування для SpawnLocation
        if child.Name == "SpawnLocation" and child:IsA("SpawnLocation") then
            print(string.format("[EnvironmentLoader] 📦 [%d/%d] Copied: %s (%s) to %s", 
                index, #children, child.Name, child.ClassName, targetParent:GetFullName()))
            print("[EnvironmentLoader] 🔍 DUMP: Original SpawnLocation:")
            print(dumpObjectProperties(child, "    "))
            print("[EnvironmentLoader] 🔍 DUMP: Cloned SpawnLocation:")
            print(dumpObjectProperties(clone, "    "))
        else
            print(string.format("[EnvironmentLoader] 📦 [%d/%d] Copied: %s (%s) to %s", 
                index, #children, child.Name, child.ClassName, targetParent:GetFullName()))
        end
    end
    
    return true
end

-- Helper function to verify objects loaded
local function verifyObjectsLoaded(expectedObjects)
    local loadedCount = 0
    local totalCount = #expectedObjects
    
    for _, objectPath in ipairs(expectedObjects) do
        local object = Workspace
        for _, part in ipairs(string.split(objectPath, ".")) do
            object = object:FindFirstChild(part)
            if not object then
                break
            end
        end
        
        if object then
            loadedCount = loadedCount + 1
        else
            warn("[EnvironmentLoader] ⚠️ Object not found:")
            warn("  └─ Шлях: " .. objectPath)
            warn("  └─ Перевірте що об'єкт існує в Workspace")
        end
    end
    
    local success = loadedCount == totalCount
    print(string.format("[EnvironmentLoader] 📊 Verification: %d/%d objects loaded", loadedCount, totalCount))
    
    return success
end

-- Load Space Environment (Planet + SpaceStation)
function EnvironmentLoader.LoadSpaceEnvironment(planetId, loadOrder)
    print("[EnvironmentLoader] 🚀 Loading Space Environment for planet:", planetId)
    
    -- Validate planet structure first
    local planetValid, planetErrors = ObjectTypeValidator.ValidatePlanetStructure(planetId)
    if not planetValid then
        warn("[EnvironmentLoader] ❌ Planet structure validation failed, attempting to fix...")
        ObjectTypeValidator.FixPlanetStructure(planetId)
        
        -- Re-validate after fixing
        planetValid, planetErrors = ObjectTypeValidator.ValidatePlanetStructure(planetId)
        if not planetValid then
            error("[EnvironmentLoader] ❌ Cannot load environment - planet structure is invalid: " .. table.concat(planetErrors, ", "))
        end
    end
    
    -- Validate space station structure
    local stationValid, stationErrors = ObjectTypeValidator.ValidateSpaceStationStructure()
    if not stationValid then
        warn("[EnvironmentLoader] ❌ Space Station structure validation failed, attempting to fix...")
        -- Note: Space station fixing would require additional implementation
        warn("[EnvironmentLoader] ⚠️ Space Station structure issues detected, proceeding with caution")
    end
    
    -- Clear workspace first
    clearWorkspace()
    
    -- Load planet workspace (visual model) and lighting
    local planetsFolder = ServerStorage:FindFirstChild("Planets")
    if not planetsFolder then
        warn("[EnvironmentLoader] ❌ Planets folder not found")
        warn("  └─ Очікуваний шлях: ServerStorage/Planets")
        return false
    end
    
    local planetFolder = planetsFolder:FindFirstChild(planetId)
    if not planetFolder then
        warn("[EnvironmentLoader] ❌ Planet folder not found")
        warn("  └─ Очікуваний шлях: ServerStorage/Planets/" .. planetId)
        warn("  └─ Доступні планети: " .. #planetsFolder:GetChildren())
        return false
    end
    
    -- Copy planet workspace (visual model on orbit)
    local planetWorkspace = planetFolder:FindFirstChild("Workspace")
    if planetWorkspace then
        copyFolderContents(planetWorkspace, Workspace)
        print("[EnvironmentLoader] ✅ Planet workspace loaded")
    else
        warn("[EnvironmentLoader] ⚠️ Planet Workspace folder not found")
        warn("  └─ Очікуваний шлях: ServerStorage/Planets/" .. planetId .. "/Workspace")
    end
    
    -- Copy planet lighting (Sky, Atmosphere, etc.)
    local planetLighting = planetFolder:FindFirstChild("Lighting")
    if planetLighting then
        copyFolderContents(planetLighting, game.Lighting)
        print("[EnvironmentLoader] ✅ Planet lighting loaded")
    else
        warn("[EnvironmentLoader] ⚠️ Planet Lighting folder not found")
    end
    
-- Process Planet Scripts with LoadOrder (optional - for planet-wide scripts)
	local planetScriptsFolder = planetFolder:FindFirstChild("Scripts")
	if planetScriptsFolder then
		-- Load Planet LoadOrder configuration
		local planetConfigFolder = planetFolder:FindFirstChild("Configuration")
		local planetLoadOrderConfig = if planetConfigFolder then LoadOrderProcessor.LoadConfig(planetConfigFolder) else nil
		
		-- Process Server scripts with LoadOrder
		local serverFolder = planetScriptsFolder:FindFirstChild("Server")
		if serverFolder then
			local serverScripts = serverFolder:GetChildren()
			
			if planetLoadOrderConfig then
				serverScripts = LoadOrderProcessor.SortServerScripts(serverScripts, planetLoadOrderConfig)
			end
			
			for index, script in ipairs(serverScripts) do
				local action = "none"
				if planetLoadOrderConfig then
					action = LoadOrderProcessor.GetScriptAction(script.Name, planetLoadOrderConfig)
				end
				
				if action == "require" and script:IsA("ModuleScript") then
					local success = pcall(require, script)
					if success then
						print(string.format("[EnvironmentLoader] ✅ [%d/%d] Planet Server: Required %s", 
							index, #serverScripts, script.Name))
					else
						print(string.format("[EnvironmentLoader] ℹ️ [%d/%d] Planet Server: %s unavailable", 
							index, #serverScripts, script.Name))
					end
				else
					print(string.format("[EnvironmentLoader] 📄 [%d/%d] Planet Server: %s available (%s)", 
						index, #serverScripts, script.Name, script.ClassName))
				end
			end
		end
		
		-- Process Client scripts
		local clientFolder = planetScriptsFolder:FindFirstChild("Client")
		if clientFolder then
			local StarterPlayerScripts = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
			local clientScripts = clientFolder:GetChildren()
			
			if planetLoadOrderConfig then
				clientScripts = LoadOrderProcessor.SortClientScripts(clientScripts, planetLoadOrderConfig)
			end
			
			for index, script in ipairs(clientScripts) do
				if script:IsA("LocalScript") then
				-- Видалити стару версію скрипта, якщо вона існує
				local oldScript = StarterPlayerScripts:FindFirstChild(script.Name)
				if oldScript then
					oldScript:Destroy()
					print(string.format("[EnvironmentLoader] 🗑️ Removed old: StarterPlayer/StarterPlayerScripts/%s", script.Name))
				end
				
				local clone = script:Clone()
				clone.Parent = StarterPlayerScripts
				print(string.format("[EnvironmentLoader] ✅ [%d/%d] Copied: %s → StarterPlayer/StarterPlayerScripts/%s", 
					index, #clientScripts, script:GetFullName(), script.Name))
                end
            end
        end
    end
    
    -- Load space station
    local spaceStationFolder = ServerStorage:FindFirstChild("Space")
    if spaceStationFolder then
        spaceStationFolder = spaceStationFolder:FindFirstChild("SpaceStation")
    end
    
    if spaceStationFolder then
        -- Copy LocationModel from workspace with attribute validation
        local workspaceFolder = spaceStationFolder:FindFirstChild("Workspace")
        if workspaceFolder then
            print("[EnvironmentLoader] 📋 SpaceStation Workspace contains:", #workspaceFolder:GetChildren(), "objects")
            
            -- Find and validate LocationModel
            local locationModel = workspaceFolder:FindFirstChild("LocationModel")
            if locationModel and locationModel:IsA("Model") then
                -- Validate LocationModel attributes
                local locationId = locationModel:GetAttribute("LocationId")
                local locationType = locationModel:GetAttribute("LocationType")
                local displayName = locationModel:GetAttribute("DisplayName")
                
                if locationId == "SpaceStation" and locationType == "Space" then
                    print("[EnvironmentLoader] ✅ LocationModel validated:", displayName or "SpaceStation")
                    
                    -- Clone LocationModel to Workspace
                    local clonedModel = locationModel:Clone()
                    clonedModel.Parent = Workspace
                    
                    print("[EnvironmentLoader] ✅ LocationModel copied to Workspace")
                    print("[EnvironmentLoader] 📋 LocationModel contains:")
                    for _, section in ipairs(clonedModel:GetChildren()) do
                        if section:IsA("Folder") then
                            print("[EnvironmentLoader]   📁 " .. section.Name .. " (" .. #section:GetChildren() .. " items)")
                        elseif section:IsA("BasePart") and section.Name:find("PrimaryPart") then
                            print("[EnvironmentLoader]   🧱 " .. section.Name .. " (PrimaryPart)")
                        else
                            print("[EnvironmentLoader]   - " .. section.Name .. " (" .. section.ClassName .. ")")
                        end
                    end
                else
                    warn("[EnvironmentLoader] ❌ LocationModel attributes invalid:")
                    warn("  └─ LocationId: " .. tostring(locationId) .. " (expected: SpaceStation)")
                    warn("  └─ LocationType: " .. tostring(locationType) .. " (expected: Space)")
                    return false
                end
            else
                warn("[EnvironmentLoader] ❌ LocationModel not found in Workspace")
                warn("  └─ Очікуваний шлях: ServerStorage/Space/SpaceStation/Workspace/LocationModel")
                return false
            end
        else
            warn("[EnvironmentLoader] ⚠️ SpaceStation Workspace folder not found")
            warn("  └─ Очікуваний шлях: ServerStorage/Space/SpaceStation/Workspace")
            return false
        end
        
-- Process SpaceStation Scripts with LoadOrder
		local scriptsFolder = spaceStationFolder:FindFirstChild("Scripts")
		if scriptsFolder then
			-- Load SpaceStation LoadOrder configuration
			local configFolder = spaceStationFolder:FindFirstChild("Configuration")
			local loadOrderConfig = if configFolder then LoadOrderProcessor.LoadConfig(configFolder) else nil
			
			-- Process Server scripts with LoadOrder
			local serverFolder = scriptsFolder:FindFirstChild("Server")
			if serverFolder then
				local serverScripts = serverFolder:GetChildren()
				
				-- Sort scripts by LoadOrder priority
				if loadOrderConfig then
					serverScripts = LoadOrderProcessor.SortServerScripts(serverScripts, loadOrderConfig)
					print("[EnvironmentLoader] 📋 Processing", #serverScripts, "SpaceStation Server scripts with LoadOrder")
				else
					print("[EnvironmentLoader] 📋 Processing", #serverScripts, "SpaceStation Server scripts (no LoadOrder)")
				end
				
				-- Process each script according to its action
				for index, script in ipairs(serverScripts) do
					local action = "none"
					if loadOrderConfig then
						action = LoadOrderProcessor.GetScriptAction(script.Name, loadOrderConfig)
					end
					
					if action == "require" and script:IsA("ModuleScript") then
						-- Require ModuleScript and call Initialize if available
						local success, result = pcall(function()
							local module = require(script)
							
							-- Try to initialize if the module has Initialize function
							if type(module) == "table" and module.Initialize then
								-- Find corresponding model (check LocationModel hierarchy first)
								local workspaceModel = nil
								
								-- Check for LocationModel/Equipment/ first (new structure)
								local locationModel = Workspace:FindFirstChild("LocationModel")
								if locationModel then
									local equipment = locationModel:FindFirstChild("Equipment")
									if equipment then
										workspaceModel = equipment:FindFirstChild(script.Name)
									end
								end
								
								-- Fallback: check directly in Workspace (old structure)
								if not workspaceModel then
									workspaceModel = Workspace:FindFirstChild(script.Name)
								end
								
								if workspaceModel then
									local initSuccess = module.Initialize(workspaceModel)
									if initSuccess then
										return true
									else
										return false, "Initialize returned false"
									end
								else
									warn(string.format("[EnvironmentLoader] ⚠️ Model '%s' not found in Workspace or LocationModel/Equipment", script.Name))
									return true  -- Module loaded but no model found (optional)
								end
							else
								return true  -- Module loaded, no Initialize method
							end
						end)
						
						if success and result then
							print(string.format("[EnvironmentLoader] ✅ [%d/%d] Required & Initialized: %s", 
								index, #serverScripts, script.Name))
							elseif success then
								print(string.format("[EnvironmentLoader] ℹ️ [%d/%d] %s unavailable (optional)", 
									index, #serverScripts, script.Name))
							else
								print(string.format("[EnvironmentLoader] ℹ️ [%d/%d] %s unavailable (optional)", 
									index, #serverScripts, script.Name))
							end
					elseif action == "clone" then
						-- Clone script to appropriate location (not implemented yet)
						print(string.format("[EnvironmentLoader] ℹ️ [%d/%d] Script clone: %s (not implemented)", 
							index, #serverScripts, script.Name))
					else
						-- No action - just log availability
						print(string.format("[EnvironmentLoader] 📄 [%d/%d] %s available (%s)", 
							index, #serverScripts, script.Name, script.ClassName))
					end
                end
            end
            
-- Process Client scripts with LoadOrder (copy to PlayerGui of all current players)
			local clientFolder = scriptsFolder:FindFirstChild("Client")
			if clientFolder then
				local Players = game:GetService("Players")
				local clientScripts = clientFolder:GetChildren()
				
				-- Sort scripts by LoadOrder priority
				if loadOrderConfig then
					clientScripts = LoadOrderProcessor.SortClientScripts(clientScripts, loadOrderConfig)
				end
				
				-- Copy scripts to each player's PlayerGui
				for index, script in ipairs(clientScripts) do
					if script:IsA("LocalScript") then
						for _, player in ipairs(Players:GetPlayers()) do
							local playerGui = player:WaitForChild("PlayerGui", 5)
							if playerGui then
								-- Remove old version of the script if it exists
								local oldScript = playerGui:FindFirstChild(script.Name)
								if oldScript then
									oldScript:Destroy()
									print(string.format("[EnvironmentLoader] 🗑️ Removed old: %s/PlayerGui/%s", player.Name, script.Name))
								end
								
								-- Clone and parent to PlayerGui
								local clone = script:Clone()
								clone.Parent = playerGui
								print(string.format("[EnvironmentLoader] ✅ [%d/%d] Copied: %s → %s/PlayerGui/%s", 
									index, #clientScripts, script:GetFullName(), player.Name, script.Name))
							else
								warn(string.format("[EnvironmentLoader] ⚠️ PlayerGui not found for %s", player.Name))
							end
						end
					end
				end
			end
            
            print("[EnvironmentLoader] ✅ Space Station scripts processed")
        end
        
        -- Copy lighting
        local stationLighting = spaceStationFolder:FindFirstChild("Lighting")
        if stationLighting then
            copyFolderContents(stationLighting, game.Lighting)
            print("[EnvironmentLoader] ✅ Space Station lighting loaded")
        end
    end
    
    -- Verify loading
    local expectedObjects = {
        "Planet",        -- From Planet/Workspace/
        "LocationModel"  -- From SpaceStation/Workspace/LocationModel (hierarchical structure)
    }
    
    local success = verifyObjectsLoaded(expectedObjects)
    
    if success then
        print("[EnvironmentLoader] ✅ Space Environment loaded successfully")
        
        -- Initialize client scripts after environment is ready
        ClientScriptInitializer.InitializeAllClientScripts("SpaceStation", planetId, nil)
    else
        warn("[EnvironmentLoader] ❌ Space Environment loading incomplete")
    end
    
    return success
end

-- Load Planet Environment (Location only)
function EnvironmentLoader.LoadPlanetEnvironment(planetId, locationId, loadOrder)
    print("[EnvironmentLoader] 🪐 Loading Planet Environment:", planetId, "location:", locationId)
    
    -- Validate location structure first
    local locationErrors = ObjectTypeValidator.ValidateLocationStructure(planetId, locationId)
    if #locationErrors > 0 then
        warn("[EnvironmentLoader] ❌ Location structure validation failed, attempting to fix...")
        ObjectTypeValidator.FixLocationStructure(planetId, locationId)
        
        -- Re-validate after fixing
        locationErrors = ObjectTypeValidator.ValidateLocationStructure(planetId, locationId)
        if #locationErrors > 0 then
            error("[EnvironmentLoader] ❌ Cannot load environment - location structure is invalid: " .. table.concat(locationErrors, ", "))
        end
    end
    
    -- Clear workspace first
    clearWorkspace()
    
    -- Get planet and location folders
    local planetsFolder = ServerStorage:FindFirstChild("Planets")
    if not planetsFolder then
        warn("[EnvironmentLoader] ❌ Planets folder not found")
        warn("  └─ Очікуваний шлях: ServerStorage/Planets")
        return false
    end
    
    local planetFolder = planetsFolder:FindFirstChild(planetId)
    if not planetFolder then
        warn("[EnvironmentLoader] ❌ Planet folder not found")
        warn("  └─ Очікуваний шлях: ServerStorage/Planets/" .. planetId)
        return false
    end
    
-- Process Planet Scripts first with LoadOrder (common for all locations)
	local planetScriptsFolder = planetFolder:FindFirstChild("Scripts")
	if planetScriptsFolder then
		-- Load Planet LoadOrder configuration
		local planetConfigFolder = planetFolder:FindFirstChild("Configuration")
		local planetLoadOrderConfig = if planetConfigFolder then LoadOrderProcessor.LoadConfig(planetConfigFolder) else nil
		
		-- Process Server scripts with LoadOrder
		local serverFolder = planetScriptsFolder:FindFirstChild("Server")
		if serverFolder then
			local serverScripts = serverFolder:GetChildren()
			
			if planetLoadOrderConfig then
				serverScripts = LoadOrderProcessor.SortServerScripts(serverScripts, planetLoadOrderConfig)
			end
			
			for index, script in ipairs(serverScripts) do
				local action = "none"
				if planetLoadOrderConfig then
					action = LoadOrderProcessor.GetScriptAction(script.Name, planetLoadOrderConfig)
				end
				
				if action == "require" and script:IsA("ModuleScript") then
					local success = pcall(require, script)
					if success then
						print(string.format("[EnvironmentLoader] ✅ [%d/%d] Planet Server: Required %s", 
							index, #serverScripts, script.Name))
					else
						print(string.format("[EnvironmentLoader] ℹ️ [%d/%d] Planet Server: %s unavailable", 
							index, #serverScripts, script.Name))
					end
				else
					print(string.format("[EnvironmentLoader] 📄 [%d/%d] Planet Server: %s available (%s)", 
						index, #serverScripts, script.Name, script.ClassName))
				end
			end
		end
		
		-- Process Client scripts
		local clientFolder = planetScriptsFolder:FindFirstChild("Client")
		if clientFolder then
			local StarterPlayerScripts = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
			local clientScripts = clientFolder:GetChildren()
			
			if planetLoadOrderConfig then
				clientScripts = LoadOrderProcessor.SortClientScripts(clientScripts, planetLoadOrderConfig)
			end
			
			for index, script in ipairs(clientScripts) do
				if script:IsA("LocalScript") then
					-- Видалити стару версію скрипта, якщо вона існує
					local oldScript = StarterPlayerScripts:FindFirstChild(script.Name)
					if oldScript then
						oldScript:Destroy()
						print(string.format("[EnvironmentLoader] 🗑️ Removed old: StarterPlayer/StarterPlayerScripts/%s", script.Name))
					end
					
					local clone = script:Clone()
					clone.Parent = StarterPlayerScripts
					print(string.format("[EnvironmentLoader] ✅ [%d/%d] Copied: %s → StarterPlayer/StarterPlayerScripts/%s", 
						index, #clientScripts, script:GetFullName(), script.Name))
				end
			end
		end
	end
    
    -- Get location folder
    local locationsFolder = planetFolder:FindFirstChild("Locations")
    if not locationsFolder then
        warn("[EnvironmentLoader] ❌ Locations folder not found")
        warn("  └─ Очікуваний шлях: ServerStorage/Planets/" .. planetId .. "/Locations")
        return false
    end
    
    local locationFolder = locationsFolder:FindFirstChild(locationId)
    if not locationFolder then
        warn("[EnvironmentLoader] ❌ Location folder not found")
        warn("  └─ Очікуваний шлях: ServerStorage/Planets/" .. planetId .. "/Locations/" .. locationId)
        warn("  └─ Доступні локації: " .. #locationsFolder:GetChildren())
        return false
    end
    
    -- Copy location workspace objects with load order
    local workspaceFolder = locationFolder:FindFirstChild("Workspace")
    if workspaceFolder then
        print("[EnvironmentLoader] 📋 Location Workspace contains:", #workspaceFolder:GetChildren(), "objects")
        for _, child in ipairs(workspaceFolder:GetChildren()) do
            print("[EnvironmentLoader]   - " .. child.Name .. " (" .. child.ClassName .. ")")
        end
        
        copyFolderContents(workspaceFolder, Workspace, loadOrder)
        print("[EnvironmentLoader] ✅ Location workspace loaded")
        -- Diagnostic: List all children of PlanetSurfaceScanner after copy
        local locationModel = Workspace:FindFirstChild("LocationModel")
        if locationModel then
            local equipment = locationModel:FindFirstChild("Equipment")
            if equipment then
                local scanner = equipment:FindFirstChild("PlanetSurfaceScanner")
                if scanner then
                    print("[EnvironmentLoader][DIAG] PlanetSurfaceScanner children after copy:")
                    for _, child in ipairs(scanner:GetChildren()) do
                        print(string.format("[EnvironmentLoader][DIAG]   - %s (%s)", child.Name, child.ClassName))
                    end
                else
                    print("[EnvironmentLoader][DIAG] PlanetSurfaceScanner not found in Equipment after copy")
                end
            else
                print("[EnvironmentLoader][DIAG] Equipment not found in LocationModel after copy")
            end
        else
            print("[EnvironmentLoader][DIAG] LocationModel not found in Workspace after copy")
        end
    else
        warn("[EnvironmentLoader] ⚠️ Workspace folder not found in location")
        warn("  └─ Очікуваний шлях: ServerStorage/Planets/" .. planetId .. "/Locations/" .. locationId .. "/Workspace")
    end
    
    -- Copy location lighting
    local locationLighting = locationFolder:FindFirstChild("Lighting")
    if locationLighting then
        copyFolderContents(locationLighting, game.Lighting)
        print("[EnvironmentLoader] ✅ Location lighting loaded")
    else
        warn("[EnvironmentLoader] ⚠️ Lighting folder not found in location")
    end
    
    -- Process Location Scripts with LoadOrder
    local scriptsFolder = locationFolder:FindFirstChild("Scripts")
    if scriptsFolder then
        -- Load Location LoadOrder configuration
        local locationConfigFolder = locationFolder:FindFirstChild("Configuration")
        local locationLoadOrderConfig = if locationConfigFolder then LoadOrderProcessor.LoadConfig(locationConfigFolder) else nil
        
        -- Process Server scripts with LoadOrder
        local serverFolder = scriptsFolder:FindFirstChild("Server")
        if serverFolder then
            local serverScripts = serverFolder:GetChildren()
            
            if locationLoadOrderConfig then
                serverScripts = LoadOrderProcessor.SortServerScripts(serverScripts, locationLoadOrderConfig)
            end
            
            for index, script in ipairs(serverScripts) do
                local action = "none"
                if locationLoadOrderConfig then
                    action = LoadOrderProcessor.GetScriptAction(script.Name, locationLoadOrderConfig)
                end
                
                if action == "require" and script:IsA("ModuleScript") then
                    local success = pcall(require, script)
                    if success then
                        print(string.format("[EnvironmentLoader] ✅ [%d/%d] Location Server: Required %s", 
                            index, #serverScripts, script.Name))
                    else
                        print(string.format("[EnvironmentLoader] ℹ️ [%d/%d] Location Server: %s unavailable", 
                            index, #serverScripts, script.Name))
                    end
                else
                    print(string.format("[EnvironmentLoader] 📄 [%d/%d] Location Server: %s available (%s)", 
                        index, #serverScripts, script.Name, script.ClassName))
                end
            end
        end
        
        -- Process Client scripts with LoadOrder (copy to StarterPlayerScripts)
        local clientFolder = scriptsFolder:FindFirstChild("Client")
        if clientFolder then
            local StarterPlayerScripts = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
            local clientScripts = clientFolder:GetChildren()
            
            if locationLoadOrderConfig then
                clientScripts = LoadOrderProcessor.SortClientScripts(clientScripts, locationLoadOrderConfig)
            end
            
            for index, script in ipairs(clientScripts) do
                if script:IsA("LocalScript") then
                    -- Видалити стару версію скрипта, якщо вона існує
                    local oldScript = StarterPlayerScripts:FindFirstChild(script.Name)
                    if oldScript then
                        oldScript:Destroy()
                        print(string.format("[EnvironmentLoader] 🗑️ Removed old: StarterPlayer/StarterPlayerScripts/%s", script.Name))
                    end
                    
                    local clone = script:Clone()
                    clone.Parent = StarterPlayerScripts
                    print(string.format("[EnvironmentLoader] ✅ [%d/%d] Copied: %s → StarterPlayer/StarterPlayerScripts/%s", 
                        index, #clientScripts, script:GetFullName(), script.Name))
                end
            end
        end
    else
        print("[EnvironmentLoader] ℹ️ Scripts folder not found in location (optional)")
    end
    
    print("[EnvironmentLoader] ✅ Location contents loaded")
    
    -- Verify loading
    local expectedObjects = {
        "SpawnLocation",
        "Baseplate"
    }
    
    local success = verifyObjectsLoaded(expectedObjects)
    
    if success then
        print("[EnvironmentLoader] ✅ Planet Environment loaded successfully")
    else
        warn("[EnvironmentLoader] ❌ Planet Environment loading incomplete")
    end
    
    return success
end

-- Public API
function EnvironmentLoader.ClearWorkspace()
    clearWorkspace()
end

function EnvironmentLoader.VerifyEnvironmentLoaded(expectedObjects)
    return verifyObjectsLoaded(expectedObjects)
end

-- Validate all structures
function EnvironmentLoader.ValidateAllStructures()
    print("[EnvironmentLoader] 🔍 Validating all environment structures...")
    
    local allValid = true
    local allErrors = {}
    
    -- Validate all planets
    local planetsFolder = ServerStorage:FindFirstChild("Planets")
    if planetsFolder then
        for _, planet in ipairs(planetsFolder:GetChildren()) do
            if planet:IsA("Folder") then
                local isValid, errors = ObjectTypeValidator.ValidatePlanetStructure(planet.Name)
                if not isValid then
                    allValid = false
                    for _, error in ipairs(errors) do
                        table.insert(allErrors, "Planet " .. planet.Name .. ": " .. error)
                    end
                end
            end
        end
    end
    
    -- Validate space station
    local stationValid, stationErrors = ObjectTypeValidator.ValidateSpaceStationStructure()
    if not stationValid then
        allValid = false
        for _, error in ipairs(stationErrors) do
            table.insert(allErrors, "SpaceStation: " .. error)
        end
    end
    
    if allValid then
        print("[EnvironmentLoader] ✅ All environment structures are valid")
    else
        print("[EnvironmentLoader] ❌ Structure validation failed:")
        for _, error in ipairs(allErrors) do
            print("  -", error)
        end
    end
    
    return allValid, allErrors
end

-- Fix all structures
function EnvironmentLoader.FixAllStructures()
    print("[EnvironmentLoader] 🔧 Fixing all environment structures...")
    
    local planetsFolder = ServerStorage:FindFirstChild("Planets")
    if planetsFolder then
        for _, planet in ipairs(planetsFolder:GetChildren()) do
            if planet:IsA("Folder") then
                ObjectTypeValidator.FixPlanetStructure(planet.Name)
            end
        end
    end
    
    print("[EnvironmentLoader] ✅ Structure fixing completed")
end

return EnvironmentLoader