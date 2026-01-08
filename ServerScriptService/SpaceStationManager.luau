--[[
================================================================================
KOSMICMAZER — Space Station Manager
================================================================================

Purpose: Manages Space Station location logic and interactions
Version: 1.0

Features:
- Inherits from BaseLocationManager
- Manages station-specific interactions
- Handles planet scanner functionality
- Manages station resources and systems
- Tracks station status

API:
- Initialize(locationModel): Initialize station systems
- Cleanup(): Cleanup station before unloading
- GetStationStatus(): Returns current station status
- EnableScanner(): Enable planet surface scanner
- DisableScanner(): Disable planet surface scanner

Calls to:
- BaseLocationManager (parent class)
- GameConfig (for configuration)

Called from:
- LocationManager (when loading SpaceStation)
- EnvironmentLoader (during environment setup)

Dependencies:
- BaseLocationManager
- GameConfig

ChangeLog:
- Version 1.0: Initial implementation inheriting from BaseLocationManager

================================================================================
]]

local ServerScriptService = game:GetService("ServerScriptService")

-- Load dependencies
local BaseLocationManager = require(ServerScriptService:FindFirstChild("BaseLocationManager"))
local _GameConfig = require(ServerScriptService:FindFirstChild("GameConfig")) -- Reserved for future use

-- SpaceStationManager inherits from BaseLocationManager
local SpaceStationManager = setmetatable({}, {__index = BaseLocationManager})
SpaceStationManager.__index = SpaceStationManager

--[[
	Create a new SpaceStationManager instance
	@return table - New SpaceStationManager instance
]]
function SpaceStationManager.new()
	local self = BaseLocationManager.new("SpaceStation", "Космічна Станція")
	setmetatable(self, SpaceStationManager)
	
	-- Station-specific properties
	self.ScannerEnabled = false
	self.ScannerModel = nil
	self.StationSystems = {
		LifeSupport = true,
		PowerGrid = true,
		Communications = true,
	}
	
	return self
end

--[[
	Override: Initialize station-specific logic
	@param locationModel Instance - The station workspace model
]]
function SpaceStationManager:OnInitialize(locationModel)
	self:Log("🛰️ Initializing Space Station systems...")
	
	-- Find scanner model
	if locationModel then
		self.ScannerModel = locationModel:FindFirstChild("PlanetSurfaceScanner", true)
		if self.ScannerModel then
			self:Log("📡 Planet Scanner found")
		else
			self:Warn("⚠️ Planet Scanner not found (optional)")
		end
	end
	
	-- Initialize station systems
	self:InitializeStationSystems()
	
	-- Setup scanner if available
	if self.ScannerModel then
		self:EnableScanner()
	end
	
	self:Log("✅ Space Station systems online")
end

--[[
	Override: Cleanup station-specific logic
]]
function SpaceStationManager:OnCleanup()
	self:Log("🧹 Shutting down Space Station systems...")
	
	-- Disable scanner
	if self.ScannerEnabled then
		self:DisableScanner()
	end
	
	-- Shutdown systems
	for systemName, _ in pairs(self.StationSystems) do
		self.StationSystems[systemName] = false
	end
	
	self:Log("✅ Space Station systems offline")
end

--[[
	Override: Update station systems
	@param deltaTime number - Time since last update
]]
function SpaceStationManager:OnUpdate(deltaTime)
	-- Update station systems status
	-- Could check for power levels, life support, etc.
end

--[[
	Override: Handle player entering station
	@param player Player - The player instance
]]
function SpaceStationManager:OnPlayerEntered(player)
	self:Log("👨‍🚀 Astronaut aboard:", player.Name)
	
	-- Grant station access
	self:SetPlayerData(player, "StationAccess", true)
	self:SetPlayerData(player, "BoardingTime", os.clock())
	
	-- Could trigger welcome UI, grant permissions, etc.
end

--[[
	Override: Handle player leaving station
	@param player Player - The player instance
]]
function SpaceStationManager:OnPlayerLeft(player)
	local boardingTime = self:GetPlayerData(player)
	if boardingTime and boardingTime.BoardingTime then
		local duration = os.clock() - boardingTime.BoardingTime
		self:Log("👨‍🚀 Astronaut departed:", player.Name, string.format("(%.1fs aboard)", duration))
	end
	
	-- Revoke station access
	-- Could save station usage stats, etc.
end

--[[
	Initialize station systems
]]
function SpaceStationManager:InitializeStationSystems()
	self:Log("⚡ Initializing station systems...")
	
	for systemName, status in pairs(self.StationSystems) do
		self.StationSystems[systemName] = true
		self:Log(string.format("  ✅ %s: ONLINE", systemName))
	end
end

--[[
	Enable planet surface scanner
	@return boolean - Success status
]]
function SpaceStationManager:EnableScanner()
	if not self.ScannerModel then
		self:Warn("⚠️ Cannot enable scanner - model not found")
		return false
	end
	
	if self.ScannerEnabled then
		self:Warn("⚠️ Scanner already enabled")
		return false
	end
	
	self.ScannerEnabled = true
	self:Log("📡 Planet Scanner ENABLED")
	
	-- Scanner logic would be handled by PlanetSurfaceScanner.luau module
	-- This just tracks the state
	
	return true
end

--[[
	Disable planet surface scanner
	@return boolean - Success status
]]
function SpaceStationManager:DisableScanner()
	if not self.ScannerEnabled then
		return false
	end
	
	self.ScannerEnabled = false
	self:Log("📡 Planet Scanner DISABLED")
	
	return true
end

--[[
	Get current station status
	@return table - Station status information
]]
function SpaceStationManager:GetStationStatus()
	return {
		LocationId = self.LocationId,
		LocationName = self.LocationName,
		IsActive = self.IsActive,
		IsReady = self.IsReady,
		ActivePlayers = self:GetActivePlayersCount(),
		ScannerEnabled = self.ScannerEnabled,
		Systems = self.StationSystems,
		Uptime = self:GetUptime(),
	}
end

--[[
	Check if a system is online
	@param systemName string - Name of the system
	@return boolean - System status
]]
function SpaceStationManager:IsSystemOnline(systemName)
	return self.StationSystems[systemName] == true
end

--[[
	Set system status
	@param systemName string - Name of the system
	@param online boolean - New status
]]
function SpaceStationManager:SetSystemStatus(systemName, online)
	if self.StationSystems[systemName] ~= nil then
		self.StationSystems[systemName] = online
		self:Log(string.format("⚡ %s: %s", systemName, online and "ONLINE" or "OFFLINE"))
	end
end

return SpaceStationManager
