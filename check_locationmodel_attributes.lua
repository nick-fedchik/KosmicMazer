-- LocationModel Attributes Checker для Roblox Studio Command Bar
-- Перевіряє та налаштовує Attributes для всіх LocationModel

local function checkLocationModelAttributes()
    print("=" .. string.rep("=", 79))
    print("KOSMICMAZER — LocationModel Attributes Check")
    print("=" .. string.rep("=", 79))
    
    local locations = {
        -- SpaceStation
        {
            path = game.ServerStorage.Space.SpaceStation.Workspace.LocationModel,
            expectedType = "SpaceLocation",
            expectedID = "SpaceStation",
            name = "SpaceStation"
        },
        
        -- Planet_1 Locations
        {
            path = game.ServerStorage.Planets.Planet_1.Locations.Location_1.Workspace.LocationModel,
            expectedType = "PlanetLocation", 
            expectedID = "Planet_1_Location_1",
            name = "Planet_1/Location_1"
        },
        {
            path = game.ServerStorage.Planets.Planet_1.Locations.Location_2.Workspace.LocationModel,
            expectedType = "PlanetLocation",
            expectedID = "Planet_1_Location_2", 
            name = "Planet_1/Location_2"
        },
        {
            path = game.ServerStorage.Planets.Planet_1.Locations.Location_3.Workspace.LocationModel,
            expectedType = "PlanetLocation",
            expectedID = "Planet_1_Location_3",
            name = "Planet_1/Location_3"
        },
        
        -- Planet_2 Locations
        {
            path = game.ServerStorage.Planets.Planet_2.Locations.Location_1.Workspace.LocationModel,
            expectedType = "PlanetLocation",
            expectedID = "Planet_2_Location_1", 
            name = "Planet_2/Location_1"
        },
        {
            path = game.ServerStorage.Planets.Planet_2.Locations.Location_2.Workspace.LocationModel,
            expectedType = "PlanetLocation",
            expectedID = "Planet_2_Location_2",
            name = "Planet_2/Location_2"
        },
        {
            path = game.ServerStorage.Planets.Planet_2.Locations.Location_3.Workspace.LocationModel,
            expectedType = "PlanetLocation", 
            expectedID = "Planet_2_Location_3",
            name = "Planet_2/Location_3"
        }
    }
    
    local foundIssues = 0
    local fixedIssues = 0
    
    for _, location in ipairs(locations) do
        print("\n🔍 Checking: " .. location.name)
        
        if location.path and location.path:IsA("Model") then
            local currentType = location.path:GetAttribute("Type")
            local currentID = location.path:GetAttribute("ID")
            
            -- Check Type attribute
            if currentType ~= location.expectedType then
                print("  ❌ Type: '" .. tostring(currentType) .. "' → '" .. location.expectedType .. "'")
                location.path:SetAttribute("Type", location.expectedType)
                foundIssues = foundIssues + 1
                fixedIssues = fixedIssues + 1
            else
                print("  ✅ Type: '" .. location.expectedType .. "'")
            end
            
            -- Check ID attribute
            if currentID ~= location.expectedID then
                print("  ❌ ID: '" .. tostring(currentID) .. "' → '" .. location.expectedID .. "'")
                location.path:SetAttribute("ID", location.expectedID)
                foundIssues = foundIssues + 1
                fixedIssues = fixedIssues + 1
            else
                print("  ✅ ID: '" .. location.expectedID .. "'")
            end
            
            -- Check organizational structure
            local architecture = location.path:FindFirstChild("Architecture")
            local equipment = location.path:FindFirstChild("Equipment")
            local environment = location.path:FindFirstChild("Environment")
            local gameplay = location.path:FindFirstChild("Gameplay")
            
            print("  📁 Structure:")
            print("    Architecture: " .. (architecture and "✅" or "❌"))
            print("    Equipment: " .. (equipment and "✅" or "❌"))
            print("    Environment: " .. (environment and "✅" or "❌"))
            print("    Gameplay: " .. (gameplay and "✅" or "❌"))
            
            -- Check for SpawnLocation in Gameplay
            if gameplay then
                local spawnLocation = gameplay:FindFirstChild("SpawnLocation")
                print("    SpawnLocation: " .. (spawnLocation and "✅" or "❌"))
            end
            
            -- Check for PlanetSurfaceScanner in Equipment (ONLY for SpaceStation)
            if location.expectedType == "SpaceLocation" and equipment then
                local scanner = equipment:FindFirstChild("PlanetSurfaceScanner")
                print("    PlanetSurfaceScanner: " .. (scanner and "✅" or "❌"))
            elseif location.expectedType == "PlanetLocation" then
                print("    PlanetSurfaceScanner: N/A (не потрібен на планеті)")
            end
            
        else
            print("  ❌ LocationModel not found!")
            foundIssues = foundIssues + 1
        end
    end
    
    print("\n" .. string.rep("=", 79))
    print("📊 Summary:")
    print("  🔍 Total issues found: " .. foundIssues)
    print("  🔧 Issues fixed: " .. fixedIssues) 
    print("  " .. (foundIssues == 0 and "✅ All LocationModels are properly configured!" or 
                                        "⚠️ Some issues may need manual fixing"))
    print("=" .. string.rep("=", 79))
end

-- Run the check
checkLocationModelAttributes()