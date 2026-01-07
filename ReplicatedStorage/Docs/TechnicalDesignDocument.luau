--[[
TECHNICAL DESIGN DOCUMENT (TDD)
Project: KosmicMazer
Platform: Roblox
Language: Lua
Document Version: 2.2
Status: Active Implementation
Owner: Development Team
Last Updated: 2024 (Updated with TeleportationManager v4.1 and GameConfig v3.2)

	==================================================
	1. PURPOSE AND SCOPE
	==================================================

	1.1 Purpose
This document describes the technical architecture, systems, data flow,
	and implementation constraints of the KosmicMazer game.

	1.2 Scope
The TDD covers:
- server-side architecture
- core systems and their responsibilities
- data models and state management
- communication between systems
- technical constraints and assumptions

	==================================================
	2. HIGH-LEVEL ARCHITECTURE
	==================================================

	2.1 Architectural Overview

The game uses a server-authoritative, modular architecture.

	Key principles:
		- Single source of truth for game state
		- Deterministic location lifecycle
		- Clear ownership of Workspace modifications
		- Separation of gameplay logic, UI, and persistence

		2.2 Main Layers

		- Core Layer (game state orchestration)
		- Systems Layer (runtime mechanics)
		- UI Layer (client-side interaction)
		- Data Layer (persistence and configuration)

		==================================================
		3. FOLDER STRUCTURE
		==================================================

	ServerScriptService/
	├── GameInit.lua (Main initialization)
	├── GameConfig.lua (Configuration module)
	├── DataStoreManager.lua (Player data persistence)
	├── PlayerDataManager.lua (Player state management)
	├── TeleportationManager.lua (Teleport system - ModuleScript v4.1)
	├── LocationManager.lua (Location switching - ModuleScript v2.0)
	└── Helpers/
	    ├── DataStoreCleaner.lua (Testing utility)
	    ├── LoadingMonitor.lua (Loading state tracking)
	    └── SystemTest.lua (System monitoring)

	StarterPlayer/
	└── StarterPlayerScripts/
	    ├── PlanetSurfaceScannerClient.lua (Scanner UI)
	    └── TeleportationClient.lua (Teleport UI)

	ServerStorage/
	├── Space/
	│   └── SpaceStation/
	│       ├── PlanetSurfaceScanner/
	│       │   └── ScannerService.lua (Scanner system - activates TeleportationManager)
	│       └── SpawnLocation/
	│           ├── SpawnLocationServer.lua (Server controller)
	│           └── SpawnLocationController.lua (Client controller)
	├── Planet_1/
	│   ├── Lighting/
	│   ├── Planet/
	│   └── Locations/
	│       ├── Location_1/
	│       └── Location_2/
	├── Backlog.lua (Development tracking)
	└── Docs/
		├── GameDesignDocument.lua
	    └── TechnicalDesignDocument.lua

		==================================================
		4. CORE SYSTEMS
		==================================================

	--------------------------------------------------
	4.1 GameInit (IMPLEMENTED - v3.6)
	--------------------------------------------------

	Responsibility:
	- Complete game initialization flow
	- Player login screen with progress bar
	- Data loading and player type detection
	- Environment preparation (Space, Planet, SpaceStation)
	- Player spawning coordination
	- System initialization (DataStoreManager, LocationManager, TeleportationManager)

	State:
	- initialized: boolean
	- currentLocation: string
	- loadingPlayers: table

	Public API:
	- createLoginScreen(player)
	- loadPlayerData(player)
	- prepareGameEnvironment(playerProfile)
	- spawnPlayer(player, playerProfile)
	- initializeGameSystem(): Initializes all core systems

	Calls to:
	- DataStoreManager: LoadPlayerData(), UpdatePlayerData(), Initialize()
	- PlayerDataManager: GetPlayerInfo()
	- GameConfig: Reads planet and game configuration
	- LocationManager: Initialize() for location switching
	- TeleportationManager: Initialize() for teleportation system
	- TweenService: Creates UI animations

	Called from:
	- Automatic execution on server start
	- Players.PlayerAdded event

	Events:
	- Players.PlayerAdded: Triggers player initialization flow

	Dependencies:
	- GameConfig module
	- DataStoreManager module
	- PlayerDataManager module
	- LocationManager module
	- TeleportationManager module
	- Players service
	- ServerStorage service
	- ReplicatedStorage service
	- TweenService

	ChangeLog:
	- Version 3.6: CRITICAL - Added TeleportationManager initialization in initializeGameSystem()
	- Version 3.5: CRITICAL - Updated to use LocationManager as ModuleScript (v2.0)
	- Version 3.5: ENHANCED - Added LocationManager.Initialize() call in initializeGameSystem()
	- Version 3.4: Updated header format to comply with CODE CONVENTION section 14
	- Version 3.3: Added player type detection and improved data handling
	- Version 3.2: Enhanced login screen with avatar and animations
	- Version 3.1: Added comprehensive workspace cleanup
	- Version 3.0: Complete rewrite with modular architecture
	- Initial implementation for game initialization

	--------------------------------------------------
	4.2 DataStoreManager (IMPLEMENTED)
	--------------------------------------------------

	Responsibility:
	- Player data persistence
	- New vs existing player detection
	- Data validation and migration

	Public API:
	- Initialize()
	- LoadPlayerData(player)
	- UpdatePlayerData(player, updates)
	- SavePlayerData(player)

	--------------------------------------------------
	4.3 PlayerDataManager (IMPLEMENTED)
	--------------------------------------------------

	Responsibility:
	- Player state management
	- Statistics tracking
	- Player type classification

	Public API:
	- GetPlayerInfo(player)
	- UpdatePlayerStats(player, updates)
	- GetPlayerType(player)

		==================================================
		5. RUNTIME SYSTEMS
		==================================================

	--------------------------------------------------
	5.1 PlanetSurfaceScanner (IMPLEMENTED)
	--------------------------------------------------

	Responsibility:
	- Planet surface scanning functionality
	- Visual and audio effects during scanning
	- Location discovery tracking
	- Teleportation system activation

	Components:
	- ScannerService.lua (Server-side logic)
	- PlanetSurfaceScannerClient.lua (Client UI)

	States:
	- Inactive (gray scanner)
	- Active (blue scanner with effects)
	- Scanning (full animation sequence)

	Public API:
	- startScanEffect(player)
	- getDiscoveredLocations(player)
	- updateTeleportationState()

	--------------------------------------------------
	5.2 TeleportationManager (IMPLEMENTED - v4.1)
	--------------------------------------------------

	Responsibility:
	- Complete teleportation system management
	- Teleportation UI management with enhanced debounce
	- Location validation and teleportation execution
	- Cooldown enforcement and state management
	- Visual effects during teleport (TeleportParticle)
	- Automatic UI hiding when player leaves SpawnLocation
	- Guaranteed Space Station return option for all planet locations
	- Persistent activation after first successful scan

	Components:
	- TeleportationManager.lua (ModuleScript - Core logic v4.1)
	- TeleportationClient.lua (Client UI - v2.1)
	- ScannerService.lua (Activates TeleportationManager after scan)
	- RemoteEvents: TeleportationEvent, TeleportationStateEvent

	States:
	- Inactive (gray SpawnLocation, no teleportation)
	- Active (blue pulsing SpawnLocation, teleportation enabled)
	- Teleporting (effect sequence and location switch)

	Public API:
	- Initialize(): System initialization and RemoteEvent connection
	- Activate(player, isActive): Activate/deactivate teleportation
	- GetDiscoveredLocations(player): Get player discovered locations
	- SwitchLocation(player, targetLocation): Teleport player to location
	- IsActive(): Check current activation state
	- OnSpawnTouched(otherPart): Handle SpawnLocation touch events
	- OnSpawnTouchEnded(otherPart): Handle SpawnLocation leave events
	- GetState(): Returns current system state for debugging

	Calls to:
	- GameConfig: Teleportation settings and location data
	- DataStoreManager: GetPlayerData(), UpdatePlayerData()
	- LocationManager: SwitchToSpaceStation(), SwitchToPlanetLocation()
	- TweenService: Creates teleportation animations
	- DebrisService: Manages effect cleanup
	- ReplicatedStorage: RemoteEvent management

	Called from:
	- GameInit (for initialization via Initialize())
	- ScannerService (for activation via Activate() after scanning)
	- TeleportationClient (for teleport requests via RemoteEvent)

	Dependencies:
	- GameConfig module
	- DataStoreManager module
	- LocationManager module
	- Players service
	- ReplicatedStorage service
	- TweenService
	- DebrisService

	Critical Fixes (v4.1):
	- FIXED: Teleportation now activates only after player uses scanner (not on game start)
	- ENHANCED: Added playerHasUsedScanner tracking for proper game flow
	- DEBUG: Added detailed logging for teleport request debugging
	- ENHANCED: Added RemoteEvent connection verification logs

	Activation Logic:
	1. Player joins game → TeleportationManager initialized but INACTIVE
	2. Player uses Scanner → ScannerService activates TeleportationManager
	3. TeleportationManager remains ACTIVE for entire game session
	4. LocationManager does NOT deactivate TeleportationManager
	5. Player can teleport between locations indefinitely after activation

		==================================================
		6. DATA MODELS
		==================================================

	--------------------------------------------------
	6.1 GameConfig 
	--------------------------------------------------

	Structure:
	- GameName: string
	- GameVersion: string
	- DEFAULT_PLANET: string
	- Planets: table (planet configurations)
	- PlanetSurfaceScanner: table (scanner settings)
	- Teleportation: table (teleport settings)
	- PULSE_EFFECT_COLOR: Color3
	- PULSE_EFFECT_SPEED: number

	--------------------------------------------------
	6.2 Player Data Model
	--------------------------------------------------

	Attributes:
	- PlayerId: number
	- PlayerName: string
	- CurrentPlanet: string
	- UnlockedPlanets: table
	- DiscoveredLocations: table
	- VisitedLocations: table
	- Stats: table
	  - JoinDate: number
	  - LastLogin: number
	  - TotalPlayTime: number
	  - LocationsDiscovered: number
	  - TotalTeleports: number
	- Settings: table

	--------------------------------------------------
	6.3 Location Model
	--------------------------------------------------

	Attributes:
	- LocationId: string
	- DisplayName: string
	- isDiscovered: boolean
	- SpawnPoint: CFrame
	- TeleportPoint: CFrame
	- Folder: string (model folder name)

==================================================
7. STATE MANAGEMENT
==================================================

		7.1 Global State Rules
		- Only one active location in Workspace
		- Only one SpawnLocation at any time

		7.2 SpawnLocation FSM
		- Defined in SpawnLocationSystem
		- Timers must be cancellable
		- All transitions are server-authoritative

==================================================
8. UI COMMUNICATION
==================================================

		8.1 Client-Server Communication

		Mechanism:
		- RemoteEvents
		- RemoteFunctions

		Use cases:
		- Open Teleport UI
		- Receive selected destination
		- Cancel teleport

==================================================
9. PERSISTENCE
==================================================

	9.1 DataStoreManager
	- Roblox DataStore integration
	- Automatic data loading on player join
	- Incremental data updates
	- Error handling and retry logic

	9.2 Data Structure
	- Player-specific data stores
	- JSON serialization
	- Data validation on load
	- Migration support for schema changes

	9.3 Save Triggers
	- On player data updates
	- On location discovery
	- On teleportation completion
	- On player leave (automatic)

==================================================
10. LOGGING AND DEBUGGING
==================================================

		10.1 Logging Standard
	- Roblox default loogging functions
	- [SystemName] Message content
	- Use emojis for status: ✅ ❌ 🚀 🔍 👤
	- Include player names in logs
	- Log state transitions

		==================================================
		11. PERFORMANCE CONSIDERATIONS
		==================================================

		- Avoid frequent Workspace or ServerStorage scans
		- Use debounces and FSM
		- Limit Heartbeat usage
		- Clean up connections on location change

		==================================================
		12. ERROR HANDLING
		==================================================

		- Fail fast on critical errors
		- Log recoverable issues
		- Guard against invalid state transitions
		- Use pcall() for external calls
		- Validate inputs before processing
		- Provide meaningful error messages
		- Fail gracefully with fallbacks

		==================================================
		13. ASSUMPTIONS AND CONSTRAINTS
		==================================================

	- Multiplayer support (multiple players can coexist)
	- Server-authoritative state management
	- Single active location per player
	- Location data loaded from ServerStorage
	- Client-server communication via RemoteEvents
	- Data persistence across sessions

==================================================
14. CODE CONVENTION
==================================================
	14.1 Script Header Comment Format
--[[
	================================================================================
	KOSMICMAZER — [System Name]
	================================================================================

	Purpose: [Brief description of system/script purpose]
	Version: [Version number]

	Features:
	- [Feature 1]
	- [Feature 2]

	API:
	- [Public function 1]: [Description]
	- [Public function 2]: [Description]

	Calls to:
	- [Module/Service]: [Function called]
	- [Module/Service]: [Function called]
	
	Called from:
	- [Module/Script]: [Function called]
	
	Events:
	- [Event name]: [Description]
	- [Event name]: [Description]
	
	
	Dependencies:
	- [Required modules/services]

	ChangeLog:
	- [Record 1]
	- [Record 2]

	================================================================================
	

	14.2 Naming Conventions
	- Scripts: PascalCase (GameInit.lua)
	- Variables: camelCase (playerData)
	- Functions: camelCase (loadPlayerData)
	- Classes: PascalCase (PlayerManager)
	- Public members: PascalCase (PlayerManager)
	- Public functions: PascalCase (LoadPlayerData)
	- Constants: UPPER_SNAKE_CASE (TELEPORT_COOLDOWN)
	- RemoteEvents: Descriptive names (TeleportationEvent)


==================================================
15. APPENDIX
==================================================

		- Diagrams (FSM, flowcharts)
		- Code conventions
		- Naming standards

		END OF TECHNICAL DESIGN DOCUMENT

]]


local module = {}

return module
