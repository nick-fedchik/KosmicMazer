--[[
================================================================================
KOSMICMAZER — Object Type Validator
================================================================================

Purpose: Validates object types and structure in ServerStorage
Version: 1.1

Features:
- Validates planet structure integrity
- Validates location structure integrity
- Validates space station structure integrity
- Provides detailed error reporting
- Supports automatic structure fixing

API:
- ValidatePlanetStructure(planetId): Validates planet folder structure
- ValidateLocationStructure(planetId, locationId): Validates location folder structure
- ValidateSpaceStationStructure(): Validates space station structure
- FixPlanetStructure(planetId): Attempts to fix planet structure issues
- FixLocationStructure(planetId, locationId): Attempts to fix location structure issues

Dependencies:
- ServerStorage: For accessing template structures

ChangeLog:
- Version 1.0: Initial implementation for Phase 1 refactoring

================================================================================
]]

local ObjectTypeValidator = {}

-- Services
local ServerStorage = game:GetService("ServerStorage")

-- Expected structure definitions
local EXPECTED_PLANET_STRUCTURE = {
    "PlanetModel",
    "Lighting", 
    "Scripts",
    "Configuration",
    "Locations"
}

local EXPECTED_LOCATION_STRUCTURE = {
    "Models",
    "Scripts",
    "Lighting", 
    "Configuration"
}

local EXPECTED_LOCATION_MODELS = {
    "InteractionObjects",
    "Baseplate",
    "SpawnLocation"
}

local EXPECTED_SPACE_STATION_STRUCTURE = {
    "Models",
    "Scripts",
    "Lighting",
    "Configuration"
}

local EXPECTED_SPACE_STATION_MODELS = {
    "SpawnLocation",
    "SpaceStation",
    "PlanetSurfaceScanner"
}

local EXPECTED_SPACE_STATION_SCRIPTS = {
    "Server",
    "Client"
}

local EXPECTED_SPACE_STATION_SERVER_SCRIPTS = {
    "PlanetSurfaceScanner"
}

local EXPECTED_SPACE_STATION_CLIENT_SCRIPTS = {
    "StationUI",
    "ScannerUI"
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
    print("[ObjectTypeValidator] 🔍 Validating planet structure:", planetId)
    
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
    
    -- Check PlanetModel contains Planet model
    local planetModelFolder = planetFolder:FindFirstChild("PlanetModel")
    if planetModelFolder then
        local planetModel = planetModelFolder:FindFirstChild("Planet")
        local isValid, message = validateObjectType(planetModel, "Model", "Planets." .. planetId .. ".PlanetModel.Planet")
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
    
    -- Check Models folder contents
    local modelsFolder = locationFolder:FindFirstChild("Models")
    if modelsFolder then
        for _, expectedModel in ipairs(EXPECTED_LOCATION_MODELS) do
            local model = modelsFolder:FindFirstChild(expectedModel)
            
            local expectedType = "Model"
            if expectedModel == "Baseplate" then
                expectedType = "Part"
            elseif expectedModel == "SpawnLocation" then
                expectedType = "SpawnLocation"
            elseif expectedModel == "InteractionObjects" then
                expectedType = "Folder"
            end
            
            local isValid, message = validateObjectType(model, expectedType, "Planets." .. planetId .. ".Locations." .. locationId .. ".Models." .. expectedModel)
            if not isValid then
                table.insert(errors, message)
            end
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
    
    -- Fix Models folder
    local modelsFolder = locationFolder:FindFirstChild("Models")
    if modelsFolder then
        -- Move misplaced objects to Models folder
        local objectsToMove = {"Baseplate", "SpawnLocation"}
        for _, objectName in ipairs(objectsToMove) do
            local object = locationFolder:FindFirstChild(objectName)
            if object then
                local targetObject = modelsFolder:FindFirstChild(objectName)
                if not targetObject then
                    object.Parent = modelsFolder
                    print("[ObjectTypeValidator] ✅ Moved", objectName, "to Models folder")
                else
                    warn("[ObjectTypeValidator] ⚠️ Duplicate", objectName, "found, removing")
                    object:Destroy()
                end
            end
        end
        
        -- Create missing objects
        local interactionObjects = modelsFolder:FindFirstChild("InteractionObjects")
        if not interactionObjects then
            interactionObjects = Instance.new("Folder")
            interactionObjects.Name = "InteractionObjects"
            interactionObjects.Parent = modelsFolder
            print("[ObjectTypeValidator] ✅ Created InteractionObjects folder")
        end
        
        local baseplate = modelsFolder:FindFirstChild("Baseplate")
        if not baseplate then
            baseplate = Instance.new("Part")
            baseplate.Name = "Baseplate"
            baseplate.Size = Vector3.new(100, 1, 100)
            baseplate.Material = Enum.Material.Grass
            baseplate.Anchored = true
            baseplate.Parent = modelsFolder
            print("[ObjectTypeValidator] ✅ Created Baseplate")
        end
        
        local spawnLocation = modelsFolder:FindFirstChild("SpawnLocation")
        if not spawnLocation then
            spawnLocation = Instance.new("SpawnLocation")
            spawnLocation.Name = "SpawnLocation"
            spawnLocation.Size = Vector3.new(8, 1, 8)
            spawnLocation.Material = Enum.Material.Neon
            spawnLocation.BrickColor = BrickColor.new("Bright blue")
            spawnLocation.Anchored = true
            spawnLocation.Parent = modelsFolder
            print("[ObjectTypeValidator] ✅ Created SpawnLocation")
        end
    end
    
    return true
end

return ObjectTypeValidator