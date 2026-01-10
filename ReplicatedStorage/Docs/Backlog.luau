--[[
================================================================================
KOSMICMAZER — BACKLOG v5.0
================================================================================
Version: 5.0
Status: Active Development
Last Updated: 2026-01-10

Цей документ містить список завдань для завершення версії 5.0 та планування
наступних версій на основі оновленої архітектури гри.

КРИТИЧНА МЕТА v5.0:
- Коректний перехід Гравця з Космічної Станції на Планетну Локацію і повернення
- Централізоване відстеження локації гравця (LocationManager як Single Source of Truth)
- Синхронізація стану локації між сервером та клієнтом
- Надійний spawn гравця з fallback механізмами

================================================================================
✅ ЗАВЕРШЕНО В v5.0
================================================================================

1. ✅ Централізоване відстеження локації гравця
   - LocationManager.SetPlayerLocation() - єдине джерело правди
   - LocationManager.GetPlayerLocation() - отримання локації
   - LocationManager.GetPlayerPlanet() - отримання планети
   - Автоматична синхронізація з Player Attributes
   - Збереження в DataStore через PlayerDataManager

2. ✅ Синхронізація локації з клієнтом
   - Додано PlayerLocationChanged RemoteEvent
   - TeleportationClient отримує оновлення в реальному часі
   - Статус бар показує поточну локацію

3. ✅ Оновлення TeleportationManager
   - Використання LocationManager.SetPlayerLocation()
   - Автоматична синхронізація з клієнтом після телепортації

4. ✅ Виправлення spawn position
   - Збільшено висоту spawn з +2 до +5 studs для надійності
   - Fallback механізм якщо LocationModel не знайдено

5. ✅ Оновлення GameInit
   - Використання LocationManager для встановлення початкової локації
   - Fallback chain для надійного spawn

6. ✅ Застарілі функції позначено як deprecated
   - getCurrentPlanet() в LocationManager
   - Рекомендовано використовувати GetPlayerPlanet(player)

================================================================================
🎯 КРИТИЧНІ ЗАВДАННЯ (ВЕРСІЯ 5.0 - COMPLETION)
================================================================================

Пріоритет: ВИСОКИЙ
Мета: Завершити централізацію та забезпечити стабільність

──────────────────────────────────────────────────────────────────────────────
1. АНАЛІЗ TODO В SERVERSTORAGE СКРИПТАХ
──────────────────────────────────────────────────────────────────────────────
Статус: 🔴 НЕ РОЗПОЧАТО
Пріоритет: ВИСОКИЙ
Час виконання: 2-3 години

Завдання:
Проаналізувати всі скрипти в ServerStorage (Space/SpaceStation, Planets) на наявність TODO/FIXME
та застарілих практик після впровадження LocationManager.

Конкретні зміни:

1.1. Пошук TODO та FIXME:
   - Grep по всіх скриптах в ServerStorage/Space
   - Grep по всіх скриптах в ServerStorage/Planets
   - Створити список знайдених TODO з контекстом
   - Класифікувати за пріоритетом

1.2. Перевірка використання застарілих API:
   - Знайти прямі виклики player:SetAttribute("CurrentLocation")
   - Знайти прямі виклики player:SetAttribute("CurrentPlanet")
   - Замінити на LocationManager.SetPlayerLocation()

1.3. Перевірка EnvironmentLoader інтеграції:
   - PlanetSurfaceScanner - чи використовує правильну конфігурацію
   - LocationController - чи коректно працює з новою структурою
   - Перевірити чи всі скрипти знають про LocationModel hierarchy

1.4. Створити звіт:
   - Список всіх знайдених TODO
   - Рекомендації щодо виправлення
   - Пріоритизація завдань

──────────────────────────────────────────────────────────────────────────────
2. ВИПРАВЛЕННЯ ПРОПАЖІ ПЛАНЕТИ З WORKSPACE
──────────────────────────────────────────────────────────────────────────────
Статус: 🔴 НЕ РОЗПОЧАТО
Пріоритет: ВИСОКИЙ
Час виконання: 2-3 години

Проблема:
Модель планети зникає з Workspace після старту гри.

Завдання:

2.1. Додати детальне логування в EnvironmentLoader:
   - Log кожного етапу завантаження Planet model
   - Log переміщення об'єктів до Workspace
   - Log валідації після завантаження
   - Додати timestamp для кожного log entry

2.2. Перевірити cleanup логіку:
   - LocationManager.cleanupWorkspace() - чи не видаляє Planet?
   - EnvironmentLoader.clearWorkspace() - перевірити чи Planet в essentialObjects
   - Перевірити чи немає конфліктів з іншими cleanup системами

2.3. Перевірити timing issues:
   - Чи Planet завантажується до того як LocationManager викликає cleanup?
   - Додати затримки якщо потрібно
   - Перевірити race conditions

2.4. Створити diagnostic tool:
   - Команда /checkplanet для перевірки наявності Planet в Workspace
   - Вивести повний шлях до всіх Planet моделей
   - Показати коли і ким була створена/видалена

──────────────────────────────────────────────────────────────────────────────
3. GRACEFUL DEGRADATION
──────────────────────────────────────────────────────────────────────────────
Статус: 🔴 НЕ РОЗПОЧАТО
Пріоритет: ВИСОКИЙ
Час виконання: 2-3 години

Завдання:
Додати fallback логіку для всіх критичних систем щоб збої в одній системі
не ламали всю гру.

Конкретні зміни:

3.1. LocationManager fallback:
   - При неможливості завантажити локацію → залишити на поточній
   - При timeout → перехід в ERROR стан з fallback
   - Детальне логування причин помилки
   - Повідомлення гравцю про проблему (UI)

3.2. DataStoreManager fallback:
   - При недоступності DataStore → session-only режим
   - Попередження гравцю що прогрес не зберігається
   - Локальне збереження session даних
   - Повторні спроби підключення в фоні

3.3. TeleportationManager fallback:
   - При помилці ініціалізації → вимкнути телепортацію
   - Візуальна індикація недоступності (червоний SpawnLocation)
   - Логування помилок для діагностики

3.4. EnvironmentLoader fallback:
   - При помилці завантаження об'єктів → skip та продовження
   - Валідація завантажених об'єктів
   - Fallback на базові об'єкти якщо критичні відсутні

3.5. Глобальний error handler:
   - Catch всіх unhandled errors
   - Логування в централізовану систему
   - Graceful shutdown при критичних помилках

Тестування:
- Симуляція відсутності SpawnLocation
- Симуляція недоступності DataStore
- Симуляція пошкоджених моделей в ServerStorage
- Перевірка recovery після помилок

──────────────────────────────────────────────────────────────────────────────
4. КОМПЛЕКСНЕ E2E ТЕСТУВАННЯ
──────────────────────────────────────────────────────────────────────────────
Статус: 🔴 НЕ РОЗПОЧАТО
Пріоритет: ВИСОКИЙ
Час виконання: 3-4 години

Завдання:
Протестувати повний цикл гри від початку до кінця.

Тестові сценарії:

4.1. Новий гравець:
   - Spawn на SpaceStation
   - Перевірка початкової локації через LocationManager
   - Сканування планети
   - Телепортація на першу локацію
   - Повернення на SpaceStation
   - Перевірка збереження прогресу

4.2. Існуючий гравець:
   - Завантаження збережених даних
   - Spawn на останній локації (або SpaceStation)
   - Перевірка доступних локацій
   - Телепортація між локаціями
   - Збереження прогресу при виході

4.3. Багатокористувацька гра:
   - Кілька гравців на різних локаціях
   - Синхронізація стану
   - Перевірка ізоляції даних гравців
   - Server performance під навантаженням

4.4. Edge cases:
   - Гравець disconnect під час телепортації
   - DataStore unavailable
   - Пошкоджена локація в ServerStorage
   - Rapid teleportation (spam)
   - Server shutdown під час гри

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
   - Опис LocationManager API

5.3. Code cleanup:
   - Видалити старі/невикористані скрипти
   - Видалити закоментований код
   - Уніфікувати стиль коду
   - Виправити всі warnings від Luau analyzer

5.4. Version tags:
   - Перевірити всі файли мають правильну версію в headers
   - Синхронізувати версії між пов'язаними модулями
   - Оновити CHANGELOG з детальним описом змін v5.0

5.5. Оновити TechnicalDesignDocument:
   - Документувати LocationManager architecture
   - Додати діаграму потоку даних для player location
   - Оновити sequence diagrams для teleportation
   - Додати приклади використання API

================================================================================
🚀 ФУНКЦІОНАЛЬНІ ЗАВДАННЯ (ВЕРСІЯ 5.1)
================================================================================

Пріоритет: СЕРЕДНІЙ
Мета: Додати ігровий контент та механіки

──────────────────────────────────────────────────────────────────────────────
6. TELEPORTATION FSM ФОРМАЛІЗАЦІЯ
──────────────────────────────────────────────────────────────────────────────
Статус: 🟡 ЧАСТКОВО (логіка є, але не формалізована FSM)
Пріоритет: СЕРЕДНІЙ
Час виконання: 2-3 години

Завдання:
TeleportationManager має логіку станів через прапорці та cooldowns,
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
7. ІГРОВА МЕХАНІКА ЛОКАЦІЙ
──────────────────────────────────────────────────────────────────────────────
Статус: 🔴 НЕ РОЗПОЧАТО
Пріоритет: СЕРЕДНІЙ
Час виконання: 5-7 днів

7.1. Resource Collection System:
   - Визначити типи ресурсів (Ore, Crystal, Artifact, Energy)
   - CollectionService tags для resource nodes
   - Spawn/respawn логіка в LocationController
   - Візуальні ефекти збору ресурсів
   - Збереження в Inventory (PlayerData)

7.2. NPC System:
   - Базовий NPC клас з AI
   - Patrol behavior
   - Interaction dialog system
   - Quest givers
   - Merchants (для майбутньої економіки)

7.3. Points of Interest:
   - Визначні місця на локаціях
   - Discovery rewards (досвід, ресурси)
   - Lore/story elements
   - Photo spots для соціального аспекту

7.4. Location-specific events:
   - Random encounters
   - Time-based events
   - Dynamic weather (опціонально)

──────────────────────────────────────────────────────────────────────────────
8. QUEST SYSTEM
──────────────────────────────────────────────────────────────────────────────
Статус: 🔴 НЕ РОЗПОЧАТО
Пріоритет: СЕРЕДНІЙ
Час виконання: 4-5 днів

8.1. Quest Architecture:
   - Quest Definition format (в Configuration файлах)
   - QuestManager для tracking активних квестів
   - Quest states: NotStarted, Active, Completed, Failed
   - Quest types: Fetch, Explore, Interact, Combat (майбутнє)

8.2. Quest Objectives:
   - Visit location
   - Collect X resources
   - Talk to NPC
   - Discover location
   - Combination objectives

8.3. Quest Rewards:
   - Experience points
   - Ресурси/предмети
   - Unlock нових локацій
   - Achievements

8.4. Quest UI:
   - Quest log (список активних)
   - Quest tracking (прогрес objectives)
   - Quest notifications (start/complete)
   - Quest journal (історія)

──────────────────────────────────────────────────────────────────────────────
9. INVENTORY SYSTEM
──────────────────────────────────────────────────────────────────────────────
Статус: 🔴 НЕ РОЗПОЧАТО
Пріоритет: СЕРЕДНІЙ
Час виконання: 3-4 дні

9.1. Inventory Data Model:
   - Додати Inventory в PlayerData schema
   - Item structure: {ItemId, Quantity, Metadata}
   - Max slots/weight system
   - Item categories (Resources, Tools, Quest Items)

9.2. Inventory Manager:
   - AddItem(player, itemId, quantity)
   - RemoveItem(player, itemId, quantity)
   - HasItem(player, itemId, quantity)
   - GetInventory(player)
   - SortInventory(sortType)

9.3. Inventory UI:
   - Grid-based або list-based layout
   - Item icons та tooltips
   - Quantity indicators
   - Sort/filter options
   - Drag-and-drop (опціонально)

9.4. Item System:
   - Item definitions (в GameConfig)
   - Item types: Consumable, Material, Quest, Tool
   - Item properties: Name, Description, Icon, Rarity
   - Use/Equip functionality

──────────────────────────────────────────────────────────────────────────────
10. PLANET-SPECIFIC RULES
──────────────────────────────────────────────────────────────────────────────
Статус: 🟡 БАЗА Є (PlanetConfig v1.0)
Пріоритет: СЕРЕДНІЙ
Час виконання: 2-3 дні

Завдання:
Розширити PlanetConfig для унікальних правил кожної планети.

10.1. Physical Properties:
   - Gravity (різна для планет)
   - Atmosphere (HasOxygen, Density, Color)
   - Temperature (впливає на stamina?)
   - Lighting (різний час доби, освітлення)

10.2. Resource Distribution:
   - Унікальні ресурси для планет
   - Rarity modifiers
   - Respawn rates
   - Seasonal availability

10.3. Economic Rules:
   - Currency values
   - Trade restrictions
   - NPC pricing модифікатори

10.4. Unlock Conditions:
   - Location unlock requirements
   - Level requirements
   - Quest prerequisites
   - Discovery mechanics

10.5. Implementation:
   - Розширити PlanetConfig.luau
   - ApplyPlanetRules() в LocationController
   - Validation в ConfigValidator
   - Documentation в TDD

──────────────────────────────────────────────────────────────────────────────
11. ВЕРСІЇ У ЛОГАХ SERVERSTORAGE СКРИПТІВ
──────────────────────────────────────────────────────────────────────────────
Статус: 🔴 НЕ РОЗПОЧАТО
Пріоритет: СЕРЕДНІЙ
Час виконання: 1-2 години

Проблема:
- Studio Script Sync НЕ синхронізує ServerStorage автоматично
- Оновлення скриптів у ServerStorage виконуються ВРУЧНУ в Roblox Studio
- Складно виявити, чи був скрипт оновлений після змін в коді
- Відсутність версій у логах ускладнює дебагінг

Рішення:
Додати номери версій до всіх лог-повідомлень від скриптів у ServerStorage.

11.1. Формат логів:
```lua
-- Замість:
print("[PlanetSurfaceScanner] 🔍 Скануємо поверхню...")

-- Використовувати:
print("[PlanetSurfaceScanner 1.8] 🔍 Скануємо поверхню...")
```

11.2. Скрипти для оновлення:
ServerStorage/Planets/{PlanetId}/Scripts/:
- SpaceStationManager.luau
- LocationController.luau (шаблон для кожної локації)
- PlanetSurfaceScanner.luau
- Інші планетні/локаційні скрипти

11.3. Імплементація:
```lua
-- В кожному скрипті:
local module = {}
module.Version = "1.8"

-- В логах використовувати:
local SCRIPT_NAME = "PlanetSurfaceScanner"
print(string.format("[%s %s] ✅ Initialized", SCRIPT_NAME, module.Version))
```

11.4. Оновлення документації:
✅ CodeConvention.luau v3.6 - додано секцію 5.3.2 "ВЕРСІЇ У ЛОГАХ SERVERSTORAGE СКРИПТІВ"

11.5. Переваги:
- Швидке виявлення застарілих скриптів у ServerStorage
- Полегшення дебагінгу (видно яка версія працює)
- Аудит після оновлень коду
- Попередження про пропущені мануальні оновлення

================================================================================
💡 ПОКРАЩЕННЯ ТА ОПТИМІЗАЦІЯ (ВЕРСІЯ 5.2+)
================================================================================

Пріоритет: НИЗЬКИЙ
Мета: Polishing та покращення UX

──────────────────────────────────────────────────────────────────────────────
12. UI/UX IMPROVEMENTS
──────────────────────────────────────────────────────────────────────────────
Статус: 🔴 НЕ РОЗПОЧАТО
Пріоритет: НИЗЬКИЙ
Час виконання: 3-5 днів

12.1. Teleportation UI redesign:
    - Більш привабливий дизайн
    - Preview локацій (зображення/3D preview)
    - Детальна інформація (resources, NPCs, quests)
    - Favorite locations
    - Recent teleports history

12.2. Scanner UI improvements:
    - 3D visualization сканування
    - Animated results reveal
    - Sound effects
    - Particle effects
    - Lore snippets про знайдені локації

12.3. HUD Elements:
    - Minimap (опціонально)
    - Current location indicator
    - Quest tracker
    - Notification system
    - Settings menu

12.4. Loading screens:
    - Tips під час завантаження
    - Progress indicators
    - Background lore
    - Artwork/screenshots

12.5. Accessibility:
    - Keybinds customization
    - UI scaling options
    - Color blind modes
    - Tutorial system для нових гравців

──────────────────────────────────────────────────────────────────────────────
13. PERFORMANCE OPTIMIZATION
──────────────────────────────────────────────────────────────────────────────
Статус: 🟡 БАЗОВА ОПТИМІЗАЦІЯ Є
Пріоритет: НИЗЬКИЙ
Час виконання: Ongoing

13.1. Memory Management:
    - Profile memory usage
    - Optimize asset loading
    - Cleanup unused assets
    - Reduce texture sizes

13.2. Network Optimization:
    - Minimize RemoteEvent calls
    - Batch updates
    - Compression для великих даних
    - Predictive client-side updates

13.3. Rendering:
    - LOD (Level of Detail) для моделей
    - Occlusion culling
    - Efficient lighting
    - Particle system optimization

13.4. Script Optimization:
    - Reduce task.wait() calls
    - Use task.spawn() wisely
    - Cache frequently used references
    - Optimize loops та searches

──────────────────────────────────────────────────────────────────────────────
14. ДОДАТКОВІ ПЛАНЕТИ ТА ЛОКАЦІЇ
──────────────────────────────────────────────────────────────────────────────
Статус: 🔴 НЕ РОЗПОЧАТО
Пріоритет: НИЗЬКИЙ
Час виконання: 2-3 тижні (per planet)

14.1. Planet_3 Design:
    - Тематика та естетика
    - 3-5 унікальних локацій
    - Унікальні ресурси
    - NPC faction
    - Quest line

14.2. Planet_4 Design:
    - Інша тематика
    - Різні environmental challenges
    - Advanced resources
    - End-game content

14.3. Content Pipeline:
    - Template для створення нових планет
    - Documentation процесу
    - Testing checklist
    - Asset guidelines

──────────────────────────────────────────────────────────────────────────────
15. MULTIPLAYER FEATURES
──────────────────────────────────────────────────────────────────────────────
Статус: 🔴 НЕ РОЗПОЧАТО
Пріоритет: НИЗЬКИЙ
Час виконання: 2-3 тижні

15.1. Player Interactions:
    - See other players в локаціях
    - Player nameplates
    - Emotes/gestures
    - Friend system integration

15.2. Cooperative Elements:
    - Group teleportation
    - Shared quest progress
    - Resource trading
    - Cooperative puzzles (майбутнє)

15.3. Social Features:
    - Party system
    - Chat channels (global/local/party)
    - Leaderboards
    - Achievements showcase

================================================================================
🔮 ДОВГОСТРОКОВІ ЦІЛІ (ВЕРСІЯ 6.0+)
================================================================================

Пріоритет: ДУЖЕ НИЗЬКИЙ
Мета: Expansion та нові можливості

16. Combat System:
    - Player combat mechanics
    - Enemy AI
    - Weapons/abilities
    - Health/damage system
    - PvE encounters

17. Skill Progression:
    - Skill trees (Exploration, Combat, Crafting)
    - Experience and leveling
    - Unlockable abilities
    - Passive bonuses

18. Procedural Generation:
    - Procedural локації
    - Random encounters
    - Dynamic events
    - Endless exploration

19. Cross-Server Features:
    - Teleport between servers
    - Global events
    - Server leaderboards
    - Persistent world state

20. Economy System:
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

Версія 5.0 (поточна):
├── Централізоване відстеження: ████████████████████░ 100% (LocationManager ✅)
├── Client sync: ████████████████████░ 100% (PlayerLocationChanged ✅)
├── Spawn fixes: ████████████████████░ 100% (Height +5, fallback ✅)
├── TODO cleanup: ░░░░░░░░░░░░░░░░░░░░ 0% (потрібен аналіз)
└── E2E Testing: ░░░░░░░░░░░░░░░░░░░░ 0%

Версія 5.1 (наступна):
├── Teleportation FSM: ░░░░░░░░░░░░░░░░░░░░ 0%
├── Game Mechanics: ░░░░░░░░░░░░░░░░░░░░ 0%
├── Quest System: ░░░░░░░░░░░░░░░░░░░░ 0%
└── Inventory: ░░░░░░░░░░░░░░░░░░░░ 0%

Загальний прогрес гри: ███████████░░░░░░░░░ 55%

================================================================================
END OF BACKLOG v5.0
================================================================================
]]
