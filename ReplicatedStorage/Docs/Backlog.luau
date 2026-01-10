--[[
================================================================================
KOSMICMAZER — BACKLOG v5.0
================================================================================
Version: 5.0
Status: Active Development
Last Updated: 2026-01-10

Цей документ містить список завдань для завершення версії 5.0 та планування
наступних версій на основі оновленої архітектури гри.


КРИТИЧНА МЕТА: коректний перехід Гравця з Космічної Станції на Планетну Локацію і повернення назад
(через TeleportationManager, LocationManager, PlanetSurfaceScanner, SpawnLocation)

OPEN ISSUES
Нема єдиного джерела правди для CurrentLocation гравця 
Маємо завжди знати яка Локація і яка поточна планета - перебуваючи як на Космічній станції,
так і на будь-якій планетній локації

(TeleportationManager та LocationManager оновлюють його окремо).

Нема єдиного джерела яка планета і локація є поточною для Гравця
Клієнтський UI (TeleportationClient) не має прямого доступу до CurrentPlanet/Location.

Гравець не спавниться на планеті - минає SpawnLocation, можливо проблеми з геометрією і координатами

Треба почистити Backlog після завершення завдань v4.0 та v5.0

Знову пропала модель планети з Workspace після старту гри (потрібен детальний лог завантаження)

Встановити Studio Script Sync - done!

================================================================================
📊 ПОТОЧНИЙ СТАН АРХІТЕКТУРИ v5.0
================================================================================


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



──────────────────────────────────────────────────────────────────────────────
4. КОМПЛЕКСНЕ E2E ТЕСТУВАННЯ
──────────────────────────────────────────────────────────────────────────────
Статус: 🔴 НЕ РОЗПОЧАТО
Пріоритет: ВИСОКИЙ
Час виконання: 3-4 години

Завдання:
Протестувати повний цикл гри від початку до кінця.

Тестові сценарії:
TODO: Записати детальні сценарії для ручного та автоматизованого тестування




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
TODO: Переміряти прогрес після завершення завдань 

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

Версія 5.0:

Загальний прогрес гри: ████████░░░░░░░░░░░░ 40%

================================================================================
END OF BACKLOG v4.0
================================================================================
]]
