--[[
================================================================================
KOSMICMAZER — Teleportation Client Script
================================================================================

Purpose: Handles client-side teleportation UI and interactions
Version: 2.0

Features:
- Shows teleportation UI when player stands on active SpawnLocation
- Displays available discovered locations in Windows 3.1 style
- Handles location selection and teleportation requests
- Shows teleportation effects and notifications
- Integrates with teleportation state changes
- Includes UI debounce to prevent flickering

API:
- createTeleportGui(): Creates teleportation interface
- showTeleportLocations(data): Displays available locations
- showNoLocationsMessage(data): Shows no locations message
- showNotification(message, type): Displays notifications
- hideTeleportGui(): Hides teleportation UI

Calls to:
- ReplicatedStorage: TeleportationEvent, TeleportationStateEvent
- TweenService: Creates UI animations
- StarterGui: Manages GUI display
- UserInputService: Handles keyboard input

Called from:
- Automatic execution on player join
- Server RemoteEvent callbacks

Events:
- teleportEvent.OnClientEvent: Handles teleportation requests
- teleportStateEvent.OnClientEvent: Handles state changes
- UserInputService.InputBegan: Handles Escape key

Dependencies:
- ReplicatedStorage service
- StarterGui service
- TweenService
- UserInputService
- Players service

ChangeLog:
- Version 2.2: ENHANCED - Added 3-second delay after successful teleportation before allowing new teleport
- Version 2.1: CRITICAL FIX - Enhanced UI debounce mechanism to prevent flickering
- Version 2.1: IMPROVED - Better handling of rapid UI state changes
- Version 2.1: IMPROVED - Added proper cleanup for UI elements
- Version 2.0: Enhanced UI with Windows 3.1 styling and debounce
- Version 1.5: Added state change notifications
- Version 1.0: Initial implementation for teleportation UI

================================================================================
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Load RemoteEventsRegistry
local RemoteEventsRegistry = require(ReplicatedStorage:WaitForChild("RemoteEventsRegistry"))

-- Version tracking
local scriptVersion = "2.2"

-- RemoteEvents (using registry for better error handling)
print(string.format("[TeleportClient %s] Очікування RemoteEvents...", scriptVersion))
local teleportEvent = RemoteEventsRegistry.WaitFor("TeleportationEvent", 30)
local teleportStateEvent = RemoteEventsRegistry.WaitFor("TeleportationStateEvent", 30)
local playerLocationEvent = RemoteEventsRegistry.WaitFor("PlayerLocationChanged", 30)

if not teleportEvent or not teleportStateEvent or not playerLocationEvent then
	error(string.format("[TeleportClient %s] ❌ Не вдалося отримати RemoteEvents! Гра не може працювати.", scriptVersion))
end

print(string.format("[TeleportClient %s] ✅ RemoteEvents готові", scriptVersion))

-- UI state
local teleportGui = nil
local isTeleporting = false
local uiDebounce = false
local lastUIAction = 0 -- Track last UI action time

-- Current player location (synced from server)
local currentPlayerLocation = {
	PlanetId = "Unknown",
	LocationId = "Unknown"
}

-- Hide teleportation GUI
local function hideTeleportGui()
	if teleportGui then
		local mainFrame = teleportGui:FindFirstChild("MainFrame")
		if mainFrame then
			local hideTween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Size = UDim2.new(0, 0, 0, 0)
			})
			hideTween:Play()
			hideTween.Completed:Connect(function()
				if teleportGui then
					teleportGui:Destroy()
					teleportGui = nil
				end
			end)
		else
			teleportGui:Destroy()
			teleportGui = nil
		end

		-- Reset teleporting state when UI is hidden
		isTeleporting = false
	end
end

-- Create teleportation UI (Windows 3.1 style)
local function createTeleportGui()
	if teleportGui then
		teleportGui:Destroy()
	end

	teleportGui = Instance.new("ScreenGui")
	teleportGui.Name = "TeleportationGui"
	teleportGui.ResetOnSpawn = false
	teleportGui.IgnoreGuiInset = true
	teleportGui.Parent = player:WaitForChild("PlayerGui")

	-- Main frame (Windows 3.1 style)
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 600, 0, 450)
	mainFrame.Position = UDim2.new(0.5, -300, 0.5, -225)
	mainFrame.BackgroundColor3 = Color3.new(0.8, 0.8, 0.8) -- Windows 3.1 gray background
	mainFrame.BorderSizePixel = 2
	mainFrame.BorderColor3 = Color3.new(0, 0, 0) -- Black border
	mainFrame.Parent = teleportGui

	-- Add title bar (Windows 3.1 style)
	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.Size = UDim2.new(1, 0, 0, 25)
	titleBar.Position = UDim2.new(0, 0, 0, 0)
	titleBar.BackgroundColor3 = Color3.new(0, 0, 0.5) -- Dark blue title bar
	titleBar.BorderSizePixel = 0
	titleBar.Parent = mainFrame

	-- Title text
	local titleText = Instance.new("TextLabel")
	titleText.Name = "TitleText"
	titleText.Size = UDim2.new(1, -40, 1, 0)
	titleText.Position = UDim2.new(0, 5, 0, 0)
	titleText.BackgroundTransparency = 1
	titleText.Text = "🚀 Телепортація"
	titleText.TextColor3 = Color3.new(1, 1, 1)
	titleText.TextScaled = false
	titleText.Font = Enum.Font.SourceSans
	titleText.TextSize = 18
	titleText.TextXAlignment = Enum.TextXAlignment.Left
	titleText.Parent = titleBar

	-- Close button [X] in top-right corner
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 20, 0, 20)
	closeButton.Position = UDim2.new(1, -20, 0, 0)
	closeButton.BackgroundColor3 = Color3.new(0.8, 0.8, 0.8)
	closeButton.BorderSizePixel = 1
	closeButton.BorderColor3 = Color3.new(0, 0, 0)
	closeButton.Text = "X"
	closeButton.TextColor3 = Color3.new(0, 0, 0)
	closeButton.Font = Enum.Font.SourceSans
	closeButton.TextSize = 14
	closeButton.Parent = titleBar

	-- Close button functionality
	closeButton.MouseButton1Click:Connect(function()
		hideTeleportGui()
	end)

	-- Content frame
	local contentFrame = Instance.new("Frame")
	contentFrame.Name = "ContentFrame"
	contentFrame.Size = UDim2.new(1, -4, 1, -29)
	contentFrame.Position = UDim2.new(0, 2, 0, 27)
	contentFrame.BackgroundColor3 = Color3.new(0.8, 0.8, 0.8)
	contentFrame.BorderSizePixel = 1
	contentFrame.BorderColor3 = Color3.new(0.5, 0.5, 0.5)
	contentFrame.Parent = mainFrame

	-- Scrolling frame for locations (Windows 3.1 style)
	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Name = "ScrollingFrame"
	scrollingFrame.Size = UDim2.new(1, -10, 1, -50)
	scrollingFrame.Position = UDim2.new(0, 5, 0, 5)
	scrollingFrame.BackgroundColor3 = Color3.new(1, 1, 1) -- White background
	scrollingFrame.BorderSizePixel = 1
	scrollingFrame.BorderColor3 = Color3.new(0.5, 0.5, 0.5)
	scrollingFrame.ScrollBarThickness = 12
	scrollingFrame.Parent = contentFrame

	-- Layout for scrolling frame
	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 5)
	layout.Parent = scrollingFrame

	-- Status bar at bottom
	local statusBar = Instance.new("Frame")
	statusBar.Name = "StatusBar"
	statusBar.Size = UDim2.new(1, 0, 0, 25)
	statusBar.Position = UDim2.new(0, 0, 1, -25)
	statusBar.BackgroundColor3 = Color3.new(0.7, 0.7, 0.7)
	statusBar.BorderSizePixel = 1
	statusBar.BorderColor3 = Color3.new(0, 0, 0)
	statusBar.Parent = contentFrame

	local statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "StatusLabel"
	statusLabel.Size = UDim2.new(1, -10, 1, 0)
	statusLabel.Position = UDim2.new(0, 5, 0, 0)
	statusLabel.BackgroundTransparency = 1
	-- Show current location in status
	local locationText = currentPlayerLocation.LocationId ~= "Unknown"
		and string.format("Поточна локація: %s | Оберіть пункт призначення", currentPlayerLocation.LocationId)
		or "Оберіть локацію для телепортації"
	statusLabel.Text = locationText
	statusLabel.TextColor3 = Color3.new(0, 0, 0)
	statusLabel.TextScaled = false
	statusLabel.Font = Enum.Font.SourceSans
	statusLabel.TextSize = 14
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.Parent = statusBar

	-- Allow closing with Escape key
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == Enum.KeyCode.Escape and teleportGui then
			hideTeleportGui()
		end
	end)

	return mainFrame, scrollingFrame, layout, statusLabel
end

-- Show teleportation locations
local function showTeleportLocations(data)
	local mainFrame, scrollingFrame, layout, statusLabel = createTeleportGui()

	-- Display discovered locations
	for i, location in ipairs(data.locations) do
		local locationFrame = Instance.new("Frame")
		locationFrame.Name = "Location" .. i
		locationFrame.Size = UDim2.new(1, -10, 0, 80)
		locationFrame.BackgroundColor3 = Color3.new(0.8, 0.8, 0.8) -- Windows 3.1 gray
		locationFrame.BorderSizePixel = 1
		locationFrame.BorderColor3 = Color3.new(0, 0, 0) -- Black border
		locationFrame.LayoutOrder = i
		locationFrame.Parent = scrollingFrame

		-- Location icon
		local iconLabel = Instance.new("TextLabel")
		iconLabel.Name = "IconLabel"
		iconLabel.Size = UDim2.new(0, 40, 0, 40)
		iconLabel.Position = UDim2.new(0, 5, 0, 5)
		iconLabel.BackgroundTransparency = 1
		iconLabel.Text = location.LocationId == "SpaceStation" and "🚀" or "📍"
		iconLabel.TextColor3 = Color3.new(0, 0, 0)
		iconLabel.TextScaled = false
		iconLabel.Font = Enum.Font.SourceSans
		iconLabel.TextSize = 24
		iconLabel.TextXAlignment = Enum.TextXAlignment.Center
		iconLabel.Parent = locationFrame

		-- Location name
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "NameLabel"
		nameLabel.Size = UDim2.new(1, -150, 0, 30)
		nameLabel.Position = UDim2.new(0, 50, 0, 5)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = location.DisplayName
		nameLabel.TextColor3 = Color3.new(0, 0, 0) -- Black text
		nameLabel.TextScaled = false
		nameLabel.Font = Enum.Font.SourceSansBold
		nameLabel.TextSize = 18
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Parent = locationFrame

		-- Planet name
		local planetLabel = Instance.new("TextLabel")
		planetLabel.Name = "PlanetLabel"
		planetLabel.Size = UDim2.new(1, -150, 0, 20)
		planetLabel.Position = UDim2.new(0, 50, 0, 35)
		planetLabel.BackgroundTransparency = 1
		planetLabel.Text = "🪐 " .. location.PlanetName
		planetLabel.TextColor3 = Color3.new(0.2, 0.2, 0.2)
		planetLabel.TextScaled = false
		planetLabel.Font = Enum.Font.SourceSans
		planetLabel.TextSize = 14
		planetLabel.TextXAlignment = Enum.TextXAlignment.Left
		planetLabel.Parent = locationFrame

		-- Teleport button (Windows 3.1 style)
		local teleportButton = Instance.new("TextButton")
		teleportButton.Name = "TeleportButton"
		teleportButton.Size = UDim2.new(0, 90, 0, 60)
		teleportButton.Position = UDim2.new(1, -95, 0, 10)
		teleportButton.BackgroundColor3 = Color3.new(0.8, 0.8, 0.8)
		teleportButton.BorderSizePixel = 2
		teleportButton.BorderColor3 = Color3.new(0, 0, 0)
		teleportButton.Text = "Телепорт"
		teleportButton.TextColor3 = Color3.new(0, 0, 0)
		teleportButton.Font = Enum.Font.SourceSansBold
		teleportButton.TextSize = 14
		teleportButton.Parent = locationFrame

		-- Teleport button functionality
		teleportButton.MouseButton1Click:Connect(function()
			print("[TeleportClient] 📍 Кнопка телепорту:", location.DisplayName, "isTeleporting:", tostring(isTeleporting))


			if not isTeleporting then
				isTeleporting = true
				teleportButton.Text = "Телепорт..."
				teleportButton.BackgroundColor3 = Color3.new(0.7, 0.7, 0.7)
				statusLabel.Text = "Телепортування на " .. location.DisplayName

				print("[TeleportClient] 📤 Відправка запиту:", location.LocationId)
				teleportEvent:FireServer(location.LocationId)
				print("[TeleportClient] ✅ Запит відправлено:", location.LocationId)
			else
				print("[TeleportClient] ⚠️ Телепортація вже виконується")
			end
		end)

		-- Hover effects (Windows 3.1 style)
		local hoverTween = nil
		locationFrame.MouseEnter:Connect(function()
			hoverTween = TweenService:Create(locationFrame, TweenInfo.new(0.1), {
				BackgroundColor3 = Color3.new(0.6, 0.6, 0.6) -- Lighter gray on hover
			})
			hoverTween:Play()
		end)

		locationFrame.MouseLeave:Connect(function()
			if hoverTween then
				hoverTween:Cancel()
			end
			hoverTween = TweenService:Create(locationFrame, TweenInfo.new(0.1), {
				BackgroundColor3 = Color3.new(0.8, 0.8, 0.8) -- Back to normal gray
			})
			hoverTween:Play()
		end)

		local buttonHoverTween = nil
		teleportButton.MouseEnter:Connect(function()
			if not isTeleporting then
				buttonHoverTween = TweenService:Create(teleportButton, TweenInfo.new(0.1), {
					BackgroundColor3 = Color3.new(0.9, 0.9, 0.9)
				})
				buttonHoverTween:Play()
			end
		end)

		teleportButton.MouseLeave:Connect(function()
			if not isTeleporting then
				if buttonHoverTween then
					buttonHoverTween:Cancel()
				end
				buttonHoverTween = TweenService:Create(teleportButton, TweenInfo.new(0.1), {
					BackgroundColor3 = Color3.new(0.8, 0.8, 0.8)
				})
				buttonHoverTween:Play()
			end
		end)
	end

	-- Update canvas size
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #data.locations * 85)

	-- Animate appearance (Windows 3.1 style)
	mainFrame.Size = UDim2.new(0, 0, 0, 0)
	local appearTween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 600, 0, 450)
	})
	appearTween:Play()
end

-- Show message when no locations available
local function showNoLocationsMessage(data)
	local mainFrame, scrollingFrame, layout, statusLabel = createTeleportGui()

	local messageLabel = Instance.new("TextLabel")
	messageLabel.Size = UDim2.new(1, -20, 0, 60)
	messageLabel.BackgroundTransparency = 1
	messageLabel.Text = data.message
	messageLabel.TextColor3 = Color3.new(0, 0, 0)
	messageLabel.TextScaled = false
	messageLabel.Font = Enum.Font.SourceSans
	messageLabel.TextSize = 18
	messageLabel.TextWrapped = true
	messageLabel.Parent = scrollingFrame

	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 70)

	-- Animate appearance
	mainFrame.Size = UDim2.new(0, 0, 0, 0)
	local appearTween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 600, 0, 450)
	})
	appearTween:Play()
end

-- Show notification
local function showNotification(message, type)
	local notification = Instance.new("ScreenGui")
	notification.Name = "TeleportNotification"
	notification.ResetOnSpawn = false
	notification.IgnoreGuiInset = true
	notification.Parent = player:WaitForChild("PlayerGui")

	local frame = Instance.new("Frame")
	frame.Name = "Frame"
	frame.Size = UDim2.new(0, 300, 0, 80)
	frame.Position = UDim2.new(0.5, -150, 0.8, 0)
	frame.BackgroundColor3 = type == "success" and Color3.new(0.1, 0.8, 0.1) or Color3.new(0.8, 0.2, 0.2)
	frame.BorderSizePixel = 2
	frame.BorderColor3 = Color3.new(0, 0, 0)
	frame.Parent = notification

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 1, -20)
	label.Position = UDim2.new(0, 10, 0, 10)
	label.BackgroundTransparency = 1
	label.Text = message
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextScaled = true
	label.Font = Enum.Font.SourceSansBold
	label.Parent = frame

	-- Animate and auto-remove
	frame.Position = UDim2.new(0.5, -150, 1, 100)
	local slideIn = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, -150, 0.8, 0)
	})
	slideIn:Play()

	task.wait(3)

	local slideOut = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = UDim2.new(0.5, -150, 1, 100)
	})
	slideOut:Play()
	slideOut.Completed:Connect(function()
		notification:Destroy()
	end)
end

-- Handle teleportation events
local function onTeleportEvent(action, data)
	local currentTime = tick()

	print("[TeleportClient] 📥 Подія:", tostring(action))
	--print("[TeleportationClient] Data: " .. tostring(data))
	--print("[TeleportationClient] Current time: " .. currentTime)
	-- print("[TeleportationClient] Last UI action: " .. lastUIAction)
	--print("[TeleportationClient] UI Debounce: " .. tostring(uiDebounce))

	-- Enhanced debounce to prevent rapid UI changes
	if uiDebounce and (currentTime - lastUIAction) < 0.3 then
		print("[TeleportClient] ⚠️ Debounce активний, ігнорую")
		return
	end

	if action == "ShowTeleportUI" then
		uiDebounce = true
		lastUIAction = currentTime
		print("[TeleportClient] 📺 Показую UI телепортації для:", data.player)

		-- Hide existing UI before showing new one
		if teleportGui then
			hideTeleportGui()
			task.wait(0.1)
		end

		showTeleportLocations(data)
		task.wait(0.3) -- Small delay to prevent rapid changes
		uiDebounce = false

	elseif action == "ShowNoLocationsMessage" then
		uiDebounce = true
		lastUIAction = currentTime
		print("[TeleportClient] 📺 Немає локацій")

		-- Hide existing UI before showing new one
		if teleportGui then
			hideTeleportGui()
			task.wait(0.1)
		end

		showNoLocationsMessage(data)
		task.wait(0.3) -- Small delay to prevent rapid changes
		uiDebounce = false

	elseif action == "HideTeleportUI" then
		uiDebounce = true
		lastUIAction = currentTime
		print("[TeleportClient] 📺 Сховую UI")
		hideTeleportGui()
		task.wait(0.3) -- Small delay to prevent rapid changes
		uiDebounce = false

	elseif action == "TeleportSuccess" then
		print("[TeleportClient] ✅ Телепортацію успішно:", tostring(data))
		isTeleporting = false
		hideTeleportGui()
		showNotification(data, "success")

		-- Add 3-second delay before allowing teleportation again
		task.wait(3)
		uiDebounce = false

	elseif action == "TeleportError" then
		warn("[TeleportClient] ❌ Помилка телепортації:", tostring(data))
		isTeleporting = false
		showNotification(data, "error")
	end

	print("[TeleportClient] ✅ Подію оброблено:", tostring(action))
end

-- Handle teleportation state changes
local function onTeleportationStateChange(isActive)
	print("[TeleportClient] 🔄 Стан системи:", (isActive and "АКТИВНА" or "НЕАКТИВНА"))

	if isActive then
		-- Show notification that teleportation is now active
		showNotification("🚀 Система телепортації активована!", "success")
	end
end

-- Handle player location updates from server
local function onPlayerLocationChanged(locationData)
	if locationData then
		currentPlayerLocation.PlanetId = locationData.PlanetId
		currentPlayerLocation.LocationId = locationData.LocationId
		print(string.format("[TeleportClient] 📍 Location updated: %s/%s",
			locationData.PlanetId, locationData.LocationId))
	end
end

-- Connect to events
teleportEvent.OnClientEvent:Connect(onTeleportEvent)
teleportStateEvent.OnClientEvent:Connect(onTeleportationStateChange)
playerLocationEvent.OnClientEvent:Connect(onPlayerLocationChanged)

print(string.format("[TeleportClient %s] 🚀 Клієнт телепортації завантажено", scriptVersion))