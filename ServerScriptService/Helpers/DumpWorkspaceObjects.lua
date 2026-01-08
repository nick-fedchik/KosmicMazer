--[[
================================================================================
DUMP WORKSPACE OBJECTS - Command Bar Script
================================================================================

Використання:
1. Скопіюй весь код нижче
2. Відкрий Roblox Studio
3. Натисни View → Output (щоб бачити результати)
4. Натисни View → Command Bar
5. Вставь код в Command Bar і натисни Enter

Скрипт виведе детальну інформацію про всі об'єкти в Workspace
================================================================================
]]

-- Функція для дампу властивостей одного об'єкта
local function dumpObject(object, indent)
    indent = indent or ""
    local output = {}
    
    table.insert(output, string.format("%s[%s] %s", indent, object.ClassName, object.Name))
    
    -- Position/CFrame для BasePart
    if object:IsA("BasePart") then
        table.insert(output, string.format("%s  └─ Position: %.2f, %.2f, %.2f", 
            indent, object.Position.X, object.Position.Y, object.Position.Z))
        table.insert(output, string.format("%s  └─ Size: %.2f, %.2f, %.2f", 
            indent, object.Size.X, object.Size.Y, object.Size.Z))
        table.insert(output, string.format("%s  └─ Anchored: %s", indent, tostring(object.Anchored)))
        table.insert(output, string.format("%s  └─ CanCollide: %s", indent, tostring(object.CanCollide)))
        
        -- CFrame повний
        local cf = object.CFrame
        table.insert(output, string.format("%s  └─ CFrame: CFrame.new(%.2f, %.2f, %.2f)", 
            indent, cf.Position.X, cf.Position.Y, cf.Position.Z))
    
    -- Model
    elseif object:IsA("Model") then
        if object.PrimaryPart then
            table.insert(output, string.format("%s  └─ PrimaryPart: %s", indent, object.PrimaryPart.Name))
            table.insert(output, string.format("%s  └─ PrimaryPart.Position: %.2f, %.2f, %.2f", 
                indent, object.PrimaryPart.Position.X, object.PrimaryPart.Position.Y, object.PrimaryPart.Position.Z))
        end
        local pivot = object:GetPivot()
        table.insert(output, string.format("%s  └─ Pivot: %.2f, %.2f, %.2f", 
            indent, pivot.Position.X, pivot.Position.Y, pivot.Position.Z))
    end
    
    -- Attributes
    local attributes = object:GetAttributes()
    if next(attributes) then
        table.insert(output, string.format("%s  └─ Attributes:", indent))
        for key, value in pairs(attributes) do
            table.insert(output, string.format("%s      • %s = %s", indent, key, tostring(value)))
        end
    end
    
    -- Children
    local children = object:GetChildren()
    if #children > 0 then
        table.insert(output, string.format("%s  └─ Children: %d", indent, #children))
    end
    
    return table.concat(output, "\n")
end

-- Головна функція дампу
local function dumpWorkspace()
    print("="..string.rep("=", 78))
    print("WORKSPACE DUMP - " .. os.date("%Y-%m-%d %H:%M:%S"))
    print("="..string.rep("=", 78))
    
    local workspace = game:GetService("Workspace")
    local count = 0
    
    for _, child in ipairs(workspace:GetChildren()) do
        -- Пропускаємо базові об'єкти
        if child.Name ~= "Camera" and child.Name ~= "Terrain" then
            count = count + 1
            print("\n" .. dumpObject(child, ""))
            
            -- Якщо це Model, виводимо його дочірні об'єкти (1 рівень)
            if child:IsA("Model") then
                for _, grandchild in ipairs(child:GetChildren()) do
                    if grandchild:IsA("BasePart") or grandchild:IsA("Model") then
                        print(dumpObject(grandchild, "  "))
                    end
                end
            end
        end
    end
    
    print("\n" .. string.rep("=", 80))
    print(string.format("TOTAL: %d objects (excluding Camera, Terrain)", count))
    print(string.rep("=", 80))
end

-- Виконати дамп
dumpWorkspace()
