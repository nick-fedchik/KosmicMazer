--[[
================================================================================
KOSMICMAZER — Environment Loader
================================================================================

Purpose: Handles loading/unloading of game environments (Space/Planet)
Version: 1.0

Features:
- Loads Space Environment (Planet + SpaceStation)
- Loads Planet Environment (Location only)
- Clears Workspace completely
- Verifies all objects loaded
- Template-based loading system

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
- Version 1.0: Initial implementation for Phase 1 refactoring

================================================================================
]]

local EnvironmentLoader = {}

-- Services
local Workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")

-- Load dependencies
local GameConfig = require(game.ServerScriptService.GameConfig)

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

-- Helper function to copy folder contents
local function copyFolderContents(sourceFolder, targetParent)
    if not sourceFolder or not targetParent then
        return false
    end
    
    for _, child in ipairs(sourceFolder:GetChildren()) do
        local clone = child:Clone()
        clone.Parent = targetParent
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
            warn("[EnvironmentLoader] ⚠️ Object not found:", objectPath)
        end
    end
    
    local success = loadedCount == totalCount
    print(string.format("[EnvironmentLoader] 📊 Verification: %d/%d objects loaded", loadedCount, totalCount))
    
    return success
end

-- Load Space Environment (Planet + SpaceStation)
function EnvironmentLoader.LoadSpaceEnvironment(planetId)
    print("[EnvironmentLoader] 🚀 Loading Space Environment for planet:", planetId)
    
    -- Clear workspace first
    clearWorkspace()
    
    -- Load planet model and lighting
    local planetFolder = ServerStorage:FindFirstChild("Planets"):FindFirstChild(planetId)
    if not planetFolder then
        warn("[EnvironmentLoader] ❌ Planet folder not found:", planetId)
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
        -- Copy all models
        local modelsFolder = spaceStationFolder:FindFirstChild("Models")
        if modelsFolder then
            copyFolderContents(modelsFolder, Workspace)
            print("[EnvironmentLoader] ✅ Space Station models loaded")
        end
        
        -- Copy scripts
        local scriptsFolder = spaceStationFolder:FindFirstChild("Scripts")
        if scriptsFolder then
            copyFolderContents(scriptsFolder, Workspace)
            print("[EnvironmentLoader] ✅ Space Station scripts loaded")
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
        "SpawnLocation",
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
function EnvironmentLoader.LoadPlanetEnvironment(planetId, locationId)
    print("[EnvironmentLoader] 🪐 Loading Planet Environment:", planetId, "location:", locationId)
    
    -- Clear workspace first
    clearWorkspace()
    
    -- Get location folder
    local locationFolder = ServerStorage:FindFirstChild("Planets")
        :FindFirstChild(planetId)
        :FindFirstChild("Locations")
        :FindFirstChild(locationId)
    
    if not locationFolder then
        warn("[EnvironmentLoader] ❌ Location folder not found:", planetId, locationId)
        return false
    end
    
    -- Copy all location contents
    for _, child in ipairs(locationFolder:GetChildren()) do
        if child.Name ~= "Configuration" then -- Don't copy config to workspace
            child:Clone().Parent = Workspace
        end
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

return EnvironmentLoader