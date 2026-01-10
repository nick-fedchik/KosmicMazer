--[[
================================================================================
GAME DESIGN DOCUMENT (GDD)
================================================================================
Проєкт: KosmicMazer
Жанр: Exploration / Adventure
Платформа: Roblox
Статус: Active Development
Версія: 4.2
Last Updated: 2026-01-10

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
2) SpawnLocation ПОВНІСТЮ ПРИХОВАНИЙ (Transparency=1, CanCollide=false, світло вимкнене)
3) Гравець доходить до PlanetSurfaceScanner → сканування планети
4) Відкриваються доступні локації на поверхні планети
5) Система телепортації активується (синій SpawnLocation з пульсацією стає видимим)
6) Гравець заходить на SpawnLocation → відкривається Teleportation UI
7) Вибір локації → телепортація на планету

==================================================
2.1. PLANET SURFACE SCANNER - ДЕТАЛЬНА СПЕЦИФІКАЦІЯ
==================================================

Призначення:
- Сканування поверхні планети для відкриття доступних локацій
- Єдиний спосіб активувати систему телепортації при першому запуску
- Інтерактивний елемент для прогресії гри

Розташування:
- LocationModel/Equipment/PlanetSurfaceScanner в SpaceStation
- Модель складається з: ScannerBaseplate, ScannerDisplay, ScannerScreen (опціонально)

Механіка активації:
1. ДЕТЕКЦІЯ ГРАВЦЯ:
   - Моніторинг відстані від гравця до ScannerBaseplate
   - INTERACTION_DISTANCE = 10 studs (налаштовується в GameConfig)
   - Перевірка кожні 0.3 секунди через monitorPlayers()
   - Логіка: (HumanoidRootPart.Position - ScannerBaseplate.Position).Magnitude <= INTERACTION_DISTANCE

2. ПОЧАТОК СКАНУВАННЯ:
   - Автоматично стартує коли гравець заходить у зону сканера
   - Лог: "[PlanetSurfaceScanner] 👤 {PlayerName} entered scanner baseplate"
   - Викликається startScanEffect(player)
   - Тривалість: SCAN_DURATION = 2 секунди (налаштовується в GameConfig)

3. ВІЗУАЛЬНІ ЕФЕКТИ (якщо є ScannerScreen):
   - Particles: сканувальні частки на ScannerScreen
   - Rings: пульсуючі кільця навколо екрану
   - Sound: ScanningSound з PlanetSurfaceScanner моделі
   - Color changes: зміна кольору дисплею під час сканування

4. РЕЗУЛЬТАТ СКАНУВАННЯ:
   - Читання даних з GameConfig.Planets[CurrentPlanet]
   - Перевірка DiscoveredLocations з PlayerData
   - Фільтрація локацій де IsDiscovered = true
   - Відправка результатів через RemoteEvent "PlanetSurfaceScanner_Results"

5. АКТИВАЦІЯ ТЕЛЕПОРТАЦІЇ:
   Умови для активації (ВСІ мають виконатись):
   a) Гравець завершив сканування (playerHasUsedScanner[UserId] = true)
   b) Знайдено хоча б 1 доступна локація (#DiscoveredLocations > 0)
   c) TeleportationManager ще не ініціалізований
   
   Послідовність активації:
   - initializeTeleportationSystem() викликається ОДИН РАЗ
   - TeleportationManager.Initialize() встановлює неактивний стан (прихований SpawnLocation)
   - TeleportationManager.Activate(player, true) робить SpawnLocation ВИДИМИМ
   - SpawnLocation стає: синій (Color3.new(0, 0.498, 1)), Transparency=0, пульсуюче світло
   - FireAllClients("TeleportationActivated", true) для оновлення UI

6. СТАН ДО СКАНУВАННЯ:
   - SpawnLocation: Transparency=1 (ПОВНІСТЮ НЕВИДИМИЙ)
   - SpawnLocation: CanCollide=false (БЕЗ КОЛІЗІЇ)
   - PointLight: Enabled=false (СВІТЛО ВИМКНЕНЕ)
   - Touched/TouchEnded: події НЕ активні
   - Лог: "[Location] 🔒 SpawnLocation приховано до першого сканування планети"

7. СТАН ПІСЛЯ СКАНУВАННЯ:
   - SpawnLocation: Transparency=0, Color=синій, пульсація
   - SpawnLocation: CanCollide=true (можна зайти)
   - PointLight: Enabled=true, Brightness=1.5-3 (пульсація)
   - Touched/TouchEnded: події АКТИВНІ для показу UI
   - Лог: "[Teleport] 🟢 Телепортація АКТИВНА"

8. ПОВТОРНІ СКАНУВАННЯ:
   - Гравець може сканувати повторно для оновлення списку локацій
   - Нові локації (додані через GameConfig) автоматично з'являться
   - Телепортація залишається активною (не деактивується)
   - SpawnLocation залишається видимим назавжди після першої активації

Технічна реалізація:
- Файл: ServerStorage/Space/SpaceStation/Scripts/Server/PlanetSurfaceScanner.luau v4.4
- Залежності: GameConfig, DataStoreManager, TeleportationManager, RemoteEventsRegistry
- LoadOrder: Завантажується через EnvironmentLoader з LoadOrder конфігурацією
- ModuleScript pattern: Initialize(modelReference) викликається EnvironmentLoader'ом


Архітектура світу (v4.0):

Space Environment (Космічна Станція):
- SpaceStation - стартова точка для всіх гравців
- Системи станції: LifeSupport, PowerGrid, Communications
- PlanetSurfaceScanner - сканування планет для активації телепортації
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
10. CHANGELOG GDD
==================================================
v4.1 (2026-01-08):
- Додано секцію 2.1: PLANET SURFACE SCANNER - детальна специфікація
- Описано повну механіку детекції гравця (INTERACTION_DISTANCE, monitorPlayers)
- Документовано 8 етапів роботи сканера: від детекції до активації телепортації
- Прописано умови активації телепортації (3 критерії)
- Описано стани SpawnLocation ДО та ПІСЛЯ сканування (Transparency, CanCollide, PointLight)
- Уточнено що SpawnLocation ПОВНІСТЮ ПРИХОВАНИЙ до першого сканування
- Додано технічні деталі: файли, версії, залежності
- Оновлено опис Space Environment (PlanetSurfaceScanner тепер обов'язковий, не опціональний)

v4.0 (2026-01-08):
- Оновлено архітектуру до LocationModel hierarchy
- Додано FSM для LocationManager
- Оновлено PlayerData Schema v2 з міграціями

==================================================
END OF GDD v4.1
==================================================
]]