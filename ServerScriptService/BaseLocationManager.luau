--[[
================================================================================
KOSMICMAZER — Base Location Manager
================================================================================

Purpose: Base class for all location managers (SpaceStation, Planet, Location)
Version: 1.0

Features:
- Common lifecycle methods (Initialize, Cleanup, Update)
- Player tracking and management
- Resource management utilities
- Event connection management
- Logging utilities
- State validation

API (Override in derived classes):
- Initialize(locationModel): Initialize location-specific logic
- Cleanup(): Clean up before unloading
- OnPlayerEnter(player): Handle player entering location
- OnPlayerLeave(player): Handle player leaving location
- Update(deltaTime): Update loop (optional)

Public Methods (Base implementation):
- GetActivePlayers(): Returns list of active players
- GetActivePlayersCount(): Returns count of active players
- IsInitialized(): Returns initialization status
- TrackPlayer(player): Add player to active list
- UntrackPlayer(player): Remove player from active list
- ConnectEvent(connection): Register event connection for cleanup
- DisconnectAllEvents(): Disconnect all registered events

Calls to:
- None (base class)

Called from:
- SpaceStationManager (inherits)
- PlanetManager (inherits)
- LocationController (inherits)

Dependencies:
- None (standalone base class)

ChangeLog:
- Version 1.0: Initial implementation as base class for location managers

================================================================================
]]

local BaseLocationManager = {}
BaseLocationManager.__index = BaseLocationManager

--[[
	Create a new instance of BaseLocationManager
	@param locationId string - Unique identifier for this location
	@param locationName string - Display name for this location
	@return table - New BaseLocationManager instance
]]
function BaseLocationManager.new(locationId, locationName)
	local self = setmetatable({}, BaseLocationManager)
	
	-- Core properties
	self.LocationId = locationId or "Unknown"
	self.LocationName = locationName or "Unknown Location"
	self.IsActive = false
	self.IsReady = false
	
	-- Player tracking
	self.ActivePlayers = {}
	self.PlayerData = {} -- Custom data per player
	
	-- Event connections
	self.Connections = {}
	
	-- Timing
	self.InitializeTime = 0
	self.LastUpdateTime = 0
	
	-- Logging prefix
	self.LogPrefix = string.format("[%s]", self.LocationName)
	
	return self
end

--[[
	Initialize the location manager
	Override this in derived classes
	@param locationModel Instance - The workspace model for this location
	@return boolean - Success status
]]
function BaseLocationManager:Initialize(locationModel)
	if self.IsActive then
		warn(self.LogPrefix, "⚠️ Already initialized")
		return false
	end
	
	self.LocationModel = locationModel
	self.InitializeTime = os.clock()
	self.IsActive = true
	
	print(self.LogPrefix, "🚀 Initializing...")
	
	-- Call derived class initialization
	local success, err = pcall(function()
		self:OnInitialize(locationModel)
	end)
	
	if not success then
		warn(self.LogPrefix, "❌ Initialization failed:", err)
		self.IsActive = false
		return false
	end
	
	self.IsReady = true
	print(self.LogPrefix, "✅ Initialized successfully")
	
	return true
end

--[[
	Cleanup the location manager before unloading
	Override this in derived classes
	@return boolean - Success status
]]
function BaseLocationManager:Cleanup()
	if not self.IsActive then
		warn(self.LogPrefix, "⚠️ Not active, nothing to cleanup")
		return false
	end
	
	print(self.LogPrefix, "🧹 Cleaning up...")
	
	-- Call derived class cleanup
	pcall(function()
		self:OnCleanup()
	end)
	
	-- Disconnect all events
	self:DisconnectAllEvents()
	
	-- Clear player tracking
	for playerId, _ in pairs(self.ActivePlayers) do
		self:UntrackPlayer(game.Players:GetPlayerByUserId(playerId))
	end
	
	self.IsActive = false
	self.IsReady = false
	
	print(self.LogPrefix, "✅ Cleanup complete")
	
	return true
end

--[[
	Update loop (called periodically if needed)
	Override this in derived classes for continuous logic
	@param deltaTime number - Time since last update
]]
function BaseLocationManager:Update(deltaTime)
	if not self.IsReady then
		return
	end
	
	self.LastUpdateTime = os.clock()
	
	-- Call derived class update
	pcall(function()
		self:OnUpdate(deltaTime)
	end)
end

--[[
	Handle player entering location
	@param player Player - The player instance
]]
function BaseLocationManager:OnPlayerEnter(player)
	if not player or not player:IsA("Player") then
		warn(self.LogPrefix, "❌ Invalid player in OnPlayerEnter")
		return
	end
	
	self:TrackPlayer(player)
	print(self.LogPrefix, "👤 Player entered:", player.Name, "| Total players:", self:GetActivePlayersCount())
	
	-- Call derived class handler
	pcall(function()
		self:OnPlayerEntered(player)
	end)
end

--[[
	Handle player leaving location
	@param player Player - The player instance
]]
function BaseLocationManager:OnPlayerLeave(player)
	if not player or not player:IsA("Player") then
		warn(self.LogPrefix, "❌ Invalid player in OnPlayerLeave")
		return
	end
	
	-- Call derived class handler before untracking
	pcall(function()
		self:OnPlayerLeft(player)
	end)
	
	self:UntrackPlayer(player)
	print(self.LogPrefix, "👤 Player left:", player.Name, "| Total players:", self:GetActivePlayersCount())
end

--[[
	Track a player as active in this location
	@param player Player - The player to track
]]
function BaseLocationManager:TrackPlayer(player)
	if not player or not player:IsA("Player") then
		return
	end
	
	local userId = player.UserId
	if not self.ActivePlayers[userId] then
		self.ActivePlayers[userId] = {
			Player = player,
			JoinTime = os.clock(),
		}
		self.PlayerData[userId] = {} -- Initialize custom data table
	end
end

--[[
	Untrack a player from this location
	@param player Player - The player to untrack
]]
function BaseLocationManager:UntrackPlayer(player)
	if not player or not player:IsA("Player") then
		return
	end
	
	local userId = player.UserId
	self.ActivePlayers[userId] = nil
	self.PlayerData[userId] = nil
end

--[[
	Get list of active players
	@return table - Array of Player instances
]]
function BaseLocationManager:GetActivePlayers()
	local players = {}
	for userId, data in pairs(self.ActivePlayers) do
		if data.Player and data.Player.Parent then
			table.insert(players, data.Player)
		else
			-- Clean up disconnected players
			self.ActivePlayers[userId] = nil
			self.PlayerData[userId] = nil
		end
	end
	return players
end

--[[
	Get count of active players
	@return number - Number of active players
]]
function BaseLocationManager:GetActivePlayersCount()
	local count = 0
	for _, _ in pairs(self.ActivePlayers) do
		count = count + 1
	end
	return count
end

--[[
	Check if location is initialized
	@return boolean - Initialization status
]]
function BaseLocationManager:IsInitialized()
	return self.IsReady
end

--[[
	Register an event connection for automatic cleanup
	@param connection RBXScriptConnection - The connection to track
]]
function BaseLocationManager:ConnectEvent(connection)
	if connection and typeof(connection) == "RBXScriptConnection" then
		table.insert(self.Connections, connection)
	end
end

--[[
	Disconnect all registered event connections
]]
function BaseLocationManager:DisconnectAllEvents()
	for _, connection in ipairs(self.Connections) do
		if connection and connection.Connected then
			connection:Disconnect()
		end
	end
	self.Connections = {}
	print(self.LogPrefix, "🔌 Disconnected all events")
end

--[[
	Log a message with location prefix
	@param ... any - Message parts to log
]]
function BaseLocationManager:Log(...)
	print(self.LogPrefix, ...)
end

--[[
	Log a warning with location prefix
	@param ... any - Warning message parts
]]
function BaseLocationManager:Warn(...)
	warn(self.LogPrefix, ...)
end

--[[
	Get custom data for a player
	@param player Player - The player instance
	@return table|nil - Custom data table or nil
]]
function BaseLocationManager:GetPlayerData(player)
	if not player or not player:IsA("Player") then
		return nil
	end
	return self.PlayerData[player.UserId]
end

--[[
	Set custom data for a player
	@param player Player - The player instance
	@param key string - Data key
	@param value any - Data value
]]
function BaseLocationManager:SetPlayerData(player, key, value)
	if not player or not player:IsA("Player") then
		return
	end
	
	local userId = player.UserId
	if not self.PlayerData[userId] then
		self.PlayerData[userId] = {}
	end
	
	self.PlayerData[userId][key] = value
end

--[[
	Get uptime since initialization
	@return number - Uptime in seconds
]]
function BaseLocationManager:GetUptime()
	if self.InitializeTime == 0 then
		return 0
	end
	return os.clock() - self.InitializeTime
end

-- ============================================================================
-- OVERRIDE THESE METHODS IN DERIVED CLASSES
-- ============================================================================

--[[
	Override: Location-specific initialization logic
	@param locationModel Instance - The workspace model
]]
function BaseLocationManager:OnInitialize(locationModel)
	-- Override in derived class
	-- Example:
	-- self:Log("Custom initialization logic here")
end

--[[
	Override: Location-specific cleanup logic
]]
function BaseLocationManager:OnCleanup()
	-- Override in derived class
	-- Example:
	-- self:Log("Custom cleanup logic here")
end

--[[
	Override: Location-specific update logic
	@param deltaTime number - Time since last update
]]
function BaseLocationManager:OnUpdate(deltaTime)
	-- Override in derived class
	-- Example:
	-- self:Log("Update logic here", deltaTime)
end

--[[
	Override: Handle player entering location (custom logic)
	@param player Player - The player instance
]]
function BaseLocationManager:OnPlayerEntered(player)
	-- Override in derived class
	-- Example:
	-- self:Log("Player entered:", player.Name)
end

--[[
	Override: Handle player leaving location (custom logic)
	@param player Player - The player instance
]]
function BaseLocationManager:OnPlayerLeft(player)
	-- Override in derived class
	-- Example:
	-- self:Log("Player left:", player.Name)
end

return BaseLocationManager
