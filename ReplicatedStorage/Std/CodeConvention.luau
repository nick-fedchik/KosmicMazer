--[[
================================================================================
KOSMICMAZER — Code Convention
================================================================================

Purpose: Стандарти оформлення коду для проекту KosmicMazer
Version: 3.5
Status: ACTIVE
Last Updated: 2026-01-07

================================================================================
1. ЗРАЗОК ВХІДНОГО КОМЕНТАРЯ СКРИПТА
================================================================================

Кожен скрипт повинен починатись з блоку коментаря у такому форматі:

LUACOMMENT_BEGIN
================================================================================
KOSMICMAZER — [Назва системи/модуля]
================================================================================

Purpose: [Короткий опис призначення скрипта - 1-2 речення]
Version: [Номер версії у форматі X.Y]

Features:
- [Основна функціональність 1]
- [Основна функціональність 2]
- [Основна функціональність 3]

API:
- [PublicFunction1(params)]: [Опис що робить функція]
- [PublicFunction2(params)]: [Опис що робить функція]

Calls to:
- [Module/Service]: [Які функції викликаються]
- [Module/Service]: [Які функції викликаються]

Called from:
- [Module/Script]: [Які функції викликаються з цього модуля]

Events:
- [Event name]: [Опис події]
- [Event name]: [Опис події]

Dependencies:
- [Required modules/services]

ChangeLog:
- Version X.Y: [Опис змін]
- Version X.Z: [Опис змін]
- Initial implementation

================================================================================
LUACOMMENT_END

================================================================================
2. ОПИС ГЛОБАЛЬНИХ ЗМІННИХ І СТРУКТУР ДАНИХ
================================================================================

2.1 ФОРМАТ ОПИСУ ГЛОБАЛЬНИХ ЗМІННИХ:
-------------------------------------

-- Перед секцією глобальних змінних додати заголовок:

--============================================================================--
-- ГЛОБАЛЬНІ ЗМІННІ / GLOBAL VARIABLES
--============================================================================--

-- Для кожної глобальної змінної:
-- @var [ТИП] Короткий опис призначення
local VARIABLE_NAME = value

ПРИКЛАД:
--============================================================================--
-- ГЛОБАЛЬНІ ЗМІННІ / GLOBAL VARIABLES
--============================================================================--

-- @var table Кеш даних гравців {[userId]: PlayerData}
local playerDataCache = {}

-- @var boolean Чи ініціалізований модуль
local isInitialized = false

-- @var number Час останнього автозбереження
local lastAutoSave = 0


2.2 ФОРМАТ ОПИСУ КОНСТАНТ:
---------------------------

--============================================================================--
-- КОНСТАНТИ / CONSTANTS
--============================================================================--

-- @const number Інтервал автозбереження в секундах
local AUTO_SAVE_INTERVAL = 60

-- @const string Назва DataStore для даних гравців
local DATA_STORE_NAME = "PlayerData"


2.3 ФОРМАТ ОПИСУ СТРУКТУР ДАНИХ:
---------------------------------

Складні структури даних описувати з типами полів:
LUACOMMENT_BEGIN
    @struct PlayerData
    Структура даних гравця, що зберігається в DataStore
    
    @field number SchemaVersion - Версія схеми даних
    @field string CurrentPlanet - ID поточної планети
    @field string CurrentLocation - ID поточної локації
    @field table UnlockedPlanets - Список розблокованих планет {string}
    @field table VisitedLocations - Список відвіданих локацій {string}
    @field table DiscoveredLocations - Список відкритих локацій {string}
    @field table Stats - Статистика гравця
        @field number JoinDate - Час першого входу (os.time)
        @field number LastLogin - Час останнього входу
        @field number TotalPlayTime - Загальний час гри в секундах
        @field number TotalTeleports - Кількість телепортацій
        @field number LocationsDiscovered - Кількість відкритих локацій
    @field table Settings - Налаштування гравця
        @field number MusicVolume - Гучність музики (0-1)
        @field number SFXVolume - Гучність ефектів (0-1)
LUACOMMENT_END
local DEFAULT_PLAYER_DATA = {
    SchemaVersion = 2,
    CurrentPlanet = "Planet_1",
    CurrentLocation = "SpaceStation",
    -- ...
}


2.4 ФОРМАТ ОПИСУ ENUM/ПЕРЕЛІЧЕНЬ:
----------------------------------

LUACOMMENT_BEGIN

    @enum LocationState
    Стани життєвого циклу локації (FSM)
LUACOMMENT_END

local LocationState = {
    IDLE = "Idle",              -- Очікування
    CLEANING = "Cleaning",      -- Очищення Workspace
    LOADING_PLANET = "LoadingPlanet",    -- Завантаження планети
    LOADING_LOCATION = "LoadingLocation", -- Завантаження локації
    VERIFYING = "Verifying",    -- Перевірка об'єктів
    READY = "Ready",            -- Готово до гри
    ERROR = "Error",            -- Помилка (fallback)
}

================================================================================
3. ОПИС ПУБЛІЧНИХ ФУНКЦІЙ (API)
================================================================================

Публічні функції - це функції, що експортуються модулем і доступні ззовні.

3.1 ФОРМАТ ОПИСУ ПУБЛІЧНИХ ФУНКЦІЙ:
------------------------------------

--============================================================================--
-- ПУБЛІЧНІ ФУНКЦІЇ / PUBLIC API
--============================================================================--

LUACOMMENT_BEGIN
    @function LoadPlayerData
    Завантажує дані гравця з DataStore
    
    @param player Player - Об'єкт гравця Roblox
    @return table|nil - Дані гравця або nil при помилці
    @throws string - Повідомлення про помилку при невдалому завантаженні
    
    @example
        local data = DataStoreManager.LoadPlayerData(player)
        if data then
            print("Дані завантажено:", data.CurrentPlanet)
        end
LUACOMMENT_END

function module.LoadPlayerData(player: Player): table?
    -- implementation
end


3.2 ОБОВ'ЯЗКОВІ ЕЛЕМЕНТИ ОПИСУ:
--------------------------------

@function [Name]     - Назва функції
[Description]        - Короткий опис що робить функція (1-3 речення)

@param [name] [Type] - Опис параметра
    - Вказувати тип (string, number, table, Player, etc.)
    - Короткий опис призначення параметра

@return [Type]       - Тип повернення та опис
    - Вказувати можливі значення (table|nil)

@throws [condition]  - Опис можливих помилок (опціонально)

@example             - Приклад використання (опціонально, рекомендовано)


3.3 ПРИКЛАДИ ПУБЛІЧНИХ ФУНКЦІЙ:
--------------------------------

LUACOMMENT_BEGIN
    @function SwitchToLocation
    Перемикає гравця на вказану локацію планети
    
    @param player Player - Гравець для телепортації
    @param planetName string - ID планети (напр. "Planet_1")
    @param locationName string - ID локації (напр. "Location_1")
    @return boolean - true якщо успішно, false при помилці
    
    @example
        local success = LocationManager.SwitchToLocation(player, "Planet_1", "Location_1")
LUACOMMENT_END
function module.SwitchToLocation(player: Player, planetName: string, locationName: string): boolean
    -- implementation
end

LUACOMMENT_BEGIN
    @function GetState
    Повертає поточний стан системи для діагностики
    
    @return string - Поточний стан з LocationState enum
LUACOMMENT_END
function module.GetState(): string
    return currentState
end

================================================================================
4. ОПИС ЛОКАЛЬНИХ ФУНКЦІЙ
================================================================================

Локальні функції - внутрішні допоміжні функції, не експортовані модулем.

4.1 ФОРМАТ ОПИСУ ЛОКАЛЬНИХ ФУНКЦІЙ:
------------------------------------

--============================================================================--
-- ЛОКАЛЬНІ ФУНКЦІЇ / LOCAL FUNCTIONS
--============================================================================--

-- Короткий опис функції (1 рядок)
-- @param [name] [Type] - опис параметра
-- @return [Type] - опис повернення
local function functionName(param1, param2)
    -- implementation
end

АБО для складніших функцій:

LUACOMMENT_BEGIN
    Розширений опис локальної функції
    Декілька рядків якщо потрібно
    
    @param param1 string - Опис першого параметра
    @param param2 number - Опис другого параметра
    @return boolean - Результат операції
LUACOMMENT_END
local function complexFunction(param1, param2)
    -- implementation
end


4.2 ПРИКЛАДИ ЛОКАЛЬНИХ ФУНКЦІЙ:
--------------------------------

-- Очищає Workspace від об'єктів попередньої локації
-- @param excludeList table? - Список об'єктів для збереження
local function clearWorkspace(excludeList)
    -- implementation
end

-- Валідує структуру даних гравця
-- @param data table - Дані для валідації
-- @return boolean, string? - Результат та опис помилки
local function validatePlayerData(data)
    -- implementation
end

LUACOMMENT_BEGIN
    Копіює модель з ServerStorage в Workspace
    Клонує модель та її дочірні елементи
    
    @param sourcePath string - Шлях до джерела в ServerStorage
    @param targetParent Instance - Батьківський об'єкт в Workspace
    @return Model? - Клонована модель або nil при помилці
LUACOMMENT_END
local function cloneToWorkspace(sourcePath, targetParent)
    -- implementation
end


4.3 МІНІМАЛЬНИЙ ОПИС (для простих функцій):
--------------------------------------------

Для очевидних коротких функцій достатньо однорядкового коментаря:

-- Повертає true якщо гравець адміністратор
local function isAdmin(player)
    return player.UserId == ADMIN_ID
end

-- Логує повідомлення з префіксом системи
local function log(message)
    print("[LocationManager] " .. message)
end

================================================================================
5. ЗАГАЛЬНІ ПРАВИЛА
================================================================================

5.1 МОВА КОМЕНТАРІВ:
- Коментарі українською мовою (переважно)
- Технічні терміни англійською (Player, DataStore, Workspace)
- Назви функцій/змінних англійською

5.2 ТИПІЗАЦІЯ:
- Використовувати Luau type annotations де можливо
- Вказувати типи в @param та @return

5.3 ПОРЯДОК СЕКЦІЙ В СКРИПТІ:
1. Вхідний коментар (header)
2. Services (Roblox services)
3. Modules (require)
4. Константи
5. Глобальні змінні
6. Локальні функції
7. Публічні функції (API)
8. Ініціалізація
9. return module

5.4 ПРИКЛАД СТРУКТУРИ СКРИПТА:

LUACOMMENT_BEGIN
================================================================================
KOSMICMAZER — Example Module
================================================================================
Purpose: Приклад структури модуля
Version: 1.0
...
================================================================================
LUACOMMENT_END

--============================================================================--
-- SERVICES
--============================================================================--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--============================================================================--
-- MODULES
--============================================================================--
local GameConfig = require(script.Parent.GameConfig)

--============================================================================--
-- КОНСТАНТИ / CONSTANTS
--============================================================================--
local TIMEOUT = 30

--============================================================================--
-- ГЛОБАЛЬНІ ЗМІННІ / GLOBAL VARIABLES
--============================================================================--
local module = {}
local isInitialized = false

--============================================================================--
-- ЛОКАЛЬНІ ФУНКЦІЇ / LOCAL FUNCTIONS
--============================================================================--
local function helperFunction()
    -- ...
end

--============================================================================--
-- ПУБЛІЧНІ ФУНКЦІЇ / PUBLIC API
--============================================================================--
function module.Initialize()
    -- ...
end

--============================================================================--
-- ІНІЦІАЛІЗАЦІЯ / INITIALIZATION
--============================================================================--
-- Auto-init code if needed

return module

================================================================================
]]

local module = {}

module.VERSION = "3.5"
module.STATUS = "ACTIVE"
module.LAST_UPDATED = "2026-01-07"

return module
