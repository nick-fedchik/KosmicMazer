-- ServerStorage Structure Dumper для Roblox Studio Command Bar
-- Копіюй весь код і вставляй в Command Bar

local function dumpInstance(instance, prefix, maxDepth, currentDepth)
    if currentDepth > maxDepth then return end
    
    local children = instance:GetChildren()
    table.sort(children, function(a, b) return a.Name < b.Name end)
    
    for i, child in ipairs(children) do
        local isLast = i == #children
        local currentPrefix = isLast and "└── " or "├── "
        local nextPrefix = prefix .. (isLast and "    " or "│   ")
        
        -- Визначаємо тип об'єкта та додаткову інформацію
        local info = ""
        local emoji = ""
        
        if child:IsA("Folder") then
            local childCount = #child:GetChildren()
            info = string.format(" [%d items]", childCount)
            emoji = "📁"
        elseif child:IsA("ModuleScript") then
            emoji = "📄"
            info = " (ModuleScript)"
        elseif child:IsA("LocalScript") then
            emoji = "💻"
            info = " (LocalScript)"
        elseif child:IsA("Script") then
            emoji = "⚙️"
            info = " (Server Script)"
        elseif child:IsA("Model") then
            local partCount = #child:GetDescendants()
            emoji = "🏗️"
            info = string.format(" (Model, %d parts)", partCount)
        elseif child:IsA("Part") then
            emoji = "🧱"
            info = " (Part)"
        elseif child:IsA("SpawnLocation") then
            emoji = "🎯"
            info = " (SpawnLocation)"
        elseif child:IsA("Configuration") then
            emoji = "⚙️"
            info = " (Configuration)"
        else
            emoji = "❓"
            info = string.format(" (%s)", child.ClassName)
        end
        
        print(prefix .. currentPrefix .. emoji .. " " .. child.Name .. info)
        
        -- Рекурсивно обробляємо дітей
        if #child:GetChildren() > 0 then
            dumpInstance(child, nextPrefix, maxDepth, currentDepth + 1)
        end
    end
end

local function dumpServerStorage()
    print("=" .. string.rep("=", 79))
    print("KOSMICMAZER — ServerStorage Structure Dump")
    print("=" .. string.rep("=", 79))
    print("📁 ServerStorage:")
    print("=" .. string.rep("=", 79))
    
    dumpInstance(game.ServerStorage, "", 5, 0)
    
    print("=" .. string.rep("=", 79))
    
    -- Статистика
    local totalFolders = 0
    local totalScripts = 0
    local totalModels = 0
    local totalParts = 0
    
    for _, descendant in pairs(game.ServerStorage:GetDescendants()) do
        if descendant:IsA("Folder") then
            totalFolders = totalFolders + 1
        elseif descendant:IsA("Script") or descendant:IsA("LocalScript") or descendant:IsA("ModuleScript") then
            totalScripts = totalScripts + 1
        elseif descendant:IsA("Model") then
            totalModels = totalModels + 1
        elseif descendant:IsA("Part") then
            totalParts = totalParts + 1
        end
    end
    
    print("📊 Статистика:")
    print("   📁 Всього папок: " .. totalFolders)
    print("   📄 Всього скриптів: " .. totalScripts) 
    print("   🏗️ Всього моделей: " .. totalModels)
    print("   🧱 Всього частин: " .. totalParts)
    print("✅ Дамп завершено!")
end

-- Запускаємо дамп
dumpServerStorage()