# Roadmap (KosmicMazer)

This is a practical, short-term roadmap based on the current code snapshot.

## v0.1 - Stabilize Core Loop
- Ensure one teleport system (remove/disable `SimpleTeleportation.server.luau`).
- Centralize RemoteEvent creation on the server; clients only WaitForChild.
- Fix player data schema for teleport counters (`Stats.TotalTeleports`).
- Make GameInit always create defaults if load fails (no early return).

## v0.2 - Location/Teleport Reliability
- Add safe SpawnLocation resolution per location switch.
- Remove duplicate event connections when SpawnLocation changes.
- Add explicit success/failure notifications to the client on teleport.

## v0.3 - Scanner + Discovery Loop
- Restore server-side ScannerService or remove client scanner UI.
- Connect scan results to DataStore (discover/visit updates).
- Activate teleportation only after first successful scan.

## v0.4 - Data Model + Persistence
- Add schema versioning and migrations.
- Add save triggers on discovery/teleport completion.
- Add a small validation report (missing fields repaired on load).

## v0.5 - UX and Visual Pass
- Replace boot screen delays with real progress markers.
- Improve feedback for loading/teleport errors.
- Revisit Lighting/Atmosphere cleanup rules per location.