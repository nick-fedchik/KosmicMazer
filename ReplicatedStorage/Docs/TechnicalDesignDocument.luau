--[[
================================================================================
KOSMICMAZER — TECHNICAL DESIGN DOCUMENT (TDD)
================================================================================

Purpose: Технічна архітектура, системи, потоки даних та обмеження реалізації
Version: 4.0
Status: Active Implementation
Owner: Development Team
Last Updated: 2026-01-08

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
├── GameInit.server.luau      -- Головна ініціалізація (v3.7)
├── GameConfig.luau           -- Конфігурація (v3.5, DATA_SCHEMA_VERSION=2)
├── ConfigValidator.luau      -- Валідація конфігурації (v1.0) ✅ NEW
├── DataStoreManager.luau     -- Персистенція даних гравців (v2.0 + migrations)
├── PlayerDataManager.luau    -- Керування станом гравців (v1.0)
├── BaseLocationManager.luau  -- Базовий клас для location managers (v1.0) ✅ NEW
├── SpaceStationManager.luau  -- Manager космічної станції (v1.0) ✅ NEW
├── LocationController.template.luau -- Шаблон для planet location controllers (v1.0) ✅ NEW
├── TeleportationManager.luau -- Система телепортації (v4.5)
├── LocationManager.luau      -- Перемикання локацій (v3.0 + FSM) ✅ UPDATED
├── EnvironmentLoader.luau    -- Завантаження середовищ (v1.8 + LoadOrder)
├── LoadOrderProcessor.luau   -- LoadOrder обробка (v1.0)
├── ObjectTypeValidator.luau  -- Валідація структур (v1.2)
└── Helpers/
    ├── ConfigValidatorTest.server.luau -- Тест ConfigValidator (v1.0) ✅ NEW
    ├── DataStoreCleaner.server.luau    -- Утиліта тестування (v1.1)
    ├── LoadingMonitor.server.luau      -- Моніторинг завантаження (v1.0)
    └── SystemTest.server.luau          -- Моніторинг систем (v1.1)

StarterPlayer/
└── StarterPlayerScripts/
    ├── TeleportationClient.luau  -- UI телепортації (LocalScript)
    ├── ScannerUI2.client.luau    -- UI сканера (LocalScript)
    └── StationUI.luau            -- UI станції (LocalScript)

ReplicatedStorage/
├── RemoteEventsRegistry.luau -- Централізований реєстр RemoteEvents (v1.0) ✅ NEW
├── Docs/
│   ├── GameDesignDocument.luau
│   ├── TechnicalDesignDocument.luau
│   ├── ArchitectureImproves.luau
│   ├── RefactoringPlan.luau
│   └── Backlog.luau
└── Std/
    ├── CodeConvention.luau (v3.5)
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
4.1 GameInit (IMPLEMENTED - v3.7)
--------------------------------------------------

Responsibility:
- Повна ініціалізація гри
- Валідація конфігурації через ConfigValidator ✅ NEW
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
- ConfigValidator: ValidateConfig() для перевірки конфігурації ✅ NEW
- DataStoreManager: LoadPlayerData(), UpdatePlayerData(), Initialize()
- PlayerDataManager: GetPlayerInfo()
- GameConfig: Читає конфігурацію
- LocationManager: Initialize()
- TeleportationManager: Initialize()
- RemoteEventsRegistry: Initialize() ✅ NEW

Dependencies:
- ConfigValidator, GameConfig, DataStoreManager, PlayerDataManager
- LocationManager, TeleportationManager, RemoteEventsRegistry
- Players, ServerStorage, ReplicatedStorage, TweenService

--------------------------------------------------
4.2 DataStoreManager (IMPLEMENTED - v2.0)
--------------------------------------------------

Responsibility:
- Персистенція даних гравців
- Виявлення нових vs існуючих гравців
- Валідація та міграція даних
- Схема версіонування даних (SchemaVersion) ✅ IMPLEMENTED

Public API:
- Initialize()
- LoadPlayerData(player)
- UpdatePlayerData(player, updates)
- SavePlayerData(player)
- migratePlayerData(playerData, player) - автоматична міграція v1→v2 ✅ NEW
- getDefaultPlayerData(player) - створення дефолтного профілю з SchemaVersion=2 ✅ NEW

Migration Support:
- v1 → v2: Консолідація Stats, додавання Settings table
- Автоматична міграція при LoadPlayerData()
- Підтримка GameConfig.DATA_SCHEMA_VERSION

Error Handling:
- При недоступності DataStore - працювати з session-only даними
- Повертати default профіль при критичних помилках

--------------------------------------------------
4.3 PlayerDataManager (IMPLEMENTED - v1.0)
--------------------------------------------------

Responsibility:
- Керування станом гравців
- Відстеження статистики
- Класифікація типів гравців

Public API:
- GetPlayerInfo(player)
- UpdatePlayerStats(player, updates)
- GetPlayerType(player)

--------------------------------------------------
4.4 ConfigValidator (IMPLEMENTED - v1.0) ✅ NEW
--------------------------------------------------

Responsibility:
- Валідація структури GameConfig при старті
- Перевірка обов'язкових полів планет та локацій
- Валідація існування моделей у ServerStorage
- Fail-fast при критичних помилках конфігурації
- Попередження про потенційні проблеми

Public API:
- ValidateConfig(config, serverStorage): (boolean, report)
- GetValidationReport(): table

Validation Categories:
- Required Fields: GameName, GameVersion, DATA_SCHEMA_VERSION, DEFAULT_PLANET, etc.
- Planet Configuration: Planet metadata, IsAvailable, Locations
- Location Configuration: Name, DisplayName, SpawnPoint, Folder
- SpaceStation Configuration: SpawnPoint, optional PlanetSurfaceScanner
- ServerStorage Models: Folder structure, model existence, type validation

Error Types:
- Errors (❌): Критичні проблеми - сервер не запуститься
- Warnings (⚠️): Потенційні проблеми - сервер запуститься з попередженнями
- Info (ℹ️): Інформаційні повідомлення про прогрес валідації

Integration:
- Викликається в GameInit.server.luau після завантаження GameConfig
- Зупиняє сервер при критичних помилках конфігурації
- Детальний звіт у консолі про всі проблеми

Benefits:
- Раннє виявлення помилок конфігурації
- Запобігання runtime помилкам через неправильну конфігурацію
- Детальні повідомлення про проблеми з контекстом

--------------------------------------------------
4.5 BaseLocationManager (IMPLEMENTED - v1.0) ✅ NEW
--------------------------------------------------

Responsibility:
- Базовий клас для всіх location managers
- Lifecycle management (Initialize, Cleanup, Update)
- Player tracking (TrackPlayer, UntrackPlayer, GetActivePlayers)
- Event connection management (ConnectEvent, DisconnectAllEvents)
- Custom player data storage (GetPlayerData, SetPlayerData)
- Override hooks для кастомної логіки

Architecture:
Базовий клас з наслідуванням для конкретних реалізацій:
- BaseLocationManager → SpaceStationManager (для космічної станції)
- BaseLocationManager → LocationController (для planet locations)

Public API:
- new(locationId, locationName): self - конструктор
- Initialize(locationModel): boolean - ініціалізація location
- Cleanup(): void - очищення перед вивантаженням
- Update(deltaTime): void - optional update loop
- OnPlayerEnter(player): void - обробка входу гравця
- OnPlayerLeave(player): void - обробка виходу гравця
- TrackPlayer(player): void - додати гравця до активних
- UntrackPlayer(player): void - видалити гравця з активних
- GetActivePlayers(): {Player} - отримати список активних гравців
- ConnectEvent(connection): void - зберегти event connection для cleanup
- DisconnectAllEvents(): void - відключити всі події
- GetPlayerData(player): table - отримати кастомні дані гравця
- SetPlayerData(player, key, value): void - встановити кастомні дані

Override Hooks:
- OnInitialize(locationModel): void - викликається при Initialize()
- OnCleanup(): void - викликається при Cleanup()
- OnUpdate(deltaTime): void - викликається при Update()
- OnPlayerEntered(player): void - викликається після OnPlayerEnter()
- OnPlayerLeft(player): void - викликається перед OnPlayerLeave()

Implementations:
1. SpaceStationManager (v1.0):
   - Управління системами станції (LifeSupport, PowerGrid, Communications)
   - Інтеграція з PlanetSurfaceScanner
   - Відстеження часу перебування гравців на станції
   - GetStationStatus(): table - статус всіх систем станції

2. LocationController (template v1.0):
   - Шаблон для planet location controllers
   - Управління ресурсами локації (spawn, collection)
   - NPC management hooks
   - Кастомізація через LOCATION_CONFIG

Benefits:
- Консистентний API для всіх location managers
- Уникнення дублювання коду (DRY)
- Player tracking автоматично cleanup при disconnect
- Event management запобігає memory leaks
- Легко додавати нові location types через наслідування

--------------------------------------------------
4.6 RemoteEventsRegistry (IMPLEMENTED - v1.0) ✅ NEW
--------------------------------------------------

Responsibility:
- Централізоване створення всіх RemoteEvents
- Єдине джерело істини для RemoteEvents
- Валідація існування RemoteEvents
- Запобігання дублікатам та конфліктам

Architectural Rules:
✅ RemoteEvents створюються ВИКЛЮЧНО через Initialize() на сервері
✅ Клієнти використовують WaitFor() або WaitForChild()
✅ Сервер використовує Get() після Initialize()
❌ НІКОЛИ не створювати RemoteEvents поза цим модулем

Public API:
- Initialize(): (boolean, string?) - створює всі RemoteEvents (server only)
- Get(eventName): RemoteEvent - отримати RemoteEvent (server only)
- WaitFor(eventName, timeout?): RemoteEvent - очікувати RemoteEvent (client)
- Validate(): (boolean, table) - перевірити існування всіх RemoteEvents
- GetRegisteredEvents(): {string} - список всіх зареєстрованих events

Registered RemoteEvents:
- TeleportationEvent - запит на телепортацію від клієнта
- TeleportationStateEvent - оновлення стану телепортації для клієнта
- PlanetSurfaceScanner_Results - результати сканування планети
- PlayerDataReady - сигнал готовності даних гравця

Lifecycle:
1. GameInit.Initialize() викликає RemoteEventsRegistry.Initialize()
2. Всі RemoteEvents створюються в ReplicatedStorage
3. Серверні системи отримують RemoteEvents через Get()
4. Клієнтські скрипти отримують через WaitFor() або WaitForChild()
5. Validate() перевіряє існування всіх events

Benefits:
- Запобігає дублюванню RemoteEvents
- Централізоване управління комунікацією client-server
- Легко додавати нові RemoteEvents
- Валідація при старті запобігає runtime помилкам
- Чітке розуміння всіх точок комунікації в грі

================================================================================
5. RUNTIME SYSTEMS
================================================================================

--------------------------------------------------
5.1 LocationManager (IMPLEMENTED - v3.0 + FSM)
--------------------------------------------------

Responsibility:
- Перемикання локацій
- Завантаження/вивантаження моделей
- Керування освітленням
- FSM-based state management ✅ IMPLEMENTED

FSM States: ✅ IMPLEMENTED
- IDLE: Очікування
- VALIDATING: Валідація параметрів запиту
- CLEANING: Очищення Workspace
- LOADING_PLANET: Завантаження планети
- LOADING_LOCATION: Завантаження локації
- VERIFYING: Перевірка об'єктів
- READY: Готово
- ERROR: Помилка (fallback)

State Transitions:
- IDLE → VALIDATING → CLEANING → LOADING_PLANET → LOADING_LOCATION → VERIFYING → READY
- Any state → ERROR (on failure)
- Timeouts: 10-30s per state with automatic fallback

Public API:
- Initialize()
- SwitchToSpaceStation(planetId, reason) - з FSM валідацією ✅ UPDATED
- SwitchToPlanetLocation(planetId, locationId, reason) - з FSM валідацією ✅ UPDATED
- GetState(): string ✅ IMPLEMENTED
- GetCurrentLocation(): table ✅ IMPLEMENTED

Error Handling:
- При неможливості завантажити локацію - залишити на поточній
- Timeout на кожен етап з fallback
- Детальне логування всіх переходів стану

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

6.1 Поточний стан ✅ IMPLEMENTED
Всі RemoteEvents створюються централізовано через RemoteEventsRegistry.luau (v1.0)

6.2 RemoteEventsRegistry (IMPLEMENTED - v1.0)
Єдиний модуль для всіх RemoteEvents:

Location: ReplicatedStorage/RemoteEventsRegistry.luau

Architecture:
- Initialize() створює всі RemoteEvents на сервері
- Get(eventName) для серверного доступу
- WaitFor(eventName, timeout) для клієнтського доступу
- Validate() перевіряє існування всіх events

Registered Events:
- TeleportationEvent - запит на телепортацію
- TeleportationStateEvent - оновлення стану телепортації
- PlanetSurfaceScanner_Results - результати сканування
- PlayerDataReady - готовність даних гравця

Правила:
✅ Всі RemoteEvents створюються ВИКЛЮЧНО через Initialize()
✅ Клієнти використовують WaitFor() або WaitForChild()
✅ Сервер використовує Get() після Initialize()
✅ Валідація при старті через Validate()
❌ НІКОЛИ не створювати RemoteEvents поза цим модулем

Integration:
- Ініціалізується в GameInit.server.luau
- Використовується TeleportationManager, TeleportationClient
- Використовується PlanetSurfaceScanner, ScannerUI
- Може використовуватися іншими системами для комунікації

================================================================================
7. DATA MODELS
================================================================================

--------------------------------------------------
7.1 GameConfig (v3.5)
--------------------------------------------------

Structure:
- GameName: string
- GameVersion: string
- DEFAULT_PLANET: string
- DEFAULT_PLANET_NAME: string
- DEBUG_MODE: boolean ✅ IMPLEMENTED
- DATA_SCHEMA_VERSION: number = 2 ✅ IMPLEMENTED
- ENABLE_REMOTEEVENTS_VALIDATION: boolean ✅ IMPLEMENTED
- Planets: table (конфігурації планет)
- SpaceStation: table (конфігурація космічної станції)
- PlanetSurfaceScanner: table (налаштування сканера)
- Teleportation: table (Delay, AnimationDuration, Cooldown)
- Spawn: table (RespawnTime, SafeDistance)
- PULSE_EFFECT_COLOR: Color3
- PULSE_EFFECT_SPEED: number
- PlanetHelpers: table (допоміжні функції)

PlanetHelpers Functions:
- GetAvailablePlanets(): {string}
- GetPlanetLocations(planetId): table
- GetLocation(planetId, locationId): table
- GetDiscoveredLocations(planetId): {string}
- GetDefaultPlanet(): string
- IsDefaultPlanet(planetId): boolean
- GetPlayerStartLocation(): table

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
7.3 Player Data Model (v2 - IMPLEMENTED)
--------------------------------------------------

Current Structure (v2):
PlayerData = {
    SchemaVersion = 2, ✅ IMPLEMENTED
    PlayerId = player.UserId,
    PlayerName = player.Name,
    CurrentPlanet = "Planet_1",
    CurrentLocation = "SpaceStation",
    UnlockedPlanets = {"Planet_1"},
    VisitedLocations = {},
    DiscoveredLocations = {},
    Stats = { ✅ CONSOLIDATED
        JoinDate = os.time(),
        LastLogin = os.time(),
        TotalPlayTime = 0,
        LocationsDiscovered = 0,
        TotalTeleports = 0,
    },
    Settings = { ✅ NEW
        MusicVolume = 1.0,
        SFXVolume = 1.0,
    },
}

Migration v1 → v2: ✅ IMPLEMENTED
- Додається SchemaVersion = 2
- Stats консолідуються в одну таблицю
- Додається Settings table з volume settings
- Автоматична міграція при LoadPlayerData()
- Використовує GameConfig.DATA_SCHEMA_VERSION для валідації

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

8.2 Location FSM (IMPLEMENTED - LocationManager v3.0) ✅
States:
- IDLE: Очікування запиту
- VALIDATING: Валідація параметрів (planetId, locationId)
- CLEANING: Очищення Workspace та Lighting
- LOADING_PLANET: Завантаження планети (Workspace/Planet, Lighting/Sky)
- LOADING_LOCATION: Завантаження локації (Workspace, Scripts)
- VERIFYING: Перевірка SpawnLocation та обов'язкових об'єктів
- READY: Готово до роботи
- ERROR: Помилка з fallback

Pipeline:
IDLE → VALIDATING → CLEANING → LOADING_PLANET → LOADING_LOCATION → VERIFYING → READY
  ↑                                      ↓                                        ↓
  └──────────────────────────────────ERROR (fallback) ←──────────────────────────┘

Timeouts:
- VALIDATING: 10s
- CLEANING: 10s
- LOADING_PLANET: 30s
- LOADING_LOCATION: 30s
- VERIFYING: 10s

Features:
- Автоматичний fallback при timeout
- Детальне логування всіх переходів
- Валідація SpawnLocation при VERIFYING
- GetState() для моніторингу

8.3 Teleportation FSM (IMPLEMENTED - TeleportationManager v4.5) ✅
States:
- INACTIVE -> ACTIVE -> TELEPORTING -> COOLDOWN -> ACTIVE
                     |
                     v
                  INACTIVE (при виході з гри)

Поточна реалізація:
- TeleportationManager v4.5 має логіку станів
- FSM не формалізована, але працює через прапорці та cooldowns
- Рекомендується додати явну FSM в майбутньому

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

✅ IMPLEMENTED (ConfigValidator v1.0)

Перевірки при старті:
- Структура GameConfig (Required Fields) ✅
- Валідація всіх планет та локацій ✅
- Перевірка SpaceStation конфігурації ✅
- Валідація моделей у ServerStorage ✅
- Fail-fast при критичних помилках ✅

Validation Flow:
1. GameInit завантажує GameConfig
2. ConfigValidator.ValidateConfig(GameConfig, ServerStorage)
3. Перевірка Required Fields (GameName, DATA_SCHEMA_VERSION, etc.)
4. Валідація всіх планет (metadata, IsAvailable, Locations)
5. Валідація всіх локацій (SpawnPoint, DisplayName, Folder)
6. Перевірка SpaceStation (SpawnPoint, optional PlanetSurfaceScanner)
7. Валідація ServerStorage structure (folders, models, types)
8. Генерація звіту (Errors, Warnings, Info)
9. При Errors - error() та зупинка сервера
10. При Warnings - продовження з логуванням

Error Types:
- ❌ Errors: Критичні проблеми - сервер не запуститься
- ⚠️ Warnings: Потенційні проблеми - сервер запуститься
- ℹ️ Info: Інформаційні повідомлення

Checked Fields:
- GameName, GameVersion exists and non-empty
- DATA_SCHEMA_VERSION is number >= 1
- DEFAULT_PLANET exists and in Planets table
- Planets table not empty
- At least one planet IsAvailable
- All locations have SpawnPoint
- SpawnLocation objects exist and correct type
- Folder structure matches configuration

Benefits:
- Раннє виявлення помилок конфігурації
- Запобігання runtime помилкам
- Детальні повідомлення про проблеми
- Зупинка сервера при критичних помилках

Documentation:
- docs/CONFIG_VALIDATION_IMPLEMENTATION.md
- docs/CONFIG_VALIDATION_ARCHITECTURE.md
- docs/CONFIG_VALIDATION_QUICK_REFERENCE.md

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

module.VERSION = "4.0"
module.STATUS = "Active Implementation"
module.LAST_UPDATED = "2026-01-08"

-- Implemented Systems Summary:
-- ✅ GameInit v3.7: Config validation integration
-- ✅ ConfigValidator v1.0: Complete config validation system
-- ✅ DataStoreManager v2.0: Schema versioning and migrations
-- ✅ LocationManager v3.0: FSM-based location switching
-- ✅ BaseLocationManager v1.0: OOP base class for locations
-- ✅ SpaceStationManager v1.0: Space station implementation
-- ✅ LocationController template v1.0: Planet location template
-- ✅ RemoteEventsRegistry v1.0: Centralized RemoteEvents management
-- ✅ TeleportationManager v4.5: Full teleportation system
-- ✅ EnvironmentLoader v1.8: LoadOrder-based loading
-- ✅ LoadOrderProcessor v1.0: LoadOrder processing utility
-- ✅ ObjectTypeValidator v1.2: Structure validation

return module
