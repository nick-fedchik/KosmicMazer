--[[
================================================================================
KOSMICMAZER — Planet Load Order Configuration
================================================================================

Purpose: Defines the loading order for Planet-level content
Version: 2.0
Planet: Planet_1 (Залізяка)

Features:
- Priority-based loading for Planet Workspace objects
- Planet-wide server scripts loading order
- Planet-wide client scripts loading order
- Configurable timeout and verification settings

API:
- LoadOrder.GetWorkspacePriority(objectName): Returns priority for object
- LoadOrder.GetServerScriptPriority(scriptName): Returns priority for script
- LoadOrder.GetClientScriptPriority(scriptName): Returns priority for script
- LoadOrder.GetServerScriptAction(scriptName): Returns "require" or "clone"
- LoadOrder.SortObjects(objects): Returns sorted array by priority

Calls to:
- EnvironmentLoader: Reads this config during LoadPlanetEnvironment()
- LoadOrderProcessor: Processes this configuration

Called from:
- EnvironmentLoader.LoadPlanetEnvironment()
- EnvironmentLoader.LoadSpaceEnvironment()

Dependencies:
- ServerStorage.Planets.Planet_1.Workspace
- ServerStorage.Planets.Planet_1.Scripts

ChangeLog:
- Version 2.0: Added ServerScripts, ClientScripts, Settings sections
- Version 1.0: Initial implementation

================================================================================
]]

--[[
================================================================================
ІНСТРУКЦІЯ З НАЛАШТУВАННЯ
================================================================================

📋 СТРУКТУРА КОНФІГУРАЦІЇ:

LoadOrder на рівні планети визначає порядок завантаження:

1. WorkspaceObjects - об'єкти з папки Planet/Workspace/
   Приклад: модель планети, атмосфера

2. ServerScripts - загальні скрипти планети з Scripts/Server/
   Доступні для ВСІХ локацій цієї планети
   Приклад: PlanetConfig, PlanetManager

3. ClientScripts - загальні клієнтські скрипти з Scripts/Client/
   Копіюються для всіх гравців на цій планеті
   Приклад: PlanetUI, PlanetEffects

⚙️ ПРАВИЛА ПРІОРИТЕТУ:

- 1-100: Базова інфраструктура (модель планети, атмосфера)
- 101-500: Стандартний контент
- 501-998: Опціональний контент
- 999: Зарезервовано для критичних фіналізаторів
- 500: За замовчуванням

🔄 ПОСЛІДОВНІСТЬ ЗАВАНТАЖЕННЯ:

1. Planet LoadOrder обробляється ПЕРЕД Location LoadOrder
2. Це гарантує що PlanetConfig доступний для LocationGameServer
3. Клієнтські скрипти планети завантажуються перед скриптами локації

📝 ЯК НАЛАШТУВАТИ:

1. WorkspaceObjects:
   {name = "Planet", priority = 1, description = "Модель планети"}

2. ServerScripts:
   {name = "PlanetConfig", priority = 1, action = "require", description = "Конфігурація планети"}

3. ClientScripts:
   {name = "PlanetUI", priority = 1, description = "UI планети"}

⚠️ ВАЖЛИВО:
- Пріоритет ServerScripts має враховувати залежності між модулями
- Якщо LocationGameServer потребує PlanetConfig, дайте PlanetConfig нижчий пріоритет

📚 Детальна документація: ReplicatedStorage/Docs/LoadOrderSystem.luau

================================================================================
]]

local LoadOrder = {}

LoadOrder.Version = "2.0"

-- Порядок копіювання об'єктів з Planet/Workspace/ → game.Workspace
LoadOrder.WorkspaceObjects = {
	{name = "Planet", priority = 1, description = "Planet visual model"},
	-- Add more planet-level objects here
}

-- Порядок обробки серверних скриптів з Planet/Scripts/Server/
LoadOrder.ServerScripts = {
	{name = "PlanetConfig", priority = 1, action = "require", description = "Planet game rules & resources"},
	{name = "PlanetManager", priority = 2, action = "require", description = "Planet controller"},
	-- ModuleScripts: action = "require" (loaded as modules)
	-- Scripts: action = "clone" (copied to Workspace)
	-- Add more scripts here
}

-- Порядок копіювання клієнтських скриптів з Planet/Scripts/Client/ → StarterPlayerScripts
LoadOrder.ClientScripts = {
	{name = "PlanetUI", priority = 1, description = "Planet-wide UI controller"},
	{name = "PlanetEffects", priority = 2, description = "Planet-specific visual effects"},
	-- Add more client scripts here
}

-- Загальні налаштування завантаження
LoadOrder.Settings = {
	LoadTimeout = 10,  -- Maximum time to wait for loading (seconds)
	EnableParallelLoading = false,  -- Load items in parallel (experimental)
	VerifyAfterLoad = true,  -- Verify all objects loaded successfully
}

-- Helper function to get priority for a Workspace object
function LoadOrder.GetWorkspacePriority(objectName: string): number
	for _, entry in ipairs(LoadOrder.WorkspaceObjects) do
		if entry.name == objectName then
			return entry.priority
		end
	end
	return 500  -- Default priority for unlisted objects
end

-- Helper function to get priority for a Server script
function LoadOrder.GetServerScriptPriority(scriptName: string): number
	for _, entry in ipairs(LoadOrder.ServerScripts) do
		if entry.name == scriptName then
			return entry.priority
		end
	end
	return 500
end

-- Helper function to get priority for a Client script
function LoadOrder.GetClientScriptPriority(scriptName: string): number
	for _, entry in ipairs(LoadOrder.ClientScripts) do
		if entry.name == scriptName then
			return entry.priority
		end
	end
	return 500
end

-- Helper function to get script action (require/clone)
function LoadOrder.GetServerScriptAction(scriptName: string): string
	for _, entry in ipairs(LoadOrder.ServerScripts) do
		if entry.name == scriptName then
			return entry.action or "require"  -- Default to require
		end
	end
	return "require"
end

-- Helper function to sort objects by load order
function LoadOrder.SortObjects(objects: {Instance}): {Instance}
	local sorted = {}
	for _, obj in ipairs(objects) do
		table.insert(sorted, obj)
	end

	table.sort(sorted, function(a, b)
		return LoadOrder.GetWorkspacePriority(a.Name) < LoadOrder.GetWorkspacePriority(b.Name)
	end)

	return sorted
end

-- Legacy compatibility: alias for WorkspaceObjects
LoadOrder.ORDER = LoadOrder.WorkspaceObjects
LoadOrder.GetPriority = LoadOrder.GetWorkspacePriority

return LoadOrder
