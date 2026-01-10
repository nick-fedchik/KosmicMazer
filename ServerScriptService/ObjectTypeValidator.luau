--[[
================================================================================
KOSMICMAZER — Object Type Validator
================================================================================

Purpose: Validates object types and structure in ServerStorage
Version: 1.4

Features:
- Validates planet structure integrity
- Validates location structure integrity (LocationModel hierarchy)
- Validates space station structure integrity (LocationModel hierarchy)
- Provides detailed error reporting
- Supports automatic structure fixing with attribute auto-correction
- Supports LocationModel hierarchical structure (Architecture/Equipment/Environment/Gameplay)
- Auto-sets LocationModel attributes (LocationId, LocationType, PlanetId)

API:
- ValidatePlanetStructure(planetId): Validates planet folder structure
- ValidateLocationStructure(planetId, locationId): Validates location folder structure
- ValidateSpaceStationStructure(): Validates space station structure
- FixPlanetStructure(planetId): Attempts to fix planet structure issues
- FixLocationStructure(planetId, locationId): Attempts to fix location structure issues

Dependencies:
- ServerStorage: For accessing template structures

ChangeLog:
- Version 1.4: FixLocationStructure now auto-sets/updates LocationModel attributes (2026-01-08)
- Version 1.4: Added attribute validation and correction even if LocationModel exists
- Version 1.4: Improved logging for attribute changes during structure fixing
- Version 1.3: Updated for LocationModel hierarchical structure (ETAP 1-6 support)
- Version 1.2: Updated for new folder structure (Workspace instead of Models/PlanetModel)
- Version 1.1: Added structure validation and fixing
- Version 1.0: Initial implementation for Phase 1 refactoring

================================================================================
]]

local ObjectTypeValidator = {}

-- Services
local ServerStorage = game:GetService("ServerStorage")

-- Expected structure definitions
local EXPECTED_PLANET_STRUCTURE = {
    "Workspace",     -- Changed from PlanetModel
    "Lighting", 
    "Scripts",
    "Configuration",
    "Locations"
}

local EXPECTED_LOCATION_STRUCTURE = {
    "Workspace",     -- Changed from Models
    "Scripts",
    "Lighting", 
    "Configuration"
}

-- LocationModel hierarchical structure
local EXPECTED_LOCATIONMODEL_FOLDERS = {
    "Architecture",
    "Equipment",
    "Environment",
    "Gameplay"
}

local EXPECTED_GAMEPLAY_OBJECTS = {
    "SpawnLocation"  -- Required spawn point
}

local EXPECTED_ARCHITECTURE_OBJECTS = {
    "Baseplate"  -- Optional base platform
}

local EXPECTED_SPACE_STATION_STRUCTURE = {
    "Workspace",     -- Changed from Models
    "Scripts",
    "Configuration"
    -- Note: Lighting removed - SpaceStation uses Planet Lighting
}

-- SpaceStation uses LocationModel structure now
-- SpawnLocation is in LocationModel/Gameplay/
-- PlanetSurfaceScanner is in LocationModel/Equipment/

local EXPECTED_SPACE_STATION_SCRIPTS = {
    "Server",
    "Client"
}

local EXPECTED_SPACE_STATION_SERVER_SCRIPTS = {
    "PlanetSurfaceScanner"
}

local EXPECTED_SPACE_STATION_CLIENT_SCRIPTS = {
    "SpaceStationUI",
    "PlanetSurfaceScannerUI"
}

-- Helper function to validate object type
local function validateObjectType(object, expectedType, objectPath)
    if not object then
        return false, string.format("[MISSING] '%s' not found (expected: %s)", objectPath, expectedType)
    end
    
    if expectedType == "Folder" and not object:IsA("Folder") then
        return false, string.format("[WRONG TYPE] '%s' expected Folder, got %s", objectPath, object.ClassName)
    end
    
    if expectedType == "Model" and not object:IsA("Model") then
        return false, string.format("[WRONG TYPE] '%s' expected Model, got %s", objectPath, object.ClassName)
    end
    
    if expectedType == "Part" and not object:IsA("BasePart") then
        return false, string.format("[WRONG TYPE] '%s' expected Part/BasePart, got %s", objectPath, object.ClassName)
    end
    
    if expectedType == "SpawnLocation" and not object:IsA("SpawnLocation") then
        return false, string.format("[WRONG TYPE] '%s' expected SpawnLocation, got %s", objectPath, object.ClassName)
    end
    
    return true, "OK"
end

-- Validate planet structure
function ObjectTypeValidator.ValidatePlanetStructure(planetId)
    print("[ObjectTypeValidator] 🔍 Validating planet structure:", planetId, "(v1.3 - LocationModel hierarchy)")
    
    local planetsFolder = ServerStorage:FindFirstChild("Planets")
    if not planetsFolder then
        return false, {"[MISSING] 'ServerStorage/Planets' folder not found"}
    end
    
    local planetFolder = planetsFolder:FindFirstChild(planetId)
    if not planetFolder then
        return false, {string.format("[MISSING] 'ServerStorage/Planets/%s' folder not found", planetId)}
    end
    
    local errors = {}
    
    -- Check main structure
    for _, expectedFolder in ipairs(EXPECTED_PLANET_STRUCTURE) do
        local folder = planetFolder:FindFirstChild(expectedFolder)
        local isValid, message = validateObjectType(folder, "Folder", "Planets." .. planetId .. "." .. expectedFolder)
        if not isValid then
            table.insert(errors, message)
        end
    end
    
    -- Check Workspace contains Planet model
    local workspaceFolder = planetFolder:FindFirstChild("Workspace")
    if workspaceFolder then
        local planetModel = workspaceFolder:FindFirstChild("Planet")
        local isValid, message = validateObjectType(planetModel, "Model", "Planets." .. planetId .. ".Workspace.Planet")
        if not isValid then
            table.insert(errors, message)
        end
    end
    
    -- Check Locations folder
    local locationsFolder = planetFolder:FindFirstChild("Locations")
    if locationsFolder then
        for _, location in ipairs(locationsFolder:GetChildren()) do
            if location:IsA("Folder") then
                local locationErrors = ObjectTypeValidator.ValidateLocationStructure(planetId, location.Name)
                for _, error in ipairs(locationErrors) do
                    table.insert(errors, error)
                end
            end
        end
    end
    
    if #errors > 0 then
        print("[ObjectTypeValidator] ❌ Planet structure validation failed:")
        for _, error in ipairs(errors) do
            print("  -", error)
        end
        return false, errors
    else
        print("[ObjectTypeValidator] ✅ Planet structure validation passed")
        return true, {}
    end
end

-- Validate location structure
function ObjectTypeValidator.ValidateLocationStructure(planetId, locationId)
    local planetsFolder = ServerStorage:FindFirstChild("Planets")
    if not planetsFolder then
        return {"[MISSING] 'ServerStorage/Planets' folder not found"}
    end
    
    local planetFolder = planetsFolder:FindFirstChild(planetId)
    if not planetFolder then
        return {string.format("[MISSING] 'ServerStorage/Planets/%s' folder not found", planetId)}
    end
    
    local locationsFolder = planetFolder:FindFirstChild("Locations")
    if not locationsFolder then
        return {string.format("[MISSING] 'ServerStorage/Planets/%s/Locations' folder not found", planetId)}
    end
    
    local locationFolder = locationsFolder:FindFirstChild(locationId)
    if not locationFolder then
        return {string.format("[MISSING] 'ServerStorage/Planets/%s/Locations/%s' folder not found", planetId, locationId)}
    end
    
    local errors = {}
    
    -- Check main structure
    for _, expectedFolder in ipairs(EXPECTED_LOCATION_STRUCTURE) do
        local folder = locationFolder:FindFirstChild(expectedFolder)
        local isValid, message = validateObjectType(folder, "Folder", "Planets." .. planetId .. ".Locations." .. locationId .. "." .. expectedFolder)
        if not isValid then
            table.insert(errors, message)
        end
    end
    
    -- Check Workspace folder contents - LocationModel hierarchy
    local workspaceFolder = locationFolder:FindFirstChild("Workspace")
    if workspaceFolder then
        local locationModel = workspaceFolder:FindFirstChild("LocationModel")
        
        if locationModel then
            
            -- Check LocationModel hierarchy folders
            for _, folderName in ipairs(EXPECTED_LOCATIONMODEL_FOLDERS) do
                local folder = locationModel:FindFirstChild(folderName)
                local isValid, message = validateObjectType(folder, "Folder", "Planets." .. planetId .. ".Locations." .. locationId .. ".Workspace.LocationModel." .. folderName)
                if not isValid then
                    table.insert(errors, message)
                end
            end
            
            -- Check Gameplay folder for required SpawnLocation
            local gameplayFolder = locationModel:FindFirstChild("Gameplay")
            if gameplayFolder then
                for _, objectName in ipairs(EXPECTED_GAMEPLAY_OBJECTS) do
                    local object = gameplayFolder:FindFirstChild(objectName)
                    local isValid, message = validateObjectType(object, "SpawnLocation", "Planets." .. planetId .. ".Locations." .. locationId .. ".Workspace.LocationModel.Gameplay." .. objectName)
                    if not isValid then
                        table.insert(errors, message)
                    end
                end
            end
            
            -- Check Architecture folder for optional Baseplate
            local architectureFolder = locationModel:FindFirstChild("Architecture")
            if architectureFolder then
                for _, objectName in ipairs(EXPECTED_ARCHITECTURE_OBJECTS) do
                    local object = architectureFolder:FindFirstChild(objectName)
                    -- Baseplate is optional, just log info
                    if not object then
                        print("[ObjectTypeValidator] ℹ️ Optional object '", objectName, "' not found in", planetId, "/", locationId)
                    end
                end
            end
        else
            -- Fallback: old structure warning
            table.insert(errors, string.format("[MISSING] LocationModel not found in %s/%s - old structure not supported", planetId, locationId))
        end
    end
    
    return errors
end

-- Validate space station structure
function ObjectTypeValidator.ValidateSpaceStationStructure()
    print("[ObjectTypeValidator] 🔍 Validating Space Station structure")
    
    local spaceFolder = ServerStorage:FindFirstChild("Space")
    if not spaceFolder then
        return false, {"[MISSING] 'ServerStorage/Space' folder not found"}
    end
    
    local spaceStationFolder = spaceFolder:FindFirstChild("SpaceStation")
    if not spaceStationFolder then
        return false, {"[MISSING] 'ServerStorage/Space/SpaceStation' folder not found"}
    end
    
    local errors = {}
    
    -- Check main structure
    for _, expectedFolder in ipairs(EXPECTED_SPACE_STATION_STRUCTURE) do
        local folder = spaceStationFolder:FindFirstChild(expectedFolder)
        local isValid, message = validateObjectType(folder, "Folder", "Space.SpaceStation." .. expectedFolder)
        if not isValid then
            table.insert(errors, message)
        end
    end
    
    -- Check for Scripts folder structure
    local scriptsFolder = spaceStationFolder:FindFirstChild("Scripts")
    if scriptsFolder then
        for _, scriptFolderName in ipairs(EXPECTED_SPACE_STATION_SCRIPTS) do
            local scriptFolder = scriptsFolder:FindFirstChild(scriptFolderName)
            if scriptFolder then
                print("    ✅ Scripts/" .. scriptFolderName .. " - Folder")
            else
                table.insert(errors, "SpaceStation.Scripts." .. scriptFolderName .. " folder missing")
            end
        end
        
        -- Check Server scripts
        local serverFolder = scriptsFolder:FindFirstChild("Server")
        if serverFolder then
            for _, scriptName in ipairs(EXPECTED_SPACE_STATION_SERVER_SCRIPTS) do
                local script = serverFolder:FindFirstChild(scriptName)
                if script then
                    print("      ✅ Server/" .. scriptName .. " - " .. script.ClassName)
                else
                    local fullPath = "ServerStorage/Space/SpaceStation/Scripts/Server/" .. scriptName
                    table.insert(errors, string.format("[MISSING] '%s' (expected: ModuleScript or Script)", fullPath))
                end
            end
        end
        
        -- Check Client scripts
        local clientFolder = scriptsFolder:FindFirstChild("Client")
        if clientFolder then
            for _, scriptName in ipairs(EXPECTED_SPACE_STATION_CLIENT_SCRIPTS) do
                local script = clientFolder:FindFirstChild(scriptName)
                if script then
                    print("      ✅ Client/" .. scriptName .. " - " .. script.ClassName)
                else
                    local fullPath = "ServerStorage/Space/SpaceStation/Scripts/Client/" .. scriptName
                    table.insert(errors, string.format("[MISSING] '%s' (expected: LocalScript)", fullPath))
                end
            end
        else
            table.insert(errors, "[MISSING] 'ServerStorage/Space/SpaceStation/Scripts/Client' folder")
        end
    end
    
    if #errors > 0 then
        print("[ObjectTypeValidator] ❌ Space Station structure validation failed (" .. #errors .. " issues):")
        print("  ┌─────────────────────────────────────────────────────────────")
        for i, err in ipairs(errors) do
            print("  │ " .. i .. ". " .. err)
        end
        print("  └─────────────────────────────────────────────────────────────")
        print("[ObjectTypeValidator] 💡 Fix: Create missing objects in ServerStorage/Space/SpaceStation/")
        return false, errors
    else
        print("[ObjectTypeValidator] ✅ Space Station structure validation passed")
        return true, {}
    end
end

-- Fix planet structure
function ObjectTypeValidator.FixPlanetStructure(planetId)
    print("[ObjectTypeValidator] 🔧 Fixing planet structure:", planetId)
    
    local planetFolder = ServerStorage:FindFirstChild("Planets"):FindFirstChild(planetId)
    if not planetFolder then
        warn("[ObjectTypeValidator] ❌ Cannot fix - planet folder not found:", planetId)
        return false
    end
    
    -- Create missing folders
    for _, folderName in ipairs(EXPECTED_PLANET_STRUCTURE) do
        local folder = planetFolder:FindFirstChild(folderName)
        if not folder then
            folder = Instance.new("Folder")
            folder.Name = folderName
            folder.Parent = planetFolder
            print("[ObjectTypeValidator] ✅ Created missing folder:", folderName)
        end
    end
    
    -- Fix locations
    local locationsFolder = planetFolder:FindFirstChild("Locations")
    if locationsFolder then
        for _, location in ipairs(locationsFolder:GetChildren()) do
            if location:IsA("Folder") then
                ObjectTypeValidator.FixLocationStructure(planetId, location.Name)
            end
        end
    end
    
    return true
end

-- Fix location structure
function ObjectTypeValidator.FixLocationStructure(planetId, locationId)
    print("[ObjectTypeValidator] 🔧 Fixing location structure:", planetId, "/", locationId)
    
    local locationFolder = ServerStorage:FindFirstChild("Planets")
        :FindFirstChild(planetId)
        :FindFirstChild("Locations")
        :FindFirstChild(locationId)
    
    if not locationFolder then
        warn("[ObjectTypeValidator] ❌ Cannot fix - location folder not found:", planetId, locationId)
        return false
    end
    
    -- Create missing folders
    for _, folderName in ipairs(EXPECTED_LOCATION_STRUCTURE) do
        local folder = locationFolder:FindFirstChild(folderName)
        if not folder then
            folder = Instance.new("Folder")
            folder.Name = folderName
            folder.Parent = locationFolder
            print("[ObjectTypeValidator] ✅ Created missing folder:", folderName)
        end
    end
    
    -- Create LocationModel hierarchy in Workspace folder
    local workspaceFolder = locationFolder:FindFirstChild("Workspace")
    if workspaceFolder then
        local locationModel = workspaceFolder:FindFirstChild("LocationModel")
        if not locationModel then
            locationModel = Instance.new("Folder")
            locationModel.Name = "LocationModel"
            locationModel.Parent = workspaceFolder
            print("[ObjectTypeValidator] ✅ Created LocationModel")
        end
        
        -- Always set/update LocationModel attributes (even if folder existed)
        local currentLocationId = locationModel:GetAttribute("LocationId")
        local currentLocationType = locationModel:GetAttribute("LocationType")
        local currentPlanetId = locationModel:GetAttribute("PlanetId")
        
        if currentLocationId ~= locationId then
            locationModel:SetAttribute("LocationId", locationId)
            print("[ObjectTypeValidator] ✅ Set LocationId =", locationId)
        end
        
        if currentLocationType ~= "Planet" then
            locationModel:SetAttribute("LocationType", "Planet")
            print("[ObjectTypeValidator] ✅ Set LocationType = Planet")
        end
        
        if currentPlanetId ~= planetId then
            locationModel:SetAttribute("PlanetId", planetId)
            print("[ObjectTypeValidator] ✅ Set PlanetId =", planetId)
        end
        
        if not locationModel:GetAttribute("DisplayName") then
            locationModel:SetAttribute("DisplayName", locationId)
            print("[ObjectTypeValidator] ✅ Set DisplayName =", locationId)
        end
        
        -- Create LocationModel hierarchy folders
        for _, folderName in ipairs(EXPECTED_LOCATIONMODEL_FOLDERS) do
            local folder = locationModel:FindFirstChild(folderName)
            if not folder then
                folder = Instance.new("Folder")
                folder.Name = folderName
                folder.Parent = locationModel
                print("[ObjectTypeValidator] ✅ Created LocationModel/" .. folderName)
            end
        end
        
        -- Move old SpawnLocation to LocationModel/Gameplay/ if exists
        local oldSpawnLocation = workspaceFolder:FindFirstChild("SpawnLocation")
        if oldSpawnLocation then
            local gameplayFolder = locationModel:FindFirstChild("Gameplay")
            if gameplayFolder and not gameplayFolder:FindFirstChild("SpawnLocation") then
                oldSpawnLocation.Parent = gameplayFolder
                print("[ObjectTypeValidator] ✅ Moved SpawnLocation to LocationModel/Gameplay/")
            end
        end
        
        -- Move old Baseplate to LocationModel/Architecture/ if exists
        local oldBaseplate = workspaceFolder:FindFirstChild("Baseplate")
        if oldBaseplate then
            local architectureFolder = locationModel:FindFirstChild("Architecture")
            if architectureFolder and not architectureFolder:FindFirstChild("Baseplate") then
                oldBaseplate.Parent = architectureFolder
                print("[ObjectTypeValidator] ✅ Moved Baseplate to LocationModel/Architecture/")
            end
        end
    end
    
    return true
end

return ObjectTypeValidator