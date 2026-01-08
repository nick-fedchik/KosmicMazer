--[[
================================================================================
KOSMICMAZER — RemoteEvents Registry
================================================================================

Purpose: Централізований реєстр RemoteEvents для уникнення дублікатів
Version: 1.0
Status: ACTIVE
Last Updated: 2026-01-08

Відповідальність:
- Створення всіх RemoteEvents на сервері
- Надання доступу до RemoteEvents для клієнта та сервера
- Валідація існування RemoteEvents при старті

Архітектурні правила:
✅ RemoteEvents створюються ВИКЛЮЧНО через Initialize() на сервері
✅ Клієнтські скрипти використовують WaitFor() або WaitForChild()
✅ Серверні скрипти використовують Get() після Initialize()
❌ Ніколи не створювати RemoteEvents поза цим модулем

================================================================================
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local RemoteEventsRegistry = {}

-- Таблиці для зберігання RemoteEvents та RemoteFunctions
RemoteEventsRegistry.Events = {}
RemoteEventsRegistry.Functions = {}

-- Список всіх RemoteEvents, які мають бути створені
local REMOTE_EVENTS_LIST = {
	"TeleportationEvent",           -- Запит на телепортацію від клієнта
	"TeleportationStateEvent",      -- Оновлення стану телепортації для клієнта
	"PlanetSurfaceScanner_Results", -- Результати сканування планети
	"PlayerDataReady",              -- Сигнал готовності даних гравця
}

-- Список всіх RemoteFunctions (якщо потрібні в майбутньому)
local REMOTE_FUNCTIONS_LIST = {
	-- Поки що пусто, додавати по потребі
}

-- Прапорець ініціалізації
local isInitialized = false

--[[
================================================================================
ФУНКЦІЯ: Initialize
================================================================================
Створює всі RemoteEvents та RemoteFunctions на сервері.
ВИКЛИКАЄТЬСЯ: Тільки на сервері, в GameInit.server.luau

Повертає: success (boolean), errorMessage (string?)
]]
function RemoteEventsRegistry.Initialize()
	-- Перевірка: Initialize можна викликати тільки на сервері
	if not RunService:IsServer() then
		warn("[RemoteEventsRegistry] ❌ Initialize() можна викликати тільки на сервері!")
		return false, "Initialize() можна викликати тільки на сервері"
	end

	-- Перевірка: Initialize можна викликати тільки один раз
	if isInitialized then
		warn("[RemoteEventsRegistry] ⚠️ Initialize() вже викликано раніше")
		return true -- Не помилка, просто вже ініціалізовано
	end

	print("[RemoteEventsRegistry] 🚀 Ініціалізація RemoteEvents...")

	-- Створити всі RemoteEvents
	local eventsCreated = 0
	for _, eventName in ipairs(REMOTE_EVENTS_LIST) do
		-- Перевірити чи вже існує
		local existingEvent = ReplicatedStorage:FindFirstChild(eventName)
		if existingEvent then
			if existingEvent:IsA("RemoteEvent") then
				print(string.format("[RemoteEventsRegistry] ♻️ RemoteEvent '%s' вже існує - використовую існуючий", eventName))
				RemoteEventsRegistry.Events[eventName] = existingEvent
				eventsCreated = eventsCreated + 1
			else
				warn(string.format("[RemoteEventsRegistry] ❌ Об'єкт '%s' існує, але це не RemoteEvent!", eventName))
				return false, string.format("Об'єкт '%s' має неправильний тип", eventName)
			end
		else
			-- Створити новий RemoteEvent
			local newEvent = Instance.new("RemoteEvent")
			newEvent.Name = eventName
			newEvent.Parent = ReplicatedStorage

			RemoteEventsRegistry.Events[eventName] = newEvent
			eventsCreated = eventsCreated + 1
			print(string.format("[RemoteEventsRegistry] ✅ Створено RemoteEvent: %s", eventName))
		end
	end

	-- Створити всі RemoteFunctions (якщо є)
	local functionsCreated = 0
	for _, functionName in ipairs(REMOTE_FUNCTIONS_LIST) do
		local existingFunction = ReplicatedStorage:FindFirstChild(functionName)
		if existingFunction then
			if existingFunction:IsA("RemoteFunction") then
				print(string.format("[RemoteEventsRegistry] ♻️ RemoteFunction '%s' вже існує - використовую існуючий", functionName))
				RemoteEventsRegistry.Functions[functionName] = existingFunction
				functionsCreated = functionsCreated + 1
			else
				warn(string.format("[RemoteEventsRegistry] ❌ Об'єкт '%s' існує, але це не RemoteFunction!", functionName))
				return false, string.format("Об'єкт '%s' має неправильний тип", functionName)
			end
		else
			local newFunction = Instance.new("RemoteFunction")
			newFunction.Name = functionName
			newFunction.Parent = ReplicatedStorage

			RemoteEventsRegistry.Functions[functionName] = newFunction
			functionsCreated = functionsCreated + 1
			print(string.format("[RemoteEventsRegistry] ✅ Створено RemoteFunction: %s", functionName))
		end
	end

	isInitialized = true
	print(string.format("[RemoteEventsRegistry] 🎉 Ініціалізація завершена! Events: %d, Functions: %d", eventsCreated, functionsCreated))

	return true
end

--[[
================================================================================
ФУНКЦІЯ: Get
================================================================================
Отримати RemoteEvent або RemoteFunction за ім'ям.
ВИКОРИСТАННЯ: На сервері після Initialize()

Параметри:
- eventName (string): Ім'я RemoteEvent або RemoteFunction

Повертає: RemoteEvent | RemoteFunction | nil
]]
function RemoteEventsRegistry.Get(eventName: string)
	-- Спочатку шукати в Events
	if RemoteEventsRegistry.Events[eventName] then
		return RemoteEventsRegistry.Events[eventName]
	end

	-- Потім шукати в Functions
	if RemoteEventsRegistry.Functions[eventName] then
		return RemoteEventsRegistry.Functions[eventName]
	end

	-- Якщо не знайдено - спробувати знайти в ReplicatedStorage
	local remote = ReplicatedStorage:FindFirstChild(eventName)
	if remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
		-- Кешувати для наступних викликів
		if remote:IsA("RemoteEvent") then
			RemoteEventsRegistry.Events[eventName] = remote
		else
			RemoteEventsRegistry.Functions[eventName] = remote
		end
		return remote
	end

	warn(string.format("[RemoteEventsRegistry] ❌ RemoteEvent/Function '%s' не знайдено!", eventName))
	return nil
end

--[[
================================================================================
ФУНКЦІЯ: WaitFor
================================================================================
Очікувати RemoteEvent або RemoteFunction (для клієнта).
ВИКОРИСТАННЯ: На клієнті для безпечного отримання RemoteEvent

Параметри:
- eventName (string): Ім'я RemoteEvent або RemoteFunction
- timeout (number?): Максимальний час очікування в секундах (за замовчуванням 30)

Повертає: RemoteEvent | RemoteFunction | nil
]]
function RemoteEventsRegistry.WaitFor(eventName: string, timeout: number?)
	local maxTimeout = timeout or 30
	local startTime = tick()

	print(string.format("[RemoteEventsRegistry] ⏳ Очікування '%s' (timeout: %ds)...", eventName, maxTimeout))

	-- Спробувати знайти в кеші
	local cached = RemoteEventsRegistry.Get(eventName)
	if cached then
		print(string.format("[RemoteEventsRegistry] ✅ '%s' знайдено в кеші", eventName))
		return cached
	end

	-- Очікувати створення в ReplicatedStorage
	local remote = ReplicatedStorage:WaitForChild(eventName, maxTimeout)

	if remote then
		-- Кешувати для наступних викликів
		if remote:IsA("RemoteEvent") then
			RemoteEventsRegistry.Events[eventName] = remote
		elseif remote:IsA("RemoteFunction") then
			RemoteEventsRegistry.Functions[eventName] = remote
		end

		local elapsedTime = tick() - startTime
		print(string.format("[RemoteEventsRegistry] ✅ '%s' знайдено за %.2fs", eventName, elapsedTime))
		return remote
	else
		warn(string.format("[RemoteEventsRegistry] ❌ Timeout! '%s' не знайдено за %ds", eventName, maxTimeout))
		return nil
	end
end

--[[
================================================================================
ФУНКЦІЯ: Validate
================================================================================
Перевірити існування всіх RemoteEvents.
ВИКОРИСТАННЯ: На сервері після Initialize() для діагностики

Повертає: valid (boolean), errors (table)
]]
function RemoteEventsRegistry.Validate()
	local valid = true
	local errors = {}

	print("[RemoteEventsRegistry] 🔍 Валідація RemoteEvents...")

	-- Перевірити Events
	for _, eventName in ipairs(REMOTE_EVENTS_LIST) do
		local event = RemoteEventsRegistry.Events[eventName]
		if not event then
			valid = false
			table.insert(errors, string.format("RemoteEvent '%s' не створено", eventName))
			warn(string.format("[RemoteEventsRegistry] ❌ Відсутній RemoteEvent: %s", eventName))
		else
			-- Перевірити що це справді RemoteEvent
			if not event:IsA("RemoteEvent") then
				valid = false
				table.insert(errors, string.format("'%s' має неправильний тип: %s", eventName, event.ClassName))
				warn(string.format("[RemoteEventsRegistry] ❌ '%s' має неправильний тип: %s", eventName, event.ClassName))
			else
				print(string.format("[RemoteEventsRegistry] ✅ RemoteEvent '%s' валідний", eventName))
			end
		end
	end

	-- Перевірити Functions
	for _, functionName in ipairs(REMOTE_FUNCTIONS_LIST) do
		local func = RemoteEventsRegistry.Functions[functionName]
		if not func then
			valid = false
			table.insert(errors, string.format("RemoteFunction '%s' не створено", functionName))
			warn(string.format("[RemoteEventsRegistry] ❌ Відсутній RemoteFunction: %s", functionName))
		else
			if not func:IsA("RemoteFunction") then
				valid = false
				table.insert(errors, string.format("'%s' має неправильний тип: %s", functionName, func.ClassName))
				warn(string.format("[RemoteEventsRegistry] ❌ '%s' має неправильний тип: %s", functionName, func.ClassName))
			else
				print(string.format("[RemoteEventsRegistry] ✅ RemoteFunction '%s' валідний", functionName))
			end
		end
	end

	if valid then
		print("[RemoteEventsRegistry] 🎉 Валідація пройдена успішно!")
	else
		warn(string.format("[RemoteEventsRegistry] ❌ Валідація не пройдена! Помилок: %d", #errors))
	end

	return valid, errors
end

--[[
================================================================================
ФУНКЦІЯ: IsInitialized
================================================================================
Перевірити чи ініціалізовано реєстр.

Повертає: boolean
]]
function RemoteEventsRegistry.IsInitialized()
	return isInitialized
end

--[[
================================================================================
ФУНКЦІЯ: GetAllEvents
================================================================================
Отримати список всіх зареєстрованих RemoteEvents (для діагностики).

Повертає: table
]]
function RemoteEventsRegistry.GetAllEvents()
	local eventsList = {}
	for eventName, _ in pairs(RemoteEventsRegistry.Events) do
		table.insert(eventsList, eventName)
	end
	return eventsList
end

--[[
================================================================================
ФУНКЦІЯ: GetAllFunctions
================================================================================
Отримати список всіх зареєстрованих RemoteFunctions (для діагностики).

Повертає: table
]]
function RemoteEventsRegistry.GetAllFunctions()
	local functionsList = {}
	for functionName, _ in pairs(RemoteEventsRegistry.Functions) do
		table.insert(functionsList, functionName)
	end
	return functionsList
end

return RemoteEventsRegistry
