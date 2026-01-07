# Architecture Audit (KosmicMazer)

## Scope
- Reviewed: `ServerScriptService/GameInit.server.luau`, `ServerScriptService/{DataStoreManager.luau,PlayerDataManager.luau,LocationManager.luau,TeleportationManager.luau}`, `StarterPlayerScripts/{TeleportationClient.luau,ScannerUI.luau,StationUI.luau}`, and `ReplicatedStorage/Docs/*`.
- Focus: architecture shape, complexity, and consistency across server/client/scripts.
- Note: `SimpleTeleportation.server.luau` has been removed (was duplicate of TeleportationManager).

## Architecture Shape
- Orchestration: `GameInit` drives the player join flow (boot UI, data load, location load, spawn).
- Core systems:
  - `DataStoreManager`: persistence + auto-save + JSON serialization.
  - `PlayerDataManager`: thin helper wrapper for player data/flags.
  - `LocationManager`: workspace cleanup and loading of SpaceStation/Planet/Location models.
  - `TeleportationManager`: core teleport system, spawn location state and UI triggers.
- Client systems:
  - `TeleportationClient`: UI and teleport request flow.
  - `PlanetSurfaceScannerClient`: scan results UI (server counterpart is referenced in docs but not present in code).
- Docs: TDD/GDD in `ReplicatedStorage/Docs` reflect a more complete architecture than the current codebase.

## Complexity Assessment
- Medium: several server modules, multiple systems that mutate Workspace and Lighting, and multiple sources creating RemoteEvents.
- High coupling between location loading and teleportation (spawn location references, touch events, UI triggering).
- Debug scripts and system tests run unconditionally, which can add noise and side effects in production.

## Consistency Check
- Good: consistent use of `GameConfig` for planet/location data.
- Drift: TDD/GDD mention systems (ScannerService, SpawnLocationController) not present in this repo snapshot.
- [FIXED] Duplication: `SimpleTeleportation.server.luau` removed - only `TeleportationManager` handles teleportation now.
- Version skew: headers claim versions (e.g., TeleportationManager v4.4) that may not match actual behavior or references in docs.

## Key Risks / Gaps
- RemoteEvent ownership is inconsistent:
  - [FIXED] `SimpleTeleportation` removed - only `TeleportationManager` creates `TeleportationEvent` now.
  - `PlanetSurfaceScannerClient` creates a server event from the client side if missing.
  - This can cause duplicated handlers, inconsistent state, or missing server authority.
- Teleportation state vs data model mismatch:
  - `TeleportationManager` updates `TotalTeleports` at top-level, but default data stores telemetry under `Stats`.
  - Reads use `Stats.TotalTeleports` in some places and root `TotalTeleports` in others.
- LocationManager cleanup:
  - Lighting cleanup removes all Lighting children; the "essential" list is a property list, not instance names.
  - Potential to delete required atmosphere/sky effects unintentionally.
- Event connections are reattached repeatedly:
  - `TeleportationManager` reconnects `Touched/TouchEnded` every spawn change without disconnecting prior handlers.
  - Leads to duplicate events and increasing CPU over time.
- GameInit flow stops on new player load failure:
  - If `LoadPlayerData` returns nil, the flow returns early without creating defaults or saving.
  - Player can be stuck on boot screen.
- Multiple systems assume `ServerStorage.Space` and `ServerStorage.<PlanetId>` structures exist; missing assets will cause runtime errors.

## Recommendations
- [DONE] Pick one teleportation system:
  - Removed `SimpleTeleportation.server.luau` - `TeleportationManager` is the only teleportation system.
  - `TeleportationEvent`/`TeleportationStateEvent` created in one place.
- Normalize player data schema:
  - Keep teleport counters in `Stats.TotalTeleports` (or rename everywhere) and migrate old data.
  - Add schema versioning + migration in `DataStoreManager`.
- Enforce server ownership of RemoteEvents:
  - Create events in a single server bootstrap; client should only WaitForChild.
- Fix repeated connection patterns:
  - Track and disconnect old `Touched/TouchEnded` connections when SpawnLocation changes.
- Harden GameInit flow:
  - Always create default profile when load fails; avoid early return that leaves the player stuck.
- Formalize LocationManager lifecycle:
  - Separate "cleanup" and "load" stages; add sanity checks for Lighting assets and ServerStorage models.

## Notable Missing/Drift Items (from TDD)
- ScannerService server-side is referenced but not present.
- SpawnLocationController scripts referenced in docs are absent.
- If these are intentionally removed, update docs to reflect current architecture.