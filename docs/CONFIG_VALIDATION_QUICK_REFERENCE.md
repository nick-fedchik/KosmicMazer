# Config Validation Quick Reference

## What is ConfigValidator?

ConfigValidator is a startup validation system that checks GameConfig structure before the server starts accepting players. It prevents runtime errors caused by misconfigured game data.

## When Does It Run?

ConfigValidator runs **automatically** at server startup, immediately after GameConfig is loaded in GameInit.server.luau.

## What Does It Validate?

### ✅ Critical Checks (ERROR - stops server)
- GameName and GameVersion exist
- DATA_SCHEMA_VERSION is a number >= 1
- DEFAULT_PLANET exists and is in Planets table
- Planets table is not empty
- At least one planet is marked as available
- SpaceStation configuration exists
- All SpawnPoints exist and are SpawnLocation type
- ServerStorage folders match GameConfig structure

### ⚠️ Non-Critical Checks (WARNING - allows server to start)
- DisplayNames for UI are provided
- Optional features like PlanetSurfaceScanner
- Discovery flags are set correctly
- Consistency between Name and ID fields

### ℹ️ Informational Messages
- Validation progress
- Feature availability status
- Statistics (planet count, location count, etc.)

## Reading Validation Reports

Example report:
```
================================================================================
CONFIG VALIDATION REPORT
================================================================================

❌ ERRORS (1):
  1. [ServerStorage] Planet 'Planet_1': Location 'Location_2' SpawnPoint not found

⚠️  WARNINGS (2):
  1. [Location:Planet_1.Location_3] Location.isDiscovered not specified
  2. [SpaceStation] PlanetSurfaceScanner not found (optional feature)

ℹ️  INFO (4):
  1. [Planets] Validated 2 planets, 2 available
  2. [Planets] Planet has 3 locations, 2 discovered
  3. [SpaceStation] Space Station validation completed
  4. [ServerStorage] ServerStorage model validation completed

================================================================================
VALIDATION RESULT: ❌ FAILED
================================================================================
```

### Understanding Report Sections

**ERRORS (❌):**
- **Critical issues** that WILL cause gameplay problems
- Server will **NOT start** if errors exist
- Must be fixed before testing

**WARNINGS (⚠️):**
- **Potential issues** that MAY affect gameplay
- Server WILL start with warnings
- Should be reviewed and fixed when possible

**INFO (ℹ️):**
- **Informational messages** about validation progress
- No action needed
- Useful for understanding what was checked

## Common Errors and Fixes

### 1. SpawnPoint Missing
```
❌ [Location:Planet_1.Location_1] Location.SpawnPoint is missing or empty
```
**Fix:** Add SpawnPoint field to location config in GameConfig.luau
```lua
Location_1 = {
    SpawnPoint = "SpawnLocation", -- Add this
    -- ... other fields
}
```

### 2. ServerStorage Model Not Found
```
❌ [ServerStorage] Planet 'Planet_1': SpawnPoint 'SpawnLocation' not found
```
**Fix:** Add SpawnLocation object to ServerStorage:
- Path: `ServerStorage/Planets/Planet_1/Locations/Location_1/Workspace/SpawnLocation`
- Type: Must be `SpawnLocation` instance

### 3. Planet Not Available
```
❌ [Planets] No planets are marked as available - players won't be able to play
```
**Fix:** Set at least one planet's IsAvailable to true:
```lua
Planet_1 = {
    IsAvailable = true, -- Must be true
    -- ... other fields
}
```

### 4. Invalid Schema Version
```
❌ [RequiredFields] DATA_SCHEMA_VERSION must be a number
```
**Fix:** Ensure schema version is a number:
```lua
GameConfig.DATA_SCHEMA_VERSION = 2 -- Number, not string
```

### 5. Planets Table Empty
```
❌ [RequiredFields] Planets table is empty - at least one planet required
```
**Fix:** Add at least one planet to GameConfig.Planets table

## Common Warnings and Fixes

### 1. Display Name Missing
```
⚠️  [RequiredFields] DEFAULT_PLANET_NAME is missing (used for UI display)
```
**Fix:** Add display name for UI:
```lua
GameConfig.DEFAULT_PLANET_NAME = "Перша Планета"
```

### 2. Discovery Flags Not Set
```
⚠️  [Location:Planet_1.Location_1] Location.isDiscovered not specified
```
**Fix:** Explicitly set discovery flags:
```lua
Location_1 = {
    isDiscovered = true,  -- Explicitly set
    isVisited = false,    -- Explicitly set
    TeleportTo = false,   -- Explicitly set
    -- ... other fields
}
```

### 3. Optional Scanner Missing
```
⚠️  [SpaceStation] PlanetSurfaceScanner not found (optional feature)
```
**Fix:** This is informational - scanner is optional. Add if needed:
- Path: `ServerStorage/Space/SpaceStation/Workspace/PlanetSurfaceScanner`
- Type: Model

## Testing Your Configuration

### Method 1: Run Test Script
1. Enable `ServerScriptService/Helpers/ConfigValidatorTest.server.luau`
2. Start server in Studio
3. Check Output window for validation report
4. Fix any errors or warnings
5. Disable test script when done

### Method 2: Normal Startup
1. Start server normally
2. ConfigValidator runs automatically
3. Check Output window for report
4. If errors exist, server will stop with error message
5. Fix errors and restart

## Manual Validation

You can also validate configuration programmatically:

```lua
local GameConfig = require(ServerScriptService.GameConfig)
local ConfigValidator = require(ServerScriptService.ConfigValidator)
local ServerStorage = game:GetService("ServerStorage")

-- Run validation
local isValid, report = ConfigValidator.ValidateConfig(GameConfig, ServerStorage)

-- Check result
if isValid then
    print("✅ Configuration is valid!")
else
    print("❌ Configuration has errors!")
end

-- Access report details
print("Errors:", #report.errors)
print("Warnings:", #report.warnings)
```

## Best Practices

### 1. Validate Before Committing
- Always run validation before committing config changes
- Fix all errors before pushing to production
- Review and address warnings

### 2. Keep Config Consistent
- Ensure Name fields match their IDs
- Use consistent naming conventions
- Document any intentional inconsistencies

### 3. Test After Changes
- Test configuration after any GameConfig edits
- Test after any ServerStorage structure changes
- Verify both local testing and production

### 4. Monitor Warnings
- Don't ignore warnings
- Review and fix warnings when possible
- Document why warnings are acceptable if they remain

### 5. Document Custom Configurations
- Comment unusual configurations in GameConfig
- Explain why certain fields are optional
- Note any intentional deviations from standards

## Integration with Other Systems

ConfigValidator works with:

- **GameInit:** Runs validation at startup
- **LocationManager:** Benefits from validated location configs
- **TeleportationManager:** Benefits from validated spawn points
- **EnvironmentLoader:** Benefits from validated ServerStorage structure
- **DataStoreManager:** Benefits from validated schema version

## Performance Impact

- **Validation Time:** < 1 second for typical configurations
- **When It Runs:** Only once at server startup
- **Impact on Players:** None (runs before players can join)
- **Memory Usage:** Minimal (report is temporary)

## Disabling Validation (Not Recommended)

If you absolutely must disable validation:

1. Open `GameInit.server.luau`
2. Comment out validation lines:
```lua
-- local configValid, validationReport = ConfigValidator.ValidateConfig(GameConfig, ServerStorage)
-- if not configValid then
--     error("[GameInit] ❌ GameConfig validation failed!")
-- end
```

**WARNING:** Disabling validation can lead to runtime errors and poor player experience!

## Getting Help

If you encounter validation issues:

1. **Check Error Message:** Read the specific error/warning
2. **Review This Guide:** Look for similar errors above
3. **Check GameConfig:** Verify the field exists and is correct
4. **Check ServerStorage:** Verify models exist in correct locations
5. **Check Documentation:** Review ArchitectureImproves.luau section 8
6. **Review Implementation:** See CONFIG_VALIDATION_IMPLEMENTATION.md

## Related Documentation

- `docs/CONFIG_VALIDATION_IMPLEMENTATION.md` - Full implementation details
- `docs/CONFIG_VALIDATION_ARCHITECTURE.md` - Architecture diagrams
- `ReplicatedStorage/Docs/ArchitectureImproves.luau` - Section 8
- `ServerScriptService/GameConfig.luau` - Configuration structure
- `ServerScriptService/ConfigValidator.luau` - Source code

## Version Information

- **ConfigValidator Version:** 1.0
- **Implemented:** 2026-01-08
- **Priority:** MEDIUM
- **Status:** ✅ COMPLETE
