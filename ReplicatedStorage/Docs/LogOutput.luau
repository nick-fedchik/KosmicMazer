  22:06:54.609  [DataCleaner] 🔒 DEBUG_MODE вимкнено - скрипт неактивний (продакшен)  -  Server - DataStoreCleaner:53
  22:06:54.611  
[ConfigValidator] 🔍 Starting configuration validation...  -  Server - ConfigValidator:583
  22:06:54.611  
================================================================================  -  Server - ConfigValidator:84
  22:06:54.611  CONFIG VALIDATION REPORT  -  Server - ConfigValidator:85
  22:06:54.611  ================================================================================  -  Server - ConfigValidator:86
  22:06:54.611  
⚠️  WARNINGS (1):  -  Server - ConfigValidator:98
  22:06:54.611    1. [Planet:Planet_2] No locations are marked as discovered - players won't be able to spawn here  -  Server - ConfigValidator:100
  22:06:54.612  
ℹ️  INFO (18):  -  Server - ConfigValidator:106
  22:06:54.612    1. [RequiredFields] Validating critical GameConfig fields...  -  Server - ConfigValidator:108
  22:06:54.612    2. [RequiredFields] Required fields validation completed  -  Server - ConfigValidator:108
  22:06:54.612    3. [Planets] Validating planet configurations...  -  Server - ConfigValidator:108
  22:06:54.612    4. [Planet:Planet_2] Planet has 0 locations, 0 discovered  -  Server - ConfigValidator:108
  22:06:54.612    5. [Planet:Planet_1] Planet has 0 locations, 2 discovered  -  Server - ConfigValidator:108
  22:06:54.612    6. [Planets] Validated 2 planets, 2 available  -  Server - ConfigValidator:108
  22:06:54.612    7. [SpaceStation] Validating Space Station configuration...  -  Server - ConfigValidator:108
  22:06:54.612    8. [SpaceStation] ✅ SpawnPoint 'SpawnLocation' found in LocationModel/Gameplay  -  Server - ConfigValidator:108
  22:06:54.613    9. [SpaceStation] ✅ PlanetSurfaceScanner found in LocationModel/Equipment  -  Server - ConfigValidator:108
  22:06:54.613    10. [SpaceStation] Space Station validation completed  -  Server - ConfigValidator:108
  22:06:54.613    11. [ServerStorage] Validating ServerStorage models...  -  Server - ConfigValidator:108
  22:06:54.613    12. [ServerStorage] Planet 'Planet_2', Location 'Location_1': ✅ SpawnPoint found in LocationModel/Gameplay  -  Server - ConfigValidator:108
  22:06:54.613    13. [ServerStorage] Planet 'Planet_2', Location 'Location_2': ✅ SpawnPoint found in LocationModel/Gameplay  -  Server - ConfigValidator:108
  22:06:54.613    14. [ServerStorage] Planet 'Planet_2', Location 'Location_3': ✅ SpawnPoint found in LocationModel/Gameplay  -  Server - ConfigValidator:108
  22:06:54.613    15. [ServerStorage] Planet 'Planet_1', Location 'Location_1': ✅ SpawnPoint found in LocationModel/Gameplay  -  Server - ConfigValidator:108
  22:06:54.614    16. [ServerStorage] Planet 'Planet_1', Location 'Location_2': ✅ SpawnPoint found in LocationModel/Gameplay  -  Server - ConfigValidator:108
  22:06:54.614    17. [ServerStorage] Planet 'Planet_1', Location 'Location_3': ✅ SpawnPoint found in LocationModel/Gameplay  -  Server - ConfigValidator:108
  22:06:54.614    18. [ServerStorage] ServerStorage model validation completed  -  Server - ConfigValidator:108
  22:06:54.614  
================================================================================  -  Server - ConfigValidator:112
  22:06:54.614  VALIDATION RESULT: ✅ PASSED  -  Server - ConfigValidator:113
  22:06:54.614  ================================================================================
  -  Server - ConfigValidator:114
  22:06:54.614  [GameInit] 🚀 GameInit завантажено  -  Server - GameInit:599
  22:06:54.689  [GameInit] 👤 Гравець приєднався: Sealord_75  -  Server - GameInit:445
  22:06:54.689  [GameInit] 🖼️ Створення екрану завантаження для: Sealord_75  -  Server - GameInit:102
  22:06:54.690  [GameInit] ✅ Екран завантаження створено  -  Server - GameInit:291
  22:06:54.690  [GameInit] Ініціалізація RemoteEvents...  -  Server - GameInit:456
  22:06:54.690  [RemoteEventsRegistry] 🚀 Ініціалізація RemoteEvents...  -  Server - RemoteEventsRegistry:72
  22:06:54.690  [RemoteEventsRegistry] ♻️ RemoteEvent 'TeleportationEvent' вже існує - використовую існуючий  -  Server - RemoteEventsRegistry:81
  22:06:54.690  [RemoteEventsRegistry] ♻️ RemoteEvent 'TeleportationStateEvent' вже існує - використовую існуючий  -  Server - RemoteEventsRegistry:81
  22:06:54.690  [RemoteEventsRegistry] ✅ Створено RemoteEvent: PlanetSurfaceScanner_Results  -  Server - RemoteEventsRegistry:96
  22:06:54.690  [RemoteEventsRegistry] ✅ Створено RemoteEvent: PlayerDataReady  -  Server - RemoteEventsRegistry:96
  22:06:54.690  [RemoteEventsRegistry] 🎉 Ініціалізація завершена! Events: 4, Functions: 0  -  Server - RemoteEventsRegistry:125
  22:06:54.690  [GameInit] ✅ RemoteEvents готові  -  Server - GameInit:462
  22:06:54.690  [RemoteEventsRegistry] 🔍 Валідація RemoteEvents...  -  Server - RemoteEventsRegistry:228
  22:06:54.690  [RemoteEventsRegistry] ✅ RemoteEvent 'TeleportationEvent' валідний  -  Server - RemoteEventsRegistry:244
  22:06:54.690  [RemoteEventsRegistry] ✅ RemoteEvent 'TeleportationStateEvent' валідний  -  Server - RemoteEventsRegistry:244
  22:06:54.690  [RemoteEventsRegistry] ✅ RemoteEvent 'PlanetSurfaceScanner_Results' валідний  -  Server - RemoteEventsRegistry:244
  22:06:54.690  [RemoteEventsRegistry] ✅ RemoteEvent 'PlayerDataReady' валідний  -  Server - RemoteEventsRegistry:244
  22:06:54.690  [RemoteEventsRegistry] 🎉 Валідація пройдена успішно!  -  Server - RemoteEventsRegistry:268
  22:06:54.787  [TeleportClient] Очікування RemoteEvents...  -  Client - TeleportationClient:70
  22:06:54.787  [RemoteEventsRegistry] ⏳ Очікування 'TeleportationEvent' (timeout: 30s)...  -  Client - RemoteEventsRegistry:186
  22:06:54.787  [RemoteEventsRegistry] ✅ 'TeleportationEvent' знайдено в кеші  -  Client - RemoteEventsRegistry:191
  22:06:54.787  [RemoteEventsRegistry] ⏳ Очікування 'TeleportationStateEvent' (timeout: 30s)...  -  Client - RemoteEventsRegistry:186
  22:06:54.788  [RemoteEventsRegistry] ✅ 'TeleportationStateEvent' знайдено в кеші  -  Client - RemoteEventsRegistry:191
  22:06:54.788  [TeleportClient] ✅ RemoteEvents готові  -  Client - TeleportationClient:78
  22:06:54.788  [TeleportClient] 🚀 Клієнт телепортації завантажено  -  Client - TeleportationClient:535
  22:06:55.305  [DataStore] 🚀 Ініціалізація менеджера даних...  -  Server - DataStoreManager:472
  22:06:55.305  [DataStore] ✅ Менеджер даних ініціалізовано  -  Server - DataStoreManager:477
  22:06:57.346  [GameInit] 💾 Завантаження даних гравця: Sealord_75  -  Server - GameInit:324
  22:06:57.346  [DataStore] 💾 Завантаження даних гравця: Sealord_75 (ID: 8125377914 )  -  Server - DataStoreManager:244
  22:06:57.613  [DataStore] ✅ Знайдено існуючі дані для: Sealord_75  -  Server - DataStoreManager:249
  22:06:57.613  [DataStore] ℹ️ Дата приєднання: 2026-01-04 11:16:14  -  Server - DataStoreManager:252
  22:06:57.614  [GameInit] ✅ Дані гравця завантажено: Sealord_75  -  Server - GameInit:329
  22:06:57.614  [GameInit] ℹ️ Поточна планета: Planet_1  -  Server - GameInit:330
  22:06:57.614  [GameInit] ℹ️ Тип гравця: Existing - Sealord_75  -  Server - GameInit:511
  22:06:59.647  [GameInit] ✅ LocationManager завантажено  -  Server - GameInit:541
  22:06:59.647  [LocationFSM] Idle → Idle (Ініціалізація)  -  Server - LocationManager:118
  22:06:59.647  [Location] ✅ Менеджер локацій ініціалізовано  -  Server - LocationManager:628
  22:07:00.665  [Location] 🚀 Перехід з Deep Space на SpaceStation, орбіта: Planet_1  -  Server - LocationManager:455
  22:07:00.665  [LocationFSM] Idle → Idle (Початок переходу на КС)  -  Server - LocationManager:118
  22:07:00.665  [LocationFSM] Idle → Validating (Перевірка моделей КС)  -  Server - LocationManager:118
  22:07:00.666  [LocationFSM] ✅ Перевірено модель: Space/SpaceStation  -  Server - LocationManager:151
  22:07:00.666  [Location] 🧹 Очищення Workspace...  -  Server - LocationManager:480
  22:07:00.666  [LocationFSM] Validating → Cleaning (Clearing workspace)  -  Server - LocationManager:118
  22:07:00.666  [Location] 🧹 Очищення, об'єктів: 2  -  Server - LocationManager:165
  22:07:00.666  [Location] 💡 Об'єктів освітлення: 1  -  Server - LocationManager:188
  22:07:00.666  [Location] 🗑️ Видалено освітлення: Sky  -  Server - LocationManager:217
  22:07:00.666  [Location] ✅ Очищення завершено  -  Server - LocationManager:243
  22:07:01.180  [LocationFSM] Cleaning → LoadingPlanet (Завантаження планети Planet_1)  -  Server - LocationManager:118
  22:07:01.180  [Location] 📦 Завантаження планети Planet_1  -  Server - LocationManager:497
  22:07:01.180  [Location] 🪐 Planet loading now handled by EnvironmentLoader  -  Server - LocationManager:353
  22:07:01.180  [LocationFSM] LoadingPlanet → LoadingLocation (Завантаження КС)  -  Server - LocationManager:118
  22:07:01.180  [Location] 📦 Завантаження SpaceStation...  -  Server - LocationManager:513
  22:07:01.180  [Location] 🚀 Loading Space Station using EnvironmentLoader  -  Server - LocationManager:249
  22:07:01.183  [Location] 📋 LoadOrder configuration loaded for SpaceStation  -  Server - LocationManager:267
  22:07:01.183  [EnvironmentLoader] 🚀 Loading Space Environment for planet: Planet_1  -  Server - EnvironmentLoader:217
  22:07:01.183  [ObjectTypeValidator] 🔍 Validating planet structure: Planet_1 (v1.3 - LocationModel hierarchy)  -  Server - ObjectTypeValidator:129
  22:07:01.183  [ObjectTypeValidator] ❌ Planet structure validation failed:  -  Server - ObjectTypeValidator:176
  22:07:01.183    - [MISSING ATTRIBUTE] LocationModel.LocationId not set for Planet_1/Location_1  -  Server - ObjectTypeValidator:178
  22:07:01.183    - [INVALID ATTRIBUTE] LocationModel.LocationType should be 'Planet' for Planet_1/Location_1  -  Server - ObjectTypeValidator:178
  22:07:01.183    - [INVALID ATTRIBUTE] LocationModel.PlanetId should be 'Planet_1' for Planet_1/Location_1  -  Server - ObjectTypeValidator:178
  22:07:01.183    - [MISSING ATTRIBUTE] LocationModel.LocationId not set for Planet_1/Location_2  -  Server - ObjectTypeValidator:178
  22:07:01.183    - [INVALID ATTRIBUTE] LocationModel.LocationType should be 'Planet' for Planet_1/Location_2  -  Server - ObjectTypeValidator:178
  22:07:01.183    - [INVALID ATTRIBUTE] LocationModel.PlanetId should be 'Planet_1' for Planet_1/Location_2  -  Server - ObjectTypeValidator:178
  22:07:01.183    - [MISSING ATTRIBUTE] LocationModel.LocationId not set for Planet_1/Location_3  -  Server - ObjectTypeValidator:178
  22:07:01.183    - [INVALID ATTRIBUTE] LocationModel.LocationType should be 'Planet' for Planet_1/Location_3  -  Server - ObjectTypeValidator:178
  22:07:01.184    - [INVALID ATTRIBUTE] LocationModel.PlanetId should be 'Planet_1' for Planet_1/Location_3  -  Server - ObjectTypeValidator:178
  22:07:01.184  [EnvironmentLoader] ❌ Planet structure validation failed, attempting to fix...  -  Server - EnvironmentLoader:222
  22:07:01.184  [ObjectTypeValidator] 🔧 Fixing planet structure: Planet_1  -  Server - ObjectTypeValidator:367
  22:07:01.184  [ObjectTypeValidator] 🔧 Fixing location structure: Planet_1 / Location_1  -  Server - ObjectTypeValidator:401
  22:07:01.184  [ObjectTypeValidator] ✅ Set LocationId = Location_1  -  Server - ObjectTypeValidator:442
  22:07:01.184  [ObjectTypeValidator] ✅ Set LocationType = Planet  -  Server - ObjectTypeValidator:447
  22:07:01.184  [ObjectTypeValidator] ✅ Set PlanetId = Planet_1  -  Server - ObjectTypeValidator:452
  22:07:01.184  [ObjectTypeValidator] ✅ Set DisplayName = Location_1  -  Server - ObjectTypeValidator:457
  22:07:01.184  [ObjectTypeValidator] 🔧 Fixing location structure: Planet_1 / Location_2  -  Server - ObjectTypeValidator:401
  22:07:01.184  [ObjectTypeValidator] ✅ Set LocationId = Location_2  -  Server - ObjectTypeValidator:442
  22:07:01.184  [ObjectTypeValidator] ✅ Set LocationType = Planet  -  Server - ObjectTypeValidator:447
  22:07:01.184  [ObjectTypeValidator] ✅ Set PlanetId = Planet_1  -  Server - ObjectTypeValidator:452
  22:07:01.184  [ObjectTypeValidator] ✅ Set DisplayName = Location_2  -  Server - ObjectTypeValidator:457
  22:07:01.184  [ObjectTypeValidator] 🔧 Fixing location structure: Planet_1 / Location_3  -  Server - ObjectTypeValidator:401
  22:07:01.184  [ObjectTypeValidator] ✅ Set LocationId = Location_3  -  Server - ObjectTypeValidator:442
  22:07:01.184  [ObjectTypeValidator] ✅ Set LocationType = Planet  -  Server - ObjectTypeValidator:447
  22:07:01.184  [ObjectTypeValidator] ✅ Set PlanetId = Planet_1  -  Server - ObjectTypeValidator:452
  22:07:01.184  [ObjectTypeValidator] ✅ Set DisplayName = Location_3  -  Server - ObjectTypeValidator:457
  22:07:01.184  [ObjectTypeValidator] 🔍 Validating planet structure: Planet_1 (v1.3 - LocationModel hierarchy)  -  Server - ObjectTypeValidator:129
  22:07:01.184  [ObjectTypeValidator] ✅ Planet structure validation passed  -  Server - ObjectTypeValidator:182
  22:07:01.184  [ObjectTypeValidator] 🔍 Validating Space Station structure  -  Server - ObjectTypeValidator:284
  22:07:01.184      ✅ Scripts/Server - Folder  -  Server - ObjectTypeValidator:313
  22:07:01.184      ✅ Scripts/Client - Folder  -  Server - ObjectTypeValidator:313
  22:07:01.184        ✅ Server/PlanetSurfaceScanner - ModuleScript  -  Server - ObjectTypeValidator:325
  22:07:01.184        ✅ Client/SpaceStationUI - LocalScript  -  Server - ObjectTypeValidator:339
  22:07:01.184        ✅ Client/PlanetSurfaceScannerUI - LocalScript  -  Server - ObjectTypeValidator:339
  22:07:01.184  [ObjectTypeValidator] ✅ Space Station structure validation passed  -  Server - ObjectTypeValidator:360
  22:07:01.184  [EnvironmentLoader] 🧹 Clearing workspace...  -  Server - EnvironmentLoader:120
  22:07:01.185  [EnvironmentLoader] ✅ Workspace and Lighting cleared  -  Server - EnvironmentLoader:148
  22:07:01.185  [EnvironmentLoader] 📦 [1/1] Copied: Planet (Model) to Workspace  -  Server - EnvironmentLoader:178
  22:07:01.185  [EnvironmentLoader] ✅ Planet workspace loaded  -  Server - EnvironmentLoader:263
  22:07:01.185  [EnvironmentLoader] 📦 [1/1] Copied: Sky (Sky) to Lighting  -  Server - EnvironmentLoader:178
  22:07:01.185  [EnvironmentLoader] ✅ Planet lighting loaded  -  Server - EnvironmentLoader:273
  22:07:01.185  [EnvironmentLoader] 📋 SpaceStation Workspace contains: 1 objects  -  Server - EnvironmentLoader:354
  22:07:01.185  [EnvironmentLoader] ✅ LocationModel validated: Cosmic Research Station  -  Server - EnvironmentLoader:365
  22:07:01.190  [EnvironmentLoader] ✅ LocationModel copied to Workspace  -  Server - EnvironmentLoader:371
  22:07:01.190  [EnvironmentLoader] 📋 LocationModel contains:  -  Server - EnvironmentLoader:372
  22:07:01.190  [EnvironmentLoader]   📁 Architecture (14 items)  -  Server - EnvironmentLoader:375
  22:07:01.190  [EnvironmentLoader]   📁 Equipment (1 items)  -  Server - EnvironmentLoader:375
  22:07:01.190  [EnvironmentLoader]   📁 Environment (0 items)  -  Server - EnvironmentLoader:375
  22:07:01.190  [EnvironmentLoader]   📁 Gameplay (1 items)  -  Server - EnvironmentLoader:375
  22:07:01.190  [EnvironmentLoader] 📋 Processing 1 SpaceStation Server scripts with LoadOrder  -  Server - EnvironmentLoader:414
  22:07:01.191  [PlanetSurfaceScanner] 🚀 Initializing PlanetSurfaceScanner...  -  Server - PlanetSurfaceScanner:754
  22:07:01.191  [PlanetSurfaceScanner] 📦 Scanner model reference received: PlanetSurfaceScanner  -  Server - PlanetSurfaceScanner:755
  22:07:01.193  [Teleport] ✅ DataStoreManager завантажено  -  Server - TeleportationManager:83
  22:07:01.193  [PlanetSurfaceScanner] 📋 Configuration loaded:  -  Server - PlanetSurfaceScanner:760
  22:07:01.193    └─ SCAN_DURATION: 2  -  Server - PlanetSurfaceScanner:761
  22:07:01.193    └─ INTERACTION_DISTANCE: 10  -  Server - PlanetSurfaceScanner:762
  22:07:01.193    └─ PULSE_SPEED: 2  -  Server - PlanetSurfaceScanner:763
  22:07:01.193  [PlanetSurfaceScanner] 🔍 Looking for scanner components:  -  Server - PlanetSurfaceScanner:771
  22:07:01.193    └─ ScannerBaseplate: ✅ FOUND  -  Server - PlanetSurfaceScanner:772
  22:07:01.193    └─ ScannerDisplay: ✅ FOUND  -  Server - PlanetSurfaceScanner:773
  22:07:01.193    └─ ScannerScreen: ✅ FOUND  -  Server - PlanetSurfaceScanner:774
  22:07:01.193  [PlanetSurfaceScanner] ✅ RemoteEvent отримано з реєстру: PlanetSurfaceScanner_Results  -  Server - PlanetSurfaceScanner:795
  22:07:01.193  [PlanetSurfaceScanner] ✅ Set planet name: Zalizyaka  -  Server - PlanetSurfaceScanner:820
  22:07:01.193  [PlanetSurfaceScanner] 🔄 Player monitoring started  -  Server - PlanetSurfaceScanner:689
  22:07:01.194    └─ Checking for players every 0.3s  -  Server - PlanetSurfaceScanner:690
  22:07:01.194    └─ INTERACTION_DISTANCE: 10  -  Server - PlanetSurfaceScanner:691
  22:07:01.194    └─ ScannerBaseplate position: 211.39849853515625, -468.5, 192.4146270751953  -  Server - PlanetSurfaceScanner:692
  22:07:01.194  [PlanetSurfaceScanner] ✅ PlanetSurfaceScanner initialized successfully  -  Server - PlanetSurfaceScanner:834
  22:07:01.194  [EnvironmentLoader] ✅ [1/1] Required & Initialized: PlanetSurfaceScanner  -  Server - EnvironmentLoader:467
  22:07:01.194  [EnvironmentLoader] ✅ [1/2] Copied: ServerStorage.Space.SpaceStation.Scripts.Client.PlanetSurfaceScannerUI → Sealord_75/PlayerGui/PlanetSurfaceScannerUI  -  Server - EnvironmentLoader:515
  22:07:01.194  [EnvironmentLoader] ✅ [2/2] Copied: ServerStorage.Space.SpaceStation.Scripts.Client.SpaceStationUI → Sealord_75/PlayerGui/SpaceStationUI  -  Server - EnvironmentLoader:515
  22:07:01.194  [EnvironmentLoader] ✅ Space Station scripts processed  -  Server - EnvironmentLoader:525
  22:07:01.194  [EnvironmentLoader] 📊 Verification: 2/2 objects loaded  -  Server - EnvironmentLoader:210
  22:07:01.194  [EnvironmentLoader] ✅ Space Environment loaded successfully  -  Server - EnvironmentLoader:545
  22:07:01.195  [ClientScriptInitializer] 🚀 Initializing client scripts...  -  Server - ClientScriptInitializer:123
  22:07:01.195    └─ Location: SpaceStation, Planet: Planet_1, LocationId: N/A  -  Server - ClientScriptInitializer:129
  22:07:01.195  [ClientScriptInitializer] ℹ️ TeleportationClient - no Initialize() function  -  Server - ClientScriptInitializer:153
  22:07:01.195  [ClientScriptInitializer] ℹ️ PlayerScriptsLoader - no Initialize() function  -  Server - ClientScriptInitializer:153
  22:07:01.195  [ClientScriptInitializer] ℹ️ RbxCharacterSounds - no Initialize() function  -  Server - ClientScriptInitializer:153
  22:07:01.195  [ClientScriptInitializer] 🎉 Initialized 0/4 client scripts  -  Server - ClientScriptInitializer:158
  22:07:01.195  [Location] ✅ LocationModel позиціоновано at Y=-450  -  Server - LocationManager:288
  22:07:01.195    └─ LocationModel.PrimaryPart: 0, -450, 0  -  Server - LocationManager:289
  22:07:01.195    └─ SpawnLocation (inside LocationModel/Gameplay): 3.6722412109375, -444.4411926269531, 14.06536865234375  -  Server - LocationManager:295
  22:07:01.195  [Location] 🔒 SpawnLocation приховано до першого сканування планети  -  Server - LocationManager:305
  22:07:01.195    └─ Section Architecture: 14 items  -  Server - LocationManager:314
  22:07:01.195    └─ Section Equipment: 1 items  -  Server - LocationManager:314
  22:07:01.195    └─ Section Environment: 0 items  -  Server - LocationManager:314
  22:07:01.195    └─ Section Gameplay: 1 items  -  Server - LocationManager:314
  22:07:01.195    └─ PlanetSurfaceScanner (inside SpaceStation): 16.086868286132812, -444.4411926269531, 85.6668701171875  -  Server - LocationManager:323
  22:07:01.196  [Location] ✅ Космічну станцію завантажено  -  Server - LocationManager:343
  22:07:01.196  [LocationFSM] LoadingLocation → Verifying (Перевірка готовності КС)  -  Server - LocationManager:118
  22:07:01.196  [LocationFSM] Verifying → Ready (КС готова)  -  Server - LocationManager:118
  22:07:01.196  [Location] ✅ Перехід на SpaceStation завершено  -  Server - LocationManager:539
  22:07:01.280  [PlanetSurfaceScannerUI] 📡 Initializing Scanner UI for model: PlanetSurfaceScanner  -  Client - PlanetSurfaceScannerUI:491
  22:07:01.280  [SpaceStationUI] 🚀 Initializing Station UI...  -  Client - SpaceStationUI:486
  22:07:01.280  [SpaceStationUI] ✅ Status bar created successfully  -  Client - SpaceStationUI:470
  22:07:03.196  [GameInit] 🔄 Підготовка появи гравця: Sealord_75  -  Server - GameInit:341
  22:07:03.747  [GameInit] ✅ Гравець з'явився на Космічній Станції  -  Server - GameInit:408
  22:07:03.747    └─ SpawnLocation: 3.6722412109375, -444.4411926269531, 14.06536865234375  -  Server - GameInit:409
  22:07:03.747    └─ Гравець (HumanoidRootPart): 3.6722412109375, -442.4411926269531, 14.06536865234375  -  Server - GameInit:410
  22:07:03.747    └─ LocationModel PrimaryPart: 0, -450, 0  -  Server - GameInit:415
  22:07:03.783  [PlanetSurfaceScannerUI] ✅ Scanner UI initialized successfully  -  Client - PlanetSurfaceScannerUI:541
  22:07:03.783  [PlanetSurfaceScannerUI] ✅ Ініціалізовано для LocationModel.Equipment.PlanetSurfaceScanner  -  Client - PlanetSurfaceScannerUI:711
  22:07:04.264  [GameInit] ✅ Гравця повністю завантажено: Sealord_75  -  Server - GameInit:588
  22:07:04.315   ▶ [PlanetSurfaceScanner] 🔍 Sealord_75 distance: 72.7 (threshold: 10) (x2)  -  Server - PlanetSurfaceScanner:708
  22:07:10.547  [PlanetSurfaceScanner] 🔍 Sealord_75 distance: 70.2 (threshold: 10)  -  Server - PlanetSurfaceScanner:708
  22:07:13.680  [PlanetSurfaceScanner] 🔍 Sealord_75 distance: 61.3 (threshold: 10)  -  Server - PlanetSurfaceScanner:708
  22:07:16.763  [PlanetSurfaceScanner] 🔍 Sealord_75 distance: 34.2 (threshold: 10)  -  Server - PlanetSurfaceScanner:708
  22:07:19.862  [PlanetSurfaceScanner] 🔍 Sealord_75 distance: 24.2 (threshold: 10)  -  Server - PlanetSurfaceScanner:708
  22:07:22.947  [PlanetSurfaceScanner] 🔍 Sealord_75 distance: 31.0 (threshold: 10)  -  Server - PlanetSurfaceScanner:708
  22:07:24.495  [PlanetSurfaceScanner] 👤 Sealord_75 entered scanner baseplate  -  Server - PlanetSurfaceScanner:715
  22:07:24.495  [PlanetSurfaceScanner] 🔍 Starting scan for Sealord_75 (first time scanner use: false)  -  Server - PlanetSurfaceScanner:537
  22:07:24.496  [PlanetSurfaceScanner] 🟢 Scanner activated  -  Server - PlanetSurfaceScanner:624
  22:07:26.062  [PlanetSurfaceScanner] 🔍 Sealord_75 distance: 3.7 (threshold: 10)  -  Server - PlanetSurfaceScanner:708
  22:07:26.529  [PlanetSurfaceScanner] ✅ Scan completed for Sealord_75  -  Server - PlanetSurfaceScanner:577
  22:07:26.530  [PlanetSurfaceScanner] 🚀 Initializing TeleportationManager...  -  Server - PlanetSurfaceScanner:216
  22:07:26.530  [PlanetSurfaceScanner] ✅ RemoteEvents отримано з реєстру  -  Server - PlanetSurfaceScanner:227
  22:07:26.530  [TeleportationManager] 🚀 Initializing Teleportation System...  -  Server - TeleportationManager:1008
  22:07:26.530  [TeleportationManager] 📋 Initial workspace state:  -  Server - TeleportationManager:1009
  22:07:26.530  [TeleportationManager] 🔍 Searching for SpawnLocation...  -  Server - TeleportationManager:141
  22:07:26.530  [TeleportationManager] ✅ Found SpawnLocation in LocationModel/Gameplay: Workspace.LocationModel.Gameplay.SpawnLocation  -  Server - TeleportationManager:162
  22:07:26.530  [TeleportationManager] ✅ SpawnLocation initialized: Workspace.LocationModel.Gameplay.SpawnLocation  -  Server - TeleportationManager:227
  22:07:26.530  [TeleportationManager] Отримання RemoteEvents з реєстру...  -  Server - TeleportationManager:1020
  22:07:26.530  [TeleportationManager] ✅ RemoteEvents отримано з реєстру  -  Server - TeleportationManager:1028
  22:07:26.530  [TeleportationManager]   - TeleportationEvent: true  -  Server - TeleportationManager:1029
  22:07:26.530  [TeleportationManager]   - TeleportationStateEvent: true  -  Server - TeleportationManager:1030
  22:07:26.531  [TeleportationManager] Connected initial events to SpawnLocation: Workspace.LocationModel.Gameplay.SpawnLocation  -  Server - TeleportationManager:1065
  22:07:26.531  [TeleportationManager] ✅ RemoteEvent OnServerEvent CONNECTED to onTeleportRequest  -  Server - TeleportationManager:1069
  22:07:26.531  [TeleportationManager] 🔍 Searching for SpawnLocation...  -  Server - TeleportationManager:141
  22:07:26.531  [TeleportationManager] ✅ Found SpawnLocation in LocationModel/Gameplay: Workspace.LocationModel.Gameplay.SpawnLocation  -  Server - TeleportationManager:162
  22:07:26.531  [TeleportationManager] 🔍 Checking spawn location - current: Workspace.LocationModel.Gameplay.SpawnLocation, new: Workspace.LocationModel.Gameplay.SpawnLocation  -  Server - TeleportationManager:238
  22:07:26.531  [TeleportationManager] ℹ️ SpawnLocation unchanged: Workspace.LocationModel.Gameplay.SpawnLocation  -  Server - TeleportationManager:266
  22:07:26.531  [Teleport] 🔒 Телепортація прихована до першого сканування планети  -  Server - TeleportationManager:295
  22:07:26.531  [Teleport] ✅ Систему телепортації ініціалізовано  -  Server - TeleportationManager:1077
  22:07:26.531  [PlanetSurfaceScanner] ✅ TeleportationManager initialized successfully  -  Server - PlanetSurfaceScanner:235
  22:07:27.545  [PlanetSurfaceScanner] 📡 Notified clients that teleportation system is ready  -  Server - PlanetSurfaceScanner:240
  22:07:27.545  [PlanetSurfaceScanner] 🚀 TELEPORTATION SYSTEM ACTIVATED - Discovered locations found  -  Server - PlanetSurfaceScanner:257
  22:07:27.545  [Teleport] 🔄 Телепортацію АКТИВОВАНО : Sealord_75  -  Server - TeleportationManager:987
  22:07:27.546  [TeleportationManager] 🔍 Searching for SpawnLocation...  -  Server - TeleportationManager:141
  22:07:27.546  [TeleportationManager] ✅ Found SpawnLocation in LocationModel/Gameplay: Workspace.LocationModel.Gameplay.SpawnLocation  -  Server - TeleportationManager:162
  22:07:27.546  [TeleportationManager] 🔍 Checking spawn location - current: Workspace.LocationModel.Gameplay.SpawnLocation, new: Workspace.LocationModel.Gameplay.SpawnLocation  -  Server - TeleportationManager:238
  22:07:27.546  [TeleportationManager] ℹ️ SpawnLocation unchanged: Workspace.LocationModel.Gameplay.SpawnLocation  -  Server - TeleportationManager:266
  22:07:27.546  [TeleportationManager] 🔗 Reconnected Touched/TouchEnded events during activation  -  Server - TeleportationManager:331
  22:07:27.546  [Teleport] 🟢 Телепортація АКТИВНА  -  Server - TeleportationManager:362
  22:07:27.546  [TeleportationManager] ✅ SpawnLocation should now be BLUE and PULSING  -  Server - TeleportationManager:991
  22:07:27.546  [TeleportationManager] 📡 Sent state change to Sealord_75: true  -  Server - TeleportationManager:1001
  22:07:27.579   ▶ [TeleportClient] 🔄 Стан системи: АКТИВНА (x2)  -  Client - TeleportationClient:523
  22:07:29.145  [PlanetSurfaceScanner] 🔍 Sealord_75 distance: 5.8 (threshold: 10)  -  Server - PlanetSurfaceScanner:708
  22:07:30.679  [PlanetSurfaceScanner] Sealord_75 left scanner baseplate  -  Server - PlanetSurfaceScanner:725
  22:07:30.679  [PlanetSurfaceScanner] 🔴 Scanner deactivated  -  Server - PlanetSurfaceScanner:646
  22:07:32.229  [PlanetSurfaceScanner] 🔍 Sealord_75 distance: 22.3 (threshold: 10)  -  Server - PlanetSurfaceScanner:708
  22:07:34.697  [PlanetSurfaceScanner] 👤 Sealord_75 entered scanner baseplate  -  Server - PlanetSurfaceScanner:715
  22:07:34.697  [PlanetSurfaceScanner] 🔍 Starting scan for Sealord_75 (first time scanner use: false)  -  Server - PlanetSurfaceScanner:537
  22:07:34.697  [PlanetSurfaceScanner] 🟢 Scanner activated  -  Server - PlanetSurfaceScanner:624
  22:07:35.329  [PlanetSurfaceScanner] 🔍 Sealord_75 distance: 4.8 (threshold: 10)  -  Server - PlanetSurfaceScanner:708
  22:07:36.713  [PlanetSurfaceScanner] ✅ Scan completed for Sealord_75  -  Server - PlanetSurfaceScanner:577
  22:07:38.445  [PlanetSurfaceScanner] 🔍 Sealord_75 distance: 3.6 (threshold: 10)  -  Server - PlanetSurfaceScanner:708
  22:07:39.378  [PlanetSurfaceScanner] Sealord_75 left scanner baseplate  -  Server - PlanetSurfaceScanner:725
  22:07:39.379  [PlanetSurfaceScanner] 🔴 Scanner deactivated  -  Server - PlanetSurfaceScanner:646
  22:07:41.595  [PlanetSurfaceScanner] 🔍 Sealord_75 distance: 29.9 (threshold: 10)  -  Server - PlanetSurfaceScanner:708
  22:07:42.411  [TeleportationManager] Sealord_75 entered SpawnLocation - first time  -  Server - TeleportationManager:650
  22:07:42.411  [TeleportationManager] ✅ Teleportation is active - showing UI for Sealord_75  -  Server - TeleportationManager:654
  22:07:42.411  [TeleportationManager] ❌ PlayerScripts NOT found for Sealord_75  -  Server - TeleportationManager:669
  22:07:42.411    └─ Очікуваний шлях: Players/Sealord_75/PlayerScripts  -  Server - TeleportationManager:670
  22:07:42.411    └─ Гравець можливо ще не повністю завантажився  -  Server - TeleportationManager:671
  22:07:42.411  [TeleportationManager] ℹ️ Player is on Space Station - not adding to available locations  -  Server - TeleportationManager:705
  22:07:42.411  [TeleportationManager] 📋 Discovered locations count: 3  -  Server - TeleportationManager:710
  22:07:42.411  [TeleportationManager] 📋 Checking location: Манівці (Location_1)  -  Server - TeleportationManager:712
  22:07:42.411  [TeleportationManager] ❌ Planet_1 template not found  -  Server - TeleportationManager:740
  22:07:42.412    └─ Очікуваний шлях: ServerStorage/Planet_1  -  Server - TeleportationManager:741
  22:07:42.412  [TeleportationManager] 📋 Checking location: Садочок (Location_1)  -  Server - TeleportationManager:712
  22:07:42.412  [TeleportationManager] ❌ Planet_1 template not found  -  Server - TeleportationManager:740
  22:07:42.412    └─ Очікуваний шлях: ServerStorage/Planet_1  -  Server - TeleportationManager:741
  22:07:42.412  [TeleportationManager] 📋 Checking location: Канапка (Location_3)  -  Server - TeleportationManager:712
  22:07:42.412  [TeleportationManager] ❌ Planet_1 template not found  -  Server - TeleportationManager:740
  22:07:42.412    └─ Очікуваний шлях: ServerStorage/Planet_1  -  Server - TeleportationManager:741
  22:07:42.446  [TeleportClient] 📥 Подія: ShowTeleportUI  -  Client - TeleportationClient:452
  22:07:42.446  [TeleportClient] 📺 Показую UI телепортації для: Sealord_75  -  Client - TeleportationClient:467
  22:07:42.728  [TeleportationManager] ⏱️ UI debounce cleared for Sealord_75  -  Server - TeleportationManager:685
  22:07:42.762  [TeleportClient] ✅ Подію оброблено: ShowTeleportUI  -  Client - TeleportationClient:518
  22:07:42.962  [TeleportationManager] ✅ Teleportation is active - showing UI for Sealord_75  -  Server - TeleportationManager:654
  22:07:42.962  [TeleportationManager] ❌ PlayerScripts NOT found for Sealord_75  -  Server - TeleportationManager:669
  22:07:42.963    └─ Очікуваний шлях: Players/Sealord_75/PlayerScripts  -  Server - TeleportationManager:670
  22:07:42.963    └─ Гравець можливо ще не повністю завантажився  -  Server - TeleportationManager:671
  22:07:42.963  [TeleportationManager] ℹ️ Player is on Space Station - not adding to available locations  -  Server - TeleportationManager:705
  22:07:42.964  [TeleportationManager] 📋 Discovered locations count: 3  -  Server - TeleportationManager:710
  22:07:42.964  [TeleportationManager] 📋 Checking location: Манівці (Location_1)  -  Server - TeleportationManager:712
  22:07:42.964  [TeleportationManager] ❌ Planet_1 template not found  -  Server - TeleportationManager:740
  22:07:42.964    └─ Очікуваний шлях: ServerStorage/Planet_1  -  Server - TeleportationManager:741
  22:07:42.964  [TeleportationManager] 📋 Checking location: Садочок (Location_1)  -  Server - TeleportationManager:712
  22:07:42.964  [TeleportationManager] ❌ Planet_1 template not found  -  Server - TeleportationManager:740
  22:07:42.964    └─ Очікуваний шлях: ServerStorage/Planet_1  -  Server - TeleportationManager:741
  22:07:42.964  [TeleportationManager] 📋 Checking location: Канапка (Location_3)  -  Server - TeleportationManager:712
  22:07:42.964  [TeleportationManager] ❌ Planet_1 template not found  -  Server - TeleportationManager:740
  22:07:42.964    └─ Очікуваний шлях: ServerStorage/Planet_1  -  Server - TeleportationManager:741
  22:07:42.978  [TeleportClient] 📥 Подія: ShowTeleportUI  -  Client - TeleportationClient:452
  22:07:42.978  [TeleportClient] 📺 Показую UI телепортації для: Sealord_75  -  Client - TeleportationClient:467
  22:07:43.278  [TeleportationManager] ⏱️ UI debounce cleared for Sealord_75  -  Server - TeleportationManager:685
  22:07:43.395  [TeleportClient] ✅ Подію оброблено: ShowTeleportUI  -  Client - TeleportationClient:518
  22:07:44.712  [PlanetSurfaceScanner] 🔍 Sealord_75 distance: 52.1 (threshold: 10)  -  Server - PlanetSurfaceScanner:708
  22:07:47.915  Disconnect from 127.0.0.1|61414  -  Studio
  22:07:47.915  [PlanetSurfaceScanner] 🔍 Sealord_75 distance: 52.1 (threshold: 10)  -  Server - PlanetSurfaceScanner:708
  22:07:47.917  [DataStore] 👤 Гравець виходить: Sealord_75  -  Server - DataStoreManager:458
  22:07:47.917  [DataStore] 🔄 Завершення роботи, збереження всіх даних...  -  Server - DataStoreManager:482
  22:07:47.917  [DataStore] ✅ Всі дані збережено  -  Server - DataStoreManager:500
  22:07:48.362  [DataStore] ✅ Дані збережено для: Sealord_75  -  Server - DataStoreManager:385
  22:07:48.362  [DataStore] ✅ Дані збережено при виході: Sealord_75  -  Server - DataStoreManager:464