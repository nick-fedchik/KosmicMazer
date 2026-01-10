  15:55:12.658  [DataCleaner] 🔒 DEBUG_MODE вимкнено - скрипт неактивний (продакшен)  -  Server - DataStoreCleaner:53
  15:55:12.660  
[ConfigValidator] 🔍 Starting configuration validation...  -  Server - ConfigValidator:529
  15:55:12.660  [PlanetConfigLoader] ✅ Loaded PlanetConfig for 'Planet_1' (Залізяка)  -  Server - PlanetConfigLoader:119
  15:55:12.660  
================================================================================  -  Server - ConfigValidator:98
  15:55:12.660  CONFIG VALIDATION REPORT  -  Server - ConfigValidator:99
  15:55:12.660  ================================================================================  -  Server - ConfigValidator:100
  15:55:12.660  
ℹ️  INFO (10):  -  Server - ConfigValidator:120
  15:55:12.661    1. [RequiredFields] Validating critical GameConfig fields...  -  Server - ConfigValidator:122
  15:55:12.661    2. [RequiredFields] Required fields validation completed  -  Server - ConfigValidator:122
  15:55:12.661    3. [Planets] Validating PlanetConfig from ServerStorage...  -  Server - ConfigValidator:122
  15:55:12.661    4. [Planets] ✅ PlanetConfig validated for Planet_1 (Залізяка) - 3 locations, 2 discovered  -  Server - ConfigValidator:122
  15:55:12.661    5. [SpaceStation] Validating Space Station configuration...  -  Server - ConfigValidator:122
  15:55:12.661    6. [SpaceStation] ✅ SpawnPoint 'SpawnLocation' found in LocationModel/Gameplay  -  Server - ConfigValidator:122
  15:55:12.661    7. [SpaceStation] ✅ PlanetSurfaceScanner found in LocationModel/Equipment  -  Server - ConfigValidator:122
  15:55:12.661    8. [SpaceStation] Space Station validation completed  -  Server - ConfigValidator:122
  15:55:12.661    9. [ServerStorage] Validating ServerStorage models...  -  Server - ConfigValidator:122
  15:55:12.661    10. [ServerStorage] ServerStorage model validation completed  -  Server - ConfigValidator:122
  15:55:12.662  
================================================================================  -  Server - ConfigValidator:126
  15:55:12.662  VALIDATION RESULT: ✅ PASSED  -  Server - ConfigValidator:127
  15:55:12.662  ================================================================================
  -  Server - ConfigValidator:128
  15:55:12.662  [GameInit] 🚀 GameInit завантажено  -  Server - GameInit:599
  15:55:12.727  [GameInit] 👤 Гравець приєднався: Sealord_75  -  Server - GameInit:445
  15:55:12.727  [GameInit] 🖼️ Створення екрану завантаження для: Sealord_75  -  Server - GameInit:102
  15:55:12.728  [GameInit] ✅ Екран завантаження створено  -  Server - GameInit:291
  15:55:12.728  [GameInit] Ініціалізація RemoteEvents...  -  Server - GameInit:456
  15:55:12.728  [RemoteEventsRegistry] 🚀 Ініціалізація RemoteEvents...  -  Server - RemoteEventsRegistry:72
  15:55:12.728  [RemoteEventsRegistry] ♻️ RemoteEvent 'TeleportationEvent' вже існує - використовую існуючий  -  Server - RemoteEventsRegistry:81
  15:55:12.728  [RemoteEventsRegistry] ♻️ RemoteEvent 'TeleportationStateEvent' вже існує - використовую існуючий  -  Server - RemoteEventsRegistry:81
  15:55:12.728  [RemoteEventsRegistry] ✅ Створено RemoteEvent: PlanetSurfaceScanner_Results  -  Server - RemoteEventsRegistry:96
  15:55:12.728  [RemoteEventsRegistry] ✅ Створено RemoteEvent: PlayerDataReady  -  Server - RemoteEventsRegistry:96
  15:55:12.728  [RemoteEventsRegistry] 🎉 Ініціалізація завершена! Events: 4, Functions: 0  -  Server - RemoteEventsRegistry:125
  15:55:12.729  [GameInit] ✅ RemoteEvents готові  -  Server - GameInit:462
  15:55:12.729  [RemoteEventsRegistry] 🔍 Валідація RemoteEvents...  -  Server - RemoteEventsRegistry:228
  15:55:12.729  [RemoteEventsRegistry] ✅ RemoteEvent 'TeleportationEvent' валідний  -  Server - RemoteEventsRegistry:244
  15:55:12.729  [RemoteEventsRegistry] ✅ RemoteEvent 'TeleportationStateEvent' валідний  -  Server - RemoteEventsRegistry:244
  15:55:12.729  [RemoteEventsRegistry] ✅ RemoteEvent 'PlanetSurfaceScanner_Results' валідний  -  Server - RemoteEventsRegistry:244
  15:55:12.729  [RemoteEventsRegistry] ✅ RemoteEvent 'PlayerDataReady' валідний  -  Server - RemoteEventsRegistry:244
  15:55:12.729  [RemoteEventsRegistry] 🎉 Валідація пройдена успішно!  -  Server - RemoteEventsRegistry:268
  15:55:12.801  [TeleportClient] Очікування RemoteEvents...  -  Client - TeleportationClient:70
  15:55:12.801  [RemoteEventsRegistry] ⏳ Очікування 'TeleportationEvent' (timeout: 30s)...  -  Client - RemoteEventsRegistry:186
  15:55:12.801  [RemoteEventsRegistry] ✅ 'TeleportationEvent' знайдено в кеші  -  Client - RemoteEventsRegistry:191
  15:55:12.801  [RemoteEventsRegistry] ⏳ Очікування 'TeleportationStateEvent' (timeout: 30s)...  -  Client - RemoteEventsRegistry:186
  15:55:12.801  [RemoteEventsRegistry] ✅ 'TeleportationStateEvent' знайдено в кеші  -  Client - RemoteEventsRegistry:191
  15:55:12.801  [TeleportClient] ✅ RemoteEvents готові  -  Client - TeleportationClient:78
  15:55:12.801  [TeleportClient] 🚀 Клієнт телепортації завантажено  -  Client - TeleportationClient:535
  15:55:13.264  [DataStore] 🚀 Ініціалізація менеджера даних...  -  Server - DataStoreManager:478
  15:55:13.264  [DataStore] ✅ Менеджер даних ініціалізовано  -  Server - DataStoreManager:483
  15:55:15.275  [GameInit] 💾 Завантаження даних гравця: Sealord_75  -  Server - GameInit:324
  15:55:15.275  [DataStore] 💾 Завантаження даних гравця: Sealord_75 (ID: 8125377914 )  -  Server - DataStoreManager:250
  15:55:15.558  [DataStore] ✅ Знайдено існуючі дані для: Sealord_75  -  Server - DataStoreManager:255
  15:55:15.558  [DataStore] ℹ️ Дата приєднання: 2026-01-04 11:16:14  -  Server - DataStoreManager:258
  15:55:15.558  [GameInit] ✅ Дані гравця завантажено: Sealord_75  -  Server - GameInit:329
  15:55:15.558  [GameInit] ℹ️ Поточна планета: Planet_1  -  Server - GameInit:330
  15:55:15.558  [GameInit] ℹ️ Тип гравця: Existing - Sealord_75  -  Server - GameInit:511
  15:55:17.592  [GameInit] ✅ LocationManager завантажено  -  Server - GameInit:541
  15:55:17.592  [LocationFSM] Idle → Idle (Ініціалізація)  -  Server - LocationManager:118
  15:55:17.592  [Location] ✅ Менеджер локацій ініціалізовано  -  Server - LocationManager:628
  15:55:18.609  [Location] 🚀 Перехід з Deep Space на SpaceStation, орбіта: Planet_1  -  Server - LocationManager:455
  15:55:18.609  [LocationFSM] Idle → Idle (Початок переходу на КС)  -  Server - LocationManager:118
  15:55:18.609  [LocationFSM] Idle → Validating (Перевірка моделей КС)  -  Server - LocationManager:118
  15:55:18.609  [LocationFSM] ✅ Перевірено модель: Space/SpaceStation  -  Server - LocationManager:151
  15:55:18.609  [Location] 🧹 Очищення Workspace...  -  Server - LocationManager:480
  15:55:18.609  [LocationFSM] Validating → Cleaning (Clearing workspace)  -  Server - LocationManager:118
  15:55:18.609  [Location] 🧹 Очищення, об'єктів: 2  -  Server - LocationManager:165
  15:55:18.609  [Location] 💡 Об'єктів освітлення: 1  -  Server - LocationManager:188
  15:55:18.609  [Location] 🗑️ Видалено освітлення: Sky  -  Server - LocationManager:217
  15:55:18.609  [Location] ✅ Очищення завершено  -  Server - LocationManager:243
  15:55:19.126  [LocationFSM] Cleaning → LoadingPlanet (Завантаження планети Planet_1)  -  Server - LocationManager:118
  15:55:19.126  [Location] 📦 Завантаження планети Planet_1  -  Server - LocationManager:497
  15:55:19.126  [Location] 🪐 Planet loading now handled by EnvironmentLoader  -  Server - LocationManager:353
  15:55:19.126  [LocationFSM] LoadingPlanet → LoadingLocation (Завантаження КС)  -  Server - LocationManager:118
  15:55:19.126  [Location] 📦 Завантаження SpaceStation...  -  Server - LocationManager:513
  15:55:19.126  [Location] 🚀 Loading Space Station using EnvironmentLoader  -  Server - LocationManager:249
  15:55:19.128  [Location] 📋 LoadOrder configuration loaded for SpaceStation  -  Server - LocationManager:267
  15:55:19.128  [EnvironmentLoader] 🚀 Loading Space Environment for planet: Planet_1  -  Server - EnvironmentLoader:217
  15:55:19.128  [ObjectTypeValidator] 🔍 Validating planet structure: Planet_1 (v1.3 - LocationModel hierarchy)  -  Server - ObjectTypeValidator:129
  15:55:19.128  [ObjectTypeValidator] ✅ Planet structure validation passed  -  Server - ObjectTypeValidator:182
  15:55:19.128  [ObjectTypeValidator] 🔍 Validating Space Station structure  -  Server - ObjectTypeValidator:270
  15:55:19.129      ✅ Scripts/Server - Folder  -  Server - ObjectTypeValidator:299
  15:55:19.129      ✅ Scripts/Client - Folder  -  Server - ObjectTypeValidator:299
  15:55:19.129        ✅ Server/PlanetSurfaceScanner - ModuleScript  -  Server - ObjectTypeValidator:311
  15:55:19.129        ✅ Client/SpaceStationUI - LocalScript  -  Server - ObjectTypeValidator:325
  15:55:19.129        ✅ Client/PlanetSurfaceScannerUI - LocalScript  -  Server - ObjectTypeValidator:325
  15:55:19.129  [ObjectTypeValidator] ✅ Space Station structure validation passed  -  Server - ObjectTypeValidator:346
  15:55:19.129  [EnvironmentLoader] 🧹 Clearing workspace...  -  Server - EnvironmentLoader:120
  15:55:19.129  [EnvironmentLoader] ✅ Workspace and Lighting cleared  -  Server - EnvironmentLoader:148
  15:55:19.129  [EnvironmentLoader] 📦 [1/1] Copied: Planet (Model) to Workspace  -  Server - EnvironmentLoader:178
  15:55:19.129  [EnvironmentLoader] ✅ Planet workspace loaded  -  Server - EnvironmentLoader:263
  15:55:19.129  [EnvironmentLoader] 📦 [1/1] Copied: Sky (Sky) to Lighting  -  Server - EnvironmentLoader:178
  15:55:19.129  [EnvironmentLoader] ✅ Planet lighting loaded  -  Server - EnvironmentLoader:273
  15:55:19.130  [EnvironmentLoader] 📋 SpaceStation Workspace contains: 1 objects  -  Server - EnvironmentLoader:360
  15:55:19.130  [EnvironmentLoader] ✅ LocationModel validated: Cosmic Research Station  -  Server - EnvironmentLoader:371
  15:55:19.133  [EnvironmentLoader] ✅ LocationModel copied to Workspace  -  Server - EnvironmentLoader:377
  15:55:19.133  [EnvironmentLoader] 📋 LocationModel contains:  -  Server - EnvironmentLoader:378
  15:55:19.134  [EnvironmentLoader]   📁 Architecture (14 items)  -  Server - EnvironmentLoader:381
  15:55:19.134  [EnvironmentLoader]   📁 Equipment (1 items)  -  Server - EnvironmentLoader:381
  15:55:19.134  [EnvironmentLoader]   📁 Environment (0 items)  -  Server - EnvironmentLoader:381
  15:55:19.134  [EnvironmentLoader]   📁 Gameplay (1 items)  -  Server - EnvironmentLoader:381
  15:55:19.134  [EnvironmentLoader] 📋 Processing 1 SpaceStation Server scripts with LoadOrder  -  Server - EnvironmentLoader:420
  15:55:19.135  [PlanetSurfaceScanner 4.6] 🚀 Initializing...  -  Server - PlanetSurfaceScanner:822
  15:55:19.135  [PlanetSurfaceScanner 4.6] 📦 Scanner model reference received: PlanetSurfaceScanner  -  Server - PlanetSurfaceScanner:823
  15:55:19.136  [Teleport] ✅ DataStoreManager завантажено  -  Server - TeleportationManager:88
  15:55:19.136  [PlanetSurfaceScanner 4.6] 📋 Configuration loaded:  -  Server - PlanetSurfaceScanner:828
  15:55:19.136    └─ SCAN_DURATION: 2  -  Server - PlanetSurfaceScanner:829
  15:55:19.136    └─ INTERACTION_DISTANCE: 10  -  Server - PlanetSurfaceScanner:830
  15:55:19.136    └─ PULSE_SPEED: 2  -  Server - PlanetSurfaceScanner:831
  15:55:19.136  [PlanetSurfaceScanner 4.6] 🔍 Looking for scanner components:  -  Server - PlanetSurfaceScanner:839
  15:55:19.137    └─ ScannerBaseplate: ✅ FOUND  -  Server - PlanetSurfaceScanner:840
  15:55:19.137    └─ ScannerDisplay: ✅ FOUND  -  Server - PlanetSurfaceScanner:841
  15:55:19.137    └─ ScannerScreen: ✅ FOUND  -  Server - PlanetSurfaceScanner:842
  15:55:19.137  [PlanetSurfaceScanner 4.6] ✅ RemoteEvent отримано з реєстру: PlanetSurfaceScanner_Results  -  Server - PlanetSurfaceScanner:863
  15:55:19.137  [PlanetSurfaceScanner] 🔄 Player monitoring started  -  Server - PlanetSurfaceScanner:754
  15:55:19.137    └─ Checking for players every 0.3s  -  Server - PlanetSurfaceScanner:755
  15:55:19.137    └─ INTERACTION_DISTANCE: 10  -  Server - PlanetSurfaceScanner:756
  15:55:19.137    └─ ScannerBaseplate position: 211.39849853515625, -468.5, 192.4146270751953  -  Server - PlanetSurfaceScanner:757
  15:55:19.137  [PlanetSurfaceScanner 4.6] ✅ Initialized successfully  -  Server - PlanetSurfaceScanner:874
  15:55:19.137  [EnvironmentLoader] ✅ [1/1] Required & Initialized: PlanetSurfaceScanner  -  Server - EnvironmentLoader:473
  15:55:19.137  [EnvironmentLoader] ✅ [1/2] Copied: ServerStorage.Space.SpaceStation.Scripts.Client.PlanetSurfaceScannerUI → Sealord_75/PlayerGui/PlanetSurfaceScannerUI  -  Server - EnvironmentLoader:521
  15:55:19.137  [EnvironmentLoader] ✅ [2/2] Copied: ServerStorage.Space.SpaceStation.Scripts.Client.SpaceStationUI → Sealord_75/PlayerGui/SpaceStationUI  -  Server - EnvironmentLoader:521
  15:55:19.137  [EnvironmentLoader] ✅ Space Station scripts processed  -  Server - EnvironmentLoader:531
  15:55:19.137  [EnvironmentLoader] 📊 Verification: 2/2 objects loaded  -  Server - EnvironmentLoader:210
  15:55:19.137  [EnvironmentLoader] ✅ Space Environment loaded successfully  -  Server - EnvironmentLoader:551
  15:55:19.137  [ClientScriptInitializer] 🚀 Initializing client scripts...  -  Server - ClientScriptInitializer:123
  15:55:19.137    └─ Location: SpaceStation, Planet: Planet_1, LocationId: N/A  -  Server - ClientScriptInitializer:129
  15:55:19.137  [ClientScriptInitializer] ℹ️ TeleportationClient - no Initialize() function  -  Server - ClientScriptInitializer:153
  15:55:19.138  [ClientScriptInitializer] ℹ️ PlanetSurfaceScannerUI - no Initialize() function  -  Server - ClientScriptInitializer:153
  15:55:19.138  [ClientScriptInitializer] ℹ️ PlayerScriptsLoader - no Initialize() function  -  Server - ClientScriptInitializer:153
  15:55:19.138  [ClientScriptInitializer] ℹ️ RbxCharacterSounds - no Initialize() function  -  Server - ClientScriptInitializer:153
  15:55:19.138  [ClientScriptInitializer] 🎉 Initialized 0/5 client scripts  -  Server - ClientScriptInitializer:158
  15:55:19.138  [Location] ✅ LocationModel позиціоновано at Y=-450  -  Server - LocationManager:288
  15:55:19.138    └─ LocationModel.PrimaryPart: 0, -450, 0  -  Server - LocationManager:289
  15:55:19.138    └─ SpawnLocation (inside LocationModel/Gameplay): 3.6722412109375, -444.4411926269531, 14.06536865234375  -  Server - LocationManager:295
  15:55:19.138  [Location] 🔒 SpawnLocation приховано до першого сканування планети  -  Server - LocationManager:305
  15:55:19.139    └─ Section Architecture: 14 items  -  Server - LocationManager:314
  15:55:19.139    └─ Section Equipment: 1 items  -  Server - LocationManager:314
  15:55:19.139    └─ Section Environment: 0 items  -  Server - LocationManager:314
  15:55:19.139    └─ Section Gameplay: 1 items  -  Server - LocationManager:314
  15:55:19.139    └─ PlanetSurfaceScanner (inside SpaceStation): 16.086868286132812, -444.4411926269531, 85.6668701171875  -  Server - LocationManager:323
  15:55:19.139  [Location] ✅ Космічну станцію завантажено  -  Server - LocationManager:343
  15:55:19.139  [LocationFSM] LoadingLocation → Verifying (Перевірка готовності КС)  -  Server - LocationManager:118
  15:55:19.139  [LocationFSM] Verifying → Ready (КС готова)  -  Server - LocationManager:118
  15:55:19.139  [Location] ✅ Перехід на SpaceStation завершено  -  Server - LocationManager:539
  15:55:19.207  [PlanetSurfaceScannerUI 1.9] 📡 Initializing Scanner UI for model: PlanetSurfaceScanner  -  Client - PlanetSurfaceScannerUI:522
  15:55:19.207  [SpaceStationUI 1.5] 🚀 Initializing Station UI...  -  Client - SpaceStationUI:491
  15:55:19.208  [SpaceStationUI] ✅ Status bar created successfully (dynamic names)  -  Client - SpaceStationUI:475
  15:55:21.158  [GameInit] 🔄 Підготовка появи гравця: Sealord_75  -  Server - GameInit:341
  15:55:21.674  [GameInit] ✅ Гравець з'явився на Космічній Станції  -  Server - GameInit:408
  15:55:21.675    └─ SpawnLocation: 3.6722412109375, -444.4411926269531, 14.06536865234375  -  Server - GameInit:409
  15:55:21.675    └─ Гравець (HumanoidRootPart): 3.6722412109375, -442.4411926269531, 14.06536865234375  -  Server - GameInit:410
  15:55:21.675    └─ LocationModel PrimaryPart: 0, -450, 0  -  Server - GameInit:415
  15:55:21.712  [PlanetSurfaceScannerUI 1.9] 🎯 ProximityPrompt configured - Enabled: true MaxActivationDistance: 6  -  Client - PlanetSurfaceScannerUI:577
  15:55:21.712  [PlanetSurfaceScannerUI 1.9] ✅ Scanner UI initialized successfully  -  Client - PlanetSurfaceScannerUI:580
  15:55:21.712  [PlanetSurfaceScannerUI 1.9] ✅ Ініціалізовано для LocationModel.Equipment.PlanetSurfaceScanner  -  Client - PlanetSurfaceScannerUI:751
  15:55:22.191  [GameInit] ✅ Гравця повністю завантажено: Sealord_75  -  Server - GameInit:588
  15:55:22.225   ▶ [PlanetSurfaceScanner] 🔍 Sealord_75 distance: 72.7 (threshold: 10) (x2)  -  Server - PlanetSurfaceScanner:773
  15:55:28.408  [PlanetSurfaceScanner] 🔍 Sealord_75 distance: 31.9 (threshold: 10)  -  Server - PlanetSurfaceScanner:773
  15:55:29.942  [PlanetSurfaceScanner] 👤 Sealord_75 entered scanner baseplate  -  Server - PlanetSurfaceScanner:780
  15:55:29.942  [PlanetSurfaceScanner] ? Set planet name: Залізяка  -  Server - PlanetSurfaceScanner:265
  15:55:29.942  [PlanetSurfaceScanner] 🔍 Starting scan for Sealord_75 (first time scanner use: false)  -  Server - PlanetSurfaceScanner:611
  15:55:29.942  [PlanetSurfaceScanner] 📡 Loading locations from planet: Planet_1 (Залізяка)  -  Server - PlanetSurfaceScanner:184
  15:55:29.942  [PlanetSurfaceScanner] ✅ Location added: Садочок (Location_1)  -  Server - PlanetSurfaceScanner:215
  15:55:29.942  [PlanetSurfaceScanner] ✅ Location added: Гута (Location_2)  -  Server - PlanetSurfaceScanner:215
  15:55:29.942  [PlanetSurfaceScanner] 📊 Total discovered locations: 2  -  Server - PlanetSurfaceScanner:221
  15:55:29.943  [PlanetSurfaceScanner] 🟢 Scanner activated  -  Server - PlanetSurfaceScanner:689
  15:55:31.492  [PlanetSurfaceScanner] 🔍 Sealord_75 distance: 4.0 (threshold: 10)  -  Server - PlanetSurfaceScanner:773
  15:55:31.991  [PlanetSurfaceScanner] ✅ Scan completed for Sealord_75  -  Server - PlanetSurfaceScanner:651
  15:55:31.991  [PlanetSurfaceScanner] 📡 Loading locations from planet: Planet_1 (Залізяка)  -  Server - PlanetSurfaceScanner:184
  15:55:31.991  [PlanetSurfaceScanner] ✅ Location added: Садочок (Location_1)  -  Server - PlanetSurfaceScanner:215
  15:55:31.991  [PlanetSurfaceScanner] ✅ Location added: Гута (Location_2)  -  Server - PlanetSurfaceScanner:215
  15:55:31.992  [PlanetSurfaceScanner] 📊 Total discovered locations: 2  -  Server - PlanetSurfaceScanner:221
  15:55:31.992  [PlanetSurfaceScanner] 🚀 Initializing TeleportationManager...  -  Server - PlanetSurfaceScanner:287
  15:55:31.992  [PlanetSurfaceScanner] ✅ RemoteEvents отримано з реєстру  -  Server - PlanetSurfaceScanner:298
  15:55:31.992  [TeleportationManager] 🚀 Initializing Teleportation System...  -  Server - TeleportationManager:1027
  15:55:31.992  [TeleportationManager] 📋 Initial workspace state:  -  Server - TeleportationManager:1028
  15:55:31.992  [TeleportationManager] 🔍 Searching for SpawnLocation...  -  Server - TeleportationManager:146
  15:55:31.992  [TeleportationManager] ✅ Found SpawnLocation in LocationModel/Gameplay: Workspace.LocationModel.Gameplay.SpawnLocation  -  Server - TeleportationManager:167
  15:55:31.992  [TeleportationManager] ✅ SpawnLocation initialized: Workspace.LocationModel.Gameplay.SpawnLocation  -  Server - TeleportationManager:232
  15:55:31.992  [TeleportationManager] Отримання RemoteEvents з реєстру...  -  Server - TeleportationManager:1039
  15:55:31.992  [TeleportationManager] ✅ RemoteEvents отримано з реєстру  -  Server - TeleportationManager:1047
  15:55:31.992  [TeleportationManager]   - TeleportationEvent: true  -  Server - TeleportationManager:1048
  15:55:31.992  [TeleportationManager]   - TeleportationStateEvent: true  -  Server - TeleportationManager:1049
  15:55:31.992  [TeleportationManager] Connected initial events to SpawnLocation: Workspace.LocationModel.Gameplay.SpawnLocation  -  Server - TeleportationManager:1084
  15:55:31.992  [TeleportationManager] ✅ RemoteEvent OnServerEvent CONNECTED to onTeleportRequest  -  Server - TeleportationManager:1088
  15:55:31.992  [TeleportationManager] 🔍 Searching for SpawnLocation...  -  Server - TeleportationManager:146
  15:55:31.992  [TeleportationManager] ✅ Found SpawnLocation in LocationModel/Gameplay: Workspace.LocationModel.Gameplay.SpawnLocation  -  Server - TeleportationManager:167
  15:55:31.992  [TeleportationManager] 🔍 Checking spawn location - current: Workspace.LocationModel.Gameplay.SpawnLocation, new: Workspace.LocationModel.Gameplay.SpawnLocation  -  Server - TeleportationManager:243
  15:55:31.992  [TeleportationManager] ℹ️ SpawnLocation unchanged: Workspace.LocationModel.Gameplay.SpawnLocation  -  Server - TeleportationManager:271
  15:55:31.992  [Teleport] 🔒 Телепортація прихована до першого сканування планети  -  Server - TeleportationManager:300
  15:55:31.992  [Teleport] ✅ Систему телепортації ініціалізовано  -  Server - TeleportationManager:1096
  15:55:31.992  [PlanetSurfaceScanner] ✅ TeleportationManager initialized successfully  -  Server - PlanetSurfaceScanner:306
  15:55:32.024  [PlanetSurfaceScannerUI 1.9] ScanResults received from server:  Залізяка  -  Client - PlanetSurfaceScannerUI:181
  15:55:32.025  [PlanetSurfaceScannerUI 1.9] 📊 Showing scan results: 2 locations found  -  Client - PlanetSurfaceScannerUI:591
  15:55:33.008  [PlanetSurfaceScanner] 📡 Notified clients that teleportation system is ready  -  Server - PlanetSurfaceScanner:311
  15:55:33.008  [PlanetSurfaceScanner] 🚀 TELEPORTATION SYSTEM ACTIVATED - Discovered locations found  -  Server - PlanetSurfaceScanner:328
  15:55:33.008  [Teleport] 🔄 Телепортацію АКТИВОВАНО : Sealord_75  -  Server - TeleportationManager:1006
  15:55:33.008  [TeleportationManager] 🔍 Searching for SpawnLocation...  -  Server - TeleportationManager:146
  15:55:33.008  [TeleportationManager] ✅ Found SpawnLocation in LocationModel/Gameplay: Workspace.LocationModel.Gameplay.SpawnLocation  -  Server - TeleportationManager:167
  15:55:33.008  [TeleportationManager] 🔍 Checking spawn location - current: Workspace.LocationModel.Gameplay.SpawnLocation, new: Workspace.LocationModel.Gameplay.SpawnLocation  -  Server - TeleportationManager:243
  15:55:33.008  [TeleportationManager] ℹ️ SpawnLocation unchanged: Workspace.LocationModel.Gameplay.SpawnLocation  -  Server - TeleportationManager:271
  15:55:33.008  [TeleportationManager] 🔗 Reconnected Touched/TouchEnded events during activation  -  Server - TeleportationManager:336
  15:55:33.008  [Teleport] 🟢 Телепортація АКТИВНА  -  Server - TeleportationManager:367
  15:55:33.008  [TeleportationManager] ✅ SpawnLocation should now be BLUE and PULSING  -  Server - TeleportationManager:1010
  15:55:33.009  [TeleportationManager] 📡 Sent state change to Sealord_75: true  -  Server - TeleportationManager:1020
  15:55:33.041   ▶ [TeleportClient] 🔄 Стан системи: АКТИВНА (x2)  -  Client - TeleportationClient:523
  15:55:34.574   ▶ [PlanetSurfaceScanner] 🔍 Sealord_75 distance: 4.0 (threshold: 10) (x4)  -  Server - PlanetSurfaceScanner:773
  15:55:46.957  [PlanetSurfaceScanner] 🔍 Sealord_75 distance: 3.9 (threshold: 10)  -  Server - PlanetSurfaceScanner:773
  15:55:49.147  Disconnect from 127.0.0.1|60032  -  Studio
  15:55:49.149  [DataStore] 👤 Гравець виходить: Sealord_75  -  Server - DataStoreManager:464
  15:55:49.150  [DataStore] 🔄 Завершення роботи, збереження всіх даних...  -  Server - DataStoreManager:488
  15:55:49.150  [DataStore] ✅ Всі дані збережено  -  Server - DataStoreManager:506
  15:55:49.165  [PlanetSurfaceScanner] 🔴 Scanner deactivated  -  Server - PlanetSurfaceScanner:711
  15:55:49.640  [DataStore] ✅ Дані збережено для: Sealord_75  -  Server - DataStoreManager:391
  15:55:49.640  [DataStore] ✅ Дані збережено при виході: Sealord_75  -  Server - DataStoreManager:470