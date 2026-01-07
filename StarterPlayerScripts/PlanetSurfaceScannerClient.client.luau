--[[
================================================================================
KOSMICMAZER — PlanetSurfaceScanner Client Script
================================================================================

Purpose: Handles client-side planet surface scanner functionality and UI
Version: 2.0

Features:
- Receives scan results from server via RemoteEvents
- Displays scan results UI in Windows 3.1 style
- Handles teleportation activation notifications
- Shows visual feedback for scanning
- Manages GUI lifecycle and cleanup

API:
- createScanResultsGui(): Creates the scan results interface
- displayScanResults(data): Displays discovered locations
- showTeleportationNotification(isActive): Shows activation status

Calls to:
- ReplicatedStorage: PlanetSurfaceScanner:Results RemoteEvent
- TweenService: Creates UI animations
- StarterGui: Manages GUI display

Called from:
- Automatic execution on player join
- Server RemoteEvent callbacks

Events:
- scanResultsEvent.OnClientEvent: Handles server communications

Dependencies:
- ReplicatedStorage service
- StarterGui service
- TweenService
- Players service

ChangeLog:
- Version 2.1: Removed duplicate teleportation notifications - TeleportationClient now handles notifications
- Version 2.0: Enhanced UI with Windows 3.1 styling
- Version 1.5: Added teleportation notifications
- Version 1.0: Initial implementation for scanner UI

================================================================================
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Ensure RemoteEvent exists
local scanResultsEvent = ReplicatedStorage:FindFirstChild("PlanetSurfaceScanner:Results")
if not scanResultsEvent then
	scanResultsEvent = Instance.new("RemoteEvent")
	scanResultsEvent.Name = "PlanetSurfaceScanner:Results"
	scanResultsEvent.Parent = ReplicatedStorage
	print("[PlanetSurfaceScannerClient] Created RemoteEvent PlanetSurfaceScanner:Results")
else
	print("[PlanetSurfaceScannerClient] RemoteEvent PlanetSurfaceScanner:Results already exists")
end

-- UI state
local scanResultsGui = nil
local teleportationActive = false

-- Create scan results UI
local function createScanResultsGui()
	if scanResultsGui then
		scanResultsGui:Destroy()
	end

	scanResultsGui = Instance.new("ScreenGui")
	scanResultsGui.Name = "ScanResultsGui"
	scanResultsGui.ResetOnSpawn = false
	scanResultsGui.IgnoreGuiInset = true
	scanResultsGui.Parent = player:WaitForChild("PlayerGui")

	-- Main frame (larger for better readability) - Windows 3.1 style
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 600, 0, 400) -- Increased for better readability
	mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200) -- Adjusted position for centering
	mainFrame.BackgroundColor3 = Color3.new(0.8, 0.8, 0.8) -- Windows 3.1 gray background
	mainFrame.BorderSizePixel = 2
	mainFrame.BorderColor3 = Color3.new(0, 0, 0) -- Black border
	mainFrame.Parent = scanResultsGui

	-- Add title bar (Windows 3.1 style)
	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.Size = UDim2.new(1, 0, 0, 20)
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
	titleText.Text = "🔍 Результати Сканування"
	titleText.TextColor3 = Color3.new(1, 1, 1)
	titleText.TextScaled = false
	titleText.Font = Enum.Font.SourceSans
	titleText.TextSize = 24 -- Doubled from 12 to 24
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
	closeButton.TextSize = 24 -- Doubled from 12 to 24
	closeButton.Parent = titleBar

	-- Close button functionality
	closeButton.MouseButton1Click:Connect(function()
		scanResultsGui:Destroy()
		scanResultsGui = nil
	end)

	-- Planet name header (always at top)
	local planetHeader = Instance.new("Frame")
	planetHeader.Name = "PlanetHeader"
	planetHeader.Size = UDim2.new(1, -4, 0, 50)
	planetHeader.Position = UDim2.new(0, 2, 0, 22)
	planetHeader.BackgroundColor3 = Color3.new(0.7, 0.7, 0.7) -- Slightly darker gray
	planetHeader.BorderSizePixel = 1
	planetHeader.BorderColor3 = Color3.new(0, 0, 0)
	planetHeader.Parent = mainFrame

	-- Planet name label
	local planetNameLabel = Instance.new("TextLabel")
	planetNameLabel.Name = "PlanetNameLabel"
	planetNameLabel.Size = UDim2.new(1, -10, 1, 0)
	planetNameLabel.Position = UDim2.new(0, 5, 0, 0)
	planetNameLabel.BackgroundTransparency = 1
	planetNameLabel.Text = "🪐 Zalizyaka" -- Will be updated dynamically
	planetNameLabel.TextColor3 = Color3.new(0, 0, 0)
	planetNameLabel.TextScaled = false
	planetNameLabel.Font = Enum.Font.SourceSansBold
	planetNameLabel.TextSize = 28 -- Large font for planet name
	planetNameLabel.TextXAlignment = Enum.TextXAlignment.Center
	planetNameLabel.Parent = planetHeader

	-- Content frame (below planet header)
	local contentFrame = Instance.new("Frame")
	contentFrame.Name = "ContentFrame"
	contentFrame.Size = UDim2.new(1, -4, 1, -76) -- Adjusted for planet header
	contentFrame.Position = UDim2.new(0, 2, 0, 74) -- Adjusted for planet header
	contentFrame.BackgroundColor3 = Color3.new(0.8, 0.8, 0.8)
	contentFrame.BorderSizePixel = 1
	contentFrame.BorderColor3 = Color3.new(0.5, 0.5, 0.5)
	contentFrame.Parent = mainFrame

	-- Title (moved to title bar above)

	-- Scrolling frame for locations (Windows 3.1 style)
	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Name = "ScrollingFrame"
	scrollingFrame.Size = UDim2.new(1, -10, 1, -10)
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

	-- Close button (moved to title bar above)

	return mainFrame, contentFrame, scrollingFrame, layout, planetNameLabel
end

-- Display scan results
local function displayScanResults(data)
	local mainFrame, contentFrame, scrollingFrame, layout, planetNameLabel = createScanResultsGui()

	if not data.locations or #data.locations == 0 then
		-- No locations found (Windows 3.1 style)
		local noResultsLabel = Instance.new("TextLabel")
		noResultsLabel.Size = UDim2.new(1, -20, 0, 40)
		noResultsLabel.BackgroundTransparency = 1
		noResultsLabel.Text = "🌌 Відкритих локацій не знайдено\nДосліджуйте планету, щоб відкрити нові місця!"
		noResultsLabel.TextColor3 = Color3.new(0, 0, 0)
		noResultsLabel.TextScaled = false
		noResultsLabel.Font = Enum.Font.SourceSans
		noResultsLabel.TextSize = 28 -- Doubled from 14 to 28
		noResultsLabel.TextWrapped = true
		noResultsLabel.Parent = scrollingFrame

		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 50)
	else
		-- Display discovered locations
		for i, location in ipairs(data.locations) do
			local locationFrame = Instance.new("Frame")
			locationFrame.Name = "Location" .. i
			locationFrame.Size = UDim2.new(1, -10, 0, 80) -- Increased for larger text
			locationFrame.BackgroundColor3 = Color3.new(0.8, 0.8, 0.8) -- Windows 3.1 gray
			locationFrame.BorderSizePixel = 1
			locationFrame.BorderColor3 = Color3.new(0, 0, 0) -- Black border
			locationFrame.LayoutOrder = i
			locationFrame.Parent = scrollingFrame

			-- Location status icon (new/visited)
			local statusIcon = Instance.new("TextLabel")
			statusIcon.Name = "StatusIcon"
			statusIcon.Size = UDim2.new(0, 30, 0, 30)
			statusIcon.Position = UDim2.new(0, 5, 0, 5)
			statusIcon.BackgroundTransparency = 1
			statusIcon.Text = location.IsVisited and "✅" or "🆕" -- Checkmark for visited, star for new
			statusIcon.TextColor3 = location.IsVisited and Color3.new(0, 0.5, 0) or Color3.new(1, 0.5, 0) -- Green for visited, orange for new
			statusIcon.TextScaled = false
			statusIcon.Font = Enum.Font.SourceSans
			statusIcon.TextSize = 24 -- Large icon
			statusIcon.TextXAlignment = Enum.TextXAlignment.Center
			statusIcon.Parent = locationFrame

			-- Location name (Windows 3.1 style)
			local nameLabel = Instance.new("TextLabel")
			nameLabel.Name = "NameLabel"
			nameLabel.Size = UDim2.new(1, -50, 0, 30) -- Adjusted for icon
			nameLabel.Position = UDim2.new(0, 40, 0, 5)
			nameLabel.BackgroundTransparency = 1
			nameLabel.Text = location.DisplayName
			nameLabel.TextColor3 = Color3.new(0, 0, 0) -- Black text
			nameLabel.TextScaled = false
			nameLabel.Font = Enum.Font.SourceSansBold
			nameLabel.TextSize = 24 -- Doubled from 14 to 24
			nameLabel.TextXAlignment = Enum.TextXAlignment.Left
			nameLabel.Parent = locationFrame

			-- Location description (Windows 3.1 style)
			local descLabel = Instance.new("TextLabel")
			descLabel.Name = "DescLabel"
			descLabel.Size = UDim2.new(1, -50, 0, 25) -- Adjusted for icon
			descLabel.Position = UDim2.new(0, 40, 0, 35)
			descLabel.BackgroundTransparency = 1
			descLabel.Text = location.IsVisited and "Відвідано" or "Нова локація"
			descLabel.TextColor3 = location.IsVisited and Color3.new(0, 0.5, 0) or Color3.new(1, 0.5, 0) -- Green for visited, orange for new
			descLabel.TextScaled = false
			descLabel.Font = Enum.Font.SourceSans
			descLabel.TextSize = 18 -- Medium font for description
			descLabel.TextXAlignment = Enum.TextXAlignment.Left
			descLabel.Parent = locationFrame

			-- Hover effect (Windows 3.1 style)
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
		end

		-- Update planet name in header
		if data.planetName then
			planetNameLabel.Text = "🪐 " .. data.planetName
		end

		-- Update canvas size
		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #data.locations * 85) -- Adjusted for larger frames
	end

	-- Animate appearance (Windows 3.1 style)
	mainFrame.Size = UDim2.new(0, 0, 0, 0)
	local appearTween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 600, 0, 400) -- Windows 3.1 style appearance
	})
	appearTween:Play()
end

-- Show teleportation activation notification
local function showTeleportationNotification(isActive)
	if isActive then
		-- Create notification
		local notification = Instance.new("ScreenGui")
		notification.Name = "TeleportationNotification"
		notification.ResetOnSpawn = false
		notification.IgnoreGuiInset = true
		notification.Parent = player:WaitForChild("PlayerGui")

		local frame = Instance.new("Frame")
		frame.Name = "Frame"
		frame.Size = UDim2.new(0, 300, 0, 80)
		frame.Position = UDim2.new(1, -320, 0, 20)
		frame.BackgroundColor3 = Color3.new(0.1, 0.8, 0.1)
		frame.BorderSizePixel = 0
		frame.Parent = notification

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, -20, 1, -20)
		label.Position = UDim2.new(0, 10, 0, 10)
		label.BackgroundTransparency = 1
		label.Text = "🚀 Система телепортації\nактивована!"
		label.TextColor3 = Color3.new(1, 1, 1)
		label.TextScaled = true
		label.Font = Enum.Font.GothamBold
		label.Parent = frame

		-- Animate and auto-remove
		frame.Position = UDim2.new(1, 0, 0, 20)
		local slideIn = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(1, -320, 0, 20)
		})
		slideIn:Play()

		task.wait(5)

		local slideOut = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = UDim2.new(1, 0, 0, 20)
		})
		slideOut:Play()
		slideOut.Completed:Connect(function()
			notification:Destroy()
		end)
	end
end

-- Handle scan results
scanResultsEvent.OnClientEvent:Connect(function(action, data)
	if action == "ScanResults" then
		print("[PlanetSurfaceScannerClient] Received scan results for " .. data.player)
		displayScanResults(data)
	elseif action == "TeleportationActivated" then
		print("[PlanetSurfaceScannerClient] Teleportation system " .. (data and "activated" or "deactivated"))
		-- Note: TeleportationClient handles the notification now to avoid duplicates
		teleportationActive = data
	elseif action == "ForceCloseGUI" then
		print("[PlanetSurfaceScannerClient] Force closing scanner GUI")
		if scanResultsGui then
			scanResultsGui:Destroy()
			scanResultsGui = nil
		end
	end
end)

print("[PlanetScannerClient] PlanetScanner client script loaded")