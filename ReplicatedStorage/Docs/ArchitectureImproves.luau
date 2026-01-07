--[[
================================================================================
KOSMICMAZER — Architecture Improvements & Refactoring Plan
================================================================================

Purpose: Узгоджена архітектура, рефакторинг структури та план міграції
Version: 3.0
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
- SimpleTeleportation перемістити до Helpers/ з Disabled = true
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
├── ObjectTypeValidator.luau   -- NEW: Валідатор типів об'єктів
│   -- Перевірка структури ServerStorage
│   -- Валідація конфігурації
│
└── LocationManagers/          -- NEW: Менеджери конкретних локацій
    ├── BaseLocationManager.luau  -- Базовий клас для локацій
    ├── Location_1_Manager.luau   -- Location 1 специфічна логіка
    ├── Location_2_Manager.luau   -- Location 2 специфічна логіка
    └── ...

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
├── ObjectTypeValidator.luau   -- ModuleScript: Валідатор типів об'єктів
└── LocationManagers/          -- Folder: Менеджери конкретних локацій
    ├── BaseLocationManager.luau -- ModuleScript: Базовий клас для локацій
    ├── Location_1_Manager.luau -- ModuleScript: Location 1 логіка
    └── Location_2_Manager.luau -- ModuleScript: Location 2 логіка

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

ЗВІДКИ                                          КУДИ                           КОЛИ
==================================================================================================
ServerStorage/.../Scripts/Server/*.luau    →    require() з ServerScriptService  При завантаженні локації
ServerStorage/.../Scripts/Server/*.server.luau → Workspace/CurrentLocation/      При завантаженні локації
ServerStorage/.../Scripts/Client/*.client.luau → StarterPlayerScripts/Location/  При завантаженні локації
                                                 + player.PlayerScripts для      Для кожного активного
                                                   кожного активного гравця      гравця

ПРИКЛАД ПОТОКУ:

1. Гравець телепортується на Location_1:
   
   ЗВІДКИ: ServerStorage/Planets/Planet_1/Locations/Location_1/Scripts/
   
   Server/LocationController.luau
       → ServerScriptService require() АБО clone в Workspace/Location_1/
   
   Server/ResourceController.server.luau
       → Clone в Workspace/Location_1/Scripts/ (виконається автоматично)
   
   Client/LocationUI.client.luau
       → Clone в StarterPlayerScripts/Location_1/
       → Clone в player.PlayerScripts/Location_1/ (для активного гравця)

2. При виході з локації:
   - Видалити Workspace/Location_1/
   - Видалити StarterPlayerScripts/Location_1/
   - Видалити player.PlayerScripts/Location_1/

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

PHASE 2: Створення менеджерів (2-3 дні)
    [ ] Створити BaseLocationManager з базовим функціоналом
    [ ] Створити GameWorldManager як головний координатор
    [ ] Створити SpaceStationManager та PlanetManager
    [ ] Створити менеджери конкретних локацій
    [ ] Створити RemoteEventsRegistry

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

module.VERSION = "3.0"
module.STATUS = "PLANNING"
module.LAST_UPDATED = "2026-01-07"

return module
