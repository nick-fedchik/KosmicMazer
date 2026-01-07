--[[
================================================================================
KOSMICMAZER — Architecture Improvements & Refactoring Plan
================================================================================

Purpose: Узгоджена архітектура, рефакторинг структури та план міграції
Version: 3.5
Status: PLANNING
Last Updated: 2026-01-07

================================================================================
ЧАСТИНА I: АРХІТЕКТУРНІ ПОКРАЩЕННЯ
================================================================================

================================================================================
1) ЄДИНЕ ДЖЕРЕЛО ІСТИНИ ДЛЯ REMOTEEVENTS
================================================================================
Проблема: RemoteEvents створюються в різних скриптах, можливі дублікати.

Рішення:
- Створити ReplicatedStorage/RemoteEventsRegistry.luau модуль
- Всі RemoteEvents створювати ВИКЛЮЧНО через цей модуль на сервері
- Клієнтські скрипти лише WaitForChild(), ніколи Instance.new()
- Валідатор існування RemoteEvents під час старту (server-side assert)

Приклад:
    local Registry = {}
    Registry.Events = {
        TeleportationEvent = Instance.new("RemoteEvent"),
        TeleportationStateEvent = Instance.new("RemoteEvent"),
        PlanetSurfaceScanner_Results = Instance.new("RemoteEvent"),
        PlayerDataReady = Instance.new("RemoteEvent"),
    }
    for name, event in pairs(Registry.Events) do
        event.Name = name
        event.Parent = ReplicatedStorage
    end
    return Registry

Пріоритет: ВИСОКИЙ

================================================================================
2) СХЕМА ДАНИХ І МІГРАЦІЇ
================================================================================
Проблема: Зміни структури даних можуть зламати існуючих гравців.

Рішення:
- Додати SchemaVersion у профіль гравця
- Додати DATA_SCHEMA_VERSION константу в GameConfig
- Функція migratePlayerData(oldData, fromVersion, toVersion) в DataStoreManager
- Автоматична міграція при завантаженні
- Звести всі статистики до одного розділу Stats

Структура даних v2:
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
        }
    }

Пріоритет: СЕРЕДНІЙ

================================================================================
3) ЧІТКИЙ ЖИТТЄВИЙ ЦИКЛ ЛОКАЦІЙ (FSM)
================================================================================
Проблема: Невизначений порядок операцій при зміні локації.

Рішення:
- LocationManager має визначений pipeline
- Метод LocationManager.GetState() для діагностики
- Timeout на кожен етап з автоматичним fallback
- Перевірка наявності моделей у ServerStorage до початку свічу

FSM стани:
    LocationState = {
        IDLE = "Idle",
        CLEANING = "Cleaning",
        LOADING_PLANET = "LoadingPlanet",
        LOADING_LOCATION = "LoadingLocation",
        VERIFYING = "Verifying",
        READY = "Ready",
        ERROR = "Error",
    }

Pipeline:
    IDLE -> CLEANING -> LOADING_PLANET -> LOADING_LOCATION -> VERIFYING -> READY
                                                                   |
                                                                   v
                                                                 ERROR (fallback)

Пріоритет: СЕРЕДНІЙ

================================================================================
4) ТЕЛЕПОРТАЦІЯ (FSM)
================================================================================
Проблема: Дублювання логіки, невідключені події, неявні стани.

Рішення:
- Один TeleportationManager в продакшені
- Видалити непотрібні DEBUG скрипти
- При зміні SpawnLocation відключувати старі події
- Зберігати підключення в таблиці для disconnect
- Винести логіку станів у явну FSM

FSM стани:
    TeleportState = {
        INACTIVE = "Inactive",
        ACTIVE = "Active",
        COOLDOWN = "Cooldown",
        TELEPORTING = "Teleporting",
    }

Приклад керування підключеннями:
    local connections = {}
    
    local function connectToSpawn(spawn)
        for _, conn in ipairs(connections) do
            conn:Disconnect()
        end
        connections = {}
        
        table.insert(connections, spawn.Touched:Connect(onTouched))
        table.insert(connections, spawn.TouchEnded:Connect(onTouchEnded))
    end

Пріоритет: СЕРЕДНІЙ

================================================================================
5) PLAYER DATA FLOW
================================================================================
Проблема: Неузгодженість оновлення даних гравця між модулями.

Рішення:
- GameInit не повинен виходити з ранніх return без спавну
- У разі помилки DataStore — створити дефолтний профіль
- Fallback spawn при помилці (космічна станція)
- Централізувати оновлення CurrentLocation ЛИШЕ в TeleportationManager
- Event PlayerDataReady для інших систем

Data Flow:
    1. GameInit -> DataStoreManager.LoadPlayerData()
    2. DataStoreManager -> повертає дані або створює default
    3. GameInit -> спавнить гравця ЗАВЖДИ
    4. GameInit -> fire PlayerDataReady event
    5. TeleportationManager -> слухає PlayerDataReady
    6. TeleportationManager -> єдиний хто оновлює CurrentLocation

Пріоритет: ВИСОКИЙ

================================================================================
6) ТЕСТОВІ/ДІАГНОСТИЧНІ СКРИПТИ
================================================================================
Проблема: Тестові скрипти можуть впливати на продакшен.

Рішення:
- Додати GameConfig.DEBUG_MODE = false
- Хелпери перевіряють цей прапорець і автовимикаються
- SystemTest/LoadingMonitor не створюють RemoteEvents

Приклад:
    local GameConfig = require(...)
    if not GameConfig.DEBUG_MODE then
        return -- Не запускати в продакшені
    end

Пріоритет: НИЗЬКИЙ

================================================================================
7) GRACEFUL DEGRADATION
================================================================================
Проблема: Збої в одній системі можуть зламати всю гру.

Рішення:
- Якщо LocationManager не може завантажити локацію — залишити на поточній
- Якщо DataStore недоступний — працювати з session-only даними
- Якщо TeleportationManager не ініціалізувався — вимкнути телепортацію
- Fallback значення для всіх критичних операцій

Пріоритет: ВИСОКИЙ

================================================================================
8) CONFIG VALIDATION
================================================================================
Проблема: Некоректна конфігурація може призвести до runtime помилок.

Рішення:
- Перевірка GameConfig структури при старті
- Assert на обовязкові поля планет/локацій
- Попередження про відсутні моделі в ServerStorage
- Fail-fast при критичних проблемах

Пріоритет: СЕРЕДНІЙ

================================================================================
ЧАСТИНА II: ПЛАН РЕФАКТОРИНГУ СТРУКТУРИ
================================================================================

================================================================================
9) НОВА СТРУКТУРА SERVERSTORAGE (З ТИПІЗАЦІЄЮ ОБ'ЄКТІВ)
================================================================================

Поточна структура (спрощена):
    ServerStorage/
    ├── Space/SpaceStation/
    ├── Planet_1/
    │   ├── Planet/
    │   ├── Lighting/
    │   └── Locations/Location_1/
    └── Effects/

Нова структура з чіткою типізацією:
    ServerStorage/
    ├── Space/                        -- Folder: Space environment
    │   ├── SpaceStation/             -- Folder: Space Station location
    │   │   ├── Models/               -- Folder: All station models
    │   │   │   ├── SpawnLocation    -- SpawnLocation: Player spawn point
    │   │   │   ├── PlanetSurfaceScanner    -- Model: Planet scanning device
    │   │   │   ├── TeleportationDevice -- Model: Teleportation interface
    │   │   │   └── ... (other station objects)
    │   │   ├── Scripts/              -- Folder: Station-specific scripts
    │   │   │   ├── Server/       -- Folder: Server-side scripts (copy to Workspace or require)
    │   │   │   │   ├── SpaceStationManager.luau -- ModuleScript: Station controller
    │   │   │   │   ├── PlanetSurfaceScanner.luau -- ModuleScript: Scanner logic (активує телепортацію)
    │   │   │   │   ├── PlanetScannerController.luau -- ModuleScript: Scanner hardware controller
    │   │   │   │   └── ...
    │   │   │   └── Client/       -- Folder: Client-side scripts (copy to StarterPlayerScripts/StarterGui)
    │   │   │       ├── StationUI.client.luau -- LocalScript: Station UI
    │   │   │       ├── ScannerUI.client.luau -- LocalScript: Scanner interface
    │   │   │       └── ...
    │   │   ├── Lighting/             -- Folder: Station lighting
    │   │   │   ├── Sky               -- Sky: Station skybox
    │   │   │   ├── Atmosphere        -- Atmosphere: Station atmosphere
    │   │   │   └── ...
    │   │   └── Configuration/        -- Folder: Station config
    │   │       ├── Settings.luau     -- ModuleScript: Station settings
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
    │   │   │   │   │   ├── Server/ -- Folder: Server scripts (copy to Workspace)
    │   │   │   │   │   │   ├── LocationController.luau -- ModuleScript: Location logic
    │   │   │   │   │   │   ├── ResourceController.luau -- ModuleScript: Resource manager
    │   │   │   │   │   │   └── ...
    │   │   │   │   │   └── Client/ -- Folder: Client scripts (copy to StarterPlayerScripts)
    │   │   │   │   │       ├── LocationUI.client.luau -- LocalScript: Location UI
    │   │   │   │   │       ├── DialogSystem.client.luau -- LocalScript: NPC dialogs
    │   │   │   │   │       └── ...
    │   │   │   │   ├── Lighting/   -- Folder: Location lighting
    │   │   │   │   │   ├── Sky       -- Sky: Location skybox
    │   │   │   │   │   ├── LightSources -- Folder: Light sources
    │   │   │   │   │   └── ...
    │   │   │   │   └── Configuration/ -- Folder: Location config
    │   │   │   │       ├── Settings.luau -- ModuleScript: Location settings
    │   │   │   │       └── ...
    │   │   │   ├── Location_2/      -- Folder: Second location
    │   │   │   │   └── ... (same structure as Location_1)
    │   │   │   └── ...
    │   │   ├── Scripts/             -- Folder: Planet-wide scripts
    │   │   │   ├── PlanetManager.luau -- ModuleScript: Planet controller
    │   │   │   └── ...
    │   │   └── Configuration/       -- Folder: Planet config
    │   │       ├── Settings.luau     -- ModuleScript: Planet settings
    │   │       └── ...
    │   └── Planet_2/               -- Folder: Second planet
    │       └── ... (same structure as Planet_1)
    ├── Effects/                    -- Folder: Global effects (existing)
    │   ├── TeleportAnimation/      -- Folder: Teleport effects
    │   │   └── TeleportParticle     -- ParticleEmitter: Teleport effect
    │   └── ...
    └── ...

================================================================================
10) МЕНЕДЖЕРИ В SERVERSCRIPTSERVICE
================================================================================

Всі менеджери знаходяться в ServerScriptService і виконуються на сервері.
Менеджери в ServerStorage/Scripts/ - це ШАБЛОНИ, не активні скрипти!

ServerScriptService/
├── GameInit.server.luau       -- EXISTING: Ініціалізація гри
│   -- Створює RemoteEvents
│   -- Завантажує дані гравця
│   -- Спавнить гравця
│
├── GameConfig.luau            -- EXISTING: Конфігурація гри
│   -- Налаштування планет/локацій
│   -- Константи гри
│
├── DataStoreManager.luau      -- EXISTING: Персистенція даних
│   -- Зберігання/завантаження даних гравців
│   -- Міграції схеми даних
│
├── PlayerDataManager.luau     -- EXISTING: Стан гравців
│   -- Кеш даних гравців
│   -- Статистика
│
├── LocationManager.luau       -- EXISTING: Перемикання локацій
│   -- Завантаження/вивантаження з ServerStorage
│   -- Керування Workspace
│   -- Керування Lighting
│
├── TeleportationManager.luau  -- EXISTING: Система телепортації
│   -- Працює з УСІМА локаціями
│   -- Обробляє SpawnLocation
│   -- UI телепортації
│   -- RemoteEvents комунікація
│
├── GameWorldManager.luau      -- NEW: Головний координатор світів
│   -- Керує завантаженням/вивантаженням світів
│   -- Координує Space і Planet менеджери
│   -- Обробляє переходи між середовищами
│
├── SpaceStationManager.luau   -- NEW: Контролер космічної станції
│   -- Керує об'єктами станції
│   -- Обробляє правила станції
│   -- Реєструє/знімає реєстрацію об'єктів
│
├── PlanetManager.luau         -- NEW: Контролер планети
│   -- Керує системами планети
│   -- Координує локації планети
│   -- Обробляє правила планети
│
├── EnvironmentLoader.luau     -- NEW: Завантажувач середовищ
│   -- Копіювання моделей з ServerStorage
│   -- Копіювання скриптів у правильні місця
│   -- Валідація завантаження
│
└── ObjectTypeValidator.luau   -- NEW: Валідатор типів об'єктів
    -- Перевірка структури ServerStorage
    -- Валідація конфігурації

МЕНЕДЖЕРИ КОНКРЕТНИХ ЛОКАЦІЙ - В SERVERSTORAGE (НЕ В SSS!):
============================================================
Менеджери конкретних локацій (Location_1_Manager, Location_2_Manager, etc.)
знаходяться в ServerStorage разом з локацією і копіюються при завантаженні.

Див. секцію 12.1.1 "КАРТА КОПІЮВАННЯ СКРИПТІВ" для деталей.

ServerStorage/Planets/{PlanetName}/Locations/{LocationName}/Scripts/Server/
├── LocationController.luau    -- ModuleScript: Контролер локації
├── ResourceController.luau    -- ModuleScript: Ресурси локації
└── {LocationName}Manager.luau -- ModuleScript: Специфічна логіка локації

ВАЖЛИВО: Різниця між ServerScriptService та ServerStorage/Scripts:
=========================================================================

ServerScriptService/LocationManager.luau:
    - ВИКОНУЄТЬСЯ автоматично при старті сервера
    - Глобальний для всіх локацій
    - Завжди активний

ServerStorage/Planets/Planet_1/Locations/Location_1/Scripts/Server/LocationController.luau:
    - НЕ виконується автоматично
    - Це ШАБЛОН для конкретної локації
    - Копіюється в Workspace при завантаженні локації
    - Або require з ServerScriptService менеджера

================================================================================
10.1) PLANETCONFIG ТА LOCATIONGAMESERVER (НОВИЙ АРХІТЕКТУРНИЙ ЕЛЕМЕНТ)
================================================================================

Статус: ✅ РЕАЛІЗОВАНО в версії 3.5

Проблема: Різні планети та локації мають різні правила гри, ресурси, фізику.
Потрібна модульна архітектура для підтримки унікальної логіки кожної локації.

Рішення:
- PlanetConfig: Конфігурація та правила гри СПІЛЬНІ для всіх локацій планети
- LocationGameServer: Унікальна ігрова логіка для КОЖНОЇ локації окремо

┌─────────────────────────────────────────────────────────────────────────────┐
│ PLANETCONFIG - КОНФІГУРАЦІЯ ПЛАНЕТИ                                         │
├─────────────────────────────────────────────────────────────────────────────┤
│ Розташування: ServerStorage/Planets/{PlanetId}/Configuration/PlanetConfig  │
│ Тип: ModuleScript                                                           │
│ Завантаження: LocationManager при зміні планети                             │
│                                                                             │
│ Відповідальність:                                                          │
│   • Фізичні властивості планети (гравітація, атмосфера)                    │
│   • Загальні правила гри для всіх локацій планети                          │
│   • Швидкості регенерації ресурсів (множники)                              │
│   • Економіка планети (ціни, валюта)                                       │
│   • Умови відкриття локацій (рівень, квести)                               │
│                                                                             │
│ API:                                                                        │
│   • GetPlanetRules(): Правила гри                                           │
│   • GetGravity(): Гравітація планети                                        │
│   • GetAtmosphere(): Параметри атмосфери                                    │
│   • GetResourceRates(): Швидкості регенерації                               │
│   • IsLocationUnlocked(locationId, playerData): Перевірка доступу          │
│   • ApplyPlanetPhysics(): Застосувати фізику до Workspace                  │
│                                                                             │
│ Приклад структури:                                                          │
│   PlanetConfig = {                                                          │
│       PLANET_ID = "Planet_1",                                               │
│       GRAVITY = 1.0,                                                        │
│       ATMOSPHERE = { HasOxygen = true, Density = 1.0, ... },                │
│       GAME_RULES = {                                                        │
│           AllowResourceCollection = true,                                   │
│           ResourceRespawnTime = 60,                                         │
│           AllowPvP = false,                                                 │
│       },                                                                    │
│       RESOURCE_RATES = { Ore = 1.0, Crystal = 0.8, ... },                  │
│       LOCATION_UNLOCK_CONDITIONS = { ... }                                  │
│   }                                                                         │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ LOCATIONGAMESERVER - ЛОГІКА ГРИ ЛОКАЦІЇ                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│ Розташування: ServerStorage/Planets/{PlanetId}/Locations/{LocationId}/     │
│               Scripts/Server/LocationGameServer.luau                        │
│ Тип: ModuleScript                                                           │
│ Завантаження: LocationManager при зміні локації                             │
│                                                                             │
│ Відповідальність:                                                          │
│   • Правила гри СПЕЦИФІЧНІ для цієї локації                                │
│   • Управління ресурсами локації (spawn, respawn)                          │
│   • Логіка NPC локації                                                     │
│   • Квести локації                                                         │
│   • Міні-ігри локації                                                      │
│   • Обробка входу/виходу гравців                                           │
│   • Трекінг активних гравців в локації                                     │
│                                                                             │
│ API:                                                                        │
│   • Initialize(locationModel): Ініціалізація логіки                        │
│   • Cleanup(): Очищення перед вивантаженням                                │
│   • OnPlayerEnter(player): Гравець входить в локацію                       │
│   • OnPlayerLeave(player): Гравець виходить з локації                      │
│   • GetLocationRules(): Правила локації                                     │
│   • GetActivePlayersCount(): Кількість активних гравців                    │
│   • IsInitialized(): Статус ініціалізації                                  │
│                                                                             │
│ Приклад структури:                                                          │
│   LocationGameServer = {                                                    │
│       LOCATION_ID = "Location_1",                                           │
│       LOCATION_NAME = "Садочок",                                            │
│       LOCATION_RULES = {                                                    │
│           DisplayName = "Садочок",                                          │
│           Features = { HasResources = true, HasNPCs = true, ... },         │
│           MaxPlayers = 10,                                                  │
│           ResourceDensity = 1.2,                                            │
│           IsSafeZone = true,                                                │
│           DifficultyLevel = 1,                                              │
│       }                                                                     │
│   }                                                                         │
└─────────────────────────────────────────────────────────────────────────────┘

ІНТЕГРАЦІЯ З LOCATIONMANAGER:
============================

LocationManager тепер автоматично:
1. Завантажує PlanetConfig при зміні планети (або Space Station)
2. Завантажує LocationGameServer при зміні локації
3. Викликає Initialize() після завантаження локації
4. Викликає Cleanup() перед вивантаженням локації
5. Надає доступ через GetCurrentPlanetConfig() та GetCurrentLocationGameServer()

Потік завантаження локації:
    LocationManager.SwitchToPlanetLocation("Planet_1", "Location_1")
      ├─> cleanupWorkspace()
      │     └─> currentLocationGameServer.Cleanup() // якщо була попередня
      │
      ├─> EnvironmentLoader.LoadPlanetEnvironment()
      │     └─> Копіює моделі з ServerStorage в Workspace
      │
      ├─> require(PlanetConfig) для Planet_1
      │     └─> currentPlanetConfig = PlanetConfig
      │
      └─> require(LocationGameServer) для Location_1
            ├─> currentLocationGameServer = LocationGameServer
            └─> LocationGameServer.Initialize(locationModel)
                  ├─> PlanetConfig.ApplyPlanetPhysics()
                  ├─> loadResources()
                  ├─> initializeNPCs()
                  └─> initializeQuests()

ПЕРЕВАГИ АРХІТЕКТУРИ:
=====================
✅ Модульність: Кожна локація має свою логіку
✅ Повторне використання: Планетарні налаштування діляться між локаціями
✅ Масштабованість: Легко додати нові планети/локації
✅ Тестування: Можна тестувати локації незалежно
✅ Підтримка: Зміни в одній локації не впливають на інші

СТВОРЕНО ШАБЛОНИ:
=================
• ServerStorage/Planets/Planet_1/Configuration/PlanetConfig.luau
• ServerStorage/Planets/Planet_1/Locations/Location_1/Scripts/Server/LocationGameServer.luau
• ServerStorage/Planets/Planet_1/Locations/Location_2/Scripts/Server/LocationGameServer.luau
• ServerStorage/Planets/Planet_1/Locations/Location_3/Scripts/Server/LocationGameServer.luau

================================================================================
11) РОЗШИРЕНА КОНФІГУРАЦІЯ GAMECONFIG
================================================================================

GameConfig розширення:
    {
        -- Системні налаштування
        DEBUG_MODE = false,
        DATA_SCHEMA_VERSION = 2,
        
        -- Світи
        Worlds = {
            Space = {
                Locations = {
                    SpaceStation = {
                        DisplayName = "Космічна Станція",
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
                            InteractionObjects = {...},
                            GameRules = {
                                ResourceRegeneration = true,
                                MaxResources = 100,
                            }
                        }
                    }
                }
            }
        }
    }

================================================================================
12) СИСТЕМА ІГРОВИХ СЕРЕДОВИЩ
================================================================================

Два типи ігрових середовищ:
1) Space Environment - гравець на орбіті планети
2) Planet Environment - гравець на поверхні планети

================================================================================
12.1) ВАЖЛИВО: РОЗМІЩЕННЯ СКРИПТІВ В ROBLOX
================================================================================

ПРАВИЛО: Скрипти, які виконуються на сервері, повинні знаходитись в ServerScriptService.
Скрипти, які знаходяться в ServerStorage, є шаблонами і не виконуються автоматично.

Roblox має обмеження на виконання скриптів:
- Script (.server.luau) → виконується ТІЛЬКИ на сервері
- LocalScript (.client.luau) → виконується ТІЛЬКИ на клієнті
- ModuleScript (.luau) → може require з обох сторін

LocalScript працює ТІЛЬКИ в:
- StarterPlayerScripts
- StarterGui / PlayerGui
- StarterCharacterScripts
- ReplicatedFirst

LocalScript НЕ працює в:
- Workspace (ігнорується!)
- ServerStorage
- ServerScriptService

Правильне розміщення скриптів:

ServerScriptService/ (ВИКОНАННЯ НА СЕРВЕРІ):
├── GameInit.server.luau       -- Script: Ініціалізація гри (виконується)
├── GameConfig.luau            -- ModuleScript: Конфігурація гри
├── DataStoreManager.luau      -- ModuleScript: Персистенція даних
├── PlayerDataManager.luau     -- ModuleScript: Стан гравців
├── LocationManager.luau       -- ModuleScript: Перемикання локацій
├── TeleportationManager.luau  -- ModuleScript: Телепортація (глобальний для ВСІХ локацій)
├── GameWorldManager.luau      -- ModuleScript: Головний координатор світів
├── SpaceStationManager.luau   -- ModuleScript: Контролер космічної станції
├── PlanetManager.luau         -- ModuleScript: Контролер планети
├── EnvironmentLoader.luau     -- ModuleScript: Завантажувач середовищ
└── ObjectTypeValidator.luau   -- ModuleScript: Валідатор типів об'єктів

ПРИМІТКА: Менеджери конкретних локацій (Location_1_Manager, etc.) 
знаходяться в ServerStorage разом з локацією - див. секцію 12.1.1

ServerStorage/ (ШАБЛОНИ - НЕ ВИКОНУЮТЬСЯ):
├── Space/
│   └── SpaceStation/
│       ├── Scripts/            -- Folder: Шаблони скриптів станції
│       │   ├── Server/       -- Folder: Server-side scripts (copy to Workspace or require)
│       │   │   ├── SpaceStationManager.luau -- ModuleScript: Шаблон контролера станції
│       │   │   ├── PlanetSurfaceScanner.luau -- ModuleScript: Сканер планет (активує телепортацію)
│       │   │   ├── PlanetScannerController.luau -- ModuleScript: Контролер обладнання сканера
│       │   │   └── ...
│       │   └── Client/       -- Folder: Client-side scripts (copy to StarterPlayerScripts/StarterGui)
│       │       ├── StationUI.client.luau -- LocalScript: Station UI
│       │       ├── ScannerUI.client.luau -- LocalScript: Scanner interface
│       │       ├── PlanetSurfaceScannerClient.client.luau -- LocalScript: Scanner UI
│       │       └── ...
│       └── ...
├── Planets/
│   ├── Planet_1/
│   │   ├── Scripts/            -- Folder: Шаблони скриптів планети
│   │   │   ├── Server/       -- Folder: Server scripts (copy to Workspace)
│   │   │   │   ├── PlanetManager.luau -- ModuleScript: Шаблон контролера
│   │   │   │   └── ...
│   │   │   └── Client/       -- Folder: Client scripts (copy to StarterPlayerScripts)
│   │   │       ├── PlanetUI.client.luau -- LocalScript: Planet UI
│   │   │       └── ...
│   │   └── Locations/
│   │       ├── Location_1/
│   │       │   ├── Scripts/    -- Folder: Шаблони скриптів локації
│   │       │   │   ├── Server/ -- Folder: Server scripts (copy to Workspace)
│   │       │   │   │   ├── LocationController.luau -- ModuleScript: Шаблон контролера
│   │       │   │   │   ├── ResourceController.luau -- ModuleScript: Шаблон контролера
│   │       │   │   │   └── ...
│   │       │   │   └── Client/ -- Folder: Client scripts (copy to StarterPlayerScripts)
│   │       │   │       ├── LocationUI.client.luau -- LocalScript: Location UI
│   │       │   │       ├── DialogSystem.client.luau -- LocalScript: NPC dialogs
│   │       │   │       └── ...
│   │       │   └── ...
│   │       └── ...
│   └── ...
└── ...

ВАЖЛИВІ ПРИНЦИПИ:

1. ServerScriptService:
   - Скрипти тут виконуються на сервері
   - ModuleScript'и для логіки менеджерів
   - Script'и для ініціалізації та подій
   - Глобальні системи та контролери

2. ServerStorage:
   - Шаблони моделей та об'єктів
   - Скрипти тут НЕ виконуються автоматично
   - Використовуються як шаблони для копіювання
   - Конфігураційні файли

3. Workspace:
   - Скрипти тут виконуються на клієнті (якщо LocalScript)
   - Скрипти тут виконуються на сервері (якщо Script)
   - Скрипти, пов'язані з конкретними об'єктами

4. ReplicatedStorage:
   - Спільні модулі між клієнтом та сервером
   - RemoteEvents та RemoteFunctions
   - Клієнтські скрипти (LocalScript)

ПРИКЛАД ПРАВИЛЬНОЇ АРХІТЕКТУРИ:

ServerScriptService/GameWorldManager.luau (виконується):
    local EnvironmentLoader = require(script.Parent.EnvironmentLoader)
    local LocationManager = require(script.Parent.LocationManager)
    
    -- Логіка координації світів

ServerStorage/Space/SpaceStation/Scripts/Server/SpaceStationManager.luau (шаблон):
    -- Логіка контролера станції
    -- Копіюється в Workspace при завантаженні
    -- Виконується там як частина завантаженого середовища

Це гарантує правильне виконання скриптів та уникнення дублювання логіки.

================================================================================
12.1.1) КАРТА КОПІЮВАННЯ СКРИПТІВ
================================================================================

==============================================================================
A) КОСМІЧНА СТАНЦІЯ (SpaceStation)
==============================================================================

ДЖЕРЕЛО: ServerStorage/Space/SpaceStation/

┌─────────────────────────────────────────────────────────────────────────────┐
│ СЕРВЕРНІ СКРИПТИ (Scripts/Server/)                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│ ЗВІДКИ:                          КУДИ:                      ТИП:            │
│ ─────────────────────────────────────────────────────────────────────────── │
│ Scripts/Server/*.luau            require() з SSS            ModuleScript    │
│ (ModuleScript)                   (НЕ копіюється!)                           │
│                                                                             │
│ Scripts/Server/*.server.luau     Workspace/SpaceStation/    Script          │
│ (Script)                         Scripts/                   (виконується)   │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ КЛІЄНТСЬКІ СКРИПТИ (Scripts/Client/)                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│ ЗВІДКИ:                          КУДИ:                      ТИП:            │
│ ─────────────────────────────────────────────────────────────────────────── │
│ Scripts/Client/*.client.luau     1. StarterPlayerScripts/   LocalScript     │
│ (LocalScript)                       SpaceStation/           (для нових)     │
│                                                                             │
│                                  2. player.PlayerScripts/   LocalScript     │
│                                     SpaceStation/           (для активних)  │
└─────────────────────────────────────────────────────────────────────────────┘

ПОТІК ЗАВАНТАЖЕННЯ КОСМІЧНОЇ СТАНЦІЇ:

1. EnvironmentLoader.LoadSpaceStation():
   
   -- Крок 1: Очистити Workspace від попередньої локації
   ClearWorkspace()
   ClearClientScripts("PreviousLocation")
   
   -- Крок 2: Копіювати моделі
   ServerStorage.Space.SpaceStation.Models:Clone().Parent = Workspace
   
   -- Крок 3: Серверні скрипти
   -- ModuleScript (.luau) → require() напряму, не копіювати
   -- Script (.server.luau) → Clone в Workspace/SpaceStation/Scripts/
   for _, script in Scripts.Server:GetChildren() do
       if script:IsA("Script") then
           script:Clone().Parent = Workspace.SpaceStation.Scripts
       end
   end
   
   -- Крок 4: Клієнтські скрипти
   local stationFolder = Instance.new("Folder")
   stationFolder.Name = "SpaceStation"
   stationFolder.Parent = StarterPlayer.StarterPlayerScripts
   
   for _, script in Scripts.Client:GetChildren() do
       script:Clone().Parent = stationFolder
   end
   
   -- Для активних гравців
   for _, player in Players:GetPlayers() do
       local playerFolder = Instance.new("Folder")
       playerFolder.Name = "SpaceStation"
       playerFolder.Parent = player.PlayerScripts
       
       for _, script in Scripts.Client:GetChildren() do
           script:Clone().Parent = playerFolder
       end
   end

ВИВАНТАЖЕННЯ КОСМІЧНОЇ СТАНЦІЇ:

1. Видалити Workspace/SpaceStation/
2. Видалити StarterPlayerScripts/SpaceStation/
3. Для кожного гравця: видалити player.PlayerScripts/SpaceStation/

==============================================================================
B) ПЛАНЕТНІ ЛОКАЦІЇ (Planet Locations)
==============================================================================

ДЖЕРЕЛО: ServerStorage/Planets/{PlanetName}/Locations/{LocationName}/

┌─────────────────────────────────────────────────────────────────────────────┐
│ СЕРВЕРНІ СКРИПТИ (Scripts/Server/)                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│ ЗВІДКИ:                          КУДИ:                      ТИП:            │
│ ─────────────────────────────────────────────────────────────────────────── │
│ Scripts/Server/*.luau            require() з SSS            ModuleScript    │
│ (ModuleScript)                   (НЕ копіюється!)                           │
│                                                                             │
│ Scripts/Server/*.server.luau     Workspace/{LocationName}/  Script          │
│ (Script)                         Scripts/                   (виконується)   │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ КЛІЄНТСЬКІ СКРИПТИ (Scripts/Client/)                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│ ЗВІДКИ:                          КУДИ:                      ТИП:            │
│ ─────────────────────────────────────────────────────────────────────────── │
│ Scripts/Client/*.client.luau     1. StarterPlayerScripts/   LocalScript     │
│ (LocalScript)                       {LocationName}/         (для нових)     │
│                                                                             │
│                                  2. player.PlayerScripts/   LocalScript     │
│                                     {LocationName}/         (для активних)  │
└─────────────────────────────────────────────────────────────────────────────┘

ПОТІК ЗАВАНТАЖЕННЯ ПЛАНЕТНОЇ ЛОКАЦІЇ:

1. EnvironmentLoader.LoadPlanetLocation(planetName, locationName):
   
   -- Крок 1: Очистити попередню локацію
   ClearWorkspace()
   ClearClientScripts("PreviousLocation")
   
   -- Крок 2: Копіювати моделі локації
   local locationTemplate = ServerStorage.Planets[planetName].Locations[locationName]
   locationTemplate.Models:Clone().Parent = Workspace
   
   -- Крок 3: Застосувати освітлення
   ApplyLighting(locationTemplate.Lighting)
   
   -- Крок 4: Серверні скрипти
   local scriptsFolder = Instance.new("Folder")
   scriptsFolder.Name = "Scripts"
   scriptsFolder.Parent = Workspace[locationName]
   
   for _, script in locationTemplate.Scripts.Server:GetChildren() do
       if script:IsA("Script") then
           script:Clone().Parent = scriptsFolder
       end
       -- ModuleScript → require() напряму з оригінального місця
   end
   
   -- Крок 5: Клієнтські скрипти
   local locationFolder = Instance.new("Folder")
   locationFolder.Name = locationName
   locationFolder.Parent = StarterPlayer.StarterPlayerScripts
   
   for _, script in locationTemplate.Scripts.Client:GetChildren() do
       script:Clone().Parent = locationFolder
   end
   
   -- Для активних гравців
   for _, player in Players:GetPlayers() do
       local playerFolder = Instance.new("Folder")
       playerFolder.Name = locationName
       playerFolder.Parent = player.PlayerScripts
       
       for _, script in locationTemplate.Scripts.Client:GetChildren() do
           script:Clone().Parent = playerFolder
       end
   end

ВИВАНТАЖЕННЯ ПЛАНЕТНОЇ ЛОКАЦІЇ:

1. Видалити Workspace/{LocationName}/
2. Видалити StarterPlayerScripts/{LocationName}/
3. Для кожного гравця: видалити player.PlayerScripts/{LocationName}/

==============================================================================
C) ГЛОБАЛЬНІ СКРИПТИ (НЕ КОПІЮЮТЬСЯ)
==============================================================================

Деякі скрипти працюють глобально для ВСІХ локацій:

┌─────────────────────────────────────────────────────────────────────────────┐
│ ГЛОБАЛЬНІ СЕРВЕРНІ СКРИПТИ (ServerScriptService/)                           │
├─────────────────────────────────────────────────────────────────────────────┤
│ СКРИПТ:                          ОПИС:                                      │
│ ─────────────────────────────────────────────────────────────────────────── │
│ GameInit.server.luau             Ініціалізація гри                          │
│ TeleportationManager.luau        Телепортація (працює всюди)                │
│ DataStoreManager.luau            Збереження даних                           │
│ PlayerDataManager.luau           Управління даними гравців                  │
│ LocationManager.luau             Перемикання локацій                        │
│ EnvironmentLoader.luau           Завантаження середовищ                     │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ ГЛОБАЛЬНІ КЛІЄНТСЬКІ СКРИПТИ (StarterPlayerScripts/)                        │
├─────────────────────────────────────────────────────────────────────────────┤
│ СКРИПТ:                          ОПИС:                                      │
│ ─────────────────────────────────────────────────────────────────────────── │
│ TeleportationClient.client.luau  UI телепортації (працює всюди)             │
│ GlobalUI.client.luau             Глобальний UI (меню, налаштування)         │
└─────────────────────────────────────────────────────────────────────────────┘

ПРАВИЛО: Глобальні скрипти НЕ видаляються при зміні локації!

================================================================================
12.2) АЛГОРИТМ ЗАВАНТАЖЕННЯ ЛОКАЦІЇ
================================================================================

function LoadLocation(locationTemplate)
    -- 1. Очистити Workspace від попередньої локації
    ClearWorkspace()
    
    -- 2. Копіювати Models/ в Workspace
    CloneToWorkspace(locationTemplate.Models)
    
    -- 3. Застосувати Lighting/
    ApplyLighting(locationTemplate.Lighting)
    
    -- 4. Обробити Scripts/Server/
    for script in locationTemplate.Scripts.Server do
        if script:IsA("ModuleScript") then
            -- ModuleScript: require з оригінального місця
            -- або клонувати в Workspace для локальних даних
            RegisterModule(script)
        elseif script:IsA("Script") then
            -- Script: клонувати в Workspace (виконається автоматично)
            script:Clone().Parent = workspace.CurrentLocation
        end
    end
    
    -- 5. Обробити Scripts/Client/
    for script in locationTemplate.Scripts.Client do
        -- LocalScript: клонувати в StarterPlayerScripts
        -- Для ВСІХ активних гравців!
        for _, player in Players:GetPlayers() do
            local clone = script:Clone()
            clone.Parent = player.PlayerScripts
        end
    end
    
    -- 6. Завантажити Configuration/
    LoadConfiguration(locationTemplate.Configuration)
end

function UnloadLocation()
    -- 1. Видалити клієнтські скрипти локації
    for _, player in Players:GetPlayers() do
        RemoveLocationScripts(player.PlayerScripts)
    end
    
    -- 2. Очистити Workspace
    ClearWorkspace()
end

================================================================================
12.3) ENVIRONMENT LOADING SEQUENCES
================================================================================

Space Environment Loading:
    1. Clear Workspace
    2. Copy Planet Model + Lighting
    3. Copy SpaceStation Models/ to Workspace
    4. Process SpaceStation Scripts/Server/
    5. Process SpaceStation Scripts/Client/ → StarterPlayerScripts
    6. Verify all objects loaded
    7. Spawn player at SpawnLocation

Planet Environment Loading:
    1. Clear Workspace
    2. Copy Location Models/ to Workspace
    3. Apply Location Lighting/
    4. Process Location Scripts/Server/
    5. Process Location Scripts/Client/ → StarterPlayerScripts
    6. Verify all objects loaded
    7. Spawn player at SpawnLocation

Environment Switching:
    - GameWorldManager координує переходи
    - Кожне середовище має свою послідовність
    - Стан гравця зберігається під час переходів
    - Loading screen при потребі
    - Клієнтські скрипти попередньої локації видаляються

================================================================================
12.4) ПРОТОКОЛ ОЧИСТКИ ЛОКАЦІЙ
================================================================================

==============================================================================
A) ОЧИСТКА КОСМІЧНОЇ СТАНЦІЇ (UnloadSpaceStation)
==============================================================================

КРОК 1: Зупинити всі активні процеси
┌─────────────────────────────────────────────────────────────────────────────┐
│ ОПЕРАЦІЯ                           │ ДЕТАЛІ                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│ 1.1 Відключити події Touched        │ Disconnect всіх connections для       │
│                                     │ TeleportPads, Scanners, etc.          │
│ 1.2 Зупинити таймери                │ Cancel всіх task.delay/task.spawn     │
│ 1.3 Закрити відкриті UI             │ Сховати ScannerUI, діалоги            │
│ 1.4 Зупинити анімації               │ Stop TweenService анімацій            │
└─────────────────────────────────────────────────────────────────────────────┘

КРОК 2: Видалити клієнтські скрипти
┌─────────────────────────────────────────────────────────────────────────────┐
│ ЗВІДКИ ВИДАЛЯТИ                    │ ЩО ВИДАЛЯТИ                            │
├─────────────────────────────────────────────────────────────────────────────┤
│ StarterPlayerScripts/              │ Folder "SpaceStation" повністю         │
│ player.PlayerScripts/              │ Folder "SpaceStation" для кожного      │
│                                    │ активного гравця                       │
└─────────────────────────────────────────────────────────────────────────────┘

Код:
    local function removeClientScripts_SpaceStation()
        -- Видалити зі StarterPlayerScripts
        local starterFolder = StarterPlayer.StarterPlayerScripts:FindFirstChild("SpaceStation")
        if starterFolder then
            starterFolder:Destroy()
        end
        
        -- Видалити з PlayerScripts кожного активного гравця
        for _, player in Players:GetPlayers() do
            local playerFolder = player:FindFirstChild("PlayerScripts")
            if playerFolder then
                local locationFolder = playerFolder:FindFirstChild("SpaceStation")
                if locationFolder then
                    locationFolder:Destroy()
                end
            end
        end
    end

КРОК 3: Видалити серверні об'єкти
┌─────────────────────────────────────────────────────────────────────────────┐
│ ЗВІДКИ ВИДАЛЯТИ                    │ ЩО ВИДАЛЯТИ                            │
├─────────────────────────────────────────────────────────────────────────────┤
│ Workspace/                         │ SpaceStation (модель з усім вмістом)   │
│ Workspace/                         │ Planet (модель планети на орбіті)      │
│ Workspace/                         │ Skybox (якщо окремий об'єкт)           │
└─────────────────────────────────────────────────────────────────────────────┘

Код:
    local function removeServerObjects_SpaceStation()
        local objectsToRemove = {
            "SpaceStation",
            "Planet",
            "Skybox",
            "SpaceEnvironment"
        }
        
        for _, objName in ipairs(objectsToRemove) do
            local obj = Workspace:FindFirstChild(objName)
            if obj then
                obj:Destroy()
            end
        end
    end

КРОК 4: Скинути освітлення
┌─────────────────────────────────────────────────────────────────────────────┐
│ ПАРАМЕТР                           │ ЗНАЧЕННЯ ЗА ЗАМОВЧУВАННЯМ              │
├─────────────────────────────────────────────────────────────────────────────┤
│ Lighting.Ambient                   │ Color3.fromRGB(127, 127, 127)          │
│ Lighting.Brightness                │ 1                                      │
│ Lighting.ColorShift_Bottom         │ Color3.fromRGB(0, 0, 0)                │
│ Lighting.ColorShift_Top            │ Color3.fromRGB(0, 0, 0)                │
│ Lighting.OutdoorAmbient            │ Color3.fromRGB(127, 127, 127)          │
│ Lighting.ClockTime                 │ 14                                     │
│ Lighting.GeographicLatitude        │ 0                                      │
│ Lighting.FogEnd                    │ 100000                                 │
│ Lighting.FogStart                  │ 0                                      │
└─────────────────────────────────────────────────────────────────────────────┘

КРОК 5: Очистити тимчасові дані
┌─────────────────────────────────────────────────────────────────────────────┐
│ ДАНІ                               │ ДІЯ                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│ SpaceStationManager.state          │ Скинути до nil                         │
│ ActiveScanResults                  │ Очистити таблицю                       │
│ PlayerPositions                    │ Зберегти для аналітики (опціонально)   │
└─────────────────────────────────────────────────────────────────────────────┘

ПОВНА ПОСЛІДОВНІСТЬ ОЧИСТКИ SPACESTATION:

    function EnvironmentLoader.UnloadSpaceStation()
        print("[EnvironmentLoader] Unloading SpaceStation...")
        
        -- 1. Зупинити процеси
        SpaceStationManager:StopAllProcesses()
        
        -- 2. Відключити події
        for _, conn in ipairs(spaceStationConnections) do
            conn:Disconnect()
        end
        spaceStationConnections = {}
        
        -- 3. Закрити UI для всіх гравців
        TeleportationManager:FireAllClients("CloseUI")
        
        -- 4. Видалити клієнтські скрипти
        removeClientScripts_SpaceStation()
        
        -- 5. Видалити серверні об'єкти
        removeServerObjects_SpaceStation()
        
        -- 6. Скинути освітлення
        resetLighting()
        
        -- 7. Очистити стан
        currentLocationName = nil
        currentLocationType = nil
        
        print("[EnvironmentLoader] SpaceStation unloaded successfully")
    end

==============================================================================
B) ОЧИСТКА ПЛАНЕТНОЇ ЛОКАЦІЇ (UnloadPlanetLocation)
==============================================================================

КРОК 1: Зупинити всі активні процеси
┌─────────────────────────────────────────────────────────────────────────────┐
│ ОПЕРАЦІЯ                           │ ДЕТАЛІ                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│ 1.1 Зупинити NPC діалоги           │ Закрити активні діалоги                │
│ 1.2 Зупинити ресурсні таймери      │ Cancel регенерації ресурсів            │
│ 1.3 Зупинити ambient sounds        │ Stop всіх SoundService звуків локації  │
│ 1.4 Закрити міні-ігри              │ Завершити активні міні-ігри            │
│ 1.5 Відключити колізії             │ Disconnect Touched events              │
└─────────────────────────────────────────────────────────────────────────────┘

КРОК 2: Видалити клієнтські скрипти
┌─────────────────────────────────────────────────────────────────────────────┐
│ ЗВІДКИ ВИДАЛЯТИ                    │ ЩО ВИДАЛЯТИ                            │
├─────────────────────────────────────────────────────────────────────────────┤
│ StarterPlayerScripts/              │ Folder "{LocationName}" повністю       │
│ player.PlayerScripts/              │ Folder "{LocationName}" для кожного    │
│                                    │ активного гравця                       │
│ StarterGui/                        │ ScreenGui "{LocationName}UI"           │
│ player.PlayerGui/                  │ ScreenGui "{LocationName}UI"           │
└─────────────────────────────────────────────────────────────────────────────┘

Код:
    local function removeClientScripts_PlanetLocation(locationName)
        -- Видалити скрипти зі StarterPlayerScripts
        local starterFolder = StarterPlayer.StarterPlayerScripts:FindFirstChild(locationName)
        if starterFolder then
            starterFolder:Destroy()
        end
        
        -- Видалити скрипти з PlayerScripts кожного гравця
        for _, player in Players:GetPlayers() do
            local playerScripts = player:FindFirstChild("PlayerScripts")
            if playerScripts then
                local locationFolder = playerScripts:FindFirstChild(locationName)
                if locationFolder then
                    locationFolder:Destroy()
                end
            end
            
            -- Видалити GUI локації
            local playerGui = player:FindFirstChild("PlayerGui")
            if playerGui then
                local locationGui = playerGui:FindFirstChild(locationName .. "UI")
                if locationGui then
                    locationGui:Destroy()
                end
            end
        end
        
        -- Видалити зі StarterGui
        local starterGui = StarterGui:FindFirstChild(locationName .. "UI")
        if starterGui then
            starterGui:Destroy()
        end
    end

КРОК 3: Видалити серверні об'єкти
┌─────────────────────────────────────────────────────────────────────────────┐
│ ЗВІДКИ ВИДАЛЯТИ                    │ ЩО ВИДАЛЯТИ                            │
├─────────────────────────────────────────────────────────────────────────────┤
│ Workspace/                         │ {LocationName} (модель локації)        │
│ Workspace/                         │ Terrain (якщо локація має свій terrain)│
│ Workspace/                         │ NPCs (NPC моделі локації)              │
│ Workspace/                         │ Resources (ресурсні об'єкти)           │
└─────────────────────────────────────────────────────────────────────────────┘

Код:
    local function removeServerObjects_PlanetLocation(locationName)
        -- Основна модель локації
        local locationModel = Workspace:FindFirstChild(locationName)
        if locationModel then
            locationModel:Destroy()
        end
        
        -- Додаткові об'єкти з тегом локації
        local CollectionService = game:GetService("CollectionService")
        local taggedObjects = CollectionService:GetTagged("Location_" .. locationName)
        for _, obj in ipairs(taggedObjects) do
            obj:Destroy()
        end
        
        -- Очистити Scripts папку якщо є окрема
        local scriptsFolder = Workspace:FindFirstChild("Scripts")
        if scriptsFolder then
            local locationScripts = scriptsFolder:FindFirstChild(locationName)
            if locationScripts then
                locationScripts:Destroy()
            end
        end
    end

КРОК 4: Скинути освітлення планети
┌─────────────────────────────────────────────────────────────────────────────┐
│ ДІЯ                                │ ДЕТАЛІ                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│ Видалити атмосферні ефекти         │ Atmosphere, Clouds, Sky                │
│ Скинути колір                      │ Ambient, OutdoorAmbient                │
│ Скинути туман                      │ FogEnd, FogStart, FogColor             │
│ Скинути час доби                   │ ClockTime до дефолту                   │
└─────────────────────────────────────────────────────────────────────────────┘

Код:
    local function resetPlanetLighting()
        local Lighting = game:GetService("Lighting")
        
        -- Видалити атмосферні ефекти локації
        for _, child in Lighting:GetChildren() do
            if child:HasTag("LocationEffect") then
                child:Destroy()
            end
        end
        
        -- Скинути до дефолтних значень
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        Lighting.Brightness = 1
        Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
        Lighting.FogColor = Color3.fromRGB(191, 191, 191)
    end

КРОК 5: Очистити тимчасові дані локації
┌─────────────────────────────────────────────────────────────────────────────┐
│ ДАНІ                               │ ДІЯ                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│ LocationManager.currentLocation    │ Скинути до nil                         │
│ ResourceController.resources       │ Очистити таблицю                       │
│ NPCController.activeNPCs           │ Очистити таблицю                       │
│ CollectedResources                 │ Зберегти в PlayerData перед очисткою   │
└─────────────────────────────────────────────────────────────────────────────┘

ПОВНА ПОСЛІДОВНІСТЬ ОЧИСТКИ PLANET LOCATION:

    function EnvironmentLoader.UnloadPlanetLocation(locationName)
        print("[EnvironmentLoader] Unloading PlanetLocation: " .. locationName)
        
        -- 1. Зберегти прогрес гравців
        for _, player in Players:GetPlayers() do
            PlayerDataManager:SaveLocationProgress(player, locationName)
        end
        
        -- 2. Зупинити процеси локації
        if LocationManagers[locationName] then
            LocationManagers[locationName]:StopAllProcesses()
        end
        
        -- 3. Відключити події
        if locationConnections[locationName] then
            for _, conn in ipairs(locationConnections[locationName]) do
                conn:Disconnect()
            end
            locationConnections[locationName] = nil
        end
        
        -- 4. Закрити UI для всіх гравців
        TeleportationManager:FireAllClients("CloseLocationUI", locationName)
        
        -- 5. Видалити клієнтські скрипти
        removeClientScripts_PlanetLocation(locationName)
        
        -- 6. Видалити серверні об'єкти
        removeServerObjects_PlanetLocation(locationName)
        
        -- 7. Скинути освітлення
        resetPlanetLighting()
        
        -- 8. Очистити стан
        currentLocationName = nil
        currentPlanetName = nil
        currentLocationType = nil
        
        print("[EnvironmentLoader] PlanetLocation unloaded: " .. locationName)
    end

==============================================================================
C) ПОРІВНЯННЯ ПРОТОКОЛІВ ОЧИСТКИ
==============================================================================

┌─────────────────────────────────────────────────────────────────────────────┐
│ АСПЕКТ               │ SPACESTATION          │ PLANET LOCATION              │
├─────────────────────────────────────────────────────────────────────────────┤
│ Клієнтські скрипти   │ SpaceStation/         │ {LocationName}/              │
│ Серверні об'єкти     │ SpaceStation, Planet  │ {LocationName}, NPCs         │
│ GUI                  │ ScannerUI             │ {LocationName}UI             │
│ Освітлення           │ Космічне (темне)      │ Планетарне (різне)           │
│ Збереження прогресу  │ Ні                    │ Так (ресурси, квести)        │
│ Атмосфера            │ Skybox                │ Atmosphere, Clouds           │
│ NPC                  │ Немає                 │ Є (діалоги, квести)          │
│ Ресурси              │ Немає                 │ Є (регенерація)              │
└─────────────────────────────────────────────────────────────────────────────┘

==============================================================================
D) ПЕРЕХІД МІЖ ЛОКАЦІЯМИ
==============================================================================

SpaceStation → PlanetLocation:
    1. UnloadSpaceStation()
    2. LoadPlanetLocation(planetName, locationName)

PlanetLocation → SpaceStation:
    1. UnloadPlanetLocation(locationName)
    2. LoadSpaceStation(planetName)

PlanetLocation → PlanetLocation (та сама планета):
    1. UnloadPlanetLocation(oldLocationName)
    2. LoadPlanetLocation(planetName, newLocationName)

PlanetLocation → PlanetLocation (інша планета):
    1. UnloadPlanetLocation(oldLocationName)
    2. LoadSpaceStation(newPlanetName) -- проміжний етап
    3. LoadPlanetLocation(newPlanetName, newLocationName)

================================================================================
ЧАСТИНА III: ПЛАН МІГРАЦІЇ
================================================================================

================================================================================
13) ФАЗИ ВПРОВАДЖЕННЯ
================================================================================

PHASE 1: Підготовка структури (1-2 дні) ✅ ЗАВЕРШЕНО
    [X] Створити нову структуру ServerStorage/Space та ServerStorage/Planets
    [X] Перемістити існуючі моделі
    [X] Створити шаблони для майбутнього контенту
    [X] Створити ObjectTypeValidator.luau для перевірки типів
    [X] Створити EnvironmentLoader.luau з валідацією
    [X] Інтегрувати ObjectTypeValidator в EnvironmentLoader
    [X] Оновити LocationManager для використання нової структури
    [X] Спроектувати систему завантаження середовищ з валідацією
    [X] Створити SpawnLocation для Space Station
    [X] Оновити документацію з типізацією об'єктів
    [X] Створити PlanetConfig модуль для кожної планети
    [X] Створити LocationGameServer для кожної локації
    [X] Інтегрувати PlanetConfig та LocationGameServer в LocationManager

PHASE 2: Створення менеджерів (2-3 дні) 🔄 В ПРОЦЕСІ
    [X] Створити шаблони менеджерів локацій (LocationGameServer в ServerStorage/.../Scripts/Server/)
    [X] Створити PlanetConfig для планет (в ServerStorage/Planets/*/Configuration/)
    [ ] Створити BaseLocationManager з базовим функціоналом (в ServerStorage/Common/)
    [ ] Створити GameWorldManager як головний координатор (в SSS)
    [ ] Створити SpaceStationManager та PlanetManager (в SSS)
    [ ] Створити RemoteEventsRegistry (в SSS)

PHASE 3: Розширення конфігурації (1 день)
    [ ] Розширити GameConfig новою структурою
    [ ] Додати конфігурацію interaction objects
    [ ] Додати конфігурацію game rules
    [ ] Додати DEBUG_MODE та DATA_SCHEMA_VERSION

PHASE 4: Міграція скриптів (3-4 дні)
    [ ] Мігрувати логіку до нових менеджерів
    [ ] Оновити LocationManager
    [ ] Оновити TeleportationManager
    [ ] Оновити ScannerService
    [ ] Імплементувати перемикання середовищ
    [ ] Імплементувати схему міграції даних

PHASE 5: Тестування (2-3 дні)
    [ ] Тестувати всі переходи локацій
    [ ] Тестувати interaction objects
    [ ] Тестувати game rules
    [ ] Тестувати перемикання середовищ
    [ ] Тестувати збереження стану гравця
    [ ] Тестувати graceful degradation

PHASE 6: Cleanup (1 день)
    [ ] Видалити стару структуру
    [ ] Очистити невикористані скрипти
    [ ] Оновити документацію TDD/GDD
    [ ] Синхронізувати всі документи

================================================================================
14) ПРІОРИТЕТИ ВПРОВАДЖЕННЯ
================================================================================

ВИСОКИЙ пріоритет (критичні проблеми):
    1. RemoteEvents Registry - запобігає дублюванням
    2. Player Data Flow - виправляє проблеми з завантаженням
    3. Graceful Degradation - стабільність гри

СЕРЕДНІЙ пріоритет (покращення якості):
    4. Config Validation - раннє виявлення помилок
    5. Location FSM - чіткий lifecycle
    6. Teleportation FSM - надійність телепортації
    7. ServerStorage Restructure - краща організація
    8. Object Type Validation - перевірка типів об'єктів
    9. Script Placement Architecture - правильне розміщення скриптів

НИЗЬКИЙ пріоритет (технічний борг):
    10. Schema Migrations - підготовка до змін
    11. New Managers - краща модульність
    12. Documentation sync - відповідність коду
    13. Test scripts config - продакшен безпека

================================================================================
15) КРИТЕРІЇ УСПІХУ
================================================================================

Технічні:
    - Жодних дублікатів RemoteEvents
    - Гравець завжди спавниться (навіть при помилках)
    - Переходи локацій без crash
    - Дані гравця не втрачаються
    - Всі об'єкти мають правильні типи
    - Валідація структури перед завантаженням

Якість коду:
    - Чіткий розподіл відповідальності
    - Легко додавати нові планети/локації
    - Конфігурація замість хардкоду
    - Зрозумілі стани систем (FSM)
    - ObjectTypeValidator перевіряє всі структури
    - EnvironmentLoader з інтегрованою валідацією
    - Правильне розміщення скриптів (Server/Client)

Документація:
    - TDD/GDD відповідає коду
    - Всі модулі задокументовані
    - Changelog актуальний
    - Структура ServerStorage з типізацією об'єктів
    - Правила розміщення скриптів в Roblox

================================================================================
]]

local module = {}

module.VERSION = "3.5"
module.STATUS = "PLANNING"
module.LAST_UPDATED = "2026-01-07"

return module
