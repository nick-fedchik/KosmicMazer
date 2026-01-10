  15:04:38.480  [DataCleaner] 🔒 DEBUG_MODE вимкнено - скрипт неактивний (продакшен)  -  Server - DataStoreCleaner:53
  15:04:38.482  
[ConfigValidator] 🔍 Starting configuration validation...  -  Server - ConfigValidator:609
  15:04:38.483  [PlanetConfigLoader] ✅ Loaded PlanetConfig for 'Planet_1' (Залізяка)  -  Server - PlanetConfigLoader:119
  15:04:38.483  
================================================================================  -  Server - ConfigValidator:90
  15:04:38.483  CONFIG VALIDATION REPORT  -  Server - ConfigValidator:91
  15:04:38.483  ================================================================================  -  Server - ConfigValidator:92
  15:04:38.483  
ℹ️  INFO (10):  -  Server - ConfigValidator:112
  15:04:38.483    1. [RequiredFields] Validating critical GameConfig fields...  -  Server - ConfigValidator:114
  15:04:38.483    2. [RequiredFields] Required fields validation completed  -  Server - ConfigValidator:114
  15:04:38.483    3. [Planets] Validating PlanetConfig from ServerStorage...  -  Server - ConfigValidator:114
  15:04:38.483    4. [Planets] ✅ PlanetConfig validated for Planet_1 (Залізяка) - 3 locations, 2 discovered  -  Server - ConfigValidator:114
  15:04:38.484    5. [SpaceStation] Validating Space Station configuration...  -  Server - ConfigValidator:114
  15:04:38.484    6. [SpaceStation] ✅ SpawnPoint 'SpawnLocation' found in LocationModel/Gameplay  -  Server - ConfigValidator:114
  15:04:38.484    7. [SpaceStation] ✅ PlanetSurfaceScanner found in LocationModel/Equipment  -  Server - ConfigValidator:114
  15:04:38.484    8. [SpaceStation] Space Station validation completed  -  Server - ConfigValidator:114
  15:04:38.484    9. [ServerStorage] Validating ServerStorage models...  -  Server - ConfigValidator:114
  15:04:38.484    10. [ServerStorage] ServerStorage model validation completed  -  Server - ConfigValidator:114
  15:04:38.484  
================================================================================  -  Server - ConfigValidator:118
  15:04:38.484  VALIDATION RESULT: ✅ PASSED  -  Server - ConfigValidator:119
  15:04:38.484  ================================================================================
  -  Server - ConfigValidator:120
  15:04:38.484  [GameInit] 🚀 GameInit завантажено  -  Server - GameInit:599
  15:04:38.550  [GameInit] 👤 Гравець приєднався: Sealord_75  -  Server - GameInit:445
  15:04:38.551  [GameInit] 🖼️ Створення екрану завантаження для: Sealord_75  -  Server - GameInit:102
  15:04:38.551  [GameInit] ✅ Екран завантаження створено  -  Server - GameInit:291
  15:04:38.552  [GameInit] Ініціалізація RemoteEvents...  -  Server - GameInit:456
  15:04:38.552  [RemoteEventsRegistry] 🚀 Ініціалізація RemoteEvents...  -  Server - RemoteEventsRegistry:72
  15:04:38.552  [RemoteEventsRegistry] ♻️ RemoteEvent 'TeleportationEvent' вже існує - використовую існуючий  -  Server - RemoteEventsRegistry:81
  15:04:38.552  [RemoteEventsRegistry] ♻️ RemoteEvent 'TeleportationStateEvent' вже існує - використовую існуючий  -  Server - RemoteEventsRegistry:81
  15:04:38.552  [RemoteEventsRegistry] ✅ Створено RemoteEvent: PlanetSurfaceScanner_Results  -  Server - RemoteEventsRegistry:96
  15:04:38.552  [RemoteEventsRegistry] ✅ Створено RemoteEvent: PlayerDataReady  -  Server - RemoteEventsRegistry:96
  15:04:38.552  [RemoteEventsRegistry] 🎉 Ініціалізація завершена! Events: 4, Functions: 0  -  Server - RemoteEventsRegistry:125
  15:04:38.552  [GameInit] ✅ RemoteEvents готові  -  Server - GameInit:462
  15:04:38.552  [RemoteEventsRegistry] 🔍 Валідація RemoteEvents...  -  Server - RemoteEventsRegistry:228
  15:04:38.552  [RemoteEventsRegistry] ✅ RemoteEvent 'TeleportationEvent' валідний  -  Server - RemoteEventsRegistry:244
  15:04:38.552  [RemoteEventsRegistry] ✅ RemoteEvent 'TeleportationStateEvent' валідний  -  Server - RemoteEventsRegistry:244
  15:04:38.553  [RemoteEventsRegistry] ✅ RemoteEvent 'PlanetSurfaceScanner_Results' валідний  -  Server - RemoteEventsRegistry:244
  15:04:38.553  [RemoteEventsRegistry] ✅ RemoteEvent 'PlayerDataReady' валідний  -  Server - RemoteEventsRegistry:244
  15:04:38.553  [RemoteEventsRegistry] 🎉 Валідація пройдена успішно!  -  Server - RemoteEventsRegistry:268
  15:04:38.607  [TeleportClient] Очікування RemoteEvents...  -  Client - TeleportationClient:70
  15:04:38.607  [RemoteEventsRegistry] ⏳ Очікування 'TeleportationEvent' (timeout: 30s)...  -  Client - RemoteEventsRegistry:186
  15:04:38.607  [RemoteEventsRegistry] ✅ 'TeleportationEvent' знайдено в кеші  -  Client - RemoteEventsRegistry:191
  15:04:38.607  [RemoteEventsRegistry] ⏳ Очікування 'TeleportationStateEvent' (timeout: 30s)...  -  Client - RemoteEventsRegistry:186
  15:04:38.607  [RemoteEventsRegistry] ✅ 'TeleportationStateEvent' знайдено в кеші  -  Client - RemoteEventsRegistry:191
  15:04:38.607  [TeleportClient] ✅ RemoteEvents готові  -  Client - TeleportationClient:78
  15:04:38.607  [TeleportClient] 🚀 Клієнт телепортації завантажено  -  Client - TeleportationClient:535
  15:04:39.095  [DataStore] 🚀 Ініціалізація менеджера даних...  -  Server - DataStoreManager:478
  15:04:39.095  [DataStore] ✅ Менеджер даних ініціалізовано  -  Server - DataStoreManager:483
  15:04:41.114  [GameInit] 💾 Завантаження даних гравця: Sealord_75  -  Server - GameInit:324
  15:04:41.114  [DataStore] 💾 Завантаження даних гравця: Sealord_75 (ID: 8125377914 )  -  Server - DataStoreManager:250
  15:04:41.396  [DataStore] ✅ Знайдено існуючі дані для: Sealord_75  -  Server - DataStoreManager:255
  15:04:41.396  [DataStore] ℹ️ Дата приєднання: 2026-01-04 11:16:14  -  Server - DataStoreManager:258
  15:04:41.396  [GameInit] ✅ Дані гравця завантажено: Sealord_75  -  Server - GameInit:329
  15:04:41.396  [GameInit] ℹ️ Поточна планета: Planet_1  -  Server - GameInit:330
  15:04:41.396  [GameInit] ℹ️ Тип гравця: Existing - Sealord_75  -  Server - GameInit:511
  15:04:43.413  [GameInit] ✅ LocationManager завантажено  -  Server - GameInit:541
  15:04:43.413  [LocationFSM] Idle → Idle (Ініціалізація)  -  Server - LocationManager:118
  15:04:43.413  [Location] ✅ Менеджер локацій ініціалізовано  -  Server - LocationManager:628
  15:04:44.429  [Location] 🚀 Перехід з Deep Space на SpaceStation, орбіта: Planet_1  -  Server - LocationManager:455
  15:04:44.429  [LocationFSM] Idle → Idle (Початок переходу на КС)  -  Server - LocationManager:118
  15:04:44.429  [LocationFSM] Idle → Validating (Перевірка моделей КС)  -  Server - LocationManager:118
  15:04:44.429  [LocationFSM] ✅ Перевірено модель: Space/SpaceStation  -  Server - LocationManager:151
  15:04:44.429  [Location] 🧹 Очищення Workspace...  -  Server - LocationManager:480
  15:04:44.429  [LocationFSM] Validating → Cleaning (Clearing workspace)  -  Server - LocationManager:118
  15:04:44.429  [Location] 🧹 Очищення, об'єктів: 2  -  Server - LocationManager:165
  15:04:44.429  [Location] 💡 Об'єктів освітлення: 1  -  Server - LocationManager:188
  15:04:44.430  [Location] 🗑️ Видалено освітлення: Sky  -  Server - LocationManager:217
  15:04:44.430  [Location] ✅ Очищення завершено  -  Server - LocationManager:243
  15:04:44.946  [LocationFSM] Cleaning → LoadingPlanet (Завантаження планети Planet_1)  -  Server - LocationManager:118
  15:04:44.946  [Location] 📦 Завантаження планети Planet_1  -  Server - LocationManager:497
  15:04:44.946  [Location] 🪐 Planet loading now handled by EnvironmentLoader  -  Server - LocationManager:353
  15:04:44.946  [LocationFSM] LoadingPlanet → LoadingLocation (Завантаження КС)  -  Server - LocationManager:118
  15:04:44.946  [Location] 📦 Завантаження SpaceStation...  -  Server - LocationManager:513
  15:04:44.946  [Location] 🚀 Loading Space Station using EnvironmentLoader  -  Server - LocationManager:249
  15:04:44.948  [Location] 📋 LoadOrder configuration loaded for SpaceStation  -  Server - LocationManager:267
  15:04:44.948  [EnvironmentLoader] 🚀 Loading Space Environment for planet: Planet_1  -  Server - EnvironmentLoader:217
  15:04:44.949  [ObjectTypeValidator] 🔍 Validating planet structure: Planet_1 (v1.3 - LocationModel hierarchy)  -  Server - ObjectTypeValidator:129
  15:04:44.949  [ObjectTypeValidator] ✅ Planet structure validation passed  -  Server - ObjectTypeValidator:182
  15:04:44.949  [ObjectTypeValidator] 🔍 Validating Space Station structure  -  Server - ObjectTypeValidator:270
  15:04:44.949      ✅ Scripts/Server - Folder  -  Server - ObjectTypeValidator:299
  15:04:44.949      ✅ Scripts/Client - Folder  -  Server - ObjectTypeValidator:299
  15:04:44.949        ✅ Server/PlanetSurfaceScanner - ModuleScript  -  Server - ObjectTypeValidator:311
  15:04:44.949        ✅ Client/SpaceStationUI - LocalScript  -  Server - ObjectTypeValidator:325
  15:04:44.949        ✅ Client/PlanetSurfaceScannerUI - LocalScript  -  Server - ObjectTypeValidator:325
  15:04:44.949  [ObjectTypeValidator] ✅ Space Station structure validation passed  -  Server - ObjectTypeValidator:346
  15:04:44.949  [EnvironmentLoader] 🧹 Clearing workspace...  -  Server - EnvironmentLoader:120
  15:04:44.949  [EnvironmentLoader] ✅ Workspace and Lighting cleared  -  Server - EnvironmentLoader:148
  15:04:44.950  [EnvironmentLoader] 📦 [1/1] Copied: Planet (Model) to Workspace  -  Server - EnvironmentLoader:178
  15:04:44.950  [EnvironmentLoader] ✅ Planet workspace loaded  -  Server - EnvironmentLoader:263
  15:04:44.950  [EnvironmentLoader] 📦 [1/1] Copied: Sky (Sky) to Lighting  -  Server - EnvironmentLoader:178
  15:04:44.950  [EnvironmentLoader] ✅ Planet lighting loaded  -  Server - EnvironmentLoader:273
  15:04:44.950  [EnvironmentLoader] 📋 SpaceStation Workspace contains: 1 objects  -  Server - EnvironmentLoader:360
  15:04:44.950  [EnvironmentLoader] ✅ LocationModel validated: Cosmic Research Station  -  Server - EnvironmentLoader:371
  15:04:44.954  [EnvironmentLoader] ✅ LocationModel copied to Workspace  -  Server - EnvironmentLoader:377
  15:04:44.954  [EnvironmentLoader] 📋 LocationModel contains:  -  Server - EnvironmentLoader:378
  15:04:44.954  [EnvironmentLoader]   📁 Architecture (14 items)  -  Server - EnvironmentLoader:381
  15:04:44.954  [EnvironmentLoader]   📁 Equipment (1 items)  -  Server - EnvironmentLoader:381
  15:04:44.954  [EnvironmentLoader]   📁 Environment (0 items)  -  Server - EnvironmentLoader:381
  15:04:44.954  [EnvironmentLoader]   📁 Gameplay (1 items)  -  Server - EnvironmentLoader:381
  15:04:44.954  [EnvironmentLoader] 📋 Processing 1 SpaceStation Server scripts with LoadOrder  -  Server - EnvironmentLoader:420
  15:04:44.955  [PlanetSurfaceScanner] 🚀 Initializing PlanetSurfaceScanner...  -  Server - PlanetSurfaceScanner:786
  15:04:44.955  [PlanetSurfaceScanner] 📦 Scanner model reference received: PlanetSurfaceScanner  -  Server - PlanetSurfaceScanner:787
  15:04:44.957  [Teleport] ✅ DataStoreManager завантажено  -  Server - TeleportationManager:88
  15:04:44.957  [PlanetSurfaceScanner] 📋 Configuration loaded:  -  Server - PlanetSurfaceScanner:792
  15:04:44.957    └─ SCAN_DURATION: 2  -  Server - PlanetSurfaceScanner:793
  15:04:44.957    └─ INTERACTION_DISTANCE: 10  -  Server - PlanetSurfaceScanner:794
  15:04:44.957    └─ PULSE_SPEED: 2  -  Server - PlanetSurfaceScanner:795
  15:04:44.957  [PlanetSurfaceScanner] 🔍 Looking for scanner components:  -  Server - PlanetSurfaceScanner:803
  15:04:44.957    └─ ScannerBaseplate: ✅ FOUND  -  Server - PlanetSurfaceScanner:804
  15:04:44.957    └─ ScannerDisplay: ✅ FOUND  -  Server - PlanetSurfaceScanner:805
  15:04:44.958    └─ ScannerScreen: ✅ FOUND  -  Server - PlanetSurfaceScanner:806
  15:04:44.958  [PlanetSurfaceScanner] ✅ RemoteEvent отримано з реєстру: PlanetSurfaceScanner_Results  -  Server - PlanetSurfaceScanner:827
  15:04:44.958  [PlanetSurfaceScanner] 🔄 Player monitoring started  -  Server - PlanetSurfaceScanner:721
  15:04:44.958    └─ Checking for players every 0.3s  -  Server - PlanetSurfaceScanner:722
  15:04:44.958    └─ INTERACTION_DISTANCE: 10  -  Server - PlanetSurfaceScanner:723
  15:04:44.958    └─ ScannerBaseplate position: 211.39849853515625, -468.5, 192.4146270751953  -  Server - PlanetSurfaceScanner:724
  15:04:44.958  [PlanetSurfaceScanner] ✅ PlanetSurfaceScanner initialized successfully  -  Server - PlanetSurfaceScanner:838
  15:04:44.958  [EnvironmentLoader] ✅ [1/1] Required & Initialized: PlanetSurfaceScanner  -  Server - EnvironmentLoader:473
  15:04:44.958  [EnvironmentLoader] ✅ [1/2] Copied: ServerStorage.Space.SpaceStation.Scripts.Client.PlanetSurfaceScannerUI → Sealord_75/PlayerGui/PlanetSurfaceScannerUI  -  Server - EnvironmentLoader:521
  15:04:44.959  [EnvironmentLoader] ✅ [2/2] Copied: ServerStorage.Space.SpaceStation.Scripts.Client.SpaceStationUI → Sealord_75/PlayerGui/SpaceStationUI  -  Server - EnvironmentLoader:521
  15:04:44.959  [EnvironmentLoader] ✅ Space Station scripts processed  -  Server - EnvironmentLoader:531
  15:04:44.959  [EnvironmentLoader] 📊 Verification: 2/2 objects loaded  -  Server - EnvironmentLoader:210
  15:04:44.959  [EnvironmentLoader] ✅ Space Environment loaded successfully  -  Server - EnvironmentLoader:551
  15:04:44.959  [ClientScriptInitializer] 🚀 Initializing client scripts...  -  Server - ClientScriptInitializer:123
  15:04:44.959    └─ Location: SpaceStation, Planet: Planet_1, LocationId: N/A  -  Server - ClientScriptInitializer:129
  15:04:44.959  [ClientScriptInitializer] ℹ️ TeleportationClient - no Initialize() function  -  Server - ClientScriptInitializer:153
  15:04:44.959  [ClientScriptInitializer] ℹ️ PlanetSurfaceScannerUI - no Initialize() function  -  Server - ClientScriptInitializer:153
  15:04:44.959  [ClientScriptInitializer] ℹ️ PlayerScriptsLoader - no Initialize() function  -  Server - ClientScriptInitializer:153
  15:04:44.959  [ClientScriptInitializer] ℹ️ RbxCharacterSounds - no Initialize() function  -  Server - ClientScriptInitializer:153
  15:04:44.959  [ClientScriptInitializer] 🎉 Initialized 0/5 client scripts  -  Server - ClientScriptInitializer:158
  15:04:44.960  [Location] ✅ LocationModel позиціоновано at Y=-450  -  Server - LocationManager:288
  15:04:44.960    └─ LocationModel.PrimaryPart: 0, -450, 0  -  Server - LocationManager:289
  15:04:44.960    └─ SpawnLocation (inside LocationModel/Gameplay): 3.6722412109375, -444.4411926269531, 14.06536865234375  -  Server - LocationManager:295
  15:04:44.960  [Location] 🔒 SpawnLocation приховано до першого сканування планети  -  Server - LocationManager:305
  15:04:44.960    └─ Section Architecture: 14 items  -  Server - LocationManager:314
  15:04:44.960    └─ Section Equipment: 1 items  -  Server - LocationManager:314
  15:04:44.961    └─ Section Environment: 0 items  -  Server - LocationManager:314
  15:04:44.961    └─ Section Gameplay: 1 items  -  Server - LocationManager:314
  15:04:44.961    └─ PlanetSurfaceScanner (inside SpaceStation): 16.086868286132812, -444.4411926269531, 85.6668701171875  -  Server - LocationManager:323
  15:04:44.961  [Location] ✅ Космічну станцію завантажено  -  Server - LocationManager:343
  15:04:44.961  [LocationFSM] LoadingLocation → Verifying (Перевірка готовності КС)  -  Server - LocationManager:118
  15:04:44.961  [LocationFSM] Verifying → Ready (КС готова)  -  Server - LocationManager:118
  15:04:44.961  [Location] ✅ Перехід на SpaceStation завершено  -  Server - LocationManager:539
  15:04:45.030  [PlanetSurfaceScannerUI 1.9] 📡 Initializing Scanner UI for model: PlanetSurfaceScanner  -  Client - PlanetSurfaceScannerUI:520
  15:04:45.031  [PlanetSurfaceScannerUI] 📡 Initializing Scanner UI for model: PlanetSurfaceScanner  -  Client - PlanetSurfaceScannerUI:492
  15:04:45.031  [SpaceStationUI 1.5] 🚀 Initializing Station UI...  -  Client - SpaceStationUI:491
  15:04:45.031  [SpaceStationUI] ✅ Status bar created successfully (dynamic names)  -  Client - SpaceStationUI:475
  15:04:46.979  [GameInit] 🔄 Підготовка появи гравця: Sealord_75  -  Server - GameInit:341
  15:04:47.529  [GameInit] ✅ Гравець з'явився на Космічній Станції  -  Server - GameInit:408
  15:04:47.529    └─ SpawnLocation: 3.6722412109375, -444.4411926269531, 14.06536865234375  -  Server - GameInit:409
  15:04:47.529    └─ Гравець (HumanoidRootPart): 3.6722412109375, -442.4411926269531, 14.06536865234375  -  Server - GameInit:410
  15:04:47.530    └─ LocationModel PrimaryPart: 0, -450, 0  -  Server - GameInit:415
  15:04:47.565  [PlanetSurfaceScannerUI 1.9] 🎯 ProximityPrompt configured - Enabled: true MaxActivationDistance: 6  -  Client - PlanetSurfaceScannerUI:575
  15:04:47.565  [PlanetSurfaceScannerUI 1.9] ✅ Scanner UI initialized successfully  -  Client - PlanetSurfaceScannerUI:577
  15:04:47.565  [PlanetSurfaceScannerUI 1.9] ✅ Ініціалізовано для LocationModel.Equipment.PlanetSurfaceScanner  -  Client - PlanetSurfaceScannerUI:747
  15:04:47.566  [PlanetSurfaceScannerUI] 🎯 ProximityPrompt configured - Enabled: true MaxActivationDistance: 6  -  Client - PlanetSurfaceScannerUI:542
  15:04:47.566  [PlanetSurfaceScannerUI] ✅ Scanner UI initialized successfully  -  Client - PlanetSurfaceScannerUI:544
  15:04:47.566  [PlanetSurfaceScannerUI] ✅ Ініціалізовано для LocationModel.Equipment.PlanetSurfaceScanner  -  Client - PlanetSurfaceScannerUI:714
  15:04:48.045  [GameInit] ✅ Гравця повністю завантажено: Sealord_75  -  Server - GameInit:588
  15:04:48.063   ▶ [PlanetSurfaceScanner] 🔍 Sealord_75 distance: 72.7 (threshold: 10) (x2)  -  Server - PlanetSurfaceScanner:740
  15:04:54.279  [PlanetSurfaceScanner] 🔍 Sealord_75 distance: 38.5 (threshold: 10)  -  Server - PlanetSurfaceScanner:740
  15:04:56.129  [PlanetSurfaceScanner] 👤 Sealord_75 entered scanner baseplate  -  Server - PlanetSurfaceScanner:747
  15:04:56.129  ServerStorage.Space.SpaceStation.Scripts.Server.PlanetSurfaceScanner:207: attempt to index nil with 'Planet_1'  -  Server - PlanetSurfaceScanner:207
  15:04:56.129  Stack Begin  -  Studio
  15:04:56.129  Script 'ServerStorage.Space.SpaceStation.Scripts.Server.PlanetSurfaceScanner', Line 207 - function resolvePlanetNameForPlayer  -  Studio - PlanetSurfaceScanner:207
  15:04:56.129  Script 'ServerStorage.Space.SpaceStation.Scripts.Server.PlanetSurfaceScanner', Line 573 - function startScanEffect  -  Studio - PlanetSurfaceScanner:573
  15:04:56.129  Script 'ServerStorage.Space.SpaceStation.Scripts.Server.PlanetSurfaceScanner', Line 752  -  Studio - PlanetSurfaceScanner:752
  15:04:56.129  Stack End  -  Studio
  15:04:56.130  [PlanetSurfaceScanner] 🟢 Scanner activated  -  Server - PlanetSurfaceScanner:656
  15:04:57.378   ▶ [PlanetSurfaceScanner] 🔍 Sealord_75 distance: 4.3 (threshold: 10) (x2)  -  Server - PlanetSurfaceScanner:740
  15:05:03.578  [PlanetSurfaceScanner] 🔍 Sealord_75 distance: 5.1 (threshold: 10)  -  Server - PlanetSurfaceScanner:740
  15:05:05.091  Disconnect from 127.0.0.1|65076  -  Studio
  15:05:05.093  [DataStore] 👤 Гравець виходить: Sealord_75  -  Server - DataStoreManager:464
  15:05:05.094  [DataStore] 🔄 Завершення роботи, збереження всіх даних...  -  Server - DataStoreManager:488
  15:05:05.094  [DataStore] ✅ Всі дані збережено  -  Server - DataStoreManager:506
  15:05:05.144  [PlanetSurfaceScanner] 🔴 Scanner deactivated  -  Server - PlanetSurfaceScanner:678
  15:05:05.811  [DataStore] ✅ Дані збережено для: Sealord_75  -  Server - DataStoreManager:391
  15:05:05.812  [DataStore] ✅ Дані збережено при виході: Sealord_75  -  Server - DataStoreManager:470