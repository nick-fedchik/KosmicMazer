--[[
KOSMICMAZER — Game Configuration
Version: 4.1
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
GameConfig.GameVersion = "5.0-RC1"

-- Data Schema Version
GameConfig.DATA_SCHEMA_VERSION = 2 -- Current schema version for player data

-- Debug settings
GameConfig.DEBUG_MODE = false -- Set to true only for development/testing
GameConfig.ENABLE_REMOTEEVENTS_VALIDATION = true -- Validate RemoteEvents on startup

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

-- Default planet for new players (orbit of Space Station)
-- ⚠️ Planet data now loaded from ServerStorage/Planets/{PlanetId}/Configuration/PlanetConfig
-- Change this value to simulate inter-planetary flight between orbits
GameConfig.DEFAULT_PLANET = "Planet_1" -- Current orbit: Planet_1
GameConfig.DEFAULT_PLANET_NAME = "Залізяка" -- Display name for UI

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

--============================================================================--
-- PLANET CONFIGURATION (DEPRECATED - MIGRATED TO SERVERSTORAGE)
--============================================================================--

--[[
⚠️ ARCHITECTURE CHANGE v4.1 (2026-01-10)

Planet data was REMOVED from GameConfig and migrated to ServerStorage:
  ServerStorage/Planets/{PlanetId}/Configuration/PlanetConfig.luau

Use PlanetConfigLoader module to access planet configurations:
  local PlanetConfigLoader = require(ServerScriptService.PlanetConfigLoader)
  local config = PlanetConfigLoader.GetCurrentPlanetConfig()

This allows:
  ✅ Each planet has its own configuration file (modular)
  ✅ Hot-reload of planet configs without restarting game
  ✅ Simulate inter-planetary flight by changing DEFAULT_PLANET
  ✅ Scanner and Teleport show ONLY current planet's locations
  ✅ Easy to add new planets (just add folder + config)

Migration notes:
  - GameConfig.Planets table REMOVED
  - GameConfig.PlanetHelpers REMOVED
  - Use PlanetConfigLoader instead
  - Planet data structure preserved in PlanetConfig files

See: ReplicatedStorage/Docs/ArchitectureImproves.luau, Problem #1
See: ReplicatedStorage/Docs/Backlog.luau, Task 0
]]


-- Planet Surface Scanner settings
GameConfig.PlanetSurfaceScanner = {
    ScanDuration = 2.0, -- Duration of scanning animation
    AutoScanOnSpawn = false, -- Version 1.3: Player must interact with scanner
    DiscoveryRadius = 1000, -- Radius for discovering new locations
    InteractionDistance = 10 -- Distance for player to interact with scanner
}

return GameConfig