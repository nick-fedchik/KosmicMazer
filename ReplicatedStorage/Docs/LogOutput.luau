  17:56:45.978  
[ConfigValidator] 🔍 Starting configuration validation...  -  Server - ConfigValidator:529
  17:56:45.978  [PlanetConfigLoader] ✅ Loaded PlanetConfig for 'Planet_1' (Залізяка)  -  Server - PlanetConfigLoader:119
  17:56:45.978  
================================================================================  -  Server - ConfigValidator:98
  17:56:45.979  CONFIG VALIDATION REPORT  -  Server - ConfigValidator:99
  17:56:45.979  ================================================================================  -  Server - ConfigValidator:100
  17:56:45.979  
ℹ️  INFO (10):  -  Server - ConfigValidator:120
  17:56:45.979    1. [RequiredFields] Validating critical GameConfig fields...  -  Server - ConfigValidator:122
  17:56:45.979    2. [RequiredFields] Required fields validation completed  -  Server - ConfigValidator:122
  17:56:45.979    3. [Planets] Validating PlanetConfig from ServerStorage...  -  Server - ConfigValidator:122
  17:56:45.979    4. [Planets] ✅ PlanetConfig validated for Planet_1 (Залізяка) - 3 locations, 2 discovered  -  Server - ConfigValidator:122
  17:56:45.979    5. [SpaceStation] Validating Space Station configuration...  -  Server - ConfigValidator:122
  17:56:45.979    6. [SpaceStation] ✅ SpawnPoint 'SpawnLocation' found in LocationModel/Gameplay  -  Server - ConfigValidator:122
  17:56:45.980    7. [SpaceStation] ✅ PlanetSurfaceScanner found in LocationModel/Equipment  -  Server - ConfigValidator:122
  17:56:45.980    8. [SpaceStation] Space Station validation completed  -  Server - ConfigValidator:122
  17:56:45.980    9. [ServerStorage] Validating ServerStorage models...  -  Server - ConfigValidator:122
  17:56:45.980    10. [ServerStorage] ServerStorage model validation completed  -  Server - ConfigValidator:122
  17:56:45.980  
================================================================================  -  Server - ConfigValidator:126
  17:56:45.980  VALIDATION RESULT: ✅ PASSED  -  Server - ConfigValidator:127
  17:56:45.980  ================================================================================
  -  Server - ConfigValidator:128
  17:56:45.980  [GameInit] 🚀 GameInit завантажено  -  Server - GameInit:599
  17:56:45.981  [DataCleaner] 🔒 DEBUG_MODE вимкнено - скрипт неактивний (продакшен)  -  Server - DataStoreCleaner:53
  17:56:46.040  [GameInit] 👤 Гравець приєднався: Sealord_75  -  Server - GameInit:445
  17:56:46.040  [GameInit] 🖼️ Створення екрану завантаження для: Sealord_75  -  Server - GameInit:102
  17:56:46.041  [GameInit] ✅ Екран завантаження створено  -  Server - GameInit:291
  17:56:46.041  [GameInit] Ініціалізація RemoteEvents...  -  Server - GameInit:456
  17:56:46.041  [RemoteEventsRegistry] 🚀 Ініціалізація RemoteEvents...  -  Server - RemoteEventsRegistry:72
  17:56:46.041  [RemoteEventsRegistry] ♻️ RemoteEvent 'TeleportationEvent' вже існує - використовую існуючий  -  Server - RemoteEventsRegistry:81
  17:56:46.041  [RemoteEventsRegistry] ♻️ RemoteEvent 'TeleportationStateEvent' вже існує - використовую існуючий  -  Server - RemoteEventsRegistry:81
  17:56:46.042  [RemoteEventsRegistry] ✅ Створено RemoteEvent: PlanetSurfaceScanner_Results  -  Server - RemoteEventsRegistry:96
  17:56:46.042  [RemoteEventsRegistry] ✅ Створено RemoteEvent: PlayerDataReady  -  Server - RemoteEventsRegistry:96
  17:56:46.042  [RemoteEventsRegistry] 🎉 Ініціалізація завершена! Events: 4, Functions: 0  -  Server - RemoteEventsRegistry:125
  17:56:46.042  [GameInit] ✅ RemoteEvents готові  -  Server - GameInit:462
  17:56:46.042  [RemoteEventsRegistry] 🔍 Валідація RemoteEvents...  -  Server - RemoteEventsRegistry:228
  17:56:46.042  [RemoteEventsRegistry] ✅ RemoteEvent 'TeleportationEvent' валідний  -  Server - RemoteEventsRegistry:244
  17:56:46.042  [RemoteEventsRegistry] ✅ RemoteEvent 'TeleportationStateEvent' валідний  -  Server - RemoteEventsRegistry:244
  17:56:46.042  [RemoteEventsRegistry] ✅ RemoteEvent 'PlanetSurfaceScanner_Results' валідний  -  Server - RemoteEventsRegistry:244
  17:56:46.043  [RemoteEventsRegistry] ✅ RemoteEvent 'PlayerDataReady' валідний  -  Server - RemoteEventsRegistry:244
  17:56:46.043  [RemoteEventsRegistry] 🎉 Валідація пройдена успішно!  -  Server - RemoteEventsRegistry:268
  17:56:46.091  [TeleportClient 2.2] Очікування RemoteEvents...  -  Client - TeleportationClient:73
  17:56:46.092  [RemoteEventsRegistry] ⏳ Очікування 'TeleportationEvent' (timeout: 30s)...  -  Client - RemoteEventsRegistry:186
  17:56:46.092  [RemoteEventsRegistry] ✅ 'TeleportationEvent' знайдено в кеші  -  Client - RemoteEventsRegistry:191
  17:56:46.092  [RemoteEventsRegistry] ⏳ Очікування 'TeleportationStateEvent' (timeout: 30s)...  -  Client - RemoteEventsRegistry:186
  17:56:46.092  [RemoteEventsRegistry] ✅ 'TeleportationStateEvent' знайдено в кеші  -  Client - RemoteEventsRegistry:191
  17:56:46.092  [TeleportClient 2.2] ✅ RemoteEvents готові  -  Client - TeleportationClient:81
  17:56:46.092  [TeleportClient 2.2] 🚀 Клієнт телепортації завантажено  -  Client - TeleportationClient:538
  17:56:46.570  [DataStore] 🚀 Ініціалізація менеджера даних...  -  Server - DataStoreManager:478
  17:56:46.570  [DataStore] ✅ Менеджер даних ініціалізовано  -  Server - DataStoreManager:483
  17:56:47.086  [GameInit] 💾 Завантаження даних гравця: Sealord_75  -  Server - GameInit:324
  17:56:47.086  [DataStore] 💾 Завантаження даних гравця: Sealord_75 (ID: 8125377914 )  -  Server - DataStoreManager:250
  17:56:47.670  [DataStore] ✅ Знайдено існуючі дані для: Sealord_75  -  Server - DataStoreManager:255
  17:56:47.671  [DataStore] ℹ️ Дата приєднання: 2026-01-04 11:16:14  -  Server - DataStoreManager:258
  17:56:47.671  [GameInit] ✅ Дані гравця завантажено: Sealord_75  -  Server - GameInit:329
  17:56:47.671  [GameInit] ℹ️ Поточна планета: Planet_1  -  Server - GameInit:330
  17:56:48.186  [GameInit] ℹ️ Тип гравця: Existing - Sealord_75  -  Server - GameInit:511
  17:56:49.204  [GameInit] ✅ LocationManager завантажено  -  Server - GameInit:541
  17:56:49.204  [LocationFSM] Idle → Idle (Ініціалізація)  -  Server - LocationManager:118
  17:56:49.204  [Location] ✅ Менеджер локацій ініціалізовано  -  Server - LocationManager:628
  17:56:49.719  [Location] 🚀 Перехід з Deep Space на SpaceStation, орбіта: Planet_1  -  Server - LocationManager:455
  17:56:49.719  [LocationFSM] Idle → Idle (Початок переходу на КС)  -  Server - LocationManager:118
  17:56:49.719  [LocationFSM] Idle → Validating (Перевірка моделей КС)  -  Server - LocationManager:118
  17:56:49.720  [LocationFSM] ✅ Перевірено модель: Space/SpaceStation  -  Server - LocationManager:151
  17:56:49.720  [Location] 🧹 Очищення Workspace...  -  Server - LocationManager:480
  17:56:49.720  [LocationFSM] Validating → Cleaning (Clearing workspace)  -  Server - LocationManager:118
  17:56:49.720  [Location] 🧹 Очищення, об'єктів: 2  -  Server - LocationManager:165
  17:56:49.720  [Location] 💡 Об'єктів освітлення: 1  -  Server - LocationManager:188
  17:56:49.720  [Location] 🗑️ Видалено освітлення: Sky  -  Server - LocationManager:217
  17:56:49.720  [Location] ✅ Очищення завершено  -  Server - LocationManager:243
  17:56:50.235  [LocationFSM] Cleaning → LoadingPlanet (Завантаження планети Planet_1)  -  Server - LocationManager:118
  17:56:50.235  [Location] 📦 Завантаження планети Planet_1  -  Server - LocationManager:497
  17:56:50.235  [Location] 🪐 Planet loading now handled by EnvironmentLoader  -  Server - LocationManager:353
  17:56:50.236  [LocationFSM] LoadingPlanet → LoadingLocation (Завантаження КС)  -  Server - LocationManager:118
  17:56:50.236  [Location] 📦 Завантаження SpaceStation...  -  Server - LocationManager:513
  17:56:50.236  [Location] 🚀 Loading Space Station using EnvironmentLoader  -  Server - LocationManager:249
  17:56:50.238  [Location] 📋 LoadOrder configuration loaded for SpaceStation  -  Server - LocationManager:267
  17:56:50.238  [EnvironmentLoader] 🚀 Loading Space Environment for planet: Planet_1  -  Server - EnvironmentLoader:234
  17:56:50.238  [ObjectTypeValidator] 🔍 Validating planet structure: Planet_1 (v1.3 - LocationModel hierarchy)  -  Server - ObjectTypeValidator:129
  17:56:50.238  [ObjectTypeValidator] ✅ Planet structure validation passed  -  Server - ObjectTypeValidator:182
  17:56:50.238  [ObjectTypeValidator] 🔍 Validating Space Station structure  -  Server - ObjectTypeValidator:270
  17:56:50.238      ✅ Scripts/Server - Folder  -  Server - ObjectTypeValidator:299
  17:56:50.239      ✅ Scripts/Client - Folder  -  Server - ObjectTypeValidator:299
  17:56:50.239        ✅ Server/PlanetSurfaceScanner - ModuleScript  -  Server - ObjectTypeValidator:311
  17:56:50.239        ✅ Client/SpaceStationUI - LocalScript  -  Server - ObjectTypeValidator:325
  17:56:50.239        ✅ Client/PlanetSurfaceScannerUI - LocalScript  -  Server - ObjectTypeValidator:325
  17:56:50.239  [ObjectTypeValidator] ✅ Space Station structure validation passed  -  Server - ObjectTypeValidator:346
  17:56:50.239  [EnvironmentLoader] 🧹 Clearing workspace...  -  Server - EnvironmentLoader:120
  17:56:50.239  [EnvironmentLoader] ✅ Workspace and Lighting cleared  -  Server - EnvironmentLoader:148
  17:56:50.239  [EnvironmentLoader] 📦 [1/1] Copied: Planet (Model) to Workspace  -  Server - EnvironmentLoader:178
  17:56:50.239  [EnvironmentLoader] ✅ Planet workspace loaded  -  Server - EnvironmentLoader:280
  17:56:50.240  [EnvironmentLoader] 📦 [1/1] Copied: Sky (Sky) to Lighting  -  Server - EnvironmentLoader:178
  17:56:50.240  [EnvironmentLoader] ✅ Planet lighting loaded  -  Server - EnvironmentLoader:290
  17:56:50.240  [EnvironmentLoader] 📋 SpaceStation Workspace contains: 1 objects  -  Server - EnvironmentLoader:377
  17:56:50.240  [EnvironmentLoader] ✅ LocationModel validated: Cosmic Research Station  -  Server - EnvironmentLoader:388
  17:56:50.244  [EnvironmentLoader] ✅ LocationModel copied to Workspace  -  Server - EnvironmentLoader:394
  17:56:50.244  [EnvironmentLoader] 📋 LocationModel contains:  -  Server - EnvironmentLoader:395
  17:56:50.244  [EnvironmentLoader]   📁 Architecture (14 items)  -  Server - EnvironmentLoader:398
  17:56:50.244  [EnvironmentLoader]   📁 Equipment (1 items)  -  Server - EnvironmentLoader:398
  17:56:50.244  [EnvironmentLoader]   📁 Environment (0 items)  -  Server - EnvironmentLoader:398
  17:56:50.244  [EnvironmentLoader]   📁 Gameplay (1 items)  -  Server - EnvironmentLoader:398
  17:56:50.244  [EnvironmentLoader] 📋 Processing 1 SpaceStation Server scripts with LoadOrder  -  Server - EnvironmentLoader:437
  17:56:50.245  [PlanetSurfaceScanner 4.6] 🚀 Initializing...  -  Server - PlanetSurfaceScanner:822
  17:56:50.245  [PlanetSurfaceScanner 4.6] 📦 Scanner model reference received: PlanetSurfaceScanner  -  Server - PlanetSurfaceScanner:823
  17:56:50.247  [Teleport] ✅ DataStoreManager завантажено  -  Server - TeleportationManager:88
  17:56:50.247  [PlanetSurfaceScanner 4.6] 📋 Configuration loaded:  -  Server - PlanetSurfaceScanner:828
  17:56:50.247    └─ SCAN_DURATION: 2  -  Server - PlanetSurfaceScanner:829
  17:56:50.247    └─ INTERACTION_DISTANCE: 10  -  Server - PlanetSurfaceScanner:830
  17:56:50.247    └─ PULSE_SPEED: 2  -  Server - PlanetSurfaceScanner:831
  17:56:50.247  [PlanetSurfaceScanner 4.6] 🔍 Looking for scanner components:  -  Server - PlanetSurfaceScanner:839
  17:56:50.247    └─ ScannerBaseplate: ✅ FOUND  -  Server - PlanetSurfaceScanner:840
  17:56:50.248    └─ ScannerDisplay: ✅ FOUND  -  Server - PlanetSurfaceScanner:841
  17:56:50.248    └─ ScannerScreen: ✅ FOUND  -  Server - PlanetSurfaceScanner:842
  17:56:50.248  [PlanetSurfaceScanner 4.6] ✅ RemoteEvent отримано з реєстру: PlanetSurfaceScanner_Results  -  Server - PlanetSurfaceScanner:863
  17:56:50.248  [PlanetSurfaceScanner] 🔄 Player monitoring started  -  Server - PlanetSurfaceScanner:754
  17:56:50.248    └─ Checking for players every 0.3s  -  Server - PlanetSurfaceScanner:755
  17:56:50.248    └─ INTERACTION_DISTANCE: 10  -  Server - PlanetSurfaceScanner:756
  17:56:50.248    └─ ScannerBaseplate position: 211.39849853515625, -468.5, 192.4146270751953  -  Server - PlanetSurfaceScanner:757
  17:56:50.248  [PlanetSurfaceScanner 4.6] ✅ Initialized successfully  -  Server - PlanetSurfaceScanner:874
  17:56:50.248  [EnvironmentLoader] ✅ [1/1] Required & Initialized: PlanetSurfaceScanner  -  Server - EnvironmentLoader:490
  17:56:50.249  [EnvironmentLoader] ✅ [1/2] Copied: ServerStorage.Space.SpaceStation.Scripts.Client.PlanetSurfaceScannerUI → Sealord_75/PlayerGui/PlanetSurfaceScannerUI  -  Server - EnvironmentLoader:538
  17:56:50.249  [EnvironmentLoader] ✅ [2/2] Copied: ServerStorage.Space.SpaceStation.Scripts.Client.SpaceStationUI → Sealord_75/PlayerGui/SpaceStationUI  -  Server - EnvironmentLoader:538
  17:56:50.249  [EnvironmentLoader] ✅ Space Station scripts processed  -  Server - EnvironmentLoader:548
  17:56:50.249  [EnvironmentLoader] Verification: 2/2 objects loaded  -  Server - EnvironmentLoader:227
  17:56:50.249  [EnvironmentLoader] ✅ Planet Environment loaded successfully  -  Server - EnvironmentLoader:568
  17:56:50.250  [Location] ✅ LocationModel позиціоновано at Y=-450  -  Server - LocationManager:288
  17:56:50.250    └─ LocationModel.PrimaryPart: 0, -450, 0  -  Server - LocationManager:289
  17:56:50.250    └─ SpawnLocation (inside LocationModel/Gameplay): 3.6722412109375, -444.4411926269531, 14.06536865234375  -  Server - LocationManager:295
  17:56:50.250  [Location] 🔒 SpawnLocation приховано до першого сканування планети  -  Server - LocationManager:305
  17:56:50.250    └─ Section Architecture: 14 items  -  Server - LocationManager:314
  17:56:50.250    └─ Section Equipment: 1 items  -  Server - LocationManager:314
  17:56:50.250    └─ Section Environment: 0 items  -  Server - LocationManager:314
  17:56:50.251    └─ Section Gameplay: 1 items  -  Server - LocationManager:314
  17:56:50.251    └─ PlanetSurfaceScanner (inside SpaceStation): 16.086868286132812, -444.4411926269531, 85.6668701171875  -  Server - LocationManager:323
  17:56:50.251  [Location] ✅ Космічну станцію завантажено  -  Server - LocationManager:343
  17:56:50.251  [LocationFSM] LoadingLocation → Verifying (Перевірка готовності КС)  -  Server - LocationManager:118
  17:56:50.251  [LocationFSM] Verifying → Ready (КС готова)  -  Server - LocationManager:118
  17:56:50.251  [Location] ✅ Перехід на SpaceStation завершено  -  Server - LocationManager:539
  17:56:50.320  [PlanetSurfaceScannerUI 2.1] 📡 Initializing Scanner UI for model: PlanetSurfaceScanner  -  Client - PlanetSurfaceScannerUI:554
  17:56:50.320  [SpaceStationUI 1.7] 🚀 Initializing Station UI...  -  Client - SpaceStationUI:527
  17:56:51.769  [GameInit] 🔄 Підготовка появи гравця: Sealord_75  -  Server - GameInit:341
  17:56:52.319  [GameInit] ✅ Гравець з'явився на Космічній Станції  -  Server - GameInit:408
  17:56:52.319    └─ SpawnLocation: 3.6722412109375, -444.4411926269531, 14.06536865234375  -  Server - GameInit:409
  17:56:52.320    └─ Гравець (HumanoidRootPart): 3.6722412109375, -442.4411926269531, 14.06536865234375  -  Server - GameInit:410
  17:56:52.320    └─ LocationModel PrimaryPart: 0, -450, 0  -  Server - GameInit:415
  17:56:52.357  [PlanetSurfaceScannerUI 2.1] 🎯 ProximityPrompt configured - Enabled: true MaxActivationDistance: 6  -  Client - PlanetSurfaceScannerUI:609
  17:56:52.357  [PlanetSurfaceScannerUI 2.1] ✅ Scanner UI initialized successfully  -  Client - PlanetSurfaceScannerUI:612
  17:56:52.357  [PlanetSurfaceScannerUI 2.1] ✅ Ініціалізовано для LocationModel.Equipment.PlanetSurfaceScanner  -  Client - PlanetSurfaceScannerUI:743
  17:56:52.836  [GameInit] ✅ Гравця повністю завантажено: Sealord_75  -  Server - GameInit:588
  17:56:53.352  [PlanetSurfaceScanner] 🔍 Sealord_75 distance: 72.7 (threshold: 10)  -  Server - PlanetSurfaceScanner:773
  17:56:54.369  [SpaceStationUI 1.7] ✅ Player ready, creating status bar  -  Studio
  17:56:56.552   ▶ [PlanetSurfaceScanner] 🔍 Sealord_75 distance: 72.7 (threshold: 10) (x17)  -  Server - PlanetSurfaceScanner:773
  17:57:47.117  [DataStore] ✅ Дані збережено для: Sealord_75  -  Server - DataStoreManager:391
  17:57:47.117  [DataStore] 💾 Автозбереження для 1 гравців  -  Server - DataStoreManager:451
  17:57:49.400   ▶ [PlanetSurfaceScanner] 🔍 Sealord_75 distance: 72.7 (threshold: 10) (x19)  -  Server - PlanetSurfaceScanner:773
  17:58:47.614  [DataStore] ✅ Дані збережено для: Sealord_75  -  Server - DataStoreManager:391
  17:58:47.614  [DataStore] 💾 Автозбереження для 1 гравців  -  Server - DataStoreManager:451
  17:58:48.382   ▶ [PlanetSurfaceScanner] 🔍 Sealord_75 distance: 72.7 (threshold: 10) (x2)  -  Server - PlanetSurfaceScanner:773
  17:58:53.038  Disconnect from 127.0.0.1|55510  -  Studio
  17:58:53.040  [DataStore] 👤 Гравець виходить: Sealord_75  -  Server - DataStoreManager:464
  17:58:53.040  [DataStore] 🔄 Завершення роботи, збереження всіх даних...  -  Server - DataStoreManager:488
  17:58:53.040  [DataStore] ✅ Всі дані збережено  -  Server - DataStoreManager:506
  17:58:53.531  [DataStore] ✅ Дані збережено для: Sealord_75  -  Server - DataStoreManager:391
  17:58:53.532  [DataStore] ✅ Дані збережено при виході: Sealord_75  -  Server - DataStoreManager:470