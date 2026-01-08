--[[
================================================================================
KOSMICMAZER — Location Controller Template
================================================================================

Purpose: Template for location-specific controllers (inherits BaseLocationManager)
Version: 1.0

Features:
- Inherits from BaseLocationManager
- Manages location-specific game logic
- Handles resource spawning and collection
- Manages NPC interactions
- Tracks location-specific events

Usage:
Copy this template to each location's Scripts/Server/ folder and customize
Example: ServerStorage/Planets/Planet_1/Locations/Location_1/Scripts/Server/LocationController.luau

API:
- Initialize(locationModel): Initialize location systems
- Cleanup(): Cleanup location before unloading
- GetLocationRules(): Returns location game rules
- SpawnResources(): Spawn location resources
- CollectResource(player, resourceId): Handle resource collection

Calls to:
- BaseLocationManager (parent class)
- PlanetConfig (for planet-wide rules)

Called from:
- LocationManager (when loading location)
- EnvironmentLoader (during environment setup)

Dependencies:
- BaseLocationManager
- PlanetConfig (optional)

ChangeLog:
- Version 1.0: Initial template based on BaseLocationManager

================================================================================
]]

local ServerScriptService = game:GetService("ServerScriptService")
local _ServerStorage = game:GetService("ServerStorage") -- Reserved for future use

-- Load dependencies
local BaseLocationManager = require(ServerScriptService:FindFirstChild("BaseLocationManager"))

-- LocationController inherits from BaseLocationManager
local LocationController = setmetatable({}, {__index = BaseLocationManager})
LocationController.__index = LocationController

-- ============================================================================
-- CONFIGURATION (Customize per location)
-- ============================================================================

local LOCATION_CONFIG = {
	LOCATION_ID = "Location_1",
	LOCATION_NAME = "Садочок",
	
	-- Location features
	Features = {
		HasResources = true,
		HasNPCs = false,
		HasQuests = false,
		IsSafeZone = true,
	},
	
	-- Game rules
	MaxPlayers = 10,
	ResourceDensity = 1.2,
	DifficultyLevel = 1,
	
	-- Resource spawning
	ResourceSpawnInterval = 60, -- seconds
	MaxResources = 20,
}

--[[
	Create a new LocationController instance
	@return table - New LocationController instance
]]
function LocationController.new()
	local self = BaseLocationManager.new(
		LOCATION_CONFIG.LOCATION_ID,
		LOCATION_CONFIG.LOCATION_NAME
	)
	setmetatable(self, LocationController)
	
	-- Location-specific properties
	self.Resources = {}
	self.ResourceCount = 0
	self.LastResourceSpawn = 0
	self.NPCs = {}
	
	return self
end

--[[
	Override: Initialize location-specific logic
	@param locationModel Instance - The location workspace model
]]
function LocationController:OnInitialize(locationModel)
	self:Log("🌍 Initializing location logic...")
	
	-- Find interaction objects
	if locationModel then
		local interactionObjects = locationModel:FindFirstChild("InteractionObjects")
		if interactionObjects then
			self:InitializeInteractionObjects(interactionObjects)
		end
	end
	
	-- Spawn initial resources if enabled
	if LOCATION_CONFIG.Features.HasResources then
		self:SpawnResources()
	end
	
	-- Initialize NPCs if enabled
	if LOCATION_CONFIG.Features.HasNPCs then
		self:InitializeNPCs()
	end
	
	self:Log("✅ Location initialized")
end

--[[
	Override: Cleanup location-specific logic
]]
function LocationController:OnCleanup()
	self:Log("🧹 Cleaning up location...")
	
	-- Clear resources
	self:ClearAllResources()
	
	-- Cleanup NPCs
	self:CleanupNPCs()
	
	self:Log("✅ Location cleanup complete")
end

--[[
	Override: Update location logic
	@param deltaTime number - Time since last update
]]
function LocationController:OnUpdate(deltaTime)
	-- Check if we need to spawn more resources
	if LOCATION_CONFIG.Features.HasResources then
		local currentTime = os.clock()
		if currentTime - self.LastResourceSpawn >= LOCATION_CONFIG.ResourceSpawnInterval then
			if self.ResourceCount < LOCATION_CONFIG.MaxResources then
				self:SpawnResources()
				self.LastResourceSpawn = currentTime
			end
		end
	end
end

--[[
	Override: Handle player entering location
	@param player Player - The player instance
]]
function LocationController:OnPlayerEntered(player)
	self:Log("🏃 Player entered location:", player.Name)
	
	-- Initialize player data
	self:SetPlayerData(player, "ResourcesCollected", 0)
	self:SetPlayerData(player, "EntryTime", os.clock())
	
	-- Could show welcome message, grant temporary buffs, etc.
end

--[[
	Override: Handle player leaving location
	@param player Player - The player instance
]]
function LocationController:OnPlayerLeft(player)
	local playerData = self:GetPlayerData(player)
	if playerData and playerData.ResourcesCollected then
		self:Log("🏃 Player left location:", player.Name, 
			string.format("(Collected %d resources)", playerData.ResourcesCollected))
	end
	
	-- Save player stats, remove temporary effects, etc.
end

-- ============================================================================
-- LOCATION-SPECIFIC METHODS (Customize per location)
-- ============================================================================

--[[
	Initialize interaction objects (resource nodes, etc.)
	@param interactionObjects Folder - Folder containing interaction objects
]]
function LocationController:InitializeInteractionObjects(interactionObjects)
	for _, object in ipairs(interactionObjects:GetChildren()) do
		if object:IsA("BasePart") then
			-- Setup resource nodes, collectibles, etc.
			local resourceId = object.Name
			self.Resources[resourceId] = {
				Model = object,
				Available = true,
				LastCollected = 0,
			}
			self.ResourceCount = self.ResourceCount + 1
			
			self:Log(string.format("  📦 Resource registered: %s", resourceId))
		end
	end
end

--[[
	Spawn location resources
	@return number - Number of resources spawned
]]
function LocationController:SpawnResources()
	local spawned = 0
	
	-- Implement resource spawning logic here
	-- Example: spawn new resource nodes, refresh collectibles, etc.
	
	if spawned > 0 then
		self:Log(string.format("📦 Spawned %d resources", spawned))
	end
	
	return spawned
end

--[[
	Clear all resources
]]
function LocationController:ClearAllResources()
	for resourceId, resourceData in pairs(self.Resources) do
		-- Clean up resource models
		if resourceData.Model and resourceData.Model.Parent then
			resourceData.Model:Destroy()
		end
	end
	
	self.Resources = {}
	self.ResourceCount = 0
	self:Log("📦 All resources cleared")
end

--[[
	Handle resource collection
	@param player Player - The player collecting
	@param resourceId string - ID of the resource
	@return boolean - Success status
]]
function LocationController:CollectResource(player, resourceId)
	local resource = self.Resources[resourceId]
	if not resource or not resource.Available then
		return false
	end
	
	-- Mark as collected
	resource.Available = false
	resource.LastCollected = os.clock()
	
	-- Update player stats
	local playerData = self:GetPlayerData(player)
	if playerData then
		playerData.ResourcesCollected = (playerData.ResourcesCollected or 0) + 1
	end
	
	self:Log(string.format("📦 %s collected resource: %s", player.Name, resourceId))
	
	return true
end

--[[
	Initialize NPCs
]]
function LocationController:InitializeNPCs()
	-- Implement NPC spawning and setup here
	self:Log("🤖 NPCs initialized")
end

--[[
	Cleanup NPCs
]]
function LocationController:CleanupNPCs()
	-- Cleanup NPC models and connections
	self.NPCs = {}
	self:Log("🤖 NPCs cleaned up")
end

--[[
	Get location rules
	@return table - Location rules
]]
function LocationController:GetLocationRules()
	return {
		LocationId = LOCATION_CONFIG.LOCATION_ID,
		LocationName = LOCATION_CONFIG.LOCATION_NAME,
		Features = LOCATION_CONFIG.Features,
		MaxPlayers = LOCATION_CONFIG.MaxPlayers,
		ResourceDensity = LOCATION_CONFIG.ResourceDensity,
		IsSafeZone = LOCATION_CONFIG.Features.IsSafeZone,
		DifficultyLevel = LOCATION_CONFIG.DifficultyLevel,
	}
end

--[[
	Get location statistics
	@return table - Location statistics
]]
function LocationController:GetLocationStats()
	return {
		LocationId = self.LocationId,
		LocationName = self.LocationName,
		IsActive = self.IsActive,
		IsReady = self.IsReady,
		ActivePlayers = self:GetActivePlayersCount(),
		ResourceCount = self.ResourceCount,
		Uptime = self:GetUptime(),
	}
end

return LocationController
