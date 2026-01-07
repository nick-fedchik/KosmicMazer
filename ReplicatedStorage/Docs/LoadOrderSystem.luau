--[[
================================================================================
KOSMICMAZER — LoadOrder System Documentation
================================================================================

Version: 2.0
Last Updated: 2026-01-07

================================================================================
1. OVERVIEW
================================================================================

LoadOrder System визначає порядок завантаження контенту на 3 рівнях:
1. SpaceStation - космічна станція (Space/SpaceStation/Configuration/)
2. Planet - планета (Planets/Planet_N/Configuration/)
3. Location - локація (Planets/Planet_N/Locations/Location_N/Configuration/)

Кожен рівень має свій LoadOrder.luau конфіг з 3 типами контенту:
- WorkspaceObjects: об'єкти з Workspace/ папки → game.Workspace
- ServerScripts: скрипти з Scripts/Server/ → require() або clone
- ClientScripts: скрипти з Scripts/Client/ → StarterPlayerScripts

================================================================================
2. LOADORDER.LUAU STRUCTURE (v2.0)
================================================================================

return {
    Version = "2.0",
    
    -- Об'єкти з Workspace/ папки
    WorkspaceObjects = {
        {name = "ObjectName", priority = 1, description = "Description"},
        {name = "SpawnLocation", priority = 999, description = "Must load last"},
    },
    
    -- Серверні скрипти з Scripts/Server/
    ServerScripts = {
        {name = "Module", priority = 1, action = "require", description = "Desc"},
        {name = "Script", priority = 2, action = "clone", description = "Desc"},
    },
    
    -- Клієнтські скрипти з Scripts/Client/
    ClientScripts = {
        {name = "UIScript", priority = 1, description = "Description"},
    },
    
    -- Налаштування (опціонально)
    Settings = {
        LoadTimeout = 10,
        EnableParallelLoading = false,
        VerifyAfterLoad = true,
    }
}

================================================================================
3. PRIORITY RULES
================================================================================

Priority Range Guide:
- 1-100: Core infrastructure (terrain, planet model, base modules)
- 101-500: Standard content (buildings, NPCs, game logic modules)
- 501-998: Optional/secondary content (decorations, effects, UI)
- 999: Critical finalizers (SpawnLocation - MUST load last!)
- Default (unlisted): 500

Lower priority = loads first
Higher priority = loads later

IMPORTANT: SpawnLocation MUST always have priority = 999 to load last!

================================================================================
4. SCRIPT ACTIONS
================================================================================

ServerScripts can have two actions:

action = "require":
- For ModuleScripts (.luau files)
- Script stays in ServerStorage
- Loaded via require() when needed
- Example: PlanetConfig, LocationGameServer, managers

action = "clone":
- For Script instances (.server.luau)
- Script is cloned to game.Workspace
- Executes immediately after cloning
- Example: Background processes, listeners

Default: "require" (if action not specified)

================================================================================
5. FILE LOCATIONS
================================================================================

Configuration files location:
├── ServerStorage/
│   ├── Space/SpaceStation/Configuration/
│   │   └── LoadOrder.luau  -- SpaceStation level
│   └── Planets/
│       └── Planet_N/
│           ├── Configuration/
│           │   └── LoadOrder.luau  -- Planet level
│           └── Locations/
│               └── Location_N/Configuration/
│                   └── LoadOrder.luau  -- Location level

Helper module:
└── ServerScriptService/
    └── LoadOrderProcessor.luau  -- Utility for processing configs

================================================================================
6. USAGE IN CODE
================================================================================

6.1) Loading Configuration:
```lua
local LoadOrderProcessor = require(ServerScriptService.LoadOrderProcessor)

-- Load config from Configuration folder
local config = LoadOrderProcessor.LoadConfig(spaceStation.Configuration)

-- Validate config
local valid, error = LoadOrderProcessor.ValidateConfig(config)
if not valid then
    warn("Invalid LoadOrder: " .. error)
end
```

6.2) Sorting Objects:
```lua
-- Get all objects from Workspace folder
local workspaceFolder = spaceStation.Workspace
local objects = workspaceFolder:GetChildren()

-- Sort by priority
local sortedObjects = LoadOrderProcessor.SortWorkspaceObjects(objects, config)

-- Copy in priority order
for _, obj in ipairs(sortedObjects) do
    local clone = obj:Clone()
    clone.Parent = game.Workspace
    print("Loaded: " .. obj.Name .. " (priority: " .. 
          LoadOrderProcessor.GetWorkspacePriority(obj.Name, config) .. ")")
end
```

6.3) Processing Server Scripts:
```lua
local scriptsFolder = spaceStation.Scripts.Server
local scripts = scriptsFolder:GetChildren()

-- Sort by priority
local sortedScripts = LoadOrderProcessor.SortServerScripts(scripts, config)

-- Process in priority order
for _, script in ipairs(sortedScripts) do
    local action = LoadOrderProcessor.GetScriptAction(script.Name, config)
    
    if action == "require" and script:IsA("ModuleScript") then
        -- Load as module
        local success, module = pcall(require, script)
        if success then
            print("Required: " .. script.Name)
        end
    elseif action == "clone" and script:IsA("Script") then
        -- Clone to Workspace
        local clone = script:Clone()
        clone.Parent = game.Workspace
        print("Cloned: " .. script.Name)
    end
end
```

6.4) Processing Client Scripts:
```lua
local clientFolder = spaceStation.Scripts.Client
local scripts = clientFolder:GetChildren()

-- Sort by priority
local sortedScripts = LoadOrderProcessor.SortClientScripts(scripts, config)

-- Copy to StarterPlayerScripts
local destination = game.StarterPlayer.StarterPlayerScripts
for _, script in ipairs(sortedScripts) do
    local clone = script:Clone()
    clone.Parent = destination
    print("Copied client script: " .. script.Name)
end
```

================================================================================
7. INTEGRATION WITH ENVIRONMENTLOADER
================================================================================

EnvironmentLoader має інтегрувати LoadOrder в:

LoadSpaceEnvironment():
1. Load SpaceStation/Configuration/LoadOrder.luau
2. Load Planet/Configuration/LoadOrder.luau
3. Sort and copy Planet/Workspace/ objects (using Planet config)
4. Sort and copy SpaceStation/Workspace/ objects (using SpaceStation config)
5. Process Planet/Scripts/Server/ (using Planet config)
6. Process SpaceStation/Scripts/Server/ (using SpaceStation config)
7. Process Planet/Scripts/Client/ (using Planet config)
8. Process SpaceStation/Scripts/Client/ (using SpaceStation config)

LoadPlanetEnvironment():
1. Load Planet/Configuration/LoadOrder.luau
2. Load Location/Configuration/LoadOrder.luau
3. Sort and copy Location/Workspace/ objects (using Location config)
4. Apply Location/Lighting/
5. Process Planet/Scripts/Server/ (using Planet config)
6. Process Location/Scripts/Server/ (using Location config)
7. Process Planet/Scripts/Client/ (using Planet config)
8. Process Location/Scripts/Client/ (using Location config)

================================================================================
8. BACKWARD COMPATIBILITY
================================================================================

LoadOrder v1.0 (Legacy):
- Only supported ORDER array for Workspace objects
- LoadOrderProcessor.luau handles both v1.0 and v2.0
- v1.0 configs still work but without Server/Client script ordering

Migration from v1.0 to v2.0:
1. Rename ORDER → WorkspaceObjects
2. Add ServerScripts = {} section
3. Add ClientScripts = {} section
4. Add Settings = {} section (optional)
5. Update Version = "2.0"

================================================================================
9. BEST PRACTICES
================================================================================

1. SpawnLocation Priority:
   ALWAYS set SpawnLocation priority to 999
   This ensures spawn point exists after all other content

2. Module Dependencies:
   If ModuleB requires ModuleA, give ModuleA lower priority:
   - ModuleA: priority = 1
   - ModuleB: priority = 2

3. UI Script Order:
   Load core UI before specialized UI:
   - CoreUI: priority = 1
   - DialogUI: priority = 2
   - QuestUI: priority = 3

4. Terrain First:
   Load terrain/baseplate before buildings:
   - Baseplate: priority = 1
   - Buildings: priority = 100

5. Description Field:
   Always add description for documentation:
   {name = "Module", priority = 1, description = "What this module does"}

6. Testing:
   After changing LoadOrder, test:
   - Objects appear in correct visual order
   - No "module not found" errors
   - SpawnLocation exists when players join

================================================================================
10. TROUBLESHOOTING
================================================================================

Problem: "Invalid LoadOrder config"
Solution: Check LoadOrder.luau syntax, ensure return statement exists

Problem: Objects load in wrong order
Solution: Check priority values, lower = first

Problem: SpawnLocation not found
Solution: Ensure SpawnLocation has priority = 999

Problem: "module not found" error
Solution: Check ServerScripts order, dependencies load first

Problem: LoadOrder not used
Solution: Verify LoadOrder.luau exists in Configuration folder

Problem: Legacy v1.0 config not working
Solution: LoadOrderProcessor handles both versions automatically

================================================================================
11. EXAMPLE CONFIGURATIONS
================================================================================

SpaceStation LoadOrder.luau:
```lua
return {
    Version = "2.0",
    WorkspaceObjects = {
        {name = "Planet", priority = 1},
        {name = "PlanetSurfaceScanner", priority = 2},
        {name = "SpawnLocation", priority = 999},
    },
    ServerScripts = {
        {name = "PlanetSurfaceScanner", priority = 1, action = "require"},
    },
    ClientScripts = {
        {name = "StationUI", priority = 1},
        {name = "ScannerUI", priority = 2},
    },
}
```

Location LoadOrder.luau:
```lua
return {
    Version = "2.0",
    WorkspaceObjects = {
        {name = "Baseplate", priority = 1},
        {name = "Buildings", priority = 100},
        {name = "NPCs", priority = 200},
        {name = "SpawnLocation", priority = 999},
    },
    ServerScripts = {
        {name = "LocationGameServer", priority = 1, action = "require"},
        {name = "ResourceController", priority = 2, action = "require"},
    },
    ClientScripts = {
        {name = "LocationUI", priority = 1},
        {name = "DialogSystem", priority = 2},
    },
}
```

================================================================================
END OF DOCUMENTATION
================================================================================
]]

return {}
