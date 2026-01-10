--[[
================================================================================
KOSMICMAZER — Planet Surface Scanner UI Client
================================================================================

Purpose: Створює та керує інтерфейсом сканера планетної поверхні згідно GuiConvention
Version: 2.0

Features:
- Відображення результатів сканування планетної поверхні (Windows 95 стиль)
- Анімований індикатор сканування з прогрес баром
- Список знайдених локацій з детальною інформацією
- 3D ефекти для кнопок згідно GuiConvention
- Інтеграція з ProximityPrompt для активації сканера
- Анімації з TweenService (Back.Out, Quad.In, Linear)
- LocationModel hierarchical structure support

API:
- Initialize(scannerModel): Ініціалізує UI для моделі сканера
- ShowScanResults(results): Показує результати сканування
- ShowScanningAnimation(): Показує анімацію сканування
- HideScanningAnimation(): Ховає анімацію сканування

Calls to:
- Players: Отримання локального гравця
- StarterGui: Створення GUI елементів
- TweenService: Анімації переходів
- ProximityPrompt: Виявлення наближення гравця

Called from:
- PlanetSurfaceScanner: Автоматична ініціалізація при завантаженні

Events:
- ScanStarted: Початок сканування
- ScanCompleted: Завершення сканування
- LocationSelected: Вибір локації з результатів

Dependencies:
- GuiConvention: Кольори WIN95_COLORS та NOTIFICATION_COLORS (defined locally)
- TweenService: Анімації
- PlanetSurfaceScanner: Модель сканера

ChangeLog:
- Version 2.0 (2026-01-10): IMPROVED Scanner UI - simplified location list
  - Removed teleport button, type, and difficulty fields
  - Now uses DisplayName from server (fixed "Невідома локація" bug)
  - Added "НОВА" status badge for unvisited locations (green badge)
  - Reduced frame height from 60px to 40px for compact display
  - Location list is now read-only (no click interactions)
- Version 2.0: Use ScanResults planetName for UI display (2026-01-10)
- Version 1.7: Removed GuiConvention dependency, colors defined locally
- Version 1.6: Renamed from ScannerUI to PlanetSurfaceScannerUI for clarity
- Version 1.5: Simplified Initialize() - removed mock results simulation
- Version 1.5: Flattened validation logic without complex nesting
- Version 1.4: Updated for LocationModel hierarchical structure (ETAP 3)
- Version 1.4: Auto-initialization now searches for LocationModel with attributes
- Version 1.4: Added LocationModel attribute validation (LocationId=SpaceStation, LocationType=Space)
- Version 1.4: Scanner search updated to LocationModel.Equipment.PlanetSurfaceScanner
- Version 1.3: Enhanced error messages and diagnostics for new structure
- Version 1.2: Removed GameConfig dependency, using local constants
- Version 1.1: Added scanning animation with progress bar

================================================================================
]]

local scriptVersion = "2.0"

--============================================================================--
--============================================================================--
-- SERVICES
--============================================================================--
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

--============================================================================--
-- MODULES
--============================================================================--
-- (No external modules required)

--============================================================================--
-- КОНСТАНТИ / CONSTANTS
--============================================================================--

-- @const number Тривалість сканування в секундах
local SCAN_DURATION = 5

-- @const number Максимальна кількість результатів
local MAX_RESULTS = 10

-- @const table Кольори Windows 95 (локально визначені)
local WIN95_COLORS = {
    WindowBackground = Color3.fromRGB(192, 192, 192),  -- Light gray
    ButtonHighlight = Color3.fromRGB(255, 255, 255),   -- White
    ButtonShadow = Color3.fromRGB(128, 128, 128),      -- Dark gray
    ButtonDarkShadow = Color3.fromRGB(64, 64, 64),     -- Very dark gray
    TitleBarActive = Color3.fromRGB(0, 0, 128),        -- Dark blue
    TitleText = Color3.fromRGB(255, 255, 255),         -- White
    ButtonFace = Color3.fromRGB(192, 192, 192),        -- Light gray
    WindowText = Color3.fromRGB(0, 0, 0),              -- Black
}

-- @const table Кольори сповіщень (локально визначені)
local NOTIFICATION_COLORS = {
    Success = Color3.fromRGB(39, 174, 96),    -- Green
    Error = Color3.fromRGB(231, 76, 60),      -- Red
    Warning = Color3.fromRGB(241, 196, 15),   -- Yellow
    Info = Color3.fromRGB(52, 152, 219),      -- Blue
}

-- @const number Тривалість UI анімацій
local UI_ANIMATION_DURATION = 0.3


--============================================================================--
-- ГЛОБАЛЬНІ ЗМІННІ / GLOBAL VARIABLES
--============================================================================--

-- @var Player Локальний гравець
local player = Players.LocalPlayer

-- @var ScreenGui? Головний GUI контейнер
local scannerGui = nil

-- @var Frame? Вікно результатів сканування
local resultsWindow = nil

-- @var Frame? Вікно анімації сканування
local scanningWindow = nil

-- @var Model? Модель сканера
local scannerModel = nil

-- @var ProximityPrompt? Промпт активації сканера
local proximityPrompt = nil

-- @var boolean Чи триває сканування
local isScanning = false

-- @var string? ??????? ????? ??????? ? ScanResults
local lastPlanetName = nil

--============================================================================--
-- ПУБЛІЧНЕ API / PUBLIC API
--============================================================================--

-- @var table PlanetSurfaceScannerUI API
local PlanetSurfaceScannerUI = {}

--============================================================================--
-- ЛОКАЛЬНІ ФУНКЦІЇ / LOCAL FUNCTIONS
--============================================================================--

local function updateScannerDisplayPlanetName(planetName: string)
	local scannerScreen = scannerModel and scannerModel:FindFirstChild("ScannerScreen")
	if not scannerScreen then return end

	local scanIndicator = scannerScreen:FindFirstChild("ScanIndicator")
	if not scanIndicator then return end

	local indicatorFrame = scanIndicator:FindFirstChild("IndicatorFrame")
	if not indicatorFrame then return end

	local scanLabel = indicatorFrame:FindFirstChild("ScanLabel")
	if not scanLabel then return end

	local displayName = planetName or "..."
	scanLabel.Text = "Planet: " .. displayName
	scanLabel.TextColor3 = Color3.new(0.8, 0.8, 1)
	scanLabel.BackgroundTransparency = 0.5
	scanIndicator.Enabled = true
	print("[PlanetSurfaceScannerUI 2.0] Set planet name on scan: " .. displayName)
end

--============================================================================--
-- REMOTEEVENT SUBSCRIPTION (v2.0)
--============================================================================--

local scanResultsEvent = ReplicatedStorage:FindFirstChild("PlanetSurfaceScanner_Results")
if scanResultsEvent and scanResultsEvent:IsA("RemoteEvent") then
	scanResultsEvent.OnClientEvent:Connect(function(eventType, data)
		if eventType == "ScanResults" and type(data) == "table" then
			lastPlanetName = data.planetName or "Unknown planet"
			updateScannerDisplayPlanetName(lastPlanetName)
			print("[PlanetSurfaceScannerUI 2.0] ScanResults received from server: ", lastPlanetName)
			PlanetSurfaceScannerUI.ShowScanResults(data.locations or {})
		end
	end)
else
	warn("[PlanetSurfaceScannerUI 2.0] RemoteEvent PlanetSurfaceScanner_Results not found in ReplicatedStorage")
end


-- Створює 3D ефект для кнопки (Windows 95 стиль)
-- @param button TextButton - Кнопка для стилізації
-- @param raised boolean - Чи кнопка "піднята"
local function create3DEffect(button: TextButton, raised: boolean)
	if raised then
		button.BorderSizePixel = 2
		button.BorderColor3 = WIN95_COLORS.ButtonHighlight
		-- Створюємо світлу рамку зверху/зліва
		local lightBorder = Instance.new("Frame")
		lightBorder.Name = "LightBorder"
		lightBorder.Size = UDim2.new(1, 2, 1, 2)
		lightBorder.Position = UDim2.new(0, -1, 0, -1)
		lightBorder.BackgroundColor3 = WIN95_COLORS.ButtonHighlight
		lightBorder.BorderSizePixel = 0
		lightBorder.ZIndex = button.ZIndex + 1
		lightBorder.Parent = button

		-- Створюємо темну рамку знизу/справа
		local darkBorder = Instance.new("Frame")
		darkBorder.Name = "DarkBorder"
		darkBorder.Size = UDim2.new(1, 2, 1, 2)
		darkBorder.Position = UDim2.new(0, 1, 0, 1)
		darkBorder.BackgroundColor3 = WIN95_COLORS.ButtonShadow
		darkBorder.BorderSizePixel = 0
		darkBorder.ZIndex = button.ZIndex + 1
		darkBorder.Parent = button
	else
		button.BorderSizePixel = 2
		button.BorderColor3 = WIN95_COLORS.ButtonDarkShadow
		-- Видаляємо 3D ефекти
		local lightBorder = button:FindFirstChild("LightBorder")
		if lightBorder then lightBorder:Destroy() end
		local darkBorder = button:FindFirstChild("DarkBorder")
		if darkBorder then darkBorder:Destroy() end
	end
end

-- Створює вікно результатів сканування
local function createResultsWindow()
	if resultsWindow then
		resultsWindow:Destroy()
	end

	resultsWindow = Instance.new("Frame")
	resultsWindow.Name = "ScanResultsWindow"
	resultsWindow.Size = UDim2.new(0, 400, 0, 300)
	resultsWindow.Position = UDim2.new(0.5, -200, 0.5, -150)
	resultsWindow.BackgroundColor3 = WIN95_COLORS.WindowBackground
	resultsWindow.BorderSizePixel = 0
	resultsWindow.Parent = scannerGui

	-- Title bar
	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.Size = UDim2.new(1, 0, 0, 20)
	titleBar.Position = UDim2.new(0, 0, 0, 0)
	titleBar.BackgroundColor3 = WIN95_COLORS.TitleBarActive
	titleBar.BorderSizePixel = 0
	titleBar.Parent = resultsWindow

	-- Title text
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, -60, 1, 0)
	titleLabel.Position = UDim2.new(0, 5, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "Результати сканування поверхні"
	titleLabel.TextColor3 = WIN95_COLORS.TitleText
	titleLabel.Font = Enum.Font.SourceSansBold
	titleLabel.TextSize = 12
	titleLabel.Parent = titleBar

	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseBtn"
	closeBtn.Size = UDim2.new(0, 16, 0, 14)
	closeBtn.Position = UDim2.new(1, -18, 0, 3)
	closeBtn.BackgroundColor3 = WIN95_COLORS.ButtonFace
	closeBtn.BorderSizePixel = 1
	closeBtn.Text = "X"
	closeBtn.Font = Enum.Font.SourceSans
	closeBtn.TextSize = 10
	closeBtn.Parent = titleBar
	create3DEffect(closeBtn, true)

	-- Content area
	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Size = UDim2.new(1, -4, 1, -44)
	content.Position = UDim2.new(0, 2, 0, 22)
	content.BackgroundTransparency = 1
	content.Parent = resultsWindow

	-- Results list
	local resultsList = Instance.new("ScrollingFrame")
	resultsList.Name = "ResultsList"
	resultsList.Size = UDim2.new(1, -10, 1, -10)
	resultsList.Position = UDim2.new(0, 5, 0, 5)
	resultsList.BackgroundColor3 = WIN95_COLORS.WindowBackground
	resultsList.BorderSizePixel = 1
	resultsList.BorderColor3 = WIN95_COLORS.ButtonShadow
	resultsList.ScrollBarThickness = 12
	resultsList.Parent = content

	-- Button container
	local buttonContainer = Instance.new("Frame")
	buttonContainer.Name = "ButtonContainer"
	buttonContainer.Size = UDim2.new(1, -4, 0, 30)
	buttonContainer.Position = UDim2.new(0, 2, 1, -32)
	buttonContainer.BackgroundTransparency = 1
	buttonContainer.Parent = resultsWindow

	-- Rescan button
	local rescanBtn = Instance.new("TextButton")
	rescanBtn.Name = "RescanBtn"
	rescanBtn.Size = UDim2.new(0, 100, 1, 0)
	rescanBtn.Position = UDim2.new(0, 5, 0, 0)
	rescanBtn.BackgroundColor3 = WIN95_COLORS.ButtonFace
	rescanBtn.BorderSizePixel = 1
	rescanBtn.Text = "Перескановати"
	rescanBtn.Font = Enum.Font.SourceSans
	rescanBtn.TextSize = 12
	rescanBtn.Parent = buttonContainer
	create3DEffect(rescanBtn, true)

	-- Close button
	local closeBtn2 = Instance.new("TextButton")
	closeBtn2.Name = "CloseBtn2"
	closeBtn2.Size = UDim2.new(0, 80, 1, 0)
	closeBtn2.Position = UDim2.new(1, -85, 0, 0)
	closeBtn2.BackgroundColor3 = WIN95_COLORS.ButtonFace
	closeBtn2.BorderSizePixel = 1
	closeBtn2.Text = "Закрити"
	closeBtn2.Font = Enum.Font.SourceSans
	closeBtn2.TextSize = 12
	closeBtn2.Parent = buttonContainer
	create3DEffect(closeBtn2, true)

	-- Анімація появи
	resultsWindow.Size = UDim2.new(0, 0, 0, 0)
	local tweenIn = TweenService:Create(resultsWindow, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 400, 0, 300)
	})
	tweenIn:Play()

	-- Обробники кнопок
	closeBtn.MouseButton1Click:Connect(function()
		local tweenOut = TweenService:Create(resultsWindow, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 0)
		})
		tweenOut:Play()
		tweenOut.Completed:Wait()
		resultsWindow:Destroy()
		resultsWindow = nil
	end)

	closeBtn2.MouseButton1Click:Connect(function()
		local tweenOut = TweenService:Create(resultsWindow, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 0)
		})
		tweenOut:Play()
		tweenOut.Completed:Wait()
		resultsWindow:Destroy()
		resultsWindow = nil
	end)

	rescanBtn.MouseButton1Click:Connect(function()
		if resultsWindow then
			resultsWindow:Destroy()
			resultsWindow = nil
		end
		PlanetSurfaceScannerUI.ShowScanningAnimation()
		task.delay(SCAN_DURATION, function()
			PlanetSurfaceScannerUI.HideScanningAnimation()
			print("[PlanetSurfaceScannerUI 2.0] Rescan completed, waiting for server results")
		end)
	end)

	-- Ефекти натискання для кнопок
	local function createButtonEffect(button)
		button.MouseEnter:Connect(function()
			create3DEffect(button, false)
		end)
		button.MouseLeave:Connect(function()
			create3DEffect(button, true)
		end)
		button.MouseButton1Down:Connect(function()
			create3DEffect(button, false)
		end)
		button.MouseButton1Up:Connect(function()
			create3DEffect(button, true)
		end)
	end

	createButtonEffect(closeBtn)
	createButtonEffect(closeBtn2)
	createButtonEffect(rescanBtn)

	return resultsList
end

-- Створює вікно анімації сканування
local function createScanningWindow()
	if scanningWindow then
		scanningWindow:Destroy()
	end

	scanningWindow = Instance.new("Frame")
	scanningWindow.Name = "ScanningWindow"
	scanningWindow.Size = UDim2.new(0, 300, 0, 150)
	scanningWindow.Position = UDim2.new(0.5, -150, 0.5, -75)
	scanningWindow.BackgroundColor3 = WIN95_COLORS.WindowBackground
	scanningWindow.BorderSizePixel = 0
	scanningWindow.Parent = scannerGui

	-- Title bar
	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.Size = UDim2.new(1, 0, 0, 20)
	titleBar.Position = UDim2.new(0, 0, 0, 0)
	titleBar.BackgroundColor3 = WIN95_COLORS.TitleBarActive
	titleBar.BorderSizePixel = 0
	titleBar.Parent = scanningWindow

	-- Title text
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, -60, 1, 0)
	titleLabel.Position = UDim2.new(0, 5, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "Сканування поверхні..."
	titleLabel.TextColor3 = WIN95_COLORS.TitleText
	titleLabel.Font = Enum.Font.SourceSansBold
	titleLabel.TextSize = 12
	titleLabel.Parent = titleBar

	-- Content area
	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Size = UDim2.new(1, -4, 1, -44)
	content.Position = UDim2.new(0, 2, 0, 22)
	content.BackgroundTransparency = 1
	content.Parent = scanningWindow

	-- Scanning animation
	local scanningIcon = Instance.new("TextLabel")
	scanningIcon.Name = "ScanningIcon"
	scanningIcon.Size = UDim2.new(0, 50, 0, 50)
	scanningIcon.Position = UDim2.new(0.5, -25, 0, 10)
	scanningIcon.BackgroundColor3 = WIN95_COLORS.WindowBackground
	scanningIcon.BorderSizePixel = 1
	scanningIcon.BorderColor3 = WIN95_COLORS.ButtonShadow
	scanningIcon.Text = "📡"
	scanningIcon.TextColor3 = WIN95_COLORS.WindowText
	scanningIcon.Font = Enum.Font.SourceSans
	scanningIcon.TextSize = 24
	scanningIcon.Parent = content

	-- Progress bar container
	local progressContainer = Instance.new("Frame")
	progressContainer.Name = "ProgressContainer"
	progressContainer.Size = UDim2.new(1, -20, 0, 20)
	progressContainer.Position = UDim2.new(0, 10, 0, 70)
	progressContainer.BackgroundColor3 = WIN95_COLORS.ButtonShadow
	progressContainer.BorderSizePixel = 0
	progressContainer.Parent = content

	-- Progress bar fill
	local progressBar = Instance.new("Frame")
	progressBar.Name = "ProgressBar"
	progressBar.Size = UDim2.new(0, 0, 1, 0)
	progressBar.Position = UDim2.new(0, 0, 0, 0)
	progressBar.BackgroundColor3 = NOTIFICATION_COLORS.Info
	progressBar.BorderSizePixel = 0
	progressBar.Parent = progressContainer

	-- Status text
	local statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "StatusLabel"
	statusLabel.Size = UDim2.new(1, -20, 0, 20)
	statusLabel.Position = UDim2.new(0, 10, 0, 100)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Text = "Аналіз поверхні..."
	statusLabel.TextColor3 = WIN95_COLORS.WindowText
	statusLabel.Font = Enum.Font.SourceSans
	statusLabel.TextSize = 12
	statusLabel.Parent = content

	-- Анімація появи
	scanningWindow.Size = UDim2.new(0, 0, 0, 0)
	local tweenIn = TweenService:Create(scanningWindow, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 300, 0, 150)
	})
	tweenIn:Play()

	-- Анімація прогрес бару
	local progressTween = TweenService:Create(progressBar, TweenInfo.new(SCAN_DURATION, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, 0, 1, 0)
	})
	progressTween:Play()

	-- Анімація іконки
	local rotationTween = TweenService:Create(scanningIcon, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {
		Rotation = 360
	})
	rotationTween:Play()

	-- Оновлення статус тексту
	local statusMessages = {"Аналіз поверхні...", "Сканування рельєфу...", "Виявлення аномалій...", "Обробка даних..."}
	for i, message in ipairs(statusMessages) do
		task.delay((i - 1) * (SCAN_DURATION / #statusMessages), function()
			if statusLabel and statusLabel.Parent then
				statusLabel.Text = message
			end
		end)
	end

	return scanningWindow
end

--============================================================================--
-- ПУБЛІЧНІ ФУНКЦІЇ / PUBLIC API IMPLEMENTATION
--============================================================================--

--[[
@function Initialize
Ініціалізує UI для моделі сканера

@param scannerModel Model - Модель сканера для інтеграції
@return nil
]]
function PlanetSurfaceScannerUI.Initialize(scannerModel: Model): nil
	print("[PlanetSurfaceScannerUI 2.0] 📡 Initializing Scanner UI for model:", scannerModel.Name)

	-- Створюємо головний GUI
	scannerGui = Instance.new("ScreenGui")
	scannerGui.Name = "PlanetSurfaceScannerUI"
	scannerGui.ResetOnSpawn = false
	scannerGui.IgnoreGuiInset = true
	scannerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	scannerGui.Parent = player:WaitForChild("PlayerGui")

	-- Знаходимо ScannerBaseplate
	local scannerBaseplate = scannerModel:FindFirstChild("ScannerBaseplate")
	if not scannerBaseplate then
		scannerBaseplate = scannerModel:WaitForChild("ScannerBaseplate", 5)
	end
	if not scannerBaseplate then
		scannerBaseplate = scannerModel:FindFirstChild("ScannerBaseplate", true)
	end
	if not scannerBaseplate then
		warn("[PlanetSurfaceScannerUI 2.0] ⚠️ ScannerBaseplate not found in scanner model")
		return
	end

	-- Знаходимо ProximityPrompt
	proximityPrompt = scannerBaseplate:FindFirstChild("ProximityPrompt")
	if not proximityPrompt then
		proximityPrompt = scannerBaseplate:WaitForChild("ProximityPrompt", 5)
	end
	if not proximityPrompt then
		proximityPrompt = scannerBaseplate:FindFirstChildWhichIsA("ProximityPrompt", true)
	end
	if not proximityPrompt then
		warn("[PlanetSurfaceScannerUI 2.0] ⚠️ ProximityPrompt not found in ScannerBaseplate")
		return
	end

	-- Підключаємо обробник ProximityPrompt


	proximityPrompt.Triggered:Connect(function(playerWhoTriggered)
		if playerWhoTriggered ~= player then return end
		if isScanning then return end

		print("[PlanetSurfaceScannerUI 2.0] 📡 ProximityPrompt TRIGGERED by player:", playerWhoTriggered.Name)
		PlanetSurfaceScannerUI.ShowScanningAnimation()

		-- Оновлюємо ScanLabel на дисплеї сканера
		updateScannerDisplayPlanetName(lastPlanetName or "...")

		task.delay(SCAN_DURATION, function()
			PlanetSurfaceScannerUI.HideScanningAnimation()
			print("[PlanetSurfaceScannerUI 2.0] ✅ Scan completed, waiting for server results")
		end)
	end)

	print("[PlanetSurfaceScannerUI 2.0] 🎯 ProximityPrompt configured - Enabled:", proximityPrompt.Enabled, "MaxActivationDistance:", proximityPrompt.MaxActivationDistance)

	local scriptName = "PlanetSurfaceScannerUI"
	print(string.format("[%s %s] ✅ Scanner UI initialized successfully", scriptName, scriptVersion))
end

--[[
@function ShowScanResults
Показує результати сканування у вікні

@param results table - Таблиця з результатами сканування
@return nil
]]
function PlanetSurfaceScannerUI.ShowScanResults(results: {any}): nil
	print("[PlanetSurfaceScannerUI 2.0] 📊 Showing scan results:", #results, "locations found")

	local resultsList = createResultsWindow()
	if not resultsList then return end

	-- Очищуємо попередні результати
	for _, child in ipairs(resultsList:GetChildren()) do
		child:Destroy()
	end

	-- Створюємо елементи результатів
	local yOffset = 5
	for i, result in ipairs(results) do
		if i > MAX_RESULTS then break end

		local resultFrame = Instance.new("Frame")
		resultFrame.Name = "Result" .. i
		resultFrame.Size = UDim2.new(1, -10, 0, 40)
		resultFrame.Position = UDim2.new(0, 5, 0, yOffset)
		resultFrame.BackgroundColor3 = WIN95_COLORS.WindowBackground
		resultFrame.BorderSizePixel = 1
		resultFrame.BorderColor3 = WIN95_COLORS.ButtonShadow
		resultFrame.Parent = resultsList

		-- Назва локації (використовуємо DisplayName з сервера)
		local locationName = result.DisplayName or "Невідома локація"
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "NameLabel"
		nameLabel.Size = UDim2.new(0.7, -10, 1, -10)
		nameLabel.Position = UDim2.new(0, 5, 0, 5)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = locationName
		nameLabel.TextColor3 = WIN95_COLORS.WindowText
		nameLabel.Font = Enum.Font.SourceSansBold
		nameLabel.TextSize = 14
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.TextYAlignment = Enum.TextYAlignment.Center
		nameLabel.Parent = resultFrame

		-- Статус "Нова" якщо не відвідана
		if not result.IsVisited then
			local statusLabel = Instance.new("TextLabel")
			statusLabel.Name = "StatusLabel"
			statusLabel.Size = UDim2.new(0, 60, 0, 20)
			statusLabel.Position = UDim2.new(1, -70, 0.5, -10)
			statusLabel.BackgroundColor3 = Color3.fromRGB(0, 150, 0) -- Зелений
			statusLabel.BorderSizePixel = 1
			statusLabel.BorderColor3 = Color3.fromRGB(0, 100, 0)
			statusLabel.Text = "НОВА"
			statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			statusLabel.Font = Enum.Font.SourceSansBold
			statusLabel.TextSize = 11
			statusLabel.Parent = resultFrame
		end

		yOffset = yOffset + 45
	end

	-- Оновлюємо розмір ScrollingFrame
	resultsList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

--[[
@function ShowScanningAnimation
Показує анімацію сканування

@return nil
]]
function PlanetSurfaceScannerUI.ShowScanningAnimation(): nil
	if isScanning then return end

	isScanning = true
	print("[PlanetSurfaceScannerUI 2.0] 📡 Starting scanning animation...")
	createScanningWindow()
end

--[[
@function HideScanningAnimation
Ховає анімацію сканування

@return nil
]]
function PlanetSurfaceScannerUI.HideScanningAnimation(): nil
	if not isScanning then return end

	isScanning = false
	print("[PlanetSurfaceScannerUI 2.0] ✅ Hiding scanning animation...")

	if scanningWindow then
		local tweenOut = TweenService:Create(scanningWindow, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 0)
		})
		tweenOut:Play()
		tweenOut.Completed:Wait()
		scanningWindow:Destroy()
		scanningWindow = nil
	end
end

--============================================================================--
-- ІНІЦІАЛІЗАЦІЯ / INITIALIZATION
--============================================================================--

-- Автоматична ініціалізація при завантаженні скрипта
task.spawn(function()
	-- Чекаємо поки LocationModel буде завантажено
	local locationModel = game.Workspace:WaitForChild("LocationModel", 30)
	if locationModel then
		-- Валідуємо що це SpaceStation LocationModel
		local locationId = locationModel:GetAttribute("LocationId")
		local locationType = locationModel:GetAttribute("LocationType")
		
		if locationId == "SpaceStation" and locationType == "Space" then
			-- Шукаємо PlanetSurfaceScanner в Equipment секції
			local equipmentFolder = locationModel:FindFirstChild("Equipment")
			if equipmentFolder then
				local scannerModel = equipmentFolder:WaitForChild("PlanetSurfaceScanner", 10)
				if scannerModel then
					PlanetSurfaceScannerUI.Initialize(scannerModel)
					local scriptName = "PlanetSurfaceScannerUI"
					print(string.format("[%s %s] ✅ Ініціалізовано для LocationModel.Equipment.PlanetSurfaceScanner", scriptName, scriptVersion))
				else
					warn("[PlanetSurfaceScannerUI 2.0] ⚠️ PlanetSurfaceScanner не знайдено в LocationModel/Equipment")
				end
			else
				warn("[PlanetSurfaceScannerUI 2.0] ⚠️ Equipment папка не знайдена в LocationModel")
			end
		else
			warn("[PlanetSurfaceScannerUI 2.0] ⚠️ LocationModel має невірні attributes:")
			warn("  └─ LocationId: " .. tostring(locationId) .. " (expected: SpaceStation)")
			warn("  └─ LocationType: " .. tostring(locationType) .. " (expected: Space)")
		end
	else
		warn("[PlanetSurfaceScannerUI 2.0] ⚠️ LocationModel не знайдено в Workspace")
		warn("  └─ Перевірте що SpaceStation завантажено через EnvironmentLoader")
	end
end)

-- Експортуємо функції для глобального доступу
_G.PlanetSurfaceScannerUI = PlanetSurfaceScannerUI

return PlanetSurfaceScannerUI