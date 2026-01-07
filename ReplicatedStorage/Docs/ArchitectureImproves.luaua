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
9) НОВА СТРУКТУРА SERVERSTORAGE
================================================================================

Поточна структура (спрощена):
    ServerStorage/
    ├── Space/SpaceStation/
    ├── Planet_1/
    │   ├── Planet/
    │   ├── Lighting/
    │   └── Locations/Location_1/
    └── Effects/

Нова структура:
    ServerStorage/
    ├── Space/
    │   ├── SpaceStation/
    │   │   ├── Models/
    │   │   │   ├── SpawnLocation
    │   │   │   ├── PlanetScanner
    │   │   │   └── TeleportationDevice
    │   │   ├── Scripts/
    │   │   ├── Lighting/
    │   │   └── Configuration/
    │   └── Common/
    │       ├── TeleportationDevice/
    │       └── Effects/
    ├── Planets/
    │   ├── Planet_1/
    │   │   ├── PlanetModel/
    │   │   ├── Lighting/
    │   │   ├── Locations/
    │   │   │   ├── Location_1/
    │   │   │   │   ├── Models/
    │   │   │   │   │   ├── SpawnLocation
    │   │   │   │   │   └── InteractionObjects/
    │   │   │   │   ├── Scripts/
    │   │   │   │   ├── Lighting/
    │   │   │   │   └── Configuration/
    │   │   │   └── Location_2/
    │   │   ├── Scripts/
    │   │   └── Configuration/
    │   └── Planet_2/
    └── Effects/

================================================================================
10) НОВІ МЕНЕДЖЕРИ
================================================================================

ServerScriptService/
├── GameWorldManager.luau      -- NEW: Головний координатор світів
│   -- Керує завантаженням/вивантаженням світів
│   -- Координує Space і Planet менеджери
│   -- Обробляє переходи між середовищами
│
├── SpaceStationManager.luau   -- NEW: Контролер космічної станції
│   -- Керує обєктами станції
│   -- Обробляє правила станції
│   -- Реєструє/знімає реєстрацію обєктів
│
├── PlanetManager.luau         -- NEW: Контролер планети
│   -- Керує системами планети
│   -- Координує локації планети
│   -- Обробляє правила планети
│
└── LocationManagers/          -- NEW: Менеджери конкретних локацій
    ├── BaseLocationManager.luau
    ├── Location_1_Manager.luau
    └── Location_2_Manager.luau

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

Space Environment Loading:
    1. Clear Workspace
    2. Copy Planet Model + Lighting
    3. Copy SpaceStation Models/Scripts/Lighting
    4. Verify all objects loaded
    5. Spawn player at SpawnLocation

Planet Environment Loading:
    1. Clear Workspace
    2. Copy Location Models/Scripts/Lighting
    3. Verify all objects loaded
    4. Spawn player at SpawnLocation

Environment Switching:
    - GameWorldManager координує переходи
    - Кожне середовище має свою послідовність
    - Стан гравця зберігається під час переходів
    - Loading screen при потребі

================================================================================
ЧАСТИНА III: ПЛАН МІГРАЦІЇ
================================================================================

================================================================================
13) ФАЗИ ВПРОВАДЖЕННЯ
================================================================================

PHASE 1: Підготовка структури (1-2 дні)
    [ ] Створити нову структуру ServerStorage/Space та ServerStorage/Planets
    [ ] Перемістити існуючі моделі
    [ ] Створити шаблони для майбутнього контенту
    [ ] Спроектувати систему завантаження середовищ

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

НИЗЬКИЙ пріоритет (технічний борг):
    8. Schema Migrations - підготовка до змін
    9. New Managers - краща модульність
    10. Documentation sync - відповідність коду
    11. Test scripts config - продакшен безпека

================================================================================
15) КРИТЕРІЇ УСПІХУ
================================================================================

Технічні:
    - Жодних дублікатів RemoteEvents
    - Гравець завжди спавниться (навіть при помилках)
    - Переходи локацій без crash
    - Дані гравця не втрачаються

Якість коду:
    - Чіткий розподіл відповідальності
    - Легко додавати нові планети/локації
    - Конфігурація замість хардкоду
    - Зрозумілі стани систем (FSM)

Документація:
    - TDD/GDD відповідає коду
    - Всі модулі задокументовані
    - Changelog актуальний

================================================================================
]]

local module = {}

module.VERSION = "3.0"
module.STATUS = "PLANNING"
module.LAST_UPDATED = "2026-01-07"

return module
