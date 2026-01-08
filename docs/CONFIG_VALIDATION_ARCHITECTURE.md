# Config Validation Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SERVER STARTUP FLOW                                 │
└─────────────────────────────────────────────────────────────────────────────┘

    Server Start
         │
         ▼
┌─────────────────────┐
│  GameInit.server    │
│     (v3.7)          │
└──────────┬──────────┘
           │
           │ Load Modules
           ▼
    ┌──────────────┐
    │  GameConfig  │
    └──────┬───────┘
           │
           ▼
    ┌──────────────────┐
    │ ConfigValidator  │◄─────── ServerStorage (for model validation)
    │     (v1.0)       │
    └──────┬───────────┘
           │
           │ ValidateConfig(GameConfig, ServerStorage)
           ▼
    ╔════════════════════╗
    ║ VALIDATION PROCESS ║
    ╚════════════════════╝
           │
           ├─→ [1] validateRequiredFields()
           │       │
           │       ├─→ GameName, GameVersion
           │       ├─→ DATA_SCHEMA_VERSION
           │       ├─→ DEFAULT_PLANET
           │       ├─→ Teleportation settings
           │       ├─→ Spawn settings
           │       ├─→ Planets table
           │       └─→ SpaceStation config
           │
           ├─→ [2] validatePlanets()
           │       │
           │       └─→ For each planet:
           │           ├─→ validatePlanet()
           │           │   ├─→ Planet metadata
           │           │   ├─→ IsAvailable flag
           │           │   └─→ Locations table
           │           │
           │           └─→ For each location:
           │               └─→ validateLocation()
           │                   ├─→ Location metadata
           │                   ├─→ SpawnPoint (critical)
           │                   ├─→ TeleportPoint
           │                   └─→ Discovery flags
           │
           ├─→ [3] validateSpaceStation()
           │       │
           │       ├─→ Station metadata
           │       ├─→ SpawnPoint existence
           │       └─→ ServerStorage structure:
           │           ├─→ Space/SpaceStation/
           │           ├─→ Workspace folder
           │           ├─→ SpawnLocation (type check)
           │           └─→ PlanetSurfaceScanner (optional)
           │
           └─→ [4] validateServerStorageModels()
                   │
                   ├─→ Planets folder structure
                   └─→ For each planet:
                       ├─→ Planet_X/Workspace/Planet
                       ├─→ Planet_X/Lighting/
                       └─→ For each location:
                           ├─→ Locations/Location_X/Workspace/
                           └─→ SpawnLocation (type check)
           │
           ▼
    ╔══════════════════╗
    ║ VALIDATION REPORT║
    ╚══════════════════╝
           │
           ├─→ ❌ Errors (critical issues)
           ├─→ ⚠️  Warnings (non-critical)
           └─→ ℹ️  Info (progress messages)
           │
           ▼
    ┌──────────────────┐
    │  Print Report    │
    └──────┬───────────┘
           │
           ▼
      Has Critical
       Errors?
           │
    ┌──────┴──────┐
    │             │
    Yes           No
    │             │
    ▼             ▼
┌────────┐    ┌──────────┐
│ error()│    │ Continue │
│ STOP   │    │ Startup  │
└────────┘    └──────────┘
                   │
                   ▼
            Initialize Systems:
            ├─→ DataStoreManager
            ├─→ LocationManager
            ├─→ TeleportationManager
            └─→ RemoteEventsRegistry
                   │
                   ▼
            Player Connect Events
```

## Validation Categories and Checks

```
╔═══════════════════════════════════════════════════════════════════════════╗
║                        VALIDATION MATRIX                                  ║
╚═══════════════════════════════════════════════════════════════════════════╝

┌─────────────────────┬──────────────────────┬──────────┬─────────────────┐
│ Category            │ Check                │ Severity │ Impact          │
├─────────────────────┼──────────────────────┼──────────┼─────────────────┤
│ GameName            │ Exists, non-empty    │ ERROR    │ Game identity   │
│ GameVersion         │ Exists, non-empty    │ ERROR    │ Version tracking│
│ DATA_SCHEMA_VERSION │ Number, >= 1         │ ERROR    │ Data migration  │
│ DEFAULT_PLANET      │ Exists, in Planets   │ ERROR    │ Player spawn    │
│ Planets table       │ Not empty            │ ERROR    │ Game content    │
│ SpaceStation.Name   │ Exists, non-empty    │ ERROR    │ Station access  │
├─────────────────────┼──────────────────────┼──────────┼─────────────────┤
│ Planet.Name         │ Matches planetId     │ WARNING  │ Consistency     │
│ Planet.DisplayName  │ Exists               │ WARNING  │ UI display      │
│ Planet.IsAvailable  │ At least one true    │ ERROR    │ Playability     │
│ Location.SpawnPoint │ Exists               │ ERROR    │ Player spawn    │
│ Location.isDiscov.. │ At least one per pl. │ WARNING  │ Accessibility   │
├─────────────────────┼──────────────────────┼──────────┼─────────────────┤
│ SS/Space/SpaceStat..│ Folder exists        │ ERROR    │ Station load    │
│ SpawnLocation       │ Type validation      │ ERROR    │ Player spawn    │
│ PlanetSurfaceScanner│ Exists               │ INFO     │ Optional feature│
│ Planet folders      │ Match config         │ ERROR    │ Planet load     │
│ Location folders    │ Match config         │ ERROR    │ Location load   │
└─────────────────────┴──────────────────────┴──────────┴─────────────────┘
```

## Error Handling Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      ERROR SEVERITY HANDLING                            │
└─────────────────────────────────────────────────────────────────────────┘

    Validation Issue Detected
            │
            ▼
    ┌───────────────┐
    │ Categorize by │
    │   Severity    │
    └───────┬───────┘
            │
    ┌───────┴────────┬──────────────┐
    │                │              │
    ▼                ▼              ▼
┌────────┐      ┌─────────┐    ┌──────┐
│ ERROR  │      │ WARNING │    │ INFO │
│ (❌)   │      │  (⚠️)   │    │ (ℹ️)  │
└───┬────┘      └────┬────┘    └───┬──┘
    │                │             │
    ├─→ Add to      ├─→ Add to    └─→ Add to
    │   errors[]    │   warnings[]    info[]
    │               │
    └─→ Set        └─→ Continue
        criticalFailure = true

            │
            ▼
    Print Full Report
            │
            ▼
    criticalFailure?
            │
    ┌───────┴────────┐
    │                │
    Yes              No
    │                │
    ▼                ▼
Stop Server    Allow Startup
               with Warnings
```

## Integration Points

```
┌─────────────────────────────────────────────────────────────────────────┐
│              CONFIGVALIDATOR INTEGRATION POINTS                         │
└─────────────────────────────────────────────────────────────────────────┘

ConfigValidator
      │
      ├─→ Validates ─────────► GameConfig
      │                             │
      │                             ├─→ Used by: GameInit
      │                             ├─→ Used by: LocationManager
      │                             ├─→ Used by: TeleportationManager
      │                             ├─→ Used by: DataStoreManager
      │                             └─→ Used by: EnvironmentLoader
      │
      ├─→ Checks ───────────► ServerStorage
      │                             │
      │                             ├─→ Space/SpaceStation/
      │                             ├─→ Planets/Planet_X/
      │                             └─→ Planets/Planet_X/Locations/
      │
      └─→ Reports to ──────────► GameInit
                                      │
                                      ├─→ Success: Continue
                                      └─→ Failure: error() and stop
```

## Benefits Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                   CONFIG VALIDATION BENEFITS                            │
└─────────────────────────────────────────────────────────────────────────┘

    Traditional Approach          │      With ConfigValidator
                                  │
┌──────────────────────┐         │    ┌──────────────────────┐
│ Server Starts        │         │    │ Server Starts        │
│   ↓                  │         │    │   ↓                  │
│ Players Join         │         │    │ Config Validation ✅ │
│   ↓                  │         │    │   ↓                  │
│ Load Location...     │         │    │ All Systems Valid    │
│   ↓                  │         │    │   ↓                  │
│ ❌ ERROR:            │         │    │ Players Join         │
│   SpawnPoint missing!│         │    │   ↓                  │
│   ↓                  │         │    │ Smooth Gameplay ✅   │
│ Players stuck ☹️     │         │    │                      │
│   ↓                  │         │    │                      │
│ Manual debugging     │         │    │                      │
│ Emergency fix        │         │    │                      │
│ Server restart       │         │    │                      │
└──────────────────────┘         │    └──────────────────────┘

Time to Fix: Hours               │    Time to Fix: Seconds
Impact: Players affected         │    Impact: Caught before startup
Cost: High                       │    Cost: Low
```
