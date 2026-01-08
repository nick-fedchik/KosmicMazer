--[[
================================================================================
KOSMICMAZER — Space Station UI Client
================================================================================

Purpose: Створює та керує статус баром космічної станції згідно GuiConvention
Version: 1.4

Features:
- Горизонтальний статус бар вгорі праворуч екрану (Windows 95 стиль)
- Відображення назви станції та поточної планети
- Кнопка виходу з гри з діалогом підтвердження
- 3D ефекти для кнопок згідно GuiConvention
- Анімації з TweenService (Back.Out, Quad.In)
- LocationModel hierarchical structure compatibility

API:
- Initialize(): Ініціалізує UI елементи
- UpdatePlanetName(planetId): Оновлює назву планети
- GetCurrentPlanetId(): Повертає ID поточної планети
- GetCurrentPlanetName(): Повертає назву поточної планети
- ShowExitConfirmation(): Показує діалог підтвердження виходу

Calls to:
- Players: Отримання локального гравця
- StarterGui: Створення GUI елементів
- TweenService: Анімації переходів

Called from:
- EnvironmentLoader: Автоматичне завантаження при переході на станцію

Events:
- ExitButtonClicked: Подія натискання кнопки виходу

Dependencies:
- GuiConvention: Кольори WIN95_COLORS та стилі
- TweenService: Анімації

ChangeLog:
- Version 1.4: Renamed from StationUI to SpaceStationUI for clarity
- Version 1.3: Updated for LocationModel hierarchical structure compatibility (ETAP 3)
- Version 1.3: Tested and verified compatibility with new space station structure
- Version 1.3: No direct changes required as UI doesn't reference SpaceStation models directly
- Version 1.2: Removed GameConfig dependency, using local constants
- Version 1.1: Added dynamic planet names and 3D button effects
- Version 1.0: Initial implementation with Windows 95 styling

================================================================================
]]

--============================================================================--
-- SERVICES
--============================================================================--
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--============================================================================--
-- MODULES
--============================================================================--
local GuiConvention = require(ReplicatedStorage:WaitForChild("Std"):WaitForChild("GuiConvention"))

--============================================================================--
-- КОНСТАНТИ / CONSTANTS
--============================================================================--

-- @const table Кольори Windows 95
local WIN95_COLORS = GuiConvention.WIN95_COLORS

-- @const string ID поточної планети за замовчуванням
local DEFAULT_PLANET_ID = "Planet_1"

-- @const string Назва космічної станції
local STATION_DISPLAY_NAME = "Космічна Станція"

-- @const table Назви планет (отримуються від сервера або хардкодяться)
local PLANET_NAMES = {
	["Planet_1"] = "Планета 1",
	["Planet_2"] = "Планета 2",
}

-- @var string ID поточної планети
local currentPlanetId = DEFAULT_PLANET_ID

-- @var string Назва поточної планети
local currentPlanetName = PLANET_NAMES[DEFAULT_PLANET_ID] or "Невідома планета"

--============================================================================--
-- ГЛОБАЛЬНІ ЗМІННІ / GLOBAL VARIABLES
--============================================================================--

-- @var Player Локальний гравець
local player = Players.LocalPlayer

-- @var ScreenGui? Головний GUI контейнер
local statusBarGui = nil

-- @var TextLabel? Назва станції
local stationNameLabel = nil

-- @var TextLabel? Назва планети
local planetNameLabel = nil

-- @var TextButton? Кнопка виходу
local exitButton = nil

--============================================================================--
-- ЛОКАЛЬНІ ФУНКЦІЇ / LOCAL FUNCTIONS
--============================================================================--

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

-- Створює діалог підтвердження виходу (Windows 95 стиль)
local function createExitDialog()
	local dialog = Instance.new("Frame")
	dialog.Name = "ExitDialog"
	dialog.Size = UDim2.new(0, 320, 0, 160)
	dialog.Position = UDim2.new(0.5, -160, 0.5, -80)
	dialog.BackgroundColor3 = WIN95_COLORS.WindowBackground
	dialog.BorderSizePixel = 0
	dialog.Parent = statusBarGui

	-- Title bar
	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.Size = UDim2.new(1, 0, 0, 20)
	titleBar.Position = UDim2.new(0, 0, 0, 0)
	titleBar.BackgroundColor3 = WIN95_COLORS.TitleBarActive
	titleBar.BorderSizePixel = 0
	titleBar.Parent = dialog

	-- Title text
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, -60, 1, 0)
	titleLabel.Position = UDim2.new(0, 5, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "Підтвердження виходу"
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

	-- Content area
	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Size = UDim2.new(1, -4, 1, -44)
	content.Position = UDim2.new(0, 2, 0, 22)
	content.BackgroundTransparency = 1
	content.Parent = dialog

	-- Message text
	local messageLabel = Instance.new("TextLabel")
	messageLabel.Name = "MessageLabel"
	messageLabel.Size = UDim2.new(1, -20, 0, 40)
	messageLabel.Position = UDim2.new(0, 10, 0, 10)
	messageLabel.BackgroundTransparency = 1
	messageLabel.Text = "Ви впевнені, що хочете вийти з гри?\nВсі незбережені дані будуть втрачені."
	messageLabel.TextColor3 = WIN95_COLORS.WindowText
	messageLabel.Font = Enum.Font.SourceSans
	messageLabel.TextSize = 12
	messageLabel.TextWrapped = true
	messageLabel.Parent = content

	-- Button container
	local buttonContainer = Instance.new("Frame")
	buttonContainer.Name = "ButtonContainer"
	buttonContainer.Size = UDim2.new(1, -20, 0, 30)
	buttonContainer.Position = UDim2.new(0, 10, 1, -40)
	buttonContainer.BackgroundTransparency = 1
	buttonContainer.Parent = content

	-- Yes button
	local yesBtn = Instance.new("TextButton")
	yesBtn.Name = "YesBtn"
	yesBtn.Size = UDim2.new(0, 80, 1, 0)
	yesBtn.Position = UDim2.new(1, -170, 0, 0)
	yesBtn.BackgroundColor3 = WIN95_COLORS.ButtonFace
	yesBtn.BorderSizePixel = 1
	yesBtn.Text = "Так"
	yesBtn.Font = Enum.Font.SourceSans
	yesBtn.TextSize = 12
	yesBtn.Parent = buttonContainer
	create3DEffect(yesBtn, true)

	-- No button
	local noBtn = Instance.new("TextButton")
	noBtn.Name = "NoBtn"
	noBtn.Size = UDim2.new(0, 80, 1, 0)
	noBtn.Position = UDim2.new(1, -80, 0, 0)
	noBtn.BackgroundColor3 = WIN95_COLORS.ButtonFace
	noBtn.BorderSizePixel = 1
	noBtn.Text = "Ні"
	noBtn.Font = Enum.Font.SourceSans
	noBtn.TextSize = 12
	noBtn.Parent = buttonContainer
	create3DEffect(noBtn, true)

	-- Анімація появи
	dialog.Size = UDim2.new(0, 0, 0, 0)
	local tweenIn = TweenService:Create(dialog, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 320, 0, 160)
	})
	tweenIn:Play()

	-- Обробники кнопок
	closeBtn.MouseButton1Click:Connect(function()
		local tweenOut = TweenService:Create(dialog, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 0)
		})
		tweenOut:Play()
		tweenOut.Completed:Wait()
		dialog:Destroy()
	end)

	yesBtn.MouseButton1Click:Connect(function()
		-- TODO: Реалізувати вихід з гри зі збереженням
		print("[SpaceStationUI] 🚪 Player confirmed exit - implementing save and quit...")
		Players.LocalPlayer:Kick("Дякуємо за гру!")
	end)

	noBtn.MouseButton1Click:Connect(function()
		local tweenOut = TweenService:Create(dialog, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 0)
		})
		tweenOut:Play()
		tweenOut.Completed:Wait()
		dialog:Destroy()
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

	createButtonEffect(yesBtn)
	createButtonEffect(noBtn)
	createButtonEffect(closeBtn)
end

-- Створює горизонтальний статус бар
local function createStatusBar()
	if statusBarGui then
		statusBarGui:Destroy()
	end

	-- Створюємо ScreenGui
	statusBarGui = Instance.new("ScreenGui")
	statusBarGui.Name = "StationStatusBar"
	statusBarGui.ResetOnSpawn = false
	statusBarGui.IgnoreGuiInset = true
	statusBarGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	statusBarGui.Parent = player:WaitForChild("PlayerGui")

	-- Головний статус бар
	local statusBar = Instance.new("Frame")
	statusBar.Name = "StatusBar"
	statusBar.Size = UDim2.new(0, 500, 0, 40)
	statusBar.Position = UDim2.new(1, -520, 0, 20)
	statusBar.BackgroundColor3 = WIN95_COLORS.WindowBackground
	statusBar.BorderSizePixel = 2
	statusBar.BorderColor3 = WIN95_COLORS.ButtonShadow
	statusBar.Parent = statusBarGui

	-- Створюємо 3D ефект для статус бару
	local lightBorder = Instance.new("Frame")
	lightBorder.Name = "LightBorder"
	lightBorder.Size = UDim2.new(1, 2, 1, 2)
	lightBorder.Position = UDim2.new(0, -1, 0, -1)
	lightBorder.BackgroundColor3 = WIN95_COLORS.ButtonHighlight
	lightBorder.BorderSizePixel = 0
	lightBorder.ZIndex = statusBar.ZIndex + 1
	lightBorder.Parent = statusBar

	local darkBorder = Instance.new("Frame")
	darkBorder.Name = "DarkBorder"
	darkBorder.Size = UDim2.new(1, 2, 1, 2)
	darkBorder.Position = UDim2.new(0, 1, 0, 1)
	darkBorder.BackgroundColor3 = WIN95_COLORS.ButtonShadow
	darkBorder.BorderSizePixel = 0
	darkBorder.ZIndex = statusBar.ZIndex + 1
	darkBorder.Parent = statusBar

	-- Секція назви станції
	local stationSection = Instance.new("Frame")
	stationSection.Name = "StationSection"
	stationSection.Size = UDim2.new(0, 180, 1, 0)
	stationSection.Position = UDim2.new(0, 5, 0, 0)
	stationSection.BackgroundTransparency = 1
	stationSection.Parent = statusBar

	-- Іконка станції
	local stationIcon = Instance.new("TextLabel")
	stationIcon.Name = "StationIcon"
	stationIcon.Size = UDim2.new(0, 30, 1, 0)
	stationIcon.Position = UDim2.new(0, 0, 0, 0)
	stationIcon.BackgroundTransparency = 1
	stationIcon.Text = "🚀"
	stationIcon.TextColor3 = WIN95_COLORS.WindowText
	stationIcon.TextScaled = false
	stationIcon.Font = Enum.Font.SourceSans
	stationIcon.TextSize = 20
	stationIcon.TextXAlignment = Enum.TextXAlignment.Center
	stationIcon.Parent = stationSection

	-- Назва станції
	stationNameLabel = Instance.new("TextLabel")
	stationNameLabel.Name = "StationNameLabel"
	stationNameLabel.Size = UDim2.new(1, -35, 1, 0)
	stationNameLabel.Position = UDim2.new(0, 35, 0, 0)
	stationNameLabel.BackgroundTransparency = 1
	stationNameLabel.Text = STATION_DISPLAY_NAME
	stationNameLabel.TextColor3 = WIN95_COLORS.WindowText
	stationNameLabel.TextScaled = false
	stationNameLabel.Font = Enum.Font.SourceSansBold
	stationNameLabel.TextSize = 14
	stationNameLabel.TextXAlignment = Enum.TextXAlignment.Left
	stationNameLabel.Parent = stationSection

	-- Секція назви планети
	local planetSection = Instance.new("Frame")
	planetSection.Name = "PlanetSection"
	planetSection.Size = UDim2.new(0, 180, 1, 0)
	planetSection.Position = UDim2.new(0, 190, 0, 0)
	planetSection.BackgroundTransparency = 1
	planetSection.Parent = statusBar

	-- Іконка планети
	local planetIcon = Instance.new("TextLabel")
	planetIcon.Name = "PlanetIcon"
	planetIcon.Size = UDim2.new(0, 30, 1, 0)
	planetIcon.Position = UDim2.new(0, 0, 0, 0)
	planetIcon.BackgroundTransparency = 1
	planetIcon.Text = "🪐"
	planetIcon.TextColor3 = WIN95_COLORS.WindowText
	planetIcon.TextScaled = false
	planetIcon.Font = Enum.Font.SourceSans
	planetIcon.TextSize = 20
	planetIcon.TextXAlignment = Enum.TextXAlignment.Center
	planetIcon.Parent = planetSection

	-- Назва планети
	planetNameLabel = Instance.new("TextLabel")
	planetNameLabel.Name = "PlanetNameLabel"
	planetNameLabel.Size = UDim2.new(1, -35, 1, 0)
	planetNameLabel.Position = UDim2.new(0, 35, 0, 0)
	planetNameLabel.BackgroundTransparency = 1
	planetNameLabel.Text = currentPlanetName
	planetNameLabel.TextColor3 = WIN95_COLORS.WindowText
	planetNameLabel.TextScaled = false
	planetNameLabel.Font = Enum.Font.SourceSansBold
	planetNameLabel.TextSize = 14
	planetNameLabel.TextXAlignment = Enum.TextXAlignment.Left
	planetNameLabel.Parent = planetSection

	-- Секція кнопки виходу
	local exitSection = Instance.new("Frame")
	exitSection.Name = "ExitSection"
	exitSection.Size = UDim2.new(0, 120, 1, 0)
	exitSection.Position = UDim2.new(1, -125, 0, 0)
	exitSection.BackgroundTransparency = 1
	exitSection.Parent = statusBar

	-- Кнопка виходу
	exitButton = Instance.new("TextButton")
	exitButton.Name = "ExitButton"
	exitButton.Size = UDim2.new(1, -10, 1, -6)
	exitButton.Position = UDim2.new(0, 5, 0, 3)
	exitButton.BackgroundColor3 = WIN95_COLORS.ButtonFace
	exitButton.BorderSizePixel = 1
	exitButton.BorderColor3 = WIN95_COLORS.ButtonShadow
	exitButton.Text = "Вихід з Гри"
	exitButton.TextColor3 = WIN95_COLORS.WindowText
	exitButton.TextScaled = false
	exitButton.Font = Enum.Font.SourceSansBold
	exitButton.TextSize = 12
	exitButton.Parent = exitSection

	-- Створюємо 3D ефект для кнопки виходу
	create3DEffect(exitButton, true)

	-- Обробник натискання кнопки виходу
	exitButton.MouseButton1Click:Connect(function()
		print("[SpaceStationUI] 🚪 Exit button clicked!")
		createExitDialog()
	end)

	-- Ефекти наведення для кнопки виходу
	exitButton.MouseEnter:Connect(function()
		create3DEffect(exitButton, false)
	end)
	exitButton.MouseLeave:Connect(function()
		create3DEffect(exitButton, true)
	end)
	exitButton.MouseButton1Down:Connect(function()
		create3DEffect(exitButton, false)
	end)
	exitButton.MouseButton1Up:Connect(function()
		create3DEffect(exitButton, true)
	end)

	print("[SpaceStationUI] ✅ Status bar created successfully")
end

--============================================================================--
-- ПУБЛІЧНІ ФУНКЦІЇ / PUBLIC API
--============================================================================--

local SpaceStationUI = {}

--[[
@function Initialize
Ініціалізує UI елементи статус бару

@return nil
]]
function SpaceStationUI.Initialize(): nil
	print("[SpaceStationUI] 🚀 Initializing Station UI...")
	createStatusBar()
	return
end

--[[
@function UpdatePlanetName
Оновлює назву поточної планети в статус барі

@param planetId string - ID планети для відображення
@return nil
]]
function SpaceStationUI.UpdatePlanetName(planetId: string): nil
	if planetNameLabel then
		currentPlanetId = planetId
		currentPlanetName = PLANET_NAMES[planetId] or "Невідома планета"
		planetNameLabel.Text = currentPlanetName
		print("[SpaceStationUI] 🪐 Planet updated to:", planetId, "-", currentPlanetName)
	else
		warn("[SpaceStationUI] ⚠️ Planet label not initialized")
	end
end


--[[
@function GetCurrentPlanetId
Повертає ID поточної планети

@return string - ID поточної планети
]]
function SpaceStationUI.GetCurrentPlanetId(): string
	return currentPlanetId
end

--[[
@function GetCurrentPlanetName
Повертає назву поточної планети

@return string - Назва поточної планети
]]
function SpaceStationUI.GetCurrentPlanetName(): string
	return currentPlanetName
end

--[[
@function ShowExitConfirmation
Показує діалог підтвердження виходу з гри

@return nil
]]
function SpaceStationUI.ShowExitConfirmation(): nil
	createExitDialog()
end

--============================================================================--
-- ІНІЦІАЛІЗАЦІЯ / INITIALIZATION
--============================================================================--

-- Автоматична ініціалізація при завантаженні скрипта
SpaceStationUI.Initialize()

return SpaceStationUI