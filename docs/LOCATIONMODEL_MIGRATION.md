# LocationModel Migration Guide

**Status:** ConfigValidator updated ✅ | Physical structures need creation ⏳

## Current Situation

The ConfigValidator has been updated to support the new LocationModel hierarchical structure, but the **physical LocationModel instances don't exist yet** in Roblox Studio. This causes 6 validation errors on startup.

## Migration Steps (Do in Roblox Studio)

### For Each Location (Planet_1/Location_1, Planet_1/Location_2, Planet_1/Location_3, Planet_2/Location_1-3, SpaceStation):

#### 1. Create LocationModel Hierarchy

Navigate to `ServerStorage/Planets/[PlanetName]/Locations/[LocationName]/Workspace/` or `ServerStorage/Space/SpaceStation/Workspace/`:

```
Workspace/
├── LocationModel/ (Folder)
│   ├── Architecture/ (Folder)
│   ├── Equipment/ (Folder)
│   ├── Environment/ (Folder)
│   └── Gameplay/ (Folder)
```

#### 2. Set LocationModel Attributes

On the **LocationModel** folder, add these attributes:

**For Planet Locations:**
- `LocationId` (string): "Location_1", "Location_2", or "Location_3"
- `LocationType` (string): "Planet"
- `PlanetId` (string): "Planet_1" or "Planet_2"
- `DisplayName` (string): Optional display name

**For SpaceStation:**
- `LocationId` (string): "SpaceStation"
- `LocationType` (string): "Space"
- `DisplayName` (string): "Space Station" (optional)

#### 3. Move Existing Objects

**Move SpawnLocation:**
- Find existing `SpawnLocation` in `Workspace/` (if it exists)
- Move it into `Workspace/LocationModel/Gameplay/SpawnLocation`

**Move PlanetSurfaceScanner (SpaceStation only):**
- Find existing `PlanetSurfaceScanner` in `Workspace/` (if it exists)
- Move it into `Workspace/LocationModel/Equipment/PlanetSurfaceScanner`

## Expected ConfigValidator Behavior After Migration

### ✅ When LocationModel exists:
```
[SpaceStation] ✅ SpawnPoint 'SpawnLocation' found in LocationModel/Gameplay
[ServerStorage] Planet 'Planet_1', Location 'Location_1': ✅ SpawnPoint 'SpawnLocation' found in LocationModel/Gameplay
```

### ℹ️ When LocationModel doesn't exist (fallback):
```
[SpaceStation] SpawnPoint 'SpawnLocation' not found (LocationModel structure missing)
[ServerStorage] Planet 'Planet_1', Location 'Location_1': SpawnPoint 'SpawnLocation' not found (LocationModel structure missing)
```

## Locations to Migrate

### Priority 1 - Critical for Launch:
- [x] SpaceStation (initial spawn location)
- [ ] Planet_1/Location_1
- [ ] Planet_1/Location_2  
- [ ] Planet_1/Location_3

### Priority 2 - Future planets:
- [ ] Planet_2/Location_1
- [ ] Planet_2/Location_2
- [ ] Planet_2/Location_3

## Verification

After creating LocationModel structures:
1. **Sync Rojo** to ensure ConfigValidator changes are in Studio
2. **Run game** and check output log
3. Validation should show `✅ SpawnPoint found in LocationModel/Gameplay`
4. All 6 errors should be resolved

## Related Files

- [ConfigValidator.luau](../ServerScriptService/ConfigValidator.luau) - Updated validation logic ✅
- [Backlog.luau](../ReplicatedStorage/Docs/Backlog.luau) - ETAP 1-6 tasks for restructuring
- [ROADMAP.md](./ROADMAP.md) - v4.1 architectural improvements

## Notes

- ConfigValidator has **backward compatibility** - locations without LocationModel will fall back to old structure validation
- After migration, old `Workspace/SpawnLocation` path will no longer be used
- This aligns with Backlog ETAP 4-5: "RESTRUCTURE PLANET LOCATIONS" and ETAP 1: "RESTRUCTURE SPACESTATION MODEL"
