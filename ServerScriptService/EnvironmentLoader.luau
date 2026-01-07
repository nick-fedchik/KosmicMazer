--[[
================================================================================
KOSMICMAZER — Environment Loader
================================================================================

Purpose: Handles loading/unloading of game environments (Space/Planet)
Version: 1.3

Features:
- Loads Space Environment (Planet + SpaceStation)
- Loads Planet Environment (Location only)
- Clears Workspace completely
- Verifies all objects loaded
- Template-based loading system
- Supports custom LoadOrder configuration

API:
- LoadSpaceEnvironment(planetId): Loads space environment with planet
- LoadPlanetEnvironment(planetId, locationId): Loads planet location
- ClearWorkspace(): Clears all objects from workspace
- VerifyEnvironmentLoaded(expectedObjects): Verifies loading success

Dependencies:
- GameConfig: For environment configuration
- ServerStorage: For template access
- Workspace: Target for loading

ChangeLog:
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
    
    print("[EnvironmentLoader] ✅ Workspace cleared")
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
    
    for _, child in ipairs(children) do
        local clone = child:Clone()
        clone.Parent = targetParent
        print("[EnvironmentLoader] 📦 Copied:", child.Name, "(" .. child.ClassName .. ") to", targetParent:GetFullName())
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
    
    -- Load planet model and lighting
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
    
    -- Copy planet model
    local planetModel = planetFolder:FindFirstChild("PlanetModel")
    if planetModel then
        copyFolderContents(planetModel, Workspace)
        print("[EnvironmentLoader] ✅ Planet model loaded")
    end
    
    -- Copy planet lighting
    local planetLighting = planetFolder:FindFirstChild("Lighting")
    if planetLighting then
        copyFolderContents(planetLighting, game.Lighting)
        print("[EnvironmentLoader] ✅ Planet lighting loaded")
    end
    
    -- Load space station
    local spaceStationFolder = ServerStorage:FindFirstChild("Space"):FindFirstChild("SpaceStation")
    if spaceStationFolder then
        -- Copy all models with load order
        local modelsFolder = spaceStationFolder:FindFirstChild("Models")
        if modelsFolder then
            print("[EnvironmentLoader] 📋 Models folder contains:", #modelsFolder:GetChildren(), "objects")
            for _, child in ipairs(modelsFolder:GetChildren()) do
                print("[EnvironmentLoader]   - " .. child.Name .. " (" .. child.ClassName .. ")")
            end
            
            copyFolderContents(modelsFolder, Workspace, loadOrder)
            print("[EnvironmentLoader] ✅ Space Station models loaded")
            
            -- Verify what's in Workspace after copying
            print("[EnvironmentLoader] 📋 Workspace now contains:")
            for _, child in ipairs(Workspace:GetChildren()) do
                print("[EnvironmentLoader]   - " .. child.Name .. " (" .. child.ClassName .. ")")
                if child:IsA("Model") or child:IsA("Folder") then
                    for _, subChild in ipairs(child:GetChildren()) do
                        print("[EnvironmentLoader]     └─ " .. subChild.Name .. " (" .. subChild.ClassName .. ")")
                    end
                end
            end
        end
        
        -- Process SpaceStation Scripts
        local scriptsFolder = spaceStationFolder:FindFirstChild("Scripts")
        if scriptsFolder then
            -- Process Server scripts (keep in ServerStorage for LocationManager access)
            local serverFolder = scriptsFolder:FindFirstChild("Server")
            if serverFolder then
                -- Server scripts remain in ServerStorage - LocationManager will access them directly
                print("  ✅ Server scripts available in ServerStorage:", #serverFolder:GetChildren(), "scripts")
                for _, script in ipairs(serverFolder:GetChildren()) do
                    print("    -", script.Name, "(" .. script.ClassName .. ")")
                end
            end
            
            -- Process Client scripts (copy to StarterPlayerScripts)
            local clientFolder = scriptsFolder:FindFirstChild("Client")
            if clientFolder then
                local StarterPlayerScripts = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
                for _, script in ipairs(clientFolder:GetChildren()) do
                    if script:IsA("LocalScript") then
                        local clone = script:Clone()
                        clone.Parent = StarterPlayerScripts
                        print("  ✅ Client Script copied to StarterPlayerScripts:", script.Name)
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
        "Planet",
        "SpaceStation",
        "SpaceStation.SpawnLocation",  -- SpawnLocation is inside SpaceStation folder
        "PlanetSurfaceScanner"
    }
    
    local success = verifyObjectsLoaded(expectedObjects)
    
    if success then
        print("[EnvironmentLoader] ✅ Space Environment loaded successfully")
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
    
    -- Get location folder
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
    
    -- Copy location models with load order
    local modelsFolder = locationFolder:FindFirstChild("Models")
    if modelsFolder then
        print("[EnvironmentLoader] 📋 Models folder contains:", #modelsFolder:GetChildren(), "objects")
        for _, child in ipairs(modelsFolder:GetChildren()) do
            print("[EnvironmentLoader]   - " .. child.Name .. " (" .. child.ClassName .. ")")
        end
        
        copyFolderContents(modelsFolder, Workspace, loadOrder)
        print("[EnvironmentLoader] ✅ Location models loaded")
    else
        warn("[EnvironmentLoader] ⚠️ Models folder not found in location")
        warn("  └─ Очікуваний шлях: ServerStorage/Planets/" .. planetId .. "/Locations/" .. locationId .. "/Models")
    end
    
    -- Copy location lighting
    local locationLighting = locationFolder:FindFirstChild("Lighting")
    if locationLighting then
        copyFolderContents(locationLighting, game.Lighting)
        print("[EnvironmentLoader] ✅ Location lighting loaded")
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