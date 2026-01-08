-- Add PlanetSurfaceScanner to Planet Locations
-- Клонує PlanetSurfaceScanner з SpaceStation до планетарних локацій

local function addPlanetSurfaceScanner()
    print("=" .. string.rep("=", 79))
    print("KOSMICMAZER — Adding PlanetSurfaceScanner to Planet Locations")
    print("=" .. string.rep("=", 79))
    
    -- Source PlanetSurfaceScanner від SpaceStation
    local sourceScannerModel = game.ServerStorage.Space.SpaceStation.Workspace.LocationModel.Equipment.PlanetSurfaceScanner
    
    if not sourceScannerModel then
        print("❌ ERROR: PlanetSurfaceScanner not found in SpaceStation!")
        return
    end
    
    print("✅ Found source PlanetSurfaceScanner: " .. sourceScannerModel.Name)
    
    -- Target locations для додавання сканера
    local planetLocations = {
        game.ServerStorage.Planets.Planet_1.Locations.Location_1.Workspace.LocationModel,
        game.ServerStorage.Planets.Planet_1.Locations.Location_2.Workspace.LocationModel,
        game.ServerStorage.Planets.Planet_1.Locations.Location_3.Workspace.LocationModel,
        game.ServerStorage.Planets.Planet_2.Locations.Location_1.Workspace.LocationModel,
        game.ServerStorage.Planets.Planet_2.Locations.Location_2.Workspace.LocationModel,
        game.ServerStorage.Planets.Planet_2.Locations.Location_3.Workspace.LocationModel,
    }
    
    local locationNames = {
        "Planet_1/Location_1",
        "Planet_1/Location_2", 
        "Planet_1/Location_3",
        "Planet_2/Location_1",
        "Planet_2/Location_2",
        "Planet_2/Location_3"
    }
    
    local addedCount = 0
    local skippedCount = 0
    
    for i, locationModel in ipairs(planetLocations) do
        local locationName = locationNames[i]
        print("\n🔍 Processing: " .. locationName)
        
        if locationModel and locationModel:FindFirstChild("Equipment") then
            local equipment = locationModel.Equipment
            local existingScanner = equipment:FindFirstChild("PlanetSurfaceScanner")
            
            if existingScanner then
                print("  ⏭️ Already has PlanetSurfaceScanner - skipping")
                skippedCount = skippedCount + 1
            else
                -- Клонуємо сканер
                local clonedScanner = sourceScannerModel:Clone()
                clonedScanner.Parent = equipment
                print("  ✅ Added PlanetSurfaceScanner to Equipment")
                addedCount = addedCount + 1
            end
        else
            print("  ❌ LocationModel or Equipment folder not found!")
        end
    end
    
    print("\n" .. string.rep("=", 79))
    print("📊 Summary:")
    print("  ➕ PlanetSurfaceScanner added: " .. addedCount)
    print("  ⏭️ Already existed: " .. skippedCount)
    print("  " .. (addedCount > 0 and "✅ PlanetSurfaceScanner successfully added!" or 
                                      "ℹ️ All locations already have PlanetSurfaceScanner"))
    print("=" .. string.rep("=", 79))
end

-- Run the addition
addPlanetSurfaceScanner()