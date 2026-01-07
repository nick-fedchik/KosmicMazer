--[[
================================================================================
KOSMICMAZER — Game Init
================================================================================

Purpose: Complete game initialization with intelligent player data handling
Version: 3.5

Features:
- Player Login Screen with progress bar and avatar display
- Intelligent player data loading and type detection
- Dynamic environment preparation based on player data
- Planet-specific world loading
- Player spawning coordination
- Comprehensive workspace cleanup

API:
- createLoginScreen(player): Creates player login GUI
- loadPlayerData(player): Loads player data from DataStore
- prepareGameEnvironment(playerProfile): Prepares game world
- spawnPlayer(player, playerProfile): Spawns player in world
- cleanupWorkspace(): Cleans up previous session components
- initializeGameSystem(): Initializes core systems

Calls to:
- DataStoreManager: LoadPlayerData(), UpdatePlayerData(), Initialize()
- PlayerDataManager: GetPlayerInfo()
- GameConfig: Reads planet and game configuration
- LocationManager: Initialize() for location switching
- TeleportationManager: Initialize() for teleportation system
- TweenService: Creates UI animations

Called from:
- Automatic execution on server start
- Players.PlayerAdded event

Events:
- Players.PlayerAdded: Triggers player initialization flow

Dependencies:
- GameConfig module
- DataStoreManager module
- PlayerDataManager module
- Players service
- ServerStorage service
- ReplicatedStorage service
- TweenService

ChangeLog:
- Version 3.6: CRITICAL - Added TeleportationManager initialization in initializeGameSystem()
- Version 3.5: CRITICAL - Updated to use LocationManager as ModuleScript (v2.0)
- Version 3.5: ENHANCED - Added LocationManager.Initialize() call in initializeGameSystem()
- Version 3.4: Updated header format to comply with CODE CONVENTION section 14
- Version 3.3: Added player type detection and improved data handling
- Version 3.2: Enhanced login screen with avatar and animations
- Version 3.1: Added comprehensive workspace cleanup
- Version 3.0: Complete rewrite with modular architecture
- Initial implementation for game initialization

================================================================================
]]

local Players = game:GetService("Players")
Players.CharacterAutoLoads = false

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Load modules
local GameConfig = require(script.Parent:FindFirstChild("GameConfig"))
local DataStoreManager = require(script.Parent:FindFirstChild("DataStoreManager"))
local PlayerDataManager = require(script.Parent:FindFirstChild("PlayerDataManager"))



-- Game state
local gameState = {
	initialized = false,
	currentLocation = "SpaceStation",
	loadingPlayers = {} -- Track players currently loading
}

-- Create Player Login Screen programmatically (2.1)
local function createBootScreen(player)
	print("[GameInit] 🖼️ Створення екрану завантаження для:", player.Name)

	-- Remove any existing LoginGui first
	local playerGui = player:WaitForChild("PlayerGui")
	local existingGui = playerGui:FindFirstChild("LoginGui")
	if existingGui then
		existingGui:Destroy()
	end

	-- Create ScreenGui
	local loginGui = Instance.new("ScreenGui")
	loginGui.Name = "LoginGui"
	loginGui.ResetOnSpawn = false
	loginGui.IgnoreGuiInset = true
	loginGui.Parent = playerGui

	-- Create MainFrame
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(1, 0, 1, 0)
	mainFrame.Position = UDim2.new(0, 0, 0, 0)
	mainFrame.BackgroundColor3 = Color3.new(0.05, 0.05, 0.1)
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = loginGui

	-- Create Game Title
	local gameTitle = Instance.new("TextLabel")
	gameTitle.Name = "GameTitle"
	gameTitle.Size = UDim2.new(0, 400, 0, 60)
	gameTitle.Position = UDim2.new(0.5, -200, 0.2, -30)
	gameTitle.BackgroundTransparency = 1
	gameTitle.Text = GameConfig.GameName .. " v" .. GameConfig.GameVersion
	gameTitle.TextColor3 = Color3.new(1, 1, 1)
	gameTitle.TextScaled = true
	gameTitle.Font = Enum.Font.GothamBold
	gameTitle.Parent = mainFrame

	-- Create Player Avatar Container
	local avatarContainer = Instance.new("Frame")
	avatarContainer.Name = "AvatarContainer"
	avatarContainer.Size = UDim2.new(0, 150, 0, 180)
	avatarContainer.Position = UDim2.new(0.5, -75, 0.25, 0)
	avatarContainer.BackgroundColor3 = Color3.new(0.1, 0.1, 0.2)
	avatarContainer.BorderSizePixel = 2
	avatarContainer.BorderColor3 = Color3.new(0.2, 0.6, 1)
	avatarContainer.Parent = mainFrame

	-- Add rounded corners to avatar container
	local avatarCorner = Instance.new("UICorner")
	avatarCorner.CornerRadius = UDim.new(0, 10)
	avatarCorner.Parent = avatarContainer

	-- Create Avatar Image
	local avatarImage = Instance.new("ImageLabel")
	avatarImage.Name = "AvatarImage"
	avatarImage.Size = UDim2.new(0, 120, 0, 120)
	avatarImage.Position = UDim2.new(0.5, -60, 0, 10)
	avatarImage.BackgroundTransparency = 1
	avatarImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
	avatarImage.Parent = avatarContainer

	-- Add rounded corners to avatar
	local avatarImageCorner = Instance.new("UICorner")
	avatarImageCorner.CornerRadius = UDim.new(0, 60)
	avatarImageCorner.Parent = avatarImage

	-- Create Player Name Label (moved down to accommodate avatar)
	local playerNameLabel = Instance.new("TextLabel")
	playerNameLabel.Name = "PlayerNameLabel"
	playerNameLabel.Size = UDim2.new(0, 300, 0, 40)
	playerNameLabel.Position = UDim2.new(0.5, -150, 0.45, -20)
	playerNameLabel.BackgroundTransparency = 1
	playerNameLabel.Text = "Гравець: " .. player.Name
	playerNameLabel.TextColor3 = Color3.new(0.8, 0.8, 1)
	playerNameLabel.TextScaled = true
	playerNameLabel.Font = Enum.Font.Gotham
	playerNameLabel.Parent = mainFrame

	-- Create Loading Label (moved down)
	local loadingLabel = Instance.new("TextLabel")
	loadingLabel.Name = "LoadingLabel"
	loadingLabel.Size = UDim2.new(0, 400, 0, 30)
	loadingLabel.Position = UDim2.new(0.5, -200, 0.55, -15)
	loadingLabel.BackgroundTransparency = 1
	loadingLabel.Text = "Завантаження..."
	loadingLabel.TextColor3 = Color3.new(0.6, 0.8, 1)
	loadingLabel.TextScaled = true
	loadingLabel.Font = Enum.Font.Gotham
	loadingLabel.Parent = mainFrame

	-- Create Progress Bar Container (moved down)
	local progressBar = Instance.new("Frame")
	progressBar.Name = "ProgressBar"
	progressBar.Size = UDim2.new(0, 400, 0, 20)
	progressBar.Position = UDim2.new(0.5, -200, 0.65, -10)
	progressBar.BackgroundColor3 = Color3.new(0.1, 0.1, 0.2)
	progressBar.BorderSizePixel = 0
	progressBar.Parent = mainFrame

	-- Add rounded corners to progress bar
	local progressCorner = Instance.new("UICorner")
	progressCorner.CornerRadius = UDim.new(0, 10)
	progressCorner.Parent = progressBar

	-- Create Progress Fill
	local progressFill = Instance.new("Frame")
	progressFill.Name = "ProgressFill"
	progressFill.Size = UDim2.new(0, 0, 1, 0)
	progressFill.Position = UDim2.new(0, 0, 0, 0)
	progressFill.BackgroundColor3 = Color3.new(0.2, 0.6, 1)
	progressFill.BorderSizePixel = 0
	progressFill.Parent = progressBar

	-- Add rounded corners to progress fill
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 10)
	fillCorner.Parent = progressFill

	-- Create Progress Label (moved down)
	local progressLabel = Instance.new("TextLabel")
	progressLabel.Name = "ProgressLabel"
	progressLabel.Size = UDim2.new(0, 400, 0, 30)
	progressLabel.Position = UDim2.new(0.5, -200, 0.7, -15)
	progressLabel.BackgroundTransparency = 1
	progressLabel.Text = "Ініціалізація... 0%"
	progressLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
	progressLabel.TextScaled = true
	progressLabel.Font = Enum.Font.Gotham
	progressLabel.Parent = mainFrame

	-- Create decorative elements (repositioned)
	local decoration1 = Instance.new("ImageLabel")
	decoration1.Name = "Decoration1"
	decoration1.Size = UDim2.new(0, 80, 0, 80)
	decoration1.Position = UDim2.new(0.1, 0, 0.8, 0)
	decoration1.BackgroundTransparency = 1
	decoration1.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png" 
	decoration1.ImageColor3 = Color3.new(0.2, 0.4, 0.8)
	decoration1.ImageTransparency = 0.5
	decoration1.Rotation = 45
	decoration1.Parent = mainFrame

	local decoration2 = Instance.new("ImageLabel")
	decoration2.Name = "Decoration2"
	decoration2.Size = UDim2.new(0, 60, 0, 60)
	decoration2.Position = UDim2.new(0.85, -60, 0.85, 0)
	decoration2.BackgroundTransparency = 1
	decoration2.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
	decoration2.ImageColor3 = Color3.new(0.4, 0.2, 0.8)
	decoration2.ImageTransparency = 0.5
	decoration2.Rotation = -30
	decoration2.Parent = mainFrame

	-- Animate avatar appearance
	local function animateAvatar()
		if avatarImage then
			-- Fade in animation
			avatarImage.ImageTransparency = 1
			local fadeIn = TweenService:Create(
				avatarImage,
				TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ImageTransparency = 0}
			)
			fadeIn:Play()

			-- Subtle scale animation
			local scaleUp = TweenService:Create(
				avatarImage,
				TweenInfo.new(1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
				{Size = UDim2.new(0, 120, 0, 120)}
			)
			scaleUp:Play()
		end

		if avatarContainer then
			-- Animate container appearance
			avatarContainer.BackgroundTransparency = 1
			local containerFadeIn = TweenService:Create(
				avatarContainer,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{BackgroundTransparency = 0}
			)
			containerFadeIn:Play()
		end
	end

	-- Start avatar animation
	task.spawn(animateAvatar)

	print("[GameInit] ✅ Екран завантаження створено")
	return loginGui
end

-- Update loading progress
local function updateBootProgress(loginGui, progress, text)
	if not loginGui then return end

	local mainFrame = loginGui:FindFirstChild("MainFrame")
	if not mainFrame then return end

	local progressBar = mainFrame:FindFirstChild("ProgressBar")
	if not progressBar then return end

	local progressFill = progressBar:FindFirstChild("ProgressFill")
	local progressLabel = mainFrame:FindFirstChild("ProgressLabel")

	if progressFill then
		local tween = TweenService:Create(
			progressFill,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Size = UDim2.new(progress, 0, 1, 0)}
		)
		tween:Play()
	end

	if progressLabel then
		progressLabel.Text = text .. " " .. math.floor(progress * 100) .. "%"
	end
end

-- Load player data (2.2)
local function loadPlayerData(player)
	print("[GameInit] 💾 Завантаження даних гравця:", player.Name)

	local playerProfile = DataStoreManager.LoadPlayerData(player)

	if playerProfile then
		print("[GameInit] ✅ Дані гравця завантажено:", player.Name)
		print("[GameInit] ℹ️ Поточна планета:", playerProfile.CurrentPlanet)
		return playerProfile
	else
		warn("[GameInit] ⚠️ Не вдалося завантажити дані для:", player.Name)
		return nil
	end
end


-- Spawn player (2.5)
local function spawnPlayer(player, playerProfile)
	print("[GameInit] 🔄 Підготовка появи гравця:", player.Name)

	-- Wait for player to be in the world
	if not player.Parent then
		player:GetPropertyChangedSignal("Parent"):Wait()
	end

	-- Load character
	if not player.Character then
		player:LoadCharacter()
	end

	-- Wait for character to be ready
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)

	if not humanoidRootPart then
		warn("[GameInit] HumanoidRootPart not found")
		warn("  └─ Гравець: " .. player.Name)
		warn("  └─ Очікуваний шлях: Players/" .. player.Name .. "/Character/HumanoidRootPart")
		warn("  └─ Можливо персонаж не завантажився за 5 секунд")
		return
	end

	-- Find SpawnLocation in Workspace (should be loaded by LocationManager)
	-- LocationManager.SwitchToSpaceStation() calls EnvironmentLoader.LoadSpaceEnvironment()
	-- which copies SpawnLocation from ServerStorage to Workspace
	local spawnLocation = nil
	
	-- Try to find in SpaceStation folder first
	local spaceStation = game.Workspace:FindFirstChild("SpaceStation")
	if spaceStation then
		spawnLocation = spaceStation:FindFirstChild("SpawnLocation")
	end
	
	-- If not in SpaceStation folder, try root Workspace
	if not spawnLocation then
		spawnLocation = game.Workspace:FindFirstChild("SpawnLocation")
	end

	if spawnLocation and spawnLocation:IsA("SpawnLocation") then
		humanoidRootPart.CFrame = spawnLocation.CFrame * CFrame.new(0, 2, 0)
		player:SetAttribute("CurrentLocation", "SpaceStation")

		if playerProfile then
			playerProfile.LastSpawnLocation = {
				Type = "SpaceStation",
				CFrame = spawnLocation.CFrame
			}
		end
		print("[GameInit] ✅ Гравець з'явився на Космічній Станції")
		print("  └─ Позиція: " .. tostring(spawnLocation.CFrame.Position))
	else
		warn("[GameInit] ❌ SpawnLocation не знайдено в Workspace після завантаження")
		warn("  └─ Перевірено шляхи:")
		warn("    • Workspace/SpaceStation/SpawnLocation")
		warn("    • Workspace/SpawnLocation")
		warn("  └─ LocationManager має завантажити SpawnLocation перед викликом spawnPlayer()")
		warn("  └─ Використовується позиція за замовчуванням (0, 10, 0)")
		-- Fallback to default position (higher up to avoid falling)
		humanoidRootPart.CFrame = CFrame.new(0, 10, 0)
		-- Set current location attribute even for fallback
		player:SetAttribute("CurrentLocation", "SpaceStation")
	end

	-- Wait a bit to ensure character is fully loaded
	task.wait(0.5)
end

-- Handle player joining (Complete Player Pre-Spawn flow)
local function onPlayerAdded(player)
	print("[GameInit] 👤 Гравець приєднався:", player.Name)

	-- Mark player as loading
	gameState.loadingPlayers[player.UserId] = true

	-- Create login screen
	local loginGui = createBootScreen(player)


	-- Stage 1. Initialize Game DataStore Manager
	updateBootProgress(loginGui, 0.1, "Ініціалізація сховища даних...")
	DataStoreManager.Initialize()
	task.wait(1)

	-- Stage 2. Load player profile
	updateBootProgress(loginGui, 0.2, "Завантаження профілю...")
	task.wait(1)
	local playerProfile = loadPlayerData(player)


	-- Stage 3. Create new player profile
	if not playerProfile then
		updateBootProgress(loginGui, 0.3, "Створення нового профілю...")
		task.wait(1)
		warn("[GameInit] ⚠️ Не вдалося завантажити дані для:", player.Name)
		return
	end

	-- Stage 4. Get player info
	updateBootProgress(loginGui, 0.3, "Отримання інформації...")

	-- Determine player type using PlayerDataManager
	local success, playerInfo = pcall(function()
		return PlayerDataManager.GetPlayerInfo(player)
	end)

	if not success then
		warn("[GameInit] ⚠️ Не вдалося отримати інфо гравця")
		playerInfo = {
			Type = "Unknown",
			JoinDate = playerProfile.Stats.JoinDate,
			LastLogin = playerProfile.Stats.LastLogin,
			TotalPlayTime = playerProfile.Stats.TotalPlayTime or 0
		}
	end

	local playerType = playerInfo.Type
	print("[GameInit] ℹ️ Тип гравця:", playerType, "-", player.Name)
	task.wait(1)

	-- Stage 5. Loading Player settings
	updateBootProgress(loginGui, 0.5, "Завантаження налаштувань...")


	-- Settings are already loaded with player data
	task.wait(1)


	-- Stage 6. Start Location Manager
	updateBootProgress(loginGui, 0.6, "Запуск менеджера локацій...")

	-- Update player profile with loaded planet
	if not playerProfile.CurrentPlanet then
		playerProfile.CurrentPlanet=GameConfig.DEFAULT_PLANET
	end

	-- Load LocationManager with fallback
	local LocationManager
	local locationManagerModule = script.Parent:FindFirstChild("LocationManager")

	if locationManagerModule then
		if locationManagerModule.ClassName == "ModuleScript" then
			local success, result = pcall(function()
				LocationManager = require(locationManagerModule)
			end)

			if success then
				print("[GameInit] ✅ LocationManager завантажено")
				LocationManager.Initialize()
			else
				warn("[GameInit] ❌ Не вдалося завантажити LocationManager:", tostring(result))
				error("[GameInit] Неможливо продовжити без LocationManager")
			end
		else
			warn("[GameInit] ❌ LocationManager не є ModuleScript")
			warn("  └─ Очікувано: ModuleScript")
			warn("  └─ Отримано: " .. locationManagerModule.ClassName)
			error("[GameInit] LocationManager має бути ModuleScript")
		end
	else
		warn("[GameInit] ❌ LocationManager модуль не знайдено")
		warn("  └─ Очікуваний шлях: ServerScriptService/LocationManager.luau")
		error("[GameInit] Неможливо продовжити без LocationManager")
	end
	task.wait(1)

	-- Stage 7. Load Planet and SpaceStation
	updateBootProgress(loginGui, 0.8, "Завантаження планети " .. playerProfile.CurrentPlanet .. "...")
	LocationManager.SwitchToSpaceStation(playerProfile.CurrentPlanet, "Deep Space")
	task.wait(1)

	-- Stage 8. Complete loading
	updateBootProgress(loginGui, 1.0, "Завершено!")
	task.wait(1)


	local spawnSuccess = pcall(function()
		spawnPlayer(player, playerProfile)
	end)


	-- Remove loading screen
	if loginGui then
		loginGui:Destroy()
	end


	if not spawnSuccess then
		warn("[GameInit] ❌ Не вдалося спавнити гравця:", player.Name)
	end

	-- Mark player as loaded
	gameState.loadingPlayers[player.UserId] = nil

	print("[GameInit] ✅ Гравця повністю завантажено:", player.Name)
end

-- Connect events
Players.PlayerAdded:Connect(onPlayerAdded)

-- Handle players already in game
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end

print("[GameInit] 🚀 GameInit завантажено")