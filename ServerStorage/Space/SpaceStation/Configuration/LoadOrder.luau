--[[
================================================================================
KOSMICMAZER — Space Station Load Order Configuration
================================================================================

Purpose: Defines the loading order for Space Station content
Version: 2.0

Features:
- Priority-based loading for Workspace objects
- Server scripts loading order (require/clone)
- Client scripts loading order
- Configurable timeout and verification settings

API:
- LoadOrder.GetWorkspacePriority(objectName): Returns priority for object
- LoadOrder.GetServerScriptPriority(scriptName): Returns priority for script
- LoadOrder.GetClientScriptPriority(scriptName): Returns priority for script
- LoadOrder.GetServerScriptAction(scriptName): Returns "require" or "clone"
- LoadOrder.SortObjects(objects): Returns sorted array by priority

Calls to:
- EnvironmentLoader: Reads this config during LoadSpaceEnvironment()
- LoadOrderProcessor: Processes this configuration

Called from:
- EnvironmentLoader.LoadSpaceEnvironment()

Dependencies:
- ServerStorage.Space.SpaceStation.Workspace
- ServerStorage.Space.SpaceStation.Scripts

ChangeLog:
- Version 2.0: Added ServerScripts, ClientScripts, Settings sections
- Version 1.0: Initial implementation (WorkspaceObjects only)

================================================================================
]]

--[[
================================================================================
ІНСТРУКЦІЯ З НАЛАШТУВАННЯ
================================================================================

📋 СТРУКТУРА КОНФІГУРАЦІЇ:

LoadOrder визначає порядок завантаження трьох типів контенту:

1. WorkspaceObjects - об'єкти з папки Workspace/
   Копіюються в game.Workspace при завантаженні

2. ServerScripts - скрипти з папки Scripts/Server/
   ModuleScripts: action="require" (завантажуються як модулі)
   Scripts: action="clone" (копіюються в Workspace)

3. ClientScripts - скрипти з папки Scripts/Client/
   Копіюються в StarterPlayerScripts для кожного гравця

⚙️ ПРАВИЛА ПРІОРИТЕТУ:

Пріоритет визначає послідовність завантаження (менше число = раніше):
- 1-100: Базова інфраструктура (Planet, основні модулі)
- 101-500: Стандартний контент (будівлі, NPC, ігрова логіка)
- 501-998: Опціональний контент (декорації, ефекти, UI)
- 999: Критичні фіналізатори (SpawnLocation - ЗАВЖДИ останнім!)
- 500: За замовчуванням (для об'єктів не вказаних в списку)

⚠️ ВАЖЛИВО:
SpawnLocation ЗАВЖДИ повинен мати priority = 999 щоб завантажуватись останнім!
Це гарантує що точка спавну існує після завантаження всього контенту.

📝 ЯК НАЛАШТУВАТИ:

1. Додайте об'єкт до відповідної секції (WorkspaceObjects/ServerScripts/ClientScripts)
2. Вкажіть назву об'єкта (name)
3. Встановіть пріоритет (priority) згідно правил вище
4. Для ServerScripts вкажіть дію (action): "require" або "clone"
5. Додайте опис (description) для документації

ПРИКЛАД:
{name = "PlanetSurfaceScanner", priority = 2, description = "Сканер поверхні планети"},

🔧 SETTINGS (Налаштування):
- LoadTimeout: Максимальний час очікування завантаження (секунди)
- EnableParallelLoading: Паралельне завантаження (експериментально)
- VerifyAfterLoad: Перевірка успішності завантаження

📚 Детальна документація: ReplicatedStorage/Docs/LoadOrderSystem.luau

================================================================================
]]

local LoadOrder = {}

LoadOrder.Version = "2.0"

-- Порядок копіювання об'єктів з SpaceStation/Workspace/ → game.Workspace
LoadOrder.WorkspaceObjects = {
	{name = "Planet", priority = 1, description = "Planet visual model"},
	{name = "PlanetSurfaceScanner", priority = 2, description = "Scanner tool (optional)"},
	{name = "SpawnLocation", priority = 999, description = "Player spawn point (must load last)"},
	-- Add more objects here with their priorities
}

-- Порядок обробки серверних скриптів з SpaceStation/Scripts/Server/
LoadOrder.ServerScripts = {
	{name = "PlanetSurfaceScanner", priority = 1, action = "require", description = "Scanner module"},
	-- ModuleScripts: action = "require" (loaded as modules)
	-- Scripts: action = "clone" (copied to Workspace)
	-- Add more scripts here
}

-- Порядок копіювання клієнтських скриптів з SpaceStation/Scripts/Client/ → StarterPlayerScripts
LoadOrder.ClientScripts = {
	{name = "StationUI", priority = 1, description = "Station UI controller"},
	{name = "ScannerUI", priority = 2, description = "Scanner interface"},
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

-- Legacy compatibility: alias for WorkspaceObjects
LoadOrder.ORDER = LoadOrder.WorkspaceObjects
LoadOrder.GetPriority = LoadOrder.GetWorkspacePriority

return LoadOrder
