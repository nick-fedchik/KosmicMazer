--[[
================================================================================
KOSMICMAZER — Client Script Initializer
================================================================================

Purpose: Ініціалізує client scripts після завантаження середовища
Version: 1.1

Features:
- Викликає Initialize() на client scripts з environment context
- Стандартизований пошук моделей у Workspace
- Інтеграція з LoadOrder системою
- LocationModel hierarchical structure support

API:
- InitializeAllClientScripts(locationType, planetId, locationId): Ініціалізує всі client scripts
- CreateEnvironment(locationType, planetId, locationId): Створює environment context

Dependencies:
- StarterPlayerScripts: Client scripts для ініціалізації
- Workspace: Моделі для environment

ChangeLog:
- Version 1.1: Updated for LocationModel hierarchical structure (ETAP 3)
- Version 1.1: FindModel() now searches within LocationModel organizational sections
- Version 1.1: Added LocationModel attribute validation for SpaceStation type
- Version 1.1: Enhanced model discovery in Architecture/Equipment/Environment/Gameplay folders
- Version 1.1: Added fallback support for old SpaceStation structure
- Version 1.0: Initial implementation with environment context support

================================================================================
]]

local ClientScriptInitializer = {}

-- Services
local StarterPlayerScripts = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

-- Client Environment Class
local ClientEnvironment = {}
ClientEnvironment.__index = ClientEnvironment

function ClientEnvironment.new(locationType, planetId, locationId)
	local self = setmetatable({}, ClientEnvironment)
	self.locationType = locationType or "Unknown"
	self.planetId = planetId or "Unknown"
	self.locationId = locationId or nil
	return self
end

-- Знайти модель у Workspace за назвою
function ClientEnvironment:FindModel(modelName)
	-- Спробуємо різні шляхи залежно від локації
	if self.locationType == "SpaceStation" then
		-- Для SpaceStation моделі можуть бути всередині LocationModel
		local locationModel = Workspace:FindFirstChild("LocationModel")
		if locationModel then
			-- Валідуємо що це SpaceStation LocationModel
			local locationId = locationModel:GetAttribute("LocationId")
			local locationType = locationModel:GetAttribute("LocationType")
			
			if locationId == "SpaceStation" and locationType == "Space" then
				-- Шукаємо в організаційних секціях
				for _, sectionName in ipairs({"Architecture", "Equipment", "Environment", "Gameplay"}) do
					local section = locationModel:FindFirstChild(sectionName)
					if section then
						local model = section:FindFirstChild(modelName)
						if model then return model end
					end
				end
				
				-- Також шукаємо прямо в LocationModel (для PrimaryPart тощо)
				local model = locationModel:FindFirstChild(modelName)
				if model then return model end
			end
		end
		
		-- Fallback: старий SpaceStation для сумісності
		local spaceStation = Workspace:FindFirstChild("SpaceStation")
		if spaceStation then
			local model = spaceStation:FindFirstChild(modelName)
			if model then return model end
		end
	elseif self.locationType == "Planet" then
		-- Для планети моделі можуть бути в різних місцях
		local planet = Workspace:FindFirstChild("Planet")
		if planet then
			local model = planet:FindFirstChild(modelName)
			if model then return model end
		end
	end
	
	-- Fallback: пошук у корені Workspace
	return Workspace:FindFirstChild(modelName)
end

-- Отримати поточну локацію
function ClientEnvironment:GetLocation()
	if self.locationType == "SpaceStation" then
		return "SpaceStation"
	elseif self.locationType == "Planet" and self.locationId then
		local safePlanet = self.planetId or "UnknownPlanet"
		return string.format("%s/%s", safePlanet, self.locationId)
	else
		return self.locationType
	end
end

-- Отримати поточну планету
function ClientEnvironment:GetCurrentPlanet()
	return self.planetId
end

-- Створити environment для client scripts
function ClientScriptInitializer.CreateEnvironment(locationType, planetId, locationId)
	return ClientEnvironment.new(locationType, planetId, locationId)
end

-- Ініціалізувати всі client scripts
function ClientScriptInitializer.InitializeAllClientScripts(locationType, planetId, locationId)
	print("[ClientScriptInitializer] 🚀 Initializing client scripts...")

	-- Normalize optional params to concrete strings for formatter safety
	local normalizedLocationType = locationType or "Unknown"
	local normalizedPlanetId = planetId or "N/A"
	local normalizedLocationId = locationId or "N/A"
	print(string.format("  └─ Location: %s, Planet: %s, LocationId: %s",
		normalizedLocationType, normalizedPlanetId, normalizedLocationId))
	
	-- Створюємо environment
	local environment = ClientScriptInitializer.CreateEnvironment(locationType, planetId, locationId)
	
	-- Знаходимо всі client scripts в StarterPlayerScripts
	local clientScripts = StarterPlayerScripts:GetChildren()
	local initializedCount = 0
	
	for _, script in ipairs(clientScripts) do
		if script:IsA("LocalScript") then
			-- Перевіряємо чи script має Initialize функцію
			local success, module = pcall(require, script)
			if success and type(module) == "table" and type(module.Initialize) == "function" then
				local initSuccess, initError = pcall(module.Initialize, environment)
				if initSuccess then
					print(string.format("[ClientScriptInitializer] ✅ Initialized: %s", script.Name))
					initializedCount = initializedCount + 1
				else
					warn(string.format("[ClientScriptInitializer] ❌ Failed to initialize %s: %s", 
						script.Name, tostring(initError)))
				end
			else
				print(string.format("[ClientScriptInitializer] ℹ️ %s - no Initialize() function", script.Name))
			end
		end
	end
	
	print(string.format("[ClientScriptInitializer] 🎉 Initialized %d/%d client scripts", 
		initializedCount, #clientScripts))
	
	return initializedCount > 0
end

return ClientScriptInitializer