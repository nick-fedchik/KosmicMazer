--[[
KOSMICMAZER — Game Configuration
Version: 3.2
Purpose: Central configuration settings for the game

API:
- GameVersion: Current game version string
- SPAWN_COOLDOWN_TIME: Cooldown time for spawn location interactions
- ENTER_DEBOUNCE_TIME: Debounce time for entering spawn locations
- POSITION_CHECK_INTERVAL: Interval for checking player position
- PULSE_EFFECT_COLOR: Color for pulse visual effects
- PULSE_EFFECT_RANGE: Range of pulse effects in studs
- PULSE_EFFECT_SPEED: Speed of pulse effects
- UI_ANIMATION_DURATION: Duration for UI animations
- UI_CLOSE_ON_ESCAPE: Whether UI closes on escape key
- TELEPORT_ANIMATION_DURATION: Duration of teleport animations
- STARTING_DISCOVERED_LOCATIONS: List of locations discovered at game start
- AUTO_DISCOVER_FIRST_PLANET: Whether to auto-discover first planet
- Teleportation: Table with teleportation settings
- Spawn: Table with spawn settings
- Locations: Table with location configurations
- GUI: Table with GUI settings
- Effects: Table with animation effect settings
- PlanetSurfaceScanner: Table with planet surface scanner settings

Calls to other scripts:
- None (configuration only)

Called by:


Dependencies:
- None (standalone configuration)

Changes: Updated to version 3.2 with optimized architecture and unified teleportation system
--]]

local GameConfig = {}
GameConfig.GameName = "KosmicMazer"
GameConfig.GameVersion = "3.3"

-- SpawnLocation settings
GameConfig.SPAWN_COOLDOWN_TIME = 3 -- seconds
GameConfig.ENTER_DEBOUNCE_TIME = 0.5 -- seconds
GameConfig.POSITION_CHECK_INTERVAL = 0.1 -- seconds

-- Visual settings
GameConfig.PULSE_EFFECT_COLOR = Color3.new(0, 0.5, 1) -- Blue
GameConfig.PULSE_EFFECT_RANGE = 20 -- studs
GameConfig.PULSE_EFFECT_SPEED = 2 -- pulses per second

-- UI settings
GameConfig.UI_ANIMATION_DURATION = 0.3 -- seconds
GameConfig.UI_CLOSE_ON_ESCAPE = true

-- Teleport settings
GameConfig.TELEPORT_ANIMATION_DURATION = 1 -- seconds

-- Location discovery
GameConfig.STARTING_DISCOVERED_LOCATIONS = {"SpaceStation"}
GameConfig.AUTO_DISCOVER_FIRST_PLANET = true

-- Default planet for new players
GameConfig.DEFAULT_PLANET = "Planet_1" -- First planet available to new players
GameConfig.DEFAULT_PLANET_NAME = "Pershia Planeta" -- Display name for UI

-- Teleportation settings
GameConfig.Teleportation = {
    Delay = 2.0, -- Delay before teleportation
    AnimationDuration = 1.5, -- Animation duration
    Cooldown = 3.0 -- Cooldown between teleports
}

-- Spawn settings
GameConfig.Spawn = {
    RespawnTime = 5.0, -- Respawn time
    SafeDistance = 10.0 -- Safe distance from other players
}

GameConfig.SpaceStation = {
		Name = "SpaceStation",
		DisplayName = "Kosmichna Stantsia",
		SpawnPoint = "SpawnLocation",
		TeleportPoint = "SpawnLocation"
}

-- Planets system (scalable for multiple planets)
--[[(будуть назви «Вирій», «Манівці», «Обабіч», «Видноколо» Нівроку Вибалок Вишгород Бровари
Теребовля
Конотоп
Прилуки
Жовті Води
Миргород
Гайсин
Ужгород
Чернігів
Бахмач
Поділ
Звенигород
Тлумач
Бориспіль
Васильків
Обухів
Гайворон )
]]

GameConfig.Planets = {
    Planet_1 = {
        Name = "Planet_1",
        DisplayName = "Zalizyaka",
        Folder = "Planet",
        IsAvailable = true, -- Available for new players
        Sky = "Sky",
        Atmosphere = "Atmosphere",
        Surface = "Surface",
        CloudLayers = {"CloudLayer0", "CloudLayer1"},
        Locations = {
            Location_1 = {
                Name = "Location_1",
                DisplayName = "Садочок",
                Folder = "Location_1",
                SpawnPoint = "SpawnLocation",
                TeleportPoint = "SpawnLocation",
                isDiscovered = true,
                isVisited = false,
                TeleportTo = false,
                Lighting = {
                    Sky = "Sky"
                },
                Environment = {
                    Baseplate = "Baseplate"
                }
            },
            Location_2 = {
                Name = "Location_2",
                DisplayName = "Гута",
                Folder = "Location_2",
                SpawnPoint = "SpawnLocation",
                TeleportPoint = "SpawnLocation",
                isDiscovered = false,
                isVisited = false,
                TeleportTo = false,
                Lighting = {
                    Sky = "Sky"
                },
                Environment = {
                    Baseplate = "Baseplate"
                }
			},
			Location_3 = {
				Name = "Location_3",
				DisplayName = "Канапка",
				Folder = "Location_3",
				SpawnPoint = "SpawnLocation",
				TeleportPoint = "SpawnLocation",
				isDiscovered = true,
				isVisited = false,
				TeleportTo = false,
				Lighting = {
					Sky = "Sky"
				},
				Environment = {
					Baseplate = "Baseplate"
				}
			}
        }
    }
    -- Future planets can be added here:
    -- Planet_2 = { ... },
    -- Planet_3 = { ... }
}

-- Helper functions for planet management
GameConfig.PlanetHelpers = {
    GetAvailablePlanets = function()
        local available = {}
        for planetId, planet in pairs(GameConfig.Planets) do
            if planet.IsAvailable then
                table.insert(available, planetId)
            end
        end
        return available
    end,
    
    GetPlanetLocations = function(planetId)
        local planet = GameConfig.Planets[planetId]
        return planet and planet.Locations or {}
    end,
    
    GetLocation = function(planetId, locationId)
        local planet = GameConfig.Planets[planetId]
        return planet and planet.Locations[locationId]
    end,
    
    GetDiscoveredLocations = function(planetId)
        local discovered = {}
        local locations = GameConfig.PlanetHelpers.GetPlanetLocations(planetId)
        for locationId, location in pairs(locations) do
            if location.isDiscovered then
                table.insert(discovered, locationId)
            end
        end
        return discovered
    end,
    
    GetDefaultPlanet = function()
        return GameConfig.DEFAULT_PLANET
    end,
    
    GetDefaultPlanetName = function()
        return GameConfig.DEFAULT_PLANET_NAME
    end,
    
    IsDefaultPlanet = function(planetId)
        return planetId == GameConfig.DEFAULT_PLANET
    end,
    
    GetPlayerStartLocation = function()
        -- Returns the starting location for new players
        local defaultPlanet = GameConfig.DEFAULT_PLANET
        local planet = GameConfig.Planets[defaultPlanet]
        if planet then
            -- Return first discovered location on default planet
            for locationId, location in pairs(planet.Locations) do
                if location.isDiscovered then
                    return {
                        PlanetId = defaultPlanet,
                        LocationId = locationId,
                        LocationName = location.DisplayName,
                        SpawnPoint = location.SpawnPoint
                    }
                end
            end
        end
        return nil
    end
}


-- Planet Surface Scanner settings
GameConfig.PlanetSurfaceScanner = {
    ScanDuration = 2.0, -- Duration of scanning animation
    AutoScanOnSpawn = false, -- Version 1.3: Player must interact with scanner
    DiscoveryRadius = 1000, -- Radius for discovering new locations
    InteractionDistance = 10 -- Distance for player to interact with scanner
}

return GameConfig