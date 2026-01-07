--[[
================================================================================
KOSMICMAZER — Game Levels Refactoring Plan
================================================================================

Purpose: Unified structure for game locations, planets, and interaction objects
Version: 1.2
Last Updated: 2026-01-07

Current Problems:
- Mixed location management across multiple scripts
- No unified location manager system
- Inconsistent object registration and state management
- Hardcoded planet/space relationships
- No separation between location-specific and global objects
- No clear game environment switching system

Proposed New Structure:

1. ServerStorage Reorganization:
   ServerStorage/
   ├── Space/                        -- Folder: Space environment
   │   ├── SpaceStation/             -- Folder: Space Station location
   │   │   ├── Models/               -- Folder: All station models
   │   │   │   ├── SpawnLocation    -- SpawnLocation: Player spawn point
   │   │   │   ├── PlanetScanner    -- Model: Planet scanning device
   │   │   │   ├── TeleportationDevice -- Model: Teleportation interface
   │   │   │   └── ... (other station objects)
   │   │   ├── Scripts/              -- Folder: Station-specific scripts
   │   │   │   ├── SpaceStationManager.lua -- ModuleScript: Station controller
   │   │   │   ├── PlanetScannerController.lua -- ModuleScript: Scanner controller
   │   │   │   └── ...
   │   │   ├── Lighting/             -- Folder: Station lighting
   │   │   │   ├── Sky               -- Sky: Station skybox
   │   │   │   ├── Atmosphere        -- Atmosphere: Station atmosphere
   │   │   │   └── ...
   │   │   └── Configuration/        -- Folder: Station config
   │   │       ├── Settings.lua     -- ModuleScript: Station settings
   │   │       └── ...
   │   └── Common/                   -- Folder: Shared space objects
   │       ├── TeleportationDevice/  -- Folder: Global teleportation system
   │       │   ├── Device           -- Model: Teleport device model
   │       │   └── ...
   │       ├── Effects/              -- Folder: Space effects
   │       │   ├── Particles         -- Folder: Particle effects
   │       │   └── ...
   │       └── ...
   ├── Planets/                     -- Folder: All planet templates
   │   ├── Planet_1/                -- Folder: First planet
   │   │   ├── PlanetModel          -- Folder: Planet visual model
   │   │   │   └── Planet           -- Model: Planet sphere with atmosphere
   │   │   ├── Lighting/            -- Folder: Planet-specific lighting
   │   │   │   ├── Sky               -- Sky: Planet skybox
   │   │   │   ├── Atmosphere        -- Atmosphere: Planet atmosphere
   │   │   │   └── ...
   │   │   ├── Locations/           -- Folder: Planet locations
   │   │   │   ├── Location_1/      -- Folder: First location
   │   │   │   │   ├── Models/     -- Folder: Location models
   │   │   │   │   │   ├── SpawnLocation -- SpawnLocation: Player spawn point
   │   │   │   │   │   ├── Baseplate -- Part: Ground/floor
   │   │   │   │   │   ├── InteractionObjects/ -- Folder: Interactive objects
   │   │   │   │   │   │   ├── ResourceNode_1 -- Part: Resource node with effects
   │   │   │   │   │   │   ├── ResourceNode_2 -- Part: Resource node with effects
   │   │   │   │   │   │   └── ...
   │   │   │   │   │   └── ...
   │   │   │   │   ├── Scripts/    -- Folder: Location-specific scripts
   │   │   │   │   │   ├── LocationManager.lua -- ModuleScript: Location controller
   │   │   │   │   │   ├── ResourceController.lua -- ModuleScript: Resource manager
   │   │   │   │   │   └── ...
   │   │   │   │   ├── Lighting/   -- Folder: Location lighting
   │   │   │   │   │   ├── Sky       -- Sky: Location skybox
   │   │   │   │   │   ├── LightSources -- Folder: Light sources
   │   │   │   │   │   └── ...
   │   │   │   │   └── Configuration/ -- Folder: Location config
   │   │   │   │       ├── Settings.lua -- ModuleScript: Location settings
   │   │   │   │       └── ...
   │   │   │   ├── Location_2/      -- Folder: Second location
   │   │   │   │   └── ... (same structure as Location_1)
   │   │   │   └── ...
   │   │   ├── Scripts/             -- Folder: Planet-wide scripts
   │   │   │   ├── PlanetManager.lua -- ModuleScript: Planet controller
   │   │   │   └── ...
   │   │   └── Configuration/       -- Folder: Planet config
   │   │       ├── Settings.lua     -- ModuleScript: Planet settings
   │   │       └── ...
   │   └── Planet_2/               -- Folder: Second planet
   │       └── ... (same structure as Planet_1)
   ├── Effects/                    -- Folder: Global effects (existing)
   │   ├── TeleportAnimation/      -- Folder: Teleport effects
   │   │   └── TeleportParticle     -- ParticleEmitter: Teleport effect
   │   └── ...
   └── ...

2. New Manager Scripts Architecture:

   ServerScriptService/
   ├── GameWorldManager.lua          -- NEW: Main world controller
   │   -- Manages loading/unloading of worlds
   │   -- Coordinates between Space and Planet managers
   │   -- Handles world transitions
   │
   ├── LocationManager.lua           -- REFACTORED: Simplified location loader
   │   -- Only handles physical loading/unloading
   │   -- Delegates logic to specific location managers
   │
   ├── SpaceStationManager.lua       -- NEW: Space Station controller
   │   -- Manages station-specific objects
   │   -- Handles station game rules
   │   -- Registers/unregisters station objects
   │
   ├── PlanetManager.lua             -- NEW: Planet controller
   │   -- Manages planet-wide systems
   │   -- Coordinates between planet locations
   │   -- Handles planet-specific rules
   │
   └── LocationManagers/             -- NEW: Location-specific managers
       ├── BaseLocationManager.lua    -- Base class for all locations
       ├── Location_1_Manager.lua     -- Location 1 specific logic
       ├── Location_2_Manager.lua     -- Location 2 specific logic
       └── ...

3. Configuration Structure:

   GameConfig.lua Enhanced:
   {
       Worlds = {
           Space = {
               Locations = {
                   SpaceStation = {
                       DisplayName = "🚀 Космічна Станція",
                       TemplatePath = "ServerStorage.Space.SpaceStation",
                       ManagerScript = "SpaceStationManager",
                       InteractionObjects = {
                           PlanetScanner = {
                               TemplatePath = "Models/PlanetScanner",
                               ControllerScript = "PlanetScannerController",
                               IsGlobal = false
                           },
                           TeleportationDevice = {
                               TemplatePath = "Common/TeleportationDevice",
                               ControllerScript = "TeleportationManager",
                               IsGlobal = true
                           }
                       },
                       GameRules = {
                           AllowScanning = true,
                           AllowTeleportation = true,
                           ...
                       }
                   }
               }
           },
           Planets = {
               Planet_1 = {
                   DisplayName = "Zalizyaka",
                   TemplatePath = "ServerStorage.Planets.Planet_1",
                   ManagerScript = "PlanetManager",
                   Locations = {
                       Location_1 = {
                           DisplayName = "Садочок",
                           TemplatePath = "Locations/Location_1",
                           ManagerScript = "Location_1_Manager",
                           InteractionObjects = {
                               ResourceNode_1 = {
                                   TemplatePath = "Models/InteractionObjects/ResourceNode_1",
                                   ControllerScript = "ResourceController",
                                   IsGlobal = false
                               }
                           },
                           GameRules = {
                               ResourceRegeneration = true,
                               MaxResources = 100,
                               ...
                           }
                       },
                       Location_2 = {
                           ...
                       }
                   }
               },
               Planet_2 = {
                   ...
               }
           }
       }
   }

4. Game Environment System:

   Game Environment (Ігрове середовище) - активний світ, в якому перебуває гравець
   Два типи ігрових середовищ:
   1) Space Environment (Космічне середовище)
   2) Planet Environment (Планетарне середовище)

   ВАЖЛИВО: Обмеження розміщення скриптів в Roblox:
   =========================================
   - Script (.server.luau) → виконується ТІЛЬКИ на сервері
   - LocalScript (.client.luau) → виконується ТІЛЬКИ на клієнті
   - ModuleScript (.luau) → може require з обох сторін

   LocalScript працює ТІЛЬКИ в:
   - StarterPlayerScripts, StarterGui, PlayerGui
   - StarterCharacterScripts, ReplicatedFirst

   LocalScript НЕ працює в:
   - Workspace (ігнорується!)
   - ServerStorage, ServerScriptService

   Тому Scripts/ розділено на Server/ та Client/:
   Scripts/
   ├── Server/           -- Копіювати в Workspace або require
   │   ├── *.luau        -- ModuleScripts (require з ServerScriptService)
   │   └── *.server.luau -- Scripts (копіювати в Workspace)
   └── Client/           -- Копіювати в StarterPlayerScripts/StarterGui
       └── *.client.luau -- LocalScripts (виконуються на клієнті)

   4.1 Space Environment Loading Process:
   1.1 Clear Workspace completely
   1.2 Remove previous location's Client scripts from StarterPlayerScripts
   1.3 Copy from ServerStorage/Planets/Planet_N/ to Workspace:
       ├── PlanetModel/         -- Folder: Planet visual model
       │   └── Planet           -- Model: Planet sphere with atmosphere
       └── Lighting/*           -- Folder: Planet-specific lighting
   1.4 Copy from ServerStorage/Space/SpaceStation/ to Workspace:
       ├── Models/             -- Folder: All station models → Workspace
       │   ├── SpawnLocation, PlanetScanner, TeleportationDevice, ...
       └── Lighting/           -- Folder: Station lighting
   1.5 Process Scripts/Server/:
       - ModuleScripts: require from original location OR clone to Workspace
       - Scripts (.server.luau): clone to Workspace (will execute automatically)
   1.6 Process Scripts/Client/:
       - LocalScripts (.client.luau): clone to StarterPlayerScripts
       - For each active player: clone to player.PlayerScripts
   1.7 Load Configuration/
   1.8 Verify all objects loaded
   1.9 Spawn player at SpawnLocation

   4.2 Planet Environment Loading Process:
   1.1 Clear Workspace completely
   1.2 Remove previous location's Client scripts from StarterPlayerScripts
   1.3 Copy from ServerStorage/Planets/Planet_N/Locations/Location_M/ to Workspace:
       ├── Models/             -- Folder: Location models → Workspace
       │   ├── SpawnLocation    -- SpawnLocation: Player spawn point
       │   ├── Baseplate        -- Part: Ground/floor
       │   ├── InteractionObjects/ -- Folder: Interactive objects
       │   └── ...
       └── Lighting/           -- Folder: Location lighting
   1.4 Process Scripts/Server/:
       - ModuleScripts: require from original location OR clone to Workspace
       - Scripts (.server.luau): clone to Workspace (will execute automatically)
   1.5 Process Scripts/Client/:
       - LocalScripts (.client.luau): clone to StarterPlayerScripts
       - For each active player: clone to player.PlayerScripts
   1.6 Load Configuration/
   1.7 Verify all objects loaded
   1.8 Spawn player at SpawnLocation

   4.3 Environment Switching Logic:
   - GameWorldManager handles environment transitions
   - Each environment has its own loading/unloading sequence
   - Player state preserved during transitions
   - Smooth transitions with loading screens if needed

5. Refactoring Steps:

Phase 1: Structure Preparation
1. Create new ServerStorage/Space and ServerStorage/Planets structure
2. Move existing models to new locations
3. Create template folders for future content
4. Design environment loading/unloading system

Phase 2: Manager Scripts Creation
1. Create BaseLocationManager with common functionality
2. Create GameWorldManager as main coordinator with environment switching
3. Create SpaceStationManager and PlanetManager
4. Create location-specific managers
5. Create environment loading utilities

Phase 3: Configuration Enhancement
1. Enhance GameConfig with new structure
2. Add interaction objects configuration
3. Add game rules configuration

Phase 4: Script Migration
1. Migrate existing logic to new managers
2. Update LocationManager to use new structure
3. Update TeleportationManager to work with new system
4. Update ScannerService to work with new structure
5. Implement environment switching logic
6. Create workspace clearing and loading utilities

Phase 5: Testing and Validation
1. Test all location transitions
2. Test interaction objects in each location
3. Test game rules enforcement
4. Test object registration/unregistration
5. Test environment switching (Space ↔ Planet)
6. Test workspace clearing and loading
7. Test player state preservation during transitions

Phase 6: Cleanup
1. Remove old structure
2. Clean up unused scripts
3. Update documentation

5. Key Benefits:
- Unified location management
- Clear separation of concerns
- Easy addition of new planets/locations
- Consistent object registration system
- Flexible game rules configuration
- Reusable interaction objects
- Better code organization
- Easier debugging and maintenance
- Clean environment switching system
- Proper workspace management
- Player state preservation

6. Implementation Notes:
- Each location manager handles its own object registry
- Global objects (like TeleportationDevice) are managed by their own controllers
- GameWorldManager coordinates between different world types
- Configuration-driven approach for easy content addition
- Backward compatibility during transition period
- Environment switching should be atomic (all-or-nothing)
- Workspace clearing must be complete to avoid conflicts
- Consider loading screens for smooth transitions

7. Environment Management Best Practices:
- Always clear Workspace before loading new environment
- Use WaitForChild() when accessing loaded objects
- Implement proper error handling for loading failures
- Cache frequently accessed objects for performance
- Use CollectionService tags for environment-specific objects
- Implement cleanup events for proper resource management
- Consider memory usage when loading large environments

================================================================================
]]