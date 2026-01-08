--[[
================================================================================
GAME DESIGN DOCUMENT (GDD)
================================================================================
Проєкт: KosmicMazer
Жанр: Exploration / Adventure
Платформа: Roblox
Статус: Active Development
Версія: 4.0
Last Updated: 2026-01-08

==================================================
1. ВИСОКА КОНЦЕПЦІЯ
==================================================
KosmicMazer — дослідницька гра про переміщення між Космічною Станцією та
планетними локаціями. Основний фокус — відкриття локацій, сканування поверхні
планет і поступове розширення маршруту телепортації.

Ключові принципи:
- Гравець перебуває РІВНО в ОДНІЙ локації в будь-який момент
- У Workspace існує РІВНО ОДИН набір об'єктів активної локації
- Сервер-авторитетна логіка (усі переходи та збереження керуються сервером)
- Чіткий життєвий цикл локацій через FSM (завантаження/очищення/перевірка)
- Гравець взаємодіє через зрозумілі UI-цикли (сканер → телепорт → дослідження)
- Модульна архітектура з BaseLocationManager для розширюваності

==================================================
2. ОСНОВНИЙ ІГРОВИЙ ЦИКЛ
==================================================

Початковий цикл (перший візит):
1) Гравець спавниться на Космічній Станції
2) Система телепортації неактивна (сірий SpawnLocation)
3) Гравець доходить до PlanetSurfaceScanner → сканування планети
4) Відкриваються доступні локації на поверхні планети
5) Система телепортації активується (синій SpawnLocation з пульсацією)
6) Гравець заходить на SpawnLocation → відкривається Teleportation UI
7) Вибір локації → телепортація на планету


Архітектура світу (v4.0):

Space Environment (Космічна Станція):
- SpaceStation - стартова точка для всіх гравців
- Системи станції: LifeSupport, PowerGrid, Communications
- PlanetSurfaceScanner (опціональний) - для сканування планет
- SpaceStationManager (v1.0) - управління станцією
- Завжди доступна для повернення

Planet Environments (Планети):
Поточні планети:
- Planet_1 (Залізяка) - перша планета, доступна за замовчуванням

PlayerData Schema v2 (IMPLEMENTED):
{
    SchemaVersion = 2,  -- для міграцій між версіями
    PlayerId = player.UserId,
    PlayerName = player.Name,
    
    -- Поточна локація
    CurrentPlanet = "Planet_1",
    CurrentLocation = "SpaceStation",
    
    -- Прогрес
    UnlockedPlanets = {"Planet_1"},  -- відкриті планети
    DiscoveredLocations = {},  -- знайдені через сканування
    VisitedLocations = {},  -- відвідані телепортацією
    
    -- Статистика (консолідовано в v2)
    Stats = {
        JoinDate = os.time(),
        LastLogin = os.time(),
        TotalPlayTime = 0,
        LocationsDiscovered = 0,
        TotalTeleports = 0,
    },
    
    -- Налаштування (додано в v2)
    Settings = {
        MusicVolume = 1.0,
        SFXVolume = 1.0,
    }
}

Міграція даних:
- Автоматична міграція v1 → v2 через DataStoreManager.migratePlayerData()
- Використовується GameConfig.DATA_SCHEMA_VERSION = 2
- При завантаженні старих даних автоматично оновлюється структура

Характеристики гравця:

Поточні (базові):
- Position: поточна позиція в світі
- Health СИСТЕМИ
==================================================

Реалізовані UI:

1. Boot/Login Screen (GameInit v3.7):
   - Відображається під час завантаження гри
   - Progress bar з етапами ініціалізації
   - Аватар гравця
   - Назва гри та версія
   - Індикатори завантаження (0-100%)

2. PlanetSurfaceScanner UI:
   - Активується при взаємодії зі сканером
   - Анімація сканування планети
   - Результати сканування (знайдені локації)
   - Візуальні та звукові ефекти
   - Оновлення DiscoveredLocations

3. Teleportation UI (TeleportationClient v2.0):
   - Список доступних локацій для телепортації
   - Інформація про кожну локацію (назва, статус)
   - Кнопка "Космічна Станція" (завжди доступна)
   - Візуальна індикація відвіданих локацій
   - Cooldown таймер між телепортаціями
   - Автоматичне приховування при виході зі SpawnLocation

4. Station UI (StationUI):
   - Інформація про системи станції
   - Статус LifeSupport, PowerGrid, Communications
   - Доступ до сканера планет

UI/UX Принципи:
- Мінімалістичний дизайн для зрозумілості
- Чіткі візуальні індикатори стану
- Анімації для покращення відчуття взаємодії
- Автоматичне приховування UI коли не потрібно
- Responsive design для різних роздільностей
- Дотримання Roblox UI guidelines
- Level: рівень гравця
- Experience: досвід для прогресії
- CТЕХНІЧНА АРХІТЕКТУРА (v4.0)
==================================================

Реалізовані системи:

Core Systems:
- GameInit v3.7: ініціалізація гри + Config validation
- ConfigValidator v1.0: валідація GameConfig при старті
- GameConfig v3.5: централізована конфігурація (DATA_SCHEMA_VERSION=2)

Data Layer:
- DataStoreManager v2.0: персистенція + міграції (v1→v2)
- PlayerDataManager v1.0: управління станом гравців
- Schema Versioning: автоматична міграція даних

Location Management:
- LocationManager v3.0: FSM-based перемикання локацій (8 станів)
- BaseLocationManager v1.0: OOP базовий клас для managers
- SpaceStationManager v1.0: управління космічною станцією
- LocationController template v1.0: шаблон для планетних локацій
- EnvironmentLoader v1.8: завантаження середовищ + LoadOrder
- LoadOrderProcessor v1.0: обробка пріоритетів об'єктів

Communication:
- RemoteEventsRegistry v1.0: централізоване управління RemoteEvents
- TeleportationManager v4.5: повна система телепортації
- TeleportationClient v2.0: клієнтський UI телепортації

Utilities:
- ObjectTypeValidator v1.2: валідація структур ServerStorage
- SystemTest v1.1: моніторинг систем (DEBUG режим)
- LoadingMonitor v1.0: відстеження завантаження (DEBUG режим)

Архітектурні принципи:
- Server-authoritative: сервер контролює всі критичні операції
- Модульність: системи незалежні та легко розширюються
- FSM patterns: чіткі стани для складних процесів
- Graceful degradation: fallback при помилках
- Config validation: перевірка конфігурації при старті
- Event-driven: RemoteEvents для client-server комунікації

==================================================
7. ЗАЛЕЖНОСТІ З ДОКУМЕНТАМИ
==================================================
- TechnicalDesignDocument v4.0: повна технічна специфікація
- ArchitectureImproves v4.0: план архітектурних покращень
- Backlog v4.0: поточні та майбутні завдання
- Code Convention v3.5: стандарти написання коду
- Logging Convention: стандарти логування

Узгодження:
✅ Структура ServerStorage (Workspace/Lighting/Scripts/Configuration)
✅ 3-рівнева ієрархія Scripts (SpaceStation/Planet/Location)
✅ FSM для LocationManager (8 станів з timeouts)
✅ RemoteEventsRegistry для централізації комунікації
✅ BaseLocationManager OOP архітектура
✅ ConfigValidator для fail-fast валідації
✅ Data Schema v2 з міграціями

==================================================
8. ROADMAP (ВЕРСІЯ 4.0+)
==================================================

Високий пріоритет (v4.1):
- Graceful Degradation: fallback логіка для всіх критичних систем
- Player Data Flow: централізація оновлення CurrentLocation
- Teleportation FSM: формалізація станів в TeleportationManager
- Тестування: повний цикл E2E тестування

Середній пріоритет (v4.2):
- Ігрова механіка локацій: збір ресурсів, NPC взаємодії
- Quest System: система квестів та досягнень
- Inventory System: інвентар та предмети
- Planet-specific rules: унікальні правила для кожної планети

Низький пріоритет (v4.3+):
- Додаткові планети: Planet_3, Planet_4
- Multiplayer interactions: кооперативні елементи
- Economy system: валюта та торгівля
- Advanced UI: покращений дизайн інтерфейсів
- Performance optimization: оптимізація для великої кількості гравців

Довгострокові цілі (v5.0):
- Combat system: бойова система
- Skill progression: розвиток навичок
- Procedural generation: генерація контенту
- Cross-server teleportation: телепортація між серверами
- Persistent world events: події у світі

==================================================
9. ДИЗАЙН ПРИНЦИПИ ТА ФІЛОСОФІЯ
==================================================

Геймплей:
- Exploration First: дослідження як основна механіка
- Progressive Discovery: поступове відкриття контенту
- Player Agency: гравець контролює темп прогресії
- Risk vs Reward: баланс між дослідженням та безпекою

Технічні:
- Fail-Safe Design: система не ламається при помилках
- Modular Architecture: легко додавати нові локації/планети
- Performance Conscious: оптимізація з самого початку
- Player Experience: технічні рішення на користь UX

==================================================
END OF GDD v4.0
==================================================
]]