--[[
================================================================================
KOSMICMAZER — BACKLOG v5.1
================================================================================
Version: 5.1
Status: Active Development
Last Updated: 2026-01-10

Цей документ містить список завдань для завершення версії 5.0 та планування
наступних версій на основі оновленої архітектури гри.

ДОДАНО ЗАВДАННЯ З REFACTORINGPLAN (2026-01-08):
- Unified structure for game locations з RefactoringPlan.luau
- Hierarchical Model Structure implementation
- Client Script Initializer Framework
- Extended LoadOrder System v3.0


OPEN ISSUES
Нема єдиного джерела правди для CurrentLocation гравця
(TeleportationManager та LocationManager оновлюють його окремо).

Нема єдиного джерела яка планета і локація є поточною для Гравця
Клієнтський UI (TeleportationClient) не має прямого доступу до CurrentPlanet/Location.

Гравець не спавниться на планеті - минає SpawnLocation, можливо проблеми з геометрією і координатами

Треба почистити Backlog після завершення завдань v4.0 та v5.0



================================================================================
📊 ПОТОЧНИЙ СТАН АРХІТЕКТУРИ v5.0
================================================================================

✅ РЕАЛІЗОВАНО:

Core Systems:
✅ GameInit v3.7: ініціалізація + Config validation
✅ ConfigValidator v1.0: повна валідація GameConfig
✅ GameConfig v3.5: DATA_SCHEMA_VERSION=2, DEBUG_MODE
✅ RemoteEventsRegistry v1.0: централізовані RemoteEvents

Data Layer:
✅ DataStoreManager v2.0: Schema versioning + міграції v1→v2
✅ PlayerDataManager v1.0: управління станом гравців
✅ Player Data Schema v2: SchemaVersion, Stats consolidation, Settings

Location Management:
✅ LocationManager v3.0: FSM з 8 станами (IDLE→VALIDATING→CLEANING→
   LOADING_PLANET→LOADING_LOCATION→VERIFYING→READY→ERROR)
✅ BaseLocationManager v1.0: OOP базовий клас (lifecycle, player tracking, events)
✅ SpaceStationManager v1.0: управління космічною станцією
✅ LocationController template v1.0: шаблон для планетних локацій
✅ EnvironmentLoader v1.8: LoadOrder-based завантаження
✅ LoadOrderProcessor v1.0: обробка пріоритетів об'єктів

Systems:
✅ TeleportationManager v4.5: повна система телепортації
✅ TeleportationClient v2.0: клієнтський UI
✅ ObjectTypeValidator v1.2: валідація структур

Utilities:
✅ SystemTest v1.1: моніторинг (DEBUG)
✅ LoadingMonitor v1.0: відстеження завантаження (DEBUG)
✅ DataStoreCleaner v1.1: утиліта очищення (DEBUG)

Structure:
✅ ServerStorage структура: Workspace/Lighting/Scripts/Configuration
✅ 3-рівнева Scripts ієрархія: SpaceStation/Planet/Location
✅ LoadOrder конфігурація для контролю завантаження

Documentation:
✅ TechnicalDesignDocument v4.0
✅ GameDesignDocument v4.0
✅ ArchitectureImproves v4.0
✅ Config Validation документація (3 файли)

================================================================================
🎯 КРИТИЧНІ ЗАВДАННЯ (ВЕРСІЯ 4.1)
================================================================================

Пріоритет: ВИСОКИЙ
Мета: Завершити архітектурні покращення та забезпечити стабільність

──────────────────────────────────────────────────────────────────────────────
1. GRACEFUL DEGRADATION
──────────────────────────────────────────────────────────────────────────────
Статус: 🔴 НЕ РОЗПОЧАТО
Пріоритет: ВИСОКИЙ
Час виконання: 2-3 години

Завдання:
Додати fallback логіку для всіх критичних систем щоб збої в одній системі
не ламали всю гру.

Конкретні зміни:

1.1. LocationManager fallback:
   - При неможливості завантажити локацію → залишити на поточній
   - При timeout → перехід в ERROR стан з fallback
   - Детальне логування причин помилки
   - Повідомлення гравцю про проблему (UI)
   
1.2. DataStoreManager fallback:
   - При недоступності DataStore → session-only режим
   - Попередження гравцю що прогрес не зберігається
   - Локальне збереження session даних
   - Повторні спроби підключення в фоні
   
1.3. TeleportationManager fallback:
   - При помилці ініціалізації → вимкнути телепортацію
   - Візуальна індикація недоступності (червоний SpawnLocation)
   - Альтернативні способи переміщення (якщо є)
   - Логування помилок для діагностики
   
1.4. EnvironmentLoader fallback:
   - При помилці завантаження об'єктів → skip та продовження
   - Валідація завантажених об'єктів
   - Fallback на базові об'єкти якщо критичні відсутні
   
1.5. Глобальний error handler:
   - Catch всіх unhandled errors
   - Логування в централізовану систему
   - Graceful shutdown при критичних помилках

Тестування:
- Симуляція відсутності SpawnLocation
- Симуляція недоступності DataStore
- Симуляція пошкоджених моделей в ServerStorage
- Перевірка recovery після помилок

──────────────────────────────────────────────────────────────────────────────
2. PLAYER DATA FLOW ЦЕНТРАЛІЗАЦІЯ
──────────────────────────────────────────────────────────────────────────────
Статус: 🟡 ЧАСТКОВО (CurrentLocation оновлюється в різних місцях)
Пріоритет: ВИСОКИЙ
Час виконання: 1-2 години

Проблема:
CurrentLocation оновлюється і в LocationManager, і потенційно в інших місцях,
що може призвести до неузгодженості даних.

Рішення:

2.1. Централізувати оновлення CurrentLocation:
   - ТІЛЬКИ TeleportationManager оновлює CurrentLocation
   - LocationManager повідомляє про успішне завантаження через event
   - TeleportationManager слухає LocationReady event та оновлює дані
   
2.2. Додати PlayerDataReady event:
   - Реалізувати в RemoteEventsRegistry (вже є в списку)
   - GameInit викликає після завантаження даних
   - TeleportationManager слухає та ініціалізується
   - Інші системи можуть підписатися на готовність даних
   
2.3. Гарантований spawn гравця:
   - GameInit НІКОЛИ не виходить без spawn
   - При помилці DataStore → створити default профіль
   - При помилці location loading → spawn на SpaceStation
   - Fallback chain: requested location → SpaceStation → hardcoded spawn
   
2.4. Lifecycle events:
   - PlayerDataLoaded: дані завантажено з DataStore
   - PlayerDataReady: дані валідовані та готові до використання
   - LocationChanged: гравець змінив локацію
   - PlayerDataSaved: дані збережено в DataStore

Implementation:
```lua
-- В TeleportationManager додати:
function TeleportationManager.Initialize()
    local playerDataReady = RemoteEventsRegistry.Get("PlayerDataReady")
    playerDataReady.Event:Connect(function(player)
        -- Ініціалізація телепортації для гравця
    end)
end

-- В GameInit після LoadPlayerData:
local playerDataReady = RemoteEventsRegistry.Get("PlayerDataReady")
playerDataReady:FireClient(player, playerProfile)
```

──────────────────────────────────────────────────────────────────────────────
3. TELEPORTATION FSM ФОРМАЛІЗАЦІЯ
──────────────────────────────────────────────────────────────────────────────
Статус: 🟡 ЧАСТКОВО (логіка є, але не формалізована FSM)
Пріоритет: СЕРЕДНІЙ
Час виконання: 2-3 години

Завдання:
TeleportationManager v4.5 має логіку станів через прапорці та cooldowns,
але потрібна явна FSM як в LocationManager.

FSM Стани:
```lua
TeleportState = {
    INACTIVE = "Inactive",      -- Телепортація недоступна (до сканування)
    ACTIVE = "Active",          -- Доступна, очікує взаємодії
    COOLDOWN = "Cooldown",      -- Cooldown між телепортаціями
    TELEPORTING = "Teleporting", -- Процес телепортації
    ERROR = "Error"             -- Помилка телепортації
}
```

State Transitions:
- INACTIVE → ACTIVE (після сканування планети)
- ACTIVE → TELEPORTING (гравець вибрав локацію)
- TELEPORTING → COOLDOWN (телепортація завершена)
- COOLDOWN → ACTIVE (cooldown закінчився)
- Any → ERROR (помилка в процесі)
- ERROR → ACTIVE (recovery після помилки)

Реалізація:

3.1. Додати FSM структуру:
```lua
local FSM = {
    currentState = TeleportState.INACTIVE,
    stateStartTime = 0,
    stateTimeouts = {
        [TeleportState.TELEPORTING] = 30,  -- 30s max
        [TeleportState.COOLDOWN] = 3,      -- 3s cooldown
    }
}
```

3.2. Додати state management:
```lua
local function setState(newState, reason)
    local oldState = FSM.currentState
    FSM.currentState = newState
    FSM.stateStartTime = tick()
    
    print(string.format("[TeleportFSM] %s → %s (%s)", 
        oldState, newState, reason or ""))
    
    -- State-specific actions
    if newState == TeleportState.ACTIVE then
        updateSpawnLocationVisuals("active")
    elseif newState == TeleportState.INACTIVE then
        updateSpawnLocationVisuals("inactive")
    end
end
```

3.3. Connection management:
```lua
local connections = {}

local function connectToSpawn(spawn)
    -- Disconnect старі підключення
    for _, conn in ipairs(connections) do
        conn:Disconnect()
    end
    connections = {}
    
    -- Нові підключення
    table.insert(connections, spawn.Touched:Connect(onTouched))
    table.insert(connections, spawn.TouchEnded:Connect(onTouchEnded))
end
```

3.4. Timeout перевірка:
```lua
local function checkStateTimeout()
    local currentTime = tick()
    local elapsed = currentTime - FSM.stateStartTime
    local timeout = FSM.stateTimeouts[FSM.currentState]
    
    if timeout and elapsed > timeout then
        warn("[TeleportFSM] State timeout: " .. FSM.currentState)
        setState(TeleportState.ERROR, "timeout")
    end
end
```

──────────────────────────────────────────────────────────────────────────────
4. КОМПЛЕКСНЕ E2E ТЕСТУВАННЯ
──────────────────────────────────────────────────────────────────────────────
Статус: 🔴 НЕ РОЗПОЧАТО
Пріоритет: ВИСОКИЙ
Час виконання: 3-4 години

Завдання:
Протестувати повний цикл гри від початку до кінця.

Тестові сценарії:

4.1. Новий гравець (happy path):
   ✓ Вхід в гру
   ✓ Створення default профілю
   ✓ Spawn на SpaceStation
   ✓ Використання PlanetSurfaceScanner
   ✓ Активація телепортації
   ✓ Телепортація на Planet_1/Location_1
   ✓ Дослідження локації
   ✓ Повернення на SpaceStation
   ✓ Телепортація на іншу локацію
   ✓ Вихід з гри та збереження даних

4.2. Існуючий гравець:
   ✓ Вхід в гру з існуючими даними
   ✓ Валідація завантаження даних
   ✓ Spawn на збереженій локації
   ✓ Перевірка DiscoveredLocations
   ✓ Телепортація між локаціями
   ✓ Оновлення статистики

4.3. Error scenarios:
   ✓ Відсутній SpawnLocation (повинен fallback)
   ✓ Недоступний DataStore (session-only режим)
   ✓ Пошкоджена локація в ServerStorage
   ✓ Timeout при завантаженні
   ✓ Network disconnect під час телепортації

4.4. Multiple players:
   ✓ Одночасний вхід 2-3 гравців
   ✓ Телепортація в різні локації
   ✓ Повернення на SpaceStation
   ✓ Перевірка ізоляції даних між гравцями

4.5. Performance:
   ✓ Час завантаження локацій (< 5s)
   ✓ Memory usage (в межах норми)
   ✓ Відсутність memory leaks
   ✓ Proper cleanup після disconnect

Інструменти:
- SystemTest.server.luau для моніторингу
- LoadingMonitor.server.luau для performance
- Manual testing в Roblox Studio
- Test Server з кількома гравцями

────────────────────────────────────────────────────────────────────────────── 
5. ДОКУМЕНТАЦІЯ ТА CODE CLEANUP
──────────────────────────────────────────────────────────────────────────────
Статус: 🟡 ЧАСТКОВО
Пріоритет: СЕРЕДНІЙ
Час виконання: 2-3 години

5.1. Оновлення коментарів в коді:
   - Всі публічні API мають JSDoc-style коментарі
   - Складна логіка пояснена
   - TODO/FIXME видалені або з планом виправлення
   
5.2. README файли:
   - README.md для проєкту (загальний опис)
   - Інструкції по встановленню/налаштуванню
   - Гайд для нових розробників
   
5.3. Code cleanup:
   - Видалити старі/невикористані скрипти
   - Видалити закоментований код
   - Уніфікувати стиль коду
   - Виправити всі warnings від Luau analyzer

5.4. Version tags:
   - Перевірити всі файли мають правильну версію в headers
   - Синхронізувати версії між пов'язаними модулями
   - Оновити CHANGELOG з детальним описом змін v4.0

================================================================================
🚀 ФУНКЦІОНАЛЬНІ ЗАВДАННЯ (ВЕРСІЯ 4.2)
================================================================================

Пріоритет: СЕРЕДНІЙ
Мета: Додати ігровий контент та механіки

──────────────────────────────────────────────────────────────────────────────
6. ІГРОВА МЕХАНІКА ЛОКАЦІЙ
──────────────────────────────────────────────────────────────────────────────
Статус: 🔴 НЕ РОЗПОЧАТО
Пріоритет: СЕРЕДНІЙ
Час виконання: 5-7 днів

6.1. Resource Collection System:
   - Визначити типи ресурсів (Ore, Crystal, Artifact, Energy)
   - CollectionService tags для resource nodes
   - Spawn/respawn логіка в LocationController
   - Візуальні ефекти збору ресурсів
   - Збереження в Inventory (PlayerData)
   
6.2. NPC System:
   - Базовий NPC клас з AI
   - Patrol behavior
   - Interaction dialog system
   - Quest givers
   - Merchants (для майбутньої економіки)
   
6.3. Points of Interest:
   - Визначні місця на локаціях
   - Discovery rewards (досвід, ресурси)
   - Lore/story elements
   - Photo spots для соціального аспекту
   
6.4. Location-specific events:
   - Random encounters
   - Time-based events (день/ніч якщо є)
   - Seasonal events (майбутнє)
   - Dynamic weather (опціонально)

──────────────────────────────────────────────────────────────────────────────
7. QUEST SYSTEM
──────────────────────────────────────────────────────────────────────────────
Статус: 🔴 НЕ РОЗПОЧАТО
Пріоритет: СЕРЕДНІЙ
Час виконання: 4-5 днів

7.1. Quest Architecture:
   - Quest Definition format (в Configuration файлах)
   - QuestManager для tracking активних квестів
   - Quest states: NotStarted, Active, Completed, Failed
   - Quest types: Fetch, Explore, Interact, Combat (майбутнє)
   
7.2. Quest Objectives:
   - Visit location
   - Collect X resources
   - Talk to NPC
   - Discover location
   - Combination objectives
   
7.3. Quest Rewards:
   - Experience points
   - Ресурси/предмети
   - Unlock нових локацій
   - Achievements
   
7.4. Quest UI:
   - Quest log (список активних)
   - Quest tracking (прогрес objectives)
   - Quest notifications (start/complete)
   - Quest journal (історія)

──────────────────────────────────────────────────────────────────────────────
8. INVENTORY SYSTEM
──────────────────────────────────────────────────────────────────────────────
Статус: 🔴 НЕ РОЗПОЧАТО
Пріоритет: СЕРЕДНІЙ
Час виконання: 3-4 дні

8.1. Inventory Data Model:
   - Додати Inventory в PlayerData schema v3
   - Item structure: {ItemId, Quantity, Metadata}
   - Max slots/weight system
   - Item categories (Resources, Tools, Quest Items)
   
8.2. Inventory Manager:
   - AddItem(player, itemId, quantity)
   - RemoveItem(player, itemId, quantity)
   - HasItem(player, itemId, quantity)
   - GetInventory(player)
   - SortInventory(sortType)
   
8.3. Inventory UI:
   - Grid-based або list-based layout
   - Item icons та tooltips
   - Quantity indicators
   - Sort/filter options
   - Drag-and-drop (опціонально)
   
8.4. Item System:
   - Item definitions (в GameConfig)
   - Item types: Consumable, Material, Quest, Tool
   - Item properties: Name, Description, Icon, Rarity
   - Use/Equip functionality

──────────────────────────────────────────────────────────────────────────────
9. PLANET-SPECIFIC RULES
──────────────────────────────────────────────────────────────────────────────
Статус: 🟡 БАЗА Є (PlanetConfig v1.0)
Пріоритет: СЕРЕДНІЙ
Час виконання: 2-3 дні

Завдання:
Розширити PlanetConfig для унікальних правил кожної планети.

9.1. Physical Properties:
   - Gravity (різна для планет)
   - Atmosphere (HasOxygen, Density, Color)
   - Temperature (впливає на stamina?)
   - Lighting (різний час доби, освітлення)
   
9.2. Resource Distribution:
   - Унікальні ресурси для планет
   - Rarity modifiers
   - Respawn rates
   - Seasonal availability
   
9.3. Economic Rules:
   - Currency values (якщо планується економіка)
   - Trade restrictions
   - NPC pricing модифікатори
   
9.4. Unlock Conditions:
   - Location unlock requirements
   - Level requirements
   - Quest prerequisites
   - Discovery mechanics
   
9.5. Implementation:
   - Розширити PlanetConfig.luau
   - ApplyPlanetRules() в LocationController
   - Validation в ConfigValidator
   - Documentation в TDD

================================================================================
💡 ПОКРАЩЕННЯ ТА ОПТИМІЗАЦІЯ (ВЕРСІЯ 4.3+)
================================================================================

Пріоритет: НИЗЬКИЙ
Мета: Polishing та покращення UX

──────────────────────────────────────────────────────────────────────────────
10. UI/UX IMPROVEMENTS
──────────────────────────────────────────────────────────────────────────────
Статус: 🔴 НЕ РОЗПОЧАТО
Пріоритет: НИЗЬКИЙ
Час виконання: 3-5 днів

10.1. Teleportation UI redesign:
    - Більш привабливий дизайн
    - Preview локацій (зображення/3D preview)
    - Детальна інформація (resources, NPCs, quests)
    - Favorite locations
    - Recent teleports history
    
10.2. Scanner UI improvements:
    - 3D visualization сканування
    - Animated results reveal
    - Sound effects
    - Particle effects
    - Lore snippets про знайдені локації
    
10.3. HUD Elements:
    - Minimap (опціонально)
    - Current location indicator
    - Quest tracker
    - Notification system
    - Settings menu
    
10.4. Loading screens:
    - Tips під час завантаження
    - Progress indicators
    - Background lore
    - Artwork/screenshots
    
10.5. Accessibility:
    - Keybinds customization
    - UI scaling options
    - Color blind modes
    - Tutorial system для нових гравців

──────────────────────────────────────────────────────────────────────────────
11. ДОДАТКОВІ ПЛАНЕТИ ТА ЛОКАЦІЇ
──────────────────────────────────────────────────────────────────────────────
Статус: 🔴 НЕ РОЗПОЧАТО
Пріоритет: НИЗЬКИЙ
Час виконання: 2-3 тижні (per planet)

11.1. Planet_3 Design:
    - Тематика та естетика
    - 3-5 унікальних локацій
    - Унікальні ресурси
    - NPC faction
    - Quest line
    
11.2. Planet_4 Design:
    - Інша тематика
    - Різні environmental challenges
    - Advanced resources
    - End-game content
    
11.3. Content Pipeline:
    - Template для створення нових планет
    - Documentation процесу
    - Testing checklist
    - Asset guidelines

──────────────────────────────────────────────────────────────────────────────
12. PERFORMANCE OPTIMIZATION
──────────────────────────────────────────────────────────────────────────────
Статус: 🟡 БАЗОВА ОПТИМІЗАЦІЯ Є
Пріоритет: НИЗЬКИЙ
Час виконання: Ongoing

12.1. Memory Management:
    - Profile memory usage
    - Optimize asset loading
    - Cleanup unused assets
    - Reduce texture sizes
    
12.2. Network Optimization:
    - Minimize RemoteEvent calls
    - Batch updates
    - Compression для великих даних
    - Predictive client-side updates
    
12.3. Rendering:
    - LOD (Level of Detail) для моделей
    - Occlusion culling
    - Efficient lighting
    - Particle system optimization
    
12.4. Script Optimization:
    - Reduce :Wait() calls
    - Use task.spawn() wisely
    - Cache frequently used references
    - Optimize loops та searches

──────────────────────────────────────────────────────────────────────────────
13. MULTIPLAYER FEATURES
──────────────────────────────────────────────────────────────────────────────
Статус: 🔴 НЕ РОЗПОЧАТО
Пріоритет: НИЗЬКИЙ
Час виконання: 2-3 тижні

13.1. Player Interactions:
    - See other players в локаціях
    - Player nameplates
    - Emotes/gestures
    - Friend system integration
    
13.2. Cooperative Elements:
    - Group teleportation
    - Shared quest progress
    - Resource trading
    - Cooperative puzzles (майбутнє)
    
13.3. Social Features:
    - Party system
    - Chat channels (global/local/party)
    - Leaderboards
    - Achievements showcase

──────────────────────────────────────────────────────────────────────────────
14. ВЕРСІЇ У ЛОГАХ SERVERSTORAGE СКРИПТІВ
──────────────────────────────────────────────────────────────────────────────
Статус: 🔴 НЕ РОЗПОЧАТО
Пріоритет: СЕРЕДНІЙ
Час виконання: 1-2 години

Проблема:
- Argon НЕ синхронізує ServerStorage автоматично
- Оновлення скриптів у ServerStorage виконуються ВРУЧНУ в Roblox Studio
- Складно виявити, чи був скрипт оновлений після змін в коді
- Відсутність версій у логах ускладнює дебагінг

Рішення:
Додати номери версій до всіх лог-повідомлень від скриптів у ServerStorage.

14.1. Формат логів:
```lua
-- Замість:
print("[PlanetSurfaceScanner] 🔍 Скануємо поверхню...")

-- Використовувати:
print("[PlanetSurfaceScanner 1.8] 🔍 Скануємо поверхню...")
```

14.2. Скрипти для оновлення:
ServerStorage/Planets/{PlanetId}/Scripts/:
- SpaceStationManager.luau
- LocationController.luau (шаблон для кожної локації)
- PlanetSurfaceScanner.luau
- Інші планетні/локаційні скрипти

14.3. Імплементація:
```lua
-- В кожному скрипті:
local module = {}
module.Version = "1.8"

-- В логах використовувати:
local SCRIPT_NAME = "PlanetSurfaceScanner"
print(string.format("[%s %s] ✅ Initialized", SCRIPT_NAME, module.Version))
```

14.4. Оновлення документації:
✅ CodeConvention.luau v3.6 - додано секцію 5.3.2 "ВЕРСІЇ У ЛОГАХ SERVERSTORAGE СКРИПТІВ"

14.5. Переваги:
- Швидке виявлення застарілих скриптів у ServerStorage
- Полегшення дебагінгу (видно яка версія працює)
- Аудит після оновлень коду
- Попередження про пропущені мануальні оновлення

Примітка:
Це технічне завдання для підтримки розробки, не впливає на функціональність гри.

================================================================================
🔮 ДОВГОСТРОКОВІ ЦІЛІ (ВЕРСІЯ 5.0+)
================================================================================

Пріоритет: ДУЖЕ НИЗЬКИЙ
Мета: Expansion та нові можливості

15. Combat System:
    - Player combat mechanics
    - Enemy AI
    - Weapons/abilities
    - Health/damage system
    - PvE encounters

16. Skill Progression:
    - Skill trees (Exploration, Combat, Crafting)
    - Experience and leveling
    - Unlockable abilities
    - Passive bonuses

17. Procedural Generation:
    - Procedural локації
    - Random encounters
    - Dynamic events
    - Endless exploration

18. Cross-Server Features:
    - Teleport between servers
    - Global events
    - Server leaderboards
    - Persistent world state

19. Economy System:
    - Currency system
    - NPC merchants
    - Player trading
    - Market economy
    - Crafting system

================================================================================
📋 ПРАВИЛА РОБОТИ З BACKLOG
================================================================================

Для розробників:

1. Вибір завдання:
   - Працювати за пріоритетом (ВИСОКИЙ → СЕРЕДНІЙ → НИЗЬКИЙ)
   - Завершувати поточну версію перед наступною
   - Консультуватися перед великими змінами

2. Перед початком роботи:
   - Прочитати опис завдання повністю
   - Перевірити залежності від інших завдань
   - Оцінити час виконання
   - Узгодити підхід якщо потрібно

3. Під час роботи:
   - Дотримуватися Code Convention
   - Оновлювати статус завдання
   - Коммітити часто з описовими повідомленнями
   - Тестувати зміни локально

4. Після завершення:
   - Оновити Changelog в файлах
   - Оновити версію якщо потрібно
   - Провести code review
   - Запустити E2E тести
   - Оновити документацію
   - Відмітити в Backlog як ✅

5. Фіксація змін:
   - Усі зміни в скриптах фіксувати у header коментарі
   - Changelog має містити дату, версію та опис
   - Додавати теги версій в git
   - Оновлювати TechnicalDesignDocument при архітектурних змінах

Для AI асистента:

• Завжди перепитувати перед реалізацією
• Показувати план дій перед виконанням
• Дотримуватися існуючих patterns в коді
• Не видаляти без запиту існуючий функціонал
• Попереджати про breaking changes
• Фокусуватися на завданнях з ВИСОКИМ пріоритетом

================================================================================
📊 МЕТРИКИ ПРОГРЕСУ
================================================================================

Версія 4.0:
├── Архітектура: ████████████████████░ 95% (Config Validation ✅)
├── Data Layer: ████████████████████░ 100% (Migrations ✅)
├── Location System: ████████████████░ 95% (FSM ✅)
└── Core Features: ██████████░░░░░░░░ 50% (Basic teleportation works)

Версія 4.1 (в процесі):
├── Graceful Degradation: ░░░░░░░░░░░░░░░░░░░░ 0%
├── Player Data Flow: ██████░░░░░░░░░░░░░░ 30%
├── Teleportation FSM: █████░░░░░░░░░░░░░░░ 25%
├── E2E Testing: ░░░░░░░░░░░░░░░░░░░░ 0%
└── Documentation: ███████████░░░░░░░░░ 60%

================================================================================
📋 SCOPE ВЕРСІЇ 4.1 - HIERARCHICAL MODEL STRUCTURE  
================================================================================
Пріоритет: КРИТИЧНИЙ
Базується на: актуальній структурі ServerStorage з LogOutput.luau
Мета: Стандартизувати структуру моделей для вирішення проблем з координатами

🎯 **ПОТОЧНИЙ СТАН (з LogOutput):**

✅ **Space/SpaceStation/Workspace/** - є SpaceStation Model (368 parts):
   - 🏗️ SpaceStation (Model) з Architecture моделями:
     - 🏗️ 4-way, 5-way bottom, Airlock, Control tower, Room, Window
     - 🧱 SpaceStationPrimaryPart (Part) [x2] 
     - 🧱 SpawnLocation (Part) - окремо від моделі
   
✅ **Planets/Planet_1/Locations/[1-3]/Workspace/** - є структури:
   - 🧱 Baseplate (Part) з моделями всередині
   - 📁 InteractionObjects/ з ResourceNode_1, ResourceNode_2
   - 🧱 SpawnLocation (Part) - окремо від основних об'єктів

❌ **ПРОБЛЕМИ ДЛЯ ВИРІШЕННЯ:**
   - SpawnLocation існує як окремий Part, не всередині головної моделі
   - SpaceStation Model не має PrimaryPart (є SpaceStationPrimaryPart Parts)
   - Немає стандартних Attributes для LocationId, LocationType
   - Embedded моделі не організовані в логічні секції
   - При PivotTo() SpaceStation модель рухається, але SpawnLocation залишається

================================================================================
📋 ЗАВДАННЯ v4.1 - ПОКРОКОВО
================================================================================

🔧 **ЕТАП 1: RESTRUCTURE SPACESTATION MODEL**
   Статус: 📋 TODO
   Час: 2-3 години
   
   Завдання:
   ├── 1.1 Перейменувати SpaceStation Model → LocationModel
   ├── 1.2 Додати Attributes до LocationModel:
   │   ├── LocationId = "SpaceStation"
   │   ├── LocationType = "Space"  
   │   └── DisplayName = "Cosmic Research Station"
   ├── 1.3 Встановити PrimaryPart для LocationModel (один з SpaceStationPrimaryPart)
   ├── 1.4 Перенести SpawnLocation ВСЕРЕДИНУ LocationModel/Gameplay/
   ├── 1.5 Організувати embedded моделі в секції:
   │   ├── Architecture/ - 4-way, 5-way bottom, Airlock, Control tower, Room, Window
   │   ├── Equipment/ - (готово для майбутнього PlanetSurfaceScanner)
   │   ├── Environment/ - декорації та effects
   │   └── Gameplay/ - SpawnLocation, CheckPoints, SafeZones
   └── 1.6 Тестувати що PivotTo() рухає всю модель разом

🔧 **ЕТАП 2: UPDATE ENVIRONMENTLOADER FOR SPACESTATION**
   Статус: 📋 TODO  
   Час: 1-2 години
   
   Завдання:
   ├── 2.1 Оновити EnvironmentLoader.LoadSpaceEnvironment():
   │   ├── Знаходити "LocationModel" замість "SpaceStation"
   │   ├── Перевіряти LocationId attribute = "SpaceStation"
   │   └── Логувати LocationId та DisplayName при завантаженні
   ├── 2.2 Оновити LocationManager.positionSpaceStation():
   │   └── Шукати "LocationModel" для PivotTo()
   ├── 2.3 Оновити GameInit.spawnPlayerAtLocation():
   │   └── Шукати SpawnLocation в LocationModel.Gameplay
   └── 2.4 Тестувати завантаження космічної станції

🔧 **ЕТАП 3: UPDATE CLIENT SCRIPTS FOR SPACESTATION**  
   Статус: 📋 TODO
   Час: 1 година
   
   Завдання:
   ├── 3.1 Оновити ScannerUI.local.luau:
   │   ├── Шукати LocationModel замість окремих моделей
   │   ├── Перевіряти LocationId = "SpaceStation"  
   │   └── Шукати PlanetSurfaceScanner в Equipment/ секції
   ├── 3.2 Оновити StationUI.local.luau:
   │   ├── Отримувати DisplayName з LocationModel attributes
   │   └── Використовувати LocationId для логіки
   └── 3.3 Тестувати що UI працює з новою структурою

🔧 **ЕТАП 4: RESTRUCTURE PLANET LOCATIONS**
   Статус: 📋 TODO
   Час: 2-3 години  
   
   Завдання:
   ├── 4.1 Для кожної Planet_1/Location_[1-3]/Workspace/:
   │   ├── Створити LocationModel як головну модель
   │   ├── Перенести Baseplate всередину як Environment/Baseplate
   │   ├── Перенести InteractionObjects як Resources/
   │   ├── Перенести SpawnLocation як Gameplay/SpawnLocation
   │   └── Встановити PrimaryPart = Baseplate
   ├── 4.2 Додати Attributes до кожної LocationModel:
   │   ├── LocationId = "CrystalCaverns" | "IronMines" | "CopperDeposits"
   │   ├── LocationType = "Planet"
   │   ├── PlanetId = "Planet_1"  
   │   └── DisplayName = "Садочок" | "Гута" | "Канапка"
   └── 4.3 Тестувати що всі об'єкти залишаються в правильних позиціях

🔧 **ЕТАП 5: UPDATE ENVIRONMENTLOADER FOR PLANETS**
   Статус: 📋 TODO
   Час: 1-2 години
   
   Завдання:  
   ├── 5.1 Оновити EnvironmentLoader.LoadPlanetEnvironment():
   │   ├── Знаходити "LocationModel" в location/Workspace/
   │   ├── Перевіряти LocationId та PlanetId attributes  
   │   └── Логувати завантажену локацію з DisplayName
   ├── 5.2 Оновити LocationManager для планетних локацій:
   │   └── Шукати "LocationModel" для позиціонування (якщо потрібно)
   └── 5.3 Тестувати завантаження всіх планетних локацій

🔧 **ЕТАП 6: FULL INTEGRATION TESTING**
   Статус: 📋 TODO  
   Час: 2-3 години
   
   Завдання:
   ├── 6.1 Тестувати повний цикл:
   │   ├── SpaceStation завантаження та spawn
   │   ├── Телепортація SpaceStation → Planet locations  
   │   ├── Телепортація між планетними локаціями
   │   └── Телепортація назад до SpaceStation
   ├── 6.2 Перевірити що координати правильні:
   │   ├── SpawnLocation в правильних позиціях
   │   ├── PivotTo() рухає все разом
   │   └── Немає "floating" об'єктів  
   ├── 6.3 Перевірити що UI працює:
   │   ├── StationUI показує правильні назви
   │   ├── ScannerUI знаходить equipment
   │   └── TeleportationUI працює з новою структурою
   └── 6.4 Виправити знайдені проблеми

================================================================================
🎯 РЕЗУЛЬТАТ v4.1:
================================================================================
✅ Стандартна назва "LocationModel" для всіх локацій
✅ Attributes замість хардкодингу (LocationId, LocationType, DisplayName)  
✅ SpawnLocation всередині головної моделі
✅ Embedded моделі в логічних секціях
✅ PivotTo() рухає всю локацію разом
✅ Скрипти адаптовані під нову структуру
✅ Повна сумісність з існуючою архітектурою

Версія 4.2 (заплановано):
├── Resource Collection: ░░░░░░░░░░░░░░░░░░░░ 0%
├── NPC System: ░░░░░░░░░░░░░░░░░░░░ 0%
├── Quest System: ░░░░░░░░░░░░░░░░░░░░ 0%
└── Inventory System: ░░░░░░░░░░░░░░░░░░░░ 0%

Загальний прогрес гри: ████████░░░░░░░░░░░░ 40%

================================================================================
END OF BACKLOG v4.0
================================================================================
]]
