--[[
================================================================================
KOSMICMAZER — TECHNICAL DESIGN DOCUMENT (TDD)
================================================================================

Purpose: Технічна архітектура, системи, потоки даних та обмеження реалізації
Version: 3.9
Status: Active Implementation
Owner: Development Team
Last Updated: 2026-01-07

================================================================================
1. PURPOSE AND SCOPE
================================================================================

1.1 Purpose
Цей документ описує технічну архітектуру, системи, потоки даних
та обмеження реалізації гри KosmicMazer.

1.2 Scope
TDD охоплює:
- Серверну архітектуру
- Основні системи та їх відповідальність
- Моделі даних та керування станом
- Комунікацію між системами
- Технічні обмеження та припущення

================================================================================
2. HIGH-LEVEL ARCHITECTURE
================================================================================

2.1 Architectural Overview
Гра використовує server-authoritative, модульну архітектуру.

Ключові принципи:
- Єдине джерело істини для стану гри
- Детермінований життєвий цикл локацій
- Чітке володіння модифікаціями Workspace
- Розділення ігрової логіки, UI та персистенції
- Graceful degradation при збоях

2.2 Main Layers
- Core Layer (оркестрація стану гри)
- Systems Layer (runtime механіки)
- UI Layer (клієнтська взаємодія)
- Data Layer (персистенція та конфігурація)

2.3 Environment Types
Два типи ігрових середовищ:
1) Space Environment - гравець на орбіті планети (SpaceStation)
2) Planet Environment - гравець на поверхні планети (Locations)

================================================================================
3. FOLDER STRUCTURE
================================================================================

3.1 Поточна структура

ServerScriptService/
├── GameInit.server.luau      -- Головна ініціалізація
├── GameConfig.luau           -- Конфігурація
├── DataStoreManager.luau     -- Персистенція даних гравців
├── PlayerDataManager.luau    -- Керування станом гравців
├── TeleportationManager.luau -- Система телепортації (ModuleScript v4.5)
├── LocationManager.luau      -- Перемикання локацій (ModuleScript v2.3)
├── EnvironmentLoader.luau    -- Завантаження середовищ (v1.6)
├── ObjectTypeValidator.luau  -- Валідація структур (v1.2)
└── Helpers/
    ├── DataStoreCleaner.server.luau    -- Утиліта тестування
    ├── LoadingMonitor.server.luau      -- Моніторинг завантаження
    └── SystemTest.server.luau          -- Моніторинг систем

StarterPlayer/
└── StarterPlayerScripts/
    ├── TeleportationClient.luau  -- UI телепортації (LocalScript)
    ├── ScannerUI2.client.luau    -- UI сканера (LocalScript)
    └── StationUI.luau            -- UI станції (LocalScript)

ReplicatedStorage/
├── Docs/
│   ├── GameDesignDocument.luau
│   ├── TechnicalDesignDocument.luau
│   ├── ArchitectureImproves.luau
│   ├── RefactoringPlan.luau
│   └── Backlog.luau
└── Std/
    ├── CodeConvention.luau
    ├── GuiConvention.luau
    └── LoggingConvention.luau

ServerStorage/
├── Space/
│   └── SpaceStation/
│       ├── Workspace/
│       │   ├── SpawnLocation              -- SpawnLocation: Точка спавну гравця
│       │   ├── PlanetSurfaceScanner       -- Model: Сканер планети
│       │   └── ...                        -- Весь контент копіюється в game.Workspace
│       ├── Scripts/
│       │   ├── Server/
│       │   │   ├── PlanetSurfaceScanner.luau         -- ModuleScript: Логіка сканера
│       │   │   └── PlanetScannerController.luau      -- ModuleScript: Контролер
│       │   └── Client/
│       │       ├── StationUI.luau         -- LocalScript: UI станції
│       │       └── ScannerUI.luau         -- LocalScript: UI сканера
│       └── Configuration/
│           └── LoadOrder.luau             -- ModuleScript: Порядок завантаження об'єктів (v1.0)
└── Planets/
    └── Planet_1/
        ├── Workspace/
        │   └── Planet                     -- Model: Модель планети на орбіті (копіюється в game.Workspace)
        ├── Lighting/
        │   ├── Sky                        -- Sky: Skybox планети (копіюється в game.Lighting)
        │   └── Atmosphere                 -- Atmosphere: Атмосфера (копіюється в game.Lighting)
        ├── Scripts/
        │   ├── Server/
        │   │   └── ...                    -- ModuleScript: Загальні серверні скрипти планети
        │   └── Client/
        │       └── ...                    -- LocalScript: Загальні клієнтські скрипти планети
        ├── Configuration/
        │   └── PlanetConfig.luau          -- ModuleScript: Конфіг планети (v1.0)
        └── Locations/
            ├── Location_1/
            │   ├── Workspace/
            │   │   ├── SpawnLocation      -- SpawnLocation: Точка спавну
            │   │   ├── Baseplate          -- Part: Підлога
            │   │   └── ...                -- Весь контент копіюється в game.Workspace
            │   ├── Scripts/
            │   │   ├── Server/
            │   │   │   └── LocationGameServer.luau  -- ModuleScript: Логіка гри (v1.0)
            │   │   └── Client/
            │   │       └── LocationUI.luau  -- LocalScript: UI локації
            │   ├── Configuration/
            │   │   └── LoadOrder.luau     -- ModuleScript: Порядок завантаження об'єктів (v1.0)
            │   └── Lighting/
            │       └── Sky                -- Sky: Skybox локації (копіюється в game.Lighting)
            ├── Location_2/
            │   ├── Workspace/
            │   │   ├── SpawnLocation      -- SpawnLocation: Точка спавну
            │   │   └── ...                -- Весь контент копіюється в game.Workspace
            │   ├── Scripts/
            │   │   ├── Server/
            │   │   │   └── LocationGameServer.luau  -- ModuleScript: Логіка гри (v1.0)
            │   │   └── Client/
            │   │       └── ...            -- LocalScript: Client скрипти (копіюються в StarterPlayerScripts)
            │   ├── Configuration/
            │   │   └── LoadOrder.luau     -- ModuleScript: Порядок завантаження об'єктів
            │   └── Lighting/
            │       └── ...                -- Копіюється в game.Lighting
            └── Location_3/
                ├── Workspace/
                │   ├── SpawnLocation      -- SpawnLocation: Точка спавну
                │   └── ...                -- Весь контент копіюється в game.Workspace
                ├── Scripts/
                │   ├── Server/
                │   │   └── LocationGameServer.luau  -- ModuleScript: Логіка гри (v1.0)
                │   └── Client/
                │       └── ...            -- LocalScript: Client скрипти (копіюються в StarterPlayerScripts)
                ├── Configuration/
                │   └── LoadOrder.luau     -- ModuleScript: Порядок завантаження об'єктів
                └── Lighting/
                    └── ...                -- Копіюється в game.Lighting

3.2 Правила іменування папок Workspace та Lighting

ВАЖЛИВО: Назви папок показують призначення контенту

Workspace папка:
- Увесь контент з цієї папки копіюється в game.Workspace
- Містить всі ігрові об'єкти: моделі, частини, SpawnLocation, тощо
- Попередня назва: Models, PlanetModel
- Нова назва: Workspace (показує що це → game.Workspace)

Lighting папка:
- Увесь контент з цієї папки копіюється в game.Lighting
- Містить: Sky, Atmosphere, ColorCorrection, Bloom, тощо
- Планети мають Lighting (Sky, Atmosphere для космосу)
- Локації мають Lighting (Sky для поверхні планети)
- SpaceStation НЕ має окремої Lighting (використовує Lighting планети)

Scripts папка:
- Має дві підпапки: Server/ та Client/
- Існує на трьох рівнях:
  1. Space/SpaceStation/Scripts - скрипти космічної станції
  2. Planets/Planet_N/Scripts - загальні скрипти планети (для всіх локацій)
  3. Planets/Planet_N/Locations/Location_N/Scripts - скрипти конкретної локації

Scripts/Server/:
- ModuleScripts, залишаються в ServerStorage
- Доступні через require() з LocationManager та інших систем
- Використовуються для серверної логіки (LocationGameServer, PlanetSurfaceScanner, тощо)

Scripts/Client/:
- LocalScripts, копіюються в StarterPlayerScripts
- Копіюються для кожного гравця при завантаженні середовища
- Виконуються на клієнті для UI та клієнтської логіки
- Послідовність копіювання при завантаженні Space:
  1. Planet/Scripts/Client/ (загальні для планети)
  2. SpaceStation/Scripts/Client/ (специфічні для станції)
- Послідовність при завантаженні Location:
  1. Planet/Scripts/Client/ (загальні для планети) - при LoadSpaceEnvironment
  2. Location/Scripts/Client/ (специфічні для локації) - при LoadPlanetEnvironment

Cleaning правила:
- Перед завантаженням нового середовища:
  1. Очищується game.Workspace (крім Camera, Terrain)
  2. Очищується game.Lighting (всі дочірні об'єкти)
  3. Client скрипти попередньої локації залишаються в StarterPlayerScripts
- EnvironmentLoader.clearWorkspace() виконує Workspace та Lighting очищення

3.3 Планована структура (див. ArchitectureImproves.luau)

ServerStorage/
├── Space/
│   ├── SpaceStation/
│   │   ├── Workspace/      -- Контент → game.Workspace
│   │   ├── Scripts/
│   │   │   ├── Server/     -- Server scripts (→ Workspace/require)
│   │   │   └── Client/     -- Client scripts (→ StarterPlayerScripts)
│   │   └── Configuration/
│   └── Common/
├── Planets/
│   └── Planet_1/
│       ├── Workspace/      -- Контент → game.Workspace
│       ├── Lighting/       -- Контент → game.Lighting
│       ├── Scripts/
│       │   ├── Server/     -- Загальні серверні скрипти планети
│       │   └── Client/     -- Загальні клієнтські скрипти планети
│       ├── Locations/
│       │   └── Location_N/
│       │       ├── Workspace/      -- Контент → game.Workspace
│       │       ├── Scripts/
│       │       │   ├── Server/ -- Server scripts
│       │       │   └── Client/ -- Client scripts
│       │       ├── Lighting/       -- Контент → game.Lighting
│       │       └── Configuration/
│       └── Configuration/
└── Effects/

3.4 Обмеження розміщення скриптів в Roblox

Типи скриптів:
- Script (в ServerScriptService) → виконується ТІЛЬКИ на сервері
- LocalScript (в StarterPlayerScripts) → виконується ТІЛЬКИ на клієнті
- ModuleScript (.luau) → може require з обох сторін

Іменування файлів (див. Std/CodeConvention.luau):
- Одна крапка тільки перед .luau
- ServerScriptService/*.server.luau → Script
- StarterPlayerScripts/*.luau → LocalScript
- Всі інші *.luau → ModuleScript

LocalScript працює ТІЛЬКИ в:
- StarterPlayerScripts, StarterGui, PlayerGui
- StarterCharacterScripts, ReplicatedFirst

LocalScript НЕ працює в:
- Workspace (ігнорується!)
- ServerStorage, ServerScriptService

Тому Scripts/ розділено:
- Scripts/Server/ → Workspace або require як ModuleScript
- Scripts/Client/ → StarterPlayerScripts для кожного гравця

================================================================================
4. CORE SYSTEMS
================================================================================

--------------------------------------------------
4.1 GameInit (IMPLEMENTED - v3.6)
--------------------------------------------------

Responsibility:
- Повна ініціалізація гри
- Екран входу з progress bar
- Завантаження даних та визначення типу гравця
- Підготовка середовища (Space, Planet, SpaceStation)
- Координація спавну гравців
- Ініціалізація систем

State:
- initialized: boolean
- currentLocation: string
- loadingPlayers: table

Public API:
- createLoginScreen(player)
- loadPlayerData(player)
- prepareGameEnvironment(playerProfile)
- spawnPlayer(player, playerProfile)
- initializeGameSystem()

Data Flow:
1. GameInit -> DataStoreManager.LoadPlayerData()
2. DataStoreManager -> повертає дані або створює default
3. GameInit -> спавнить гравця ЗАВЖДИ (навіть при помилках)
4. GameInit -> fire PlayerDataReady event
5. TeleportationManager -> слухає PlayerDataReady

Calls to:
- DataStoreManager: LoadPlayerData(), UpdatePlayerData(), Initialize()
- PlayerDataManager: GetPlayerInfo()
- GameConfig: Читає конфігурацію
- LocationManager: Initialize()
- TeleportationManager: Initialize()

Dependencies:
- GameConfig, DataStoreManager, PlayerDataManager
- LocationManager, TeleportationManager
- Players, ServerStorage, ReplicatedStorage, TweenService

--------------------------------------------------
4.2 DataStoreManager (IMPLEMENTED)
--------------------------------------------------

Responsibility:
- Персистенція даних гравців
- Виявлення нових vs існуючих гравців
- Валідація та міграція даних
- [PLANNED] Схема версіонування даних

Public API:
- Initialize()
- LoadPlayerData(player)
- UpdatePlayerData(player, updates)
- SavePlayerData(player)
- [PLANNED] MigratePlayerData(oldData, fromVersion, toVersion)

Error Handling:
- При недоступності DataStore - працювати з session-only даними
- Повертати default профіль при критичних помилках

--------------------------------------------------
4.3 PlayerDataManager (IMPLEMENTED)
--------------------------------------------------

Responsibility:
- Керування станом гравців
- Відстеження статистики
- Класифікація типів гравців

Public API:
- GetPlayerInfo(player)
- UpdatePlayerStats(player, updates)
- GetPlayerType(player)

================================================================================
5. RUNTIME SYSTEMS
================================================================================

--------------------------------------------------
5.1 LocationManager (IMPLEMENTED - v2.0)
--------------------------------------------------

Responsibility:
- Перемикання локацій
- Завантаження/вивантаження моделей
- Керування освітленням

[PLANNED] FSM States:
- IDLE: Очікування
- CLEANING: Очищення Workspace
- LOADING_PLANET: Завантаження планети
- LOADING_LOCATION: Завантаження локації
- VERIFYING: Перевірка об'єктів
- READY: Готово
- ERROR: Помилка (fallback)

Public API:
- Initialize()
- SwitchToSpaceStation(player)
- SwitchToPlanetLocation(player, locationName)
- [PLANNED] GetState(): string

Error Handling:
- При неможливості завантажити локацію - залишити на поточній
- Timeout на кожен етап з fallback

--------------------------------------------------
5.2 TeleportationManager (IMPLEMENTED - v4.1)
--------------------------------------------------

Responsibility:
- Повне керування телепортацією
- UI телепортації з debounce
- Валідація локацій та виконання телепортації
- Cooldown та керування станом
- Візуальні ефекти (TeleportParticle)
- Автоматичне приховування UI при виході зі SpawnLocation
- Гарантована опція повернення на Space Station

[PLANNED] FSM States:
- INACTIVE: Неактивний (сірий SpawnLocation)
- ACTIVE: Активний (синя пульсація)
- COOLDOWN: Період очікування
- TELEPORTING: Виконання телепорту

Components:
- TeleportationManager.luau (ModuleScript v4.1)
- TeleportationClient.client.luau (Client UI v2.1)
- ScannerService.luau (Активує після скану)
- RemoteEvents: TeleportationEvent, TeleportationStateEvent

Public API:
- Initialize()
- Activate(player, isActive)
- GetDiscoveredLocations(player)
- SwitchLocation(player, targetLocation)
- IsActive()
- OnSpawnTouched(otherPart)
- OnSpawnTouchEnded(otherPart)
- GetState()

Activation Logic:
1. Гравець приєднується → TeleportationManager ініціалізований але INACTIVE
2. Гравець використовує Scanner → ScannerService активує TeleportationManager
3. TeleportationManager залишається ACTIVE на всю сесію
4. Гравець може телепортуватися між локаціями після активації

Connection Management:
- Зберігати підключення в таблиці для disconnect
- При зміні SpawnLocation відключати старі події

--------------------------------------------------
5.3 PlanetSurfaceScanner (IMPLEMENTED)
--------------------------------------------------

Responsibility:
- Сканування поверхні планети
- Візуальні та аудіо ефекти
- Відстеження відкритих локацій
- Активація телепортації

Components:
- PlanetSurfaceScanner.luau (Server logic)
- ScannerService.luau (Scanner controller)
- PlanetSurfaceScannerClient.client.luau (Client UI)

States:
- Inactive (сірий сканер)
- Active (синій сканер з ефектами)
- Scanning (повна анімація)

Public API:
- startScanEffect(player)
- getDiscoveredLocations(player)
- updateTeleportationState()

--------------------------------------------------
5.4 PlanetConfig (NEW - IMPLEMENTED v1.0)
--------------------------------------------------

Responsibility:
- Конфігурація та правила гри СПІЛЬНІ для всіх локацій планети
- Фізичні властивості планети (гравітація, атмосфера)
- Швидкості регенерації ресурсів
- Економіка планети
- Умови відкриття локацій

Location:
ServerStorage/Planets/{PlanetId}/Configuration/PlanetConfig.luau

State:
- PLANET_ID: string
- PLANET_NAME: string
- GRAVITY: number (множник, 1.0 = земна)
- ATMOSPHERE: table (HasOxygen, Density, Color, ...)
- LIGHTING: table (ClockTime, Brightness, ...)
- GAME_RULES: table (AllowResourceCollection, AllowPvP, ...)
- RESOURCE_RATES: table (Ore, Crystal, Artifact, Energy)
- ECONOMY: table (Currency, BasePrices)
- LOCATION_UNLOCK_CONDITIONS: table (умови відкриття)

Public API:
- GetPlanetRules(): table
- GetGravity(): number
- GetAtmosphere(): table
- GetResourceRates(): table
- IsLocationUnlocked(locationId, playerData): boolean
- ApplyPlanetPhysics(): void (застосовує гравітацію до Workspace)

Lifecycle:
- Завантажується LocationManager при зміні планети
- Застосовується при Initialize() LocationGameServer
- Доступний через LocationManager.GetCurrentPlanetConfig()

--------------------------------------------------
5.5 LocationGameServer (NEW - IMPLEMENTED v1.0)
--------------------------------------------------

Responsibility:
- Унікальна ігрова логіка для КОЖНОЇ локації окремо
- Управління ресурсами локації (spawn, respawn)
- Логіка NPC локації
- Квести локації
- Міні-ігри локації
- Трекінг активних гравців в локації

Location:
ServerStorage/Planets/{PlanetId}/Locations/{LocationId}/Scripts/Server/LocationGameServer.luau

State:
- LOCATION_ID: string
- LOCATION_NAME: string
- PLANET_ID: string
- LOCATION_RULES: table (DisplayName, Features, MaxPlayers, ...)
- locationModel: Model (reference до Workspace)
- activePlayers: table (активні гравці в локації)
- resources: table (ресурси локації)
- connections: table (події)
- isInitialized: boolean

Public API:
- Initialize(locationModel): boolean
- Cleanup(): void
- OnPlayerEnter(player): void
- OnPlayerLeave(player): void
- GetLocationRules(): table
- GetActivePlayersCount(): number
- IsInitialized(): boolean

Lifecycle:
1. LocationManager.SwitchToPlanetLocation() викликає EnvironmentLoader
2. EnvironmentLoader копіює локацію в Workspace
3. LocationManager завантажує LocationGameServer з ServerStorage
4. LocationManager викликає Initialize(locationModel)
5. LocationGameServer:
   - Завантажує ресурси (CollectionService tags)
   - Ініціалізує NPC
   - Ініціалізує квести
   - Застосовує PlanetConfig.ApplyPlanetPhysics()
6. При виході з локації: LocationManager викликає Cleanup()

Integration:
- Доступний через LocationManager.GetCurrentLocationGameServer()
- Використовує PlanetConfig для планетарних налаштувань
- Підключений до PlayerDataManager для прогресу гравця

Створені шаблони:
- Location_1/Scripts/Server/LocationGameServer.luau (повний функціонал)
- Location_2/Scripts/Server/LocationGameServer.luau (базовий шаблон)
- Location_3/Scripts/Server/LocationGameServer.luau (базовий шаблон)

================================================================================
6. REMOTE EVENTS ARCHITECTURE
================================================================================

6.1 Поточний стан
RemoteEvents створюються в різних скриптах, можливі дублікати.

6.2 [PLANNED] RemoteEventsRegistry
Єдиний модуль для всіх RemoteEvents:

RemoteEventsRegistry.Events = {
    TeleportationEvent = Instance.new("RemoteEvent"),
    TeleportationStateEvent = Instance.new("RemoteEvent"),
    PlanetSurfaceScanner_Results = Instance.new("RemoteEvent"),
    PlayerDataReady = Instance.new("RemoteEvent"),
}

Правила:
- Всі RemoteEvents створювати ВИКЛЮЧНО через цей модуль на сервері
- Клієнтські скрипти лише WaitForChild(), ніколи Instance.new()
- Валідатор існування під час старту (server-side assert)

================================================================================
7. DATA MODELS
================================================================================

--------------------------------------------------
7.1 GameConfig
--------------------------------------------------

Structure:
- GameName: string
- GameVersion: string
- DEFAULT_PLANET: string
- DEBUG_MODE: boolean [PLANNED]
- DATA_SCHEMA_VERSION: number [PLANNED]
- Planets: table (конфігурації планет)
- PlanetSurfaceScanner: table (налаштування сканера)
- Teleportation: table (налаштування телепорту)
- PULSE_EFFECT_COLOR: Color3
- PULSE_EFFECT_SPEED: number

--------------------------------------------------
7.2 LoadOrder Configuration
--------------------------------------------------

Purpose:
Визначає порядок завантаження об'єктів на локації для уникнення
геометричних конфліктів та забезпечення правильної ініціалізації.

Location:
- ServerStorage/Space/SpaceStation/Configuration/LoadOrder.luau
- ServerStorage/Planets/Planet_N/Locations/Location_N/Configuration/LoadOrder.luau

Structure:
```lua
LoadOrder.ORDER = {
    {name = "SpaceStation", priority = 1},  -- Завантажується першим
    {name = "Planet", priority = 2},
    {name = "PlanetSurfaceScanner", priority = 3},
    {name = "SpawnLocation", priority = 999},  -- Завжди останнім
}
```

API:
- GetPriority(objectName: string): number - отримати пріоритет об'єкта
- SortObjects(objects: {Instance}): {Instance} - відсортувати об'єкти за пріоритетом

Rules:
- Об'єкти не вказані в ORDER отримують пріоритет 500 (середній)
- SpawnLocation має пріоритет 999 (завантажується останнім за замовчуванням)
- Менший пріоритет = раніше завантажується
- Сценарист може змінювати порядок редагуючи Configuration/LoadOrder.luau

Usage:
LocationManager завантажує LoadOrder для кожної локації та передає
в EnvironmentLoader.LoadSpaceEnvironment() або LoadPlanetEnvironment().

--------------------------------------------------
7.3 Player Data Model
--------------------------------------------------

Current Structure:
- PlayerId: number
- PlayerName: string
- CurrentPlanet: string
- CurrentLocation: string
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

[PLANNED] v2 Structure:
PlayerData = {
    SchemaVersion = 2,
    CurrentPlanet = "Planet_1",
    CurrentLocation = "SpaceStation",
    UnlockedPlanets = {"Planet_1"},
    VisitedLocations = {},
    DiscoveredLocations = {},
    Stats = {
        JoinDate = os.time(),
        LastLogin = os.time(),
        TotalPlayTime = 0,
        TotalTeleports = 0,
        LocationsDiscovered = 0,
    },
    Settings = {
        MusicVolume = 1.0,
        SFXVolume = 1.0,
    },
}

--------------------------------------------------
7.3 Location Model
--------------------------------------------------

Attributes:
- LocationId: string
- DisplayName: string
- isDiscovered: boolean
- SpawnPoint: CFrame
- TeleportPoint: CFrame
- Folder: string (назва папки моделі)

================================================================================
8. STATE MANAGEMENT
================================================================================

8.1 Global State Rules
- Тільки одна активна локація в Workspace
- Тільки один SpawnLocation в будь-який момент
- TeleportationManager - єдиний хто оновлює CurrentLocation

8.2 [PLANNED] Location FSM
Pipeline:
IDLE -> CLEANING -> LOADING_PLANET -> LOADING_LOCATION -> VERIFYING -> READY
                                                                    |
                                                                    v
                                                                  ERROR (fallback)

8.3 [PLANNED] Teleportation FSM
States:
- INACTIVE -> ACTIVE -> TELEPORTING -> COOLDOWN -> ACTIVE
                     |
                     v
                  INACTIVE (при виході з гри)

================================================================================
9. CLIENT-SERVER COMMUNICATION
================================================================================

9.1 Mechanism
- RemoteEvents (одностороння комунікація)
- RemoteFunctions (двостороння комунікація)

9.2 Use Cases
- Open Teleport UI
- Receive selected destination
- Cancel teleport
- Scanner results
- Player data ready notification

9.3 [PLANNED] Communication Flow
- Клієнти WaitForChild() для RemoteEvents
- Сервер створює всі RemoteEvents через Registry
- Валідація на сервері перед обробкою

================================================================================
10. PERSISTENCE
================================================================================

10.1 DataStoreManager
- Інтеграція з Roblox DataStore
- Автоматичне завантаження при приєднанні гравця
- Інкрементальні оновлення даних
- Обробка помилок та retry logic
- [PLANNED] Session-only fallback при недоступності

10.2 Data Structure
- Індивідуальні data stores для гравців
- JSON серіалізація
- Валідація даних при завантаженні
- [PLANNED] Підтримка міграції схеми

10.3 Save Triggers
- При оновленні даних гравця
- При відкритті локації
- При завершенні телепортації
- При виході гравця (автоматично)

================================================================================
11. LOGGING AND DEBUGGING
================================================================================

11.1 Logging Standard (див. LoggingConventions.luau)

Формат: [SYSTEM] EMOJI Message (context)

Префікси емодзі:
- ✅ Успіх / Готово
- ❌ Помилка / Збій
- 🚀 Старт процесу
- 🔍 Пошук / Перевірка
- 👤 Гравець
- 📊 Дані / Статистика
- ⏳ Очікування
- ⚠️ Попередження
- 💾 Збереження
- 🔄 Оновлення

11.2 Debug Mode
- GameConfig.DEBUG_MODE = false для продакшену
- Хелпери перевіряють прапорець і автовимикаються
- Тестові скрипти не створюють RemoteEvents в продакшені

================================================================================
12. PERFORMANCE CONSIDERATIONS
================================================================================

- Уникати частих сканувань Workspace або ServerStorage
- Використовувати debounces та FSM
- Обмежити використання Heartbeat
- Очищати connections при зміні локації
- Кешувати часто використовувані посилання

================================================================================
13. ERROR HANDLING
================================================================================

13.1 Principles
- Fail fast при критичних помилках
- Логувати відновлювані проблеми
- Захист від невалідних переходів стану
- Використовувати pcall() для зовнішніх викликів
- Валідувати входи перед обробкою
- Надавати змістовні повідомлення про помилки

13.2 Graceful Degradation
- Якщо LocationManager не може завантажити локацію - залишити на поточній
- Якщо DataStore недоступний - працювати з session-only даними
- Якщо TeleportationManager не ініціалізувався - вимкнути телепортацію
- Fallback значення для всіх критичних операцій
- Гравець ЗАВЖДИ спавниться (fallback на космічну станцію)

================================================================================
14. CONFIG VALIDATION
================================================================================

[PLANNED] Перевірки при старті:
- Структура GameConfig
- Assert на обов'язкові поля планет/локацій
- Попередження про відсутні моделі в ServerStorage
- Fail-fast при критичних проблемах конфігурації

================================================================================
15. ASSUMPTIONS AND CONSTRAINTS
================================================================================

- Підтримка мультиплеєра (кілька гравців одночасно)
- Server-authoritative керування станом
- Одна активна локація на гравця
- Дані локацій завантажуються з ServerStorage
- Комунікація клієнт-сервер через RemoteEvents
- Персистенція даних між сесіями

================================================================================
16. CODE CONVENTION
================================================================================

16.1 Script Header Format
--[[
================================================================================
KOSMICMAZER — [System Name]
================================================================================

Purpose: [Brief description]
Version: [Version number]

Features:
- [Feature 1]
- [Feature 2]

API:
- [Function 1]: [Description]
- [Function 2]: [Description]

Calls to:
- [Module/Service]: [Function called]

Called from:
- [Module/Script]: [Function called]

Events:
- [Event name]: [Description]

Dependencies:
- [Required modules/services]

ChangeLog:
- [Record 1]
- [Record 2]

================================================================================


16.2 Naming Conventions
- Scripts: PascalCase (GameInit.luau)
- Variables: camelCase (playerData)
- Functions: camelCase (loadPlayerData)
- Classes: PascalCase (PlayerManager)
- Public members: PascalCase (PlayerManager)
- Public functions: PascalCase (LoadPlayerData)
- Constants: UPPER_SNAKE_CASE (TELEPORT_COOLDOWN)
- RemoteEvents: Descriptive names (TeleportationEvent)

16.3 File Extensions
- Server scripts: .server.luau
- Client scripts: .client.luau
- ModuleScripts: .luau
- Documentation: .luau або .luaua

================================================================================
17. MIGRATION PLAN
================================================================================

Див. детальний план у ArchitectureImproves.luaua

Фази:
1. Підготовка структури (1-2 дні)
2. Створення менеджерів (2-3 дні)
3. Розширення конфігурації (1 день)
4. Міграція скриптів (3-4 дні)
5. Тестування (2-3 дні)
6. Cleanup (1 день)

Пріоритети:
- ВИСОКИЙ: RemoteEvents Registry, Player Data Flow, Graceful Degradation
- СЕРЕДНІЙ: Config Validation, FSM implementations
- НИЗЬКИЙ: Schema Migrations, New Managers

================================================================================
18. APPENDIX
================================================================================

Пов'язані документи:
- ArchitectureImproves.luaua - Детальний план архітектурних покращень
- LoggingConventions.luau - Стандарти логування
- GameDesignDocument.luau - Ігровий дизайн
- Roadmap.luaua - Дорожня карта розробки

================================================================================
END OF TECHNICAL DESIGN DOCUMENT
================================================================================
]]

local module = {}

module.VERSION = "3.0"
module.STATUS = "Active Implementation"
module.LAST_UPDATED = "2026-01-07"

return module
