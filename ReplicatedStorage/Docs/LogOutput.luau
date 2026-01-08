  20:47:17.930  [DataCleaner] 🔒 DEBUG_MODE вимкнено - скрипт неактивний (продакшен)  -  Server - DataStoreCleaner:53
  20:47:17.932  
[ConfigValidator] 🔍 Starting configuration validation...  -  Server - ConfigValidator:582
  20:47:17.932  
================================================================================  -  Server - ConfigValidator:83
  20:47:17.932  CONFIG VALIDATION REPORT  -  Server - ConfigValidator:84
  20:47:17.932  ================================================================================  -  Server - ConfigValidator:85
  20:47:17.932  
⚠️  WARNINGS (1):  -  Server - ConfigValidator:97
  20:47:17.932    1. [Planet:Planet_2] No locations are marked as discovered - players won't be able to spawn here  -  Server - ConfigValidator:99
  20:47:17.932  
ℹ️  INFO (18):  -  Server - ConfigValidator:105
  20:47:17.932    1. [RequiredFields] Validating critical GameConfig fields...  -  Server - ConfigValidator:107
  20:47:17.932    2. [RequiredFields] Required fields validation completed  -  Server - ConfigValidator:107
  20:47:17.932    3. [Planets] Validating planet configurations...  -  Server - ConfigValidator:107
  20:47:17.933    4. [Planet:Planet_2] Planet has 0 locations, 0 discovered  -  Server - ConfigValidator:107
  20:47:17.933    5. [Planet:Planet_1] Planet has 0 locations, 2 discovered  -  Server - ConfigValidator:107
  20:47:17.933    6. [Planets] Validated 2 planets, 2 available  -  Server - ConfigValidator:107
  20:47:17.933    7. [SpaceStation] Validating Space Station configuration...  -  Server - ConfigValidator:107
  20:47:17.933    8. [SpaceStation] ✅ SpawnPoint 'SpawnLocation' found in LocationModel/Gameplay  -  Server - ConfigValidator:107
  20:47:17.933    9. [SpaceStation] ✅ PlanetSurfaceScanner found in LocationModel/Equipment  -  Server - ConfigValidator:107
  20:47:17.933    10. [SpaceStation] Space Station validation completed  -  Server - ConfigValidator:107
  20:47:17.933    11. [ServerStorage] Validating ServerStorage models...  -  Server - ConfigValidator:107
  20:47:17.933    12. [ServerStorage] Planet 'Planet_2', Location 'Location_1': ✅ SpawnPoint found in LocationModel/Gameplay  -  Server - ConfigValidator:107
  20:47:17.933    13. [ServerStorage] Planet 'Planet_2', Location 'Location_2': ✅ SpawnPoint found in LocationModel/Gameplay  -  Server - ConfigValidator:107
  20:47:17.933    14. [ServerStorage] Planet 'Planet_2', Location 'Location_3': ✅ SpawnPoint found in LocationModel/Gameplay  -  Server - ConfigValidator:107
  20:47:17.933    15. [ServerStorage] Planet 'Planet_1', Location 'Location_1': ✅ SpawnPoint found in LocationModel/Gameplay  -  Server - ConfigValidator:107
  20:47:17.933    16. [ServerStorage] Planet 'Planet_1', Location 'Location_2': ✅ SpawnPoint found in LocationModel/Gameplay  -  Server - ConfigValidator:107
  20:47:17.933    17. [ServerStorage] Planet 'Planet_1', Location 'Location_3': ✅ SpawnPoint found in LocationModel/Gameplay  -  Server - ConfigValidator:107
  20:47:17.933    18. [ServerStorage] ServerStorage model validation completed  -  Server - ConfigValidator:107
  20:47:17.933  
================================================================================  -  Server - ConfigValidator:111
  20:47:17.933  VALIDATION RESULT: ✅ PASSED  -  Server - ConfigValidator:112
  20:47:17.933  ================================================================================
  -  Server - ConfigValidator:113
  20:47:17.933  [GameInit] 🚀 GameInit завантажено  -  Server - GameInit:599
  20:47:18.000  [GameInit] 👤 Гравець приєднався: Sealord_75  -  Server - GameInit:445
  20:47:18.000  [GameInit] 🖼️ Створення екрану завантаження для: Sealord_75  -  Server - GameInit:102
  20:47:18.001  [GameInit] ✅ Екран завантаження створено  -  Server - GameInit:291
  20:47:18.001  [GameInit] Ініціалізація RemoteEvents...  -  Server - GameInit:456
  20:47:18.001  [RemoteEventsRegistry] 🚀 Ініціалізація RemoteEvents...  -  Server - RemoteEventsRegistry:72
  20:47:18.001  [RemoteEventsRegistry] ♻️ RemoteEvent 'TeleportationEvent' вже існує - використовую існуючий  -  Server - RemoteEventsRegistry:81
  20:47:18.001  [RemoteEventsRegistry] ♻️ RemoteEvent 'TeleportationStateEvent' вже існує - використовую існуючий  -  Server - RemoteEventsRegistry:81
  20:47:18.001  [RemoteEventsRegistry] ✅ Створено RemoteEvent: PlanetSurfaceScanner_Results  -  Server - RemoteEventsRegistry:96
  20:47:18.001  [RemoteEventsRegistry] ✅ Створено RemoteEvent: PlayerDataReady  -  Server - RemoteEventsRegistry:96
  20:47:18.001  [RemoteEventsRegistry] 🎉 Ініціалізація завершена! Events: 4, Functions: 0  -  Server - RemoteEventsRegistry:125
  20:47:18.001  [GameInit] ✅ RemoteEvents готові  -  Server - GameInit:462
  20:47:18.001  [RemoteEventsRegistry] 🔍 Валідація RemoteEvents...  -  Server - RemoteEventsRegistry:228
  20:47:18.001  [RemoteEventsRegistry] ✅ RemoteEvent 'TeleportationEvent' валідний  -  Server - RemoteEventsRegistry:244
  20:47:18.001  [RemoteEventsRegistry] ✅ RemoteEvent 'TeleportationStateEvent' валідний  -  Server - RemoteEventsRegistry:244
  20:47:18.001  [RemoteEventsRegistry] ✅ RemoteEvent 'PlanetSurfaceScanner_Results' валідний  -  Server - RemoteEventsRegistry:244
  20:47:18.001  [RemoteEventsRegistry] ✅ RemoteEvent 'PlayerDataReady' валідний  -  Server - RemoteEventsRegistry:244
  20:47:18.001  [RemoteEventsRegistry] 🎉 Валідація пройдена успішно!  -  Server - RemoteEventsRegistry:268
  20:47:18.062  [TeleportClient] Очікування RemoteEvents...  -  Client - TeleportationClient:70
  20:47:18.062  [RemoteEventsRegistry] ⏳ Очікування 'TeleportationEvent' (timeout: 30s)...  -  Client - RemoteEventsRegistry:186
  20:47:18.062  [RemoteEventsRegistry] ✅ 'TeleportationEvent' знайдено в кеші  -  Client - RemoteEventsRegistry:191
  20:47:18.062  [RemoteEventsRegistry] ⏳ Очікування 'TeleportationStateEvent' (timeout: 30s)...  -  Client - RemoteEventsRegistry:186
  20:47:18.062  [RemoteEventsRegistry] ✅ 'TeleportationStateEvent' знайдено в кеші  -  Client - RemoteEventsRegistry:191
  20:47:18.062  [TeleportClient] ✅ RemoteEvents готові  -  Client - TeleportationClient:78
  20:47:18.062  [TeleportClient] 🚀 Клієнт телепортації завантажено  -  Client - TeleportationClient:535
  20:47:18.525  [DataStore] 🚀 Ініціалізація менеджера даних...  -  Server - DataStoreManager:472
  20:47:18.525  [DataStore] ✅ Менеджер даних ініціалізовано  -  Server - DataStoreManager:477
  20:47:20.537  [GameInit] 💾 Завантаження даних гравця: Sealord_75  -  Server - GameInit:324
  20:47:20.537  [DataStore] 💾 Завантаження даних гравця: Sealord_75 (ID: 8125377914 )  -  Server - DataStoreManager:244
  20:47:20.704  [DataStore] ✅ Знайдено існуючі дані для: Sealord_75  -  Server - DataStoreManager:249
  20:47:20.704  [DataStore] ℹ️ Дата приєднання: 2026-01-04 11:16:14  -  Server - DataStoreManager:252
  20:47:20.704  [GameInit] ✅ Дані гравця завантажено: Sealord_75  -  Server - GameInit:329
  20:47:20.704  [GameInit] ℹ️ Поточна планета: Planet_1  -  Server - GameInit:330
  20:47:20.704  [GameInit] ℹ️ Тип гравця: Existing - Sealord_75  -  Server - GameInit:511
  20:47:22.721  [GameInit] ✅ LocationManager завантажено  -  Server - GameInit:541
  20:47:22.721  [LocationFSM] Idle → Idle (Ініціалізація)  -  Server - LocationManager:113
  20:47:22.721  [Location] ✅ Менеджер локацій ініціалізовано  -  Server - LocationManager:613
  20:47:23.736  [Location] 🚀 Перехід з Deep Space на SpaceStation, орбіта: Planet_1  -  Server - LocationManager:440
  20:47:23.736  [LocationFSM] Idle → Idle (Початок переходу на КС)  -  Server - LocationManager:113
  20:47:23.736  [LocationFSM] Idle → Validating (Перевірка моделей КС)  -  Server - LocationManager:113
  20:47:23.736  [LocationFSM] ✅ Перевірено модель: Space/SpaceStation  -  Server - LocationManager:146
  20:47:23.736  [Location] 🧹 Очищення Workspace...  -  Server - LocationManager:465
  20:47:23.736  [LocationFSM] Validating → Cleaning (Clearing workspace)  -  Server - LocationManager:113
  20:47:23.736  [Location] 🧹 Очищення, об'єктів: 2  -  Server - LocationManager:160
  20:47:23.736  [Location] 💡 Об'єктів освітлення: 1  -  Server - LocationManager:183
  20:47:23.736  [Location] 🗑️ Видалено освітлення: Sky  -  Server - LocationManager:212
  20:47:23.736  [Location] ✅ Очищення завершено  -  Server - LocationManager:238
  20:47:24.253  [LocationFSM] Cleaning → LoadingPlanet (Завантаження планети Planet_1)  -  Server - LocationManager:113
  20:47:24.253  [Location] 📦 Завантаження планети Planet_1  -  Server - LocationManager:482
  20:47:24.253  [Location] 🪐 Planet loading now handled by EnvironmentLoader  -  Server - LocationManager:338
  20:47:24.253  [LocationFSM] LoadingPlanet → LoadingLocation (Завантаження КС)  -  Server - LocationManager:113
  20:47:24.254  [Location] 📦 Завантаження SpaceStation...  -  Server - LocationManager:498
  20:47:24.254  [Location] 🚀 Loading Space Station using EnvironmentLoader  -  Server - LocationManager:244
  20:47:24.257  [Location] 📋 LoadOrder configuration loaded for SpaceStation  -  Server - LocationManager:262
  20:47:24.257  [EnvironmentLoader] 🚀 Loading Space Environment for planet: Planet_1  -  Server - EnvironmentLoader:209
  20:47:24.257  [ObjectTypeValidator] 🔍 Validating planet structure: Planet_1 (v1.3 - LocationModel hierarchy)  -  Server - ObjectTypeValidator:125
  20:47:24.258  [ObjectTypeValidator] ❌ Planet structure validation failed:  -  Server - ObjectTypeValidator:172
  20:47:24.258    - [MISSING ATTRIBUTE] LocationModel.LocationId not set for Planet_1/Location_1  -  Server - ObjectTypeValidator:174
  20:47:24.258    - [INVALID ATTRIBUTE] LocationModel.LocationType should be 'Planet' for Planet_1/Location_1  -  Server - ObjectTypeValidator:174
  20:47:24.258    - [INVALID ATTRIBUTE] LocationModel.PlanetId should be 'Planet_1' for Planet_1/Location_1  -  Server - ObjectTypeValidator:174
  20:47:24.258    - [MISSING ATTRIBUTE] LocationModel.LocationId not set for Planet_1/Location_2  -  Server - ObjectTypeValidator:174
  20:47:24.258    - [INVALID ATTRIBUTE] LocationModel.LocationType should be 'Planet' for Planet_1/Location_2  -  Server - ObjectTypeValidator:174
  20:47:24.258    - [INVALID ATTRIBUTE] LocationModel.PlanetId should be 'Planet_1' for Planet_1/Location_2  -  Server - ObjectTypeValidator:174
  20:47:24.259    - [MISSING ATTRIBUTE] LocationModel.LocationId not set for Planet_1/Location_3  -  Server - ObjectTypeValidator:174
  20:47:24.259    - [INVALID ATTRIBUTE] LocationModel.LocationType should be 'Planet' for Planet_1/Location_3  -  Server - ObjectTypeValidator:174
  20:47:24.259    - [INVALID ATTRIBUTE] LocationModel.PlanetId should be 'Planet_1' for Planet_1/Location_3  -  Server - ObjectTypeValidator:174
  20:47:24.259  [EnvironmentLoader] ❌ Planet structure validation failed, attempting to fix...  -  Server - EnvironmentLoader:214
  20:47:24.259  [ObjectTypeValidator] 🔧 Fixing planet structure: Planet_1  -  Server - ObjectTypeValidator:363
  20:47:24.259  [ObjectTypeValidator] 🔧 Fixing location structure: Planet_1 / Location_1  -  Server - ObjectTypeValidator:397
  20:47:24.259  [ObjectTypeValidator] ✅ Set LocationId = Location_1  -  Server - ObjectTypeValidator:438
  20:47:24.259  [ObjectTypeValidator] ✅ Set LocationType = Planet  -  Server - ObjectTypeValidator:443
  20:47:24.259  [ObjectTypeValidator] ✅ Set PlanetId = Planet_1  -  Server - ObjectTypeValidator:448
  20:47:24.260  [ObjectTypeValidator] ✅ Set DisplayName = Location_1  -  Server - ObjectTypeValidator:453
  20:47:24.260  [ObjectTypeValidator] 🔧 Fixing location structure: Planet_1 / Location_2  -  Server - ObjectTypeValidator:397
  20:47:24.260  [ObjectTypeValidator] ✅ Set LocationId = Location_2  -  Server - ObjectTypeValidator:438
  20:47:24.260  [ObjectTypeValidator] ✅ Set LocationType = Planet  -  Server - ObjectTypeValidator:443
  20:47:24.260  [ObjectTypeValidator] ✅ Set PlanetId = Planet_1  -  Server - ObjectTypeValidator:448
  20:47:24.260  [ObjectTypeValidator] ✅ Set DisplayName = Location_2  -  Server - ObjectTypeValidator:453
  20:47:24.260  [ObjectTypeValidator] 🔧 Fixing location structure: Planet_1 / Location_3  -  Server - ObjectTypeValidator:397
  20:47:24.260  [ObjectTypeValidator] ✅ Set LocationId = Location_3  -  Server - ObjectTypeValidator:438
  20:47:24.260  [ObjectTypeValidator] ✅ Set LocationType = Planet  -  Server - ObjectTypeValidator:443
  20:47:24.260  [ObjectTypeValidator] ✅ Set PlanetId = Planet_1  -  Server - ObjectTypeValidator:448
  20:47:24.260  [ObjectTypeValidator] ✅ Set DisplayName = Location_3  -  Server - ObjectTypeValidator:453
  20:47:24.260  [ObjectTypeValidator] 🔍 Validating planet structure: Planet_1 (v1.3 - LocationModel hierarchy)  -  Server - ObjectTypeValidator:125
  20:47:24.260  [ObjectTypeValidator] ✅ Planet structure validation passed  -  Server - ObjectTypeValidator:178
  20:47:24.260  [ObjectTypeValidator] 🔍 Validating Space Station structure  -  Server - ObjectTypeValidator:280
  20:47:24.260      ✅ Scripts/Server - Folder  -  Server - ObjectTypeValidator:309
  20:47:24.260      ✅ Scripts/Client - Folder  -  Server - ObjectTypeValidator:309
  20:47:24.261        ✅ Server/PlanetSurfaceScanner - ModuleScript  -  Server - ObjectTypeValidator:321
  20:47:24.261        ✅ Client/StationUI - LocalScript  -  Server - ObjectTypeValidator:335
  20:47:24.261        ✅ Client/ScannerUI - LocalScript  -  Server - ObjectTypeValidator:335
  20:47:24.261  [ObjectTypeValidator] ✅ Space Station structure validation passed  -  Server - ObjectTypeValidator:356
  20:47:24.261  [EnvironmentLoader] 🧹 Clearing workspace...  -  Server - EnvironmentLoader:112
  20:47:24.261  [EnvironmentLoader] ✅ Workspace and Lighting cleared  -  Server - EnvironmentLoader:140
  20:47:24.261  [EnvironmentLoader] 📦 [1/1] Copied: Planet (Model) to Workspace  -  Server - EnvironmentLoader:170
  20:47:24.262  [EnvironmentLoader] ✅ Planet workspace loaded  -  Server - EnvironmentLoader:255
  20:47:24.262  [EnvironmentLoader] 📦 [1/1] Copied: Sky (Sky) to Lighting  -  Server - EnvironmentLoader:170
  20:47:24.262  [EnvironmentLoader] ✅ Planet lighting loaded  -  Server - EnvironmentLoader:265
  20:47:24.262  [EnvironmentLoader] 📋 SpaceStation Workspace contains: 1 objects  -  Server - EnvironmentLoader:346
  20:47:24.262  [EnvironmentLoader] ✅ LocationModel validated: Cosmic Research Station  -  Server - EnvironmentLoader:357
  20:47:24.265  [EnvironmentLoader] ✅ LocationModel copied to Workspace  -  Server - EnvironmentLoader:363
  20:47:24.265  [EnvironmentLoader] 📋 LocationModel contains:  -  Server - EnvironmentLoader:364
  20:47:24.265  [EnvironmentLoader]   📁 Architecture (14 items)  -  Server - EnvironmentLoader:367
  20:47:24.265  [EnvironmentLoader]   📁 Equipment (1 items)  -  Server - EnvironmentLoader:367
  20:47:24.265  [EnvironmentLoader]   📁 Environment (0 items)  -  Server - EnvironmentLoader:367
  20:47:24.265  [EnvironmentLoader]   📁 Gameplay (1 items)  -  Server - EnvironmentLoader:367
  20:47:24.265  [EnvironmentLoader] 📋 Processing 1 SpaceStation Server scripts with LoadOrder  -  Server - EnvironmentLoader:406
  20:47:24.266  [EnvironmentLoader] ✅ [1/1] Required & Initialized: PlanetSurfaceScanner  -  Server - EnvironmentLoader:443
  20:47:24.267  [EnvironmentLoader] ✅ [1/2] Copied: ServerStorage.Space.SpaceStation.Scripts.Client.StationUI → StarterPlayer/StarterPlayerScripts/StationUI  -  Server - EnvironmentLoader:486
  20:47:24.267  [EnvironmentLoader] ✅ [2/2] Copied: ServerStorage.Space.SpaceStation.Scripts.Client.ScannerUI → StarterPlayer/StarterPlayerScripts/ScannerUI  -  Server - EnvironmentLoader:486
  20:47:24.267  [EnvironmentLoader] ✅ Space Station scripts processed  -  Server - EnvironmentLoader:492
  20:47:24.267  [EnvironmentLoader] 📊 Verification: 2/2 objects loaded  -  Server - EnvironmentLoader:202
  20:47:24.267  [EnvironmentLoader] ✅ Space Environment loaded successfully  -  Server - EnvironmentLoader:512
  20:47:24.267  [ClientScriptInitializer] 🚀 Initializing client scripts...  -  Server - ClientScriptInitializer:123
  20:47:24.267    └─ Location: SpaceStation, Planet: Planet_1, LocationId: N/A  -  Server - ClientScriptInitializer:129
  20:47:24.267  [ClientScriptInitializer] ℹ️ TeleportationClient - no Initialize() function  -  Server - ClientScriptInitializer:153
  20:47:24.268  [ClientScriptInitializer] ℹ️ PlayerScriptsLoader - no Initialize() function  -  Server - ClientScriptInitializer:153
  20:47:24.268  [ClientScriptInitializer] ℹ️ RbxCharacterSounds - no Initialize() function  -  Server - ClientScriptInitializer:153
  20:47:24.268  [ClientScriptInitializer] ℹ️ StationUI - no Initialize() function  -  Server - ClientScriptInitializer:153
  20:47:24.268  [ClientScriptInitializer] ℹ️ ScannerUI - no Initialize() function  -  Server - ClientScriptInitializer:153
  20:47:24.268  [ClientScriptInitializer] 🎉 Initialized 0/6 client scripts  -  Server - ClientScriptInitializer:158
  20:47:24.268  [Location] ✅ Космічну станцію завантажено  -  Server - LocationManager:328
  20:47:24.268  [LocationFSM] LoadingLocation → Verifying (Перевірка готовності КС)  -  Server - LocationManager:113
  20:47:24.268  [LocationFSM] Verifying → Ready (КС готова)  -  Server - LocationManager:113
  20:47:24.268  [Location] ✅ Перехід на SpaceStation завершено  -  Server - LocationManager:524
  20:47:26.286  [GameInit] 🔄 Підготовка появи гравця: Sealord_75  -  Server - GameInit:341
  20:47:26.819  [GameInit] ✅ Гравець з'явився на Космічній Станції  -  Server - GameInit:408
  20:47:26.819    └─ SpawnLocation: 283, -468.5, 180  -  Server - GameInit:409
  20:47:26.819    └─ Гравець (HumanoidRootPart): 283, -466.5, 180  -  Server - GameInit:410
  20:47:26.820    └─ LocationModel знайдено, але PrimaryPart не встановлено  -  Server - GameInit:417
  20:47:27.336  [GameInit] ✅ Гравця повністю завантажено: Sealord_75  -  Server - GameInit:588
  20:47:47.880  Disconnect from 127.0.0.1|64288  -  Studio
  20:47:47.882  [DataStore] 👤 Гравець виходить: Sealord_75  -  Server - DataStoreManager:458
  20:47:47.882  [DataStore] 🔄 Завершення роботи, збереження всіх даних...  -  Server - DataStoreManager:482
  20:47:47.882  [DataStore] ✅ Всі дані збережено  -  Server - DataStoreManager:500
  20:47:48.368  [DataStore] ✅ Дані збережено для: Sealord_75  -  Server - DataStoreManager:385
  20:47:48.368  [DataStore] ✅ Дані збережено при виході: Sealord_75  -  Server - DataStoreManager:464