print("=========================================")
print("[СКАНЕР] ЗАПУСК ТОТАЛЬНОГО АНАЛИЗА, ЕБЛАН!")
print("=========================================")

local plr = game.Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerScriptService")
local LS = game:GetService("Lighting")
local WS = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

-- ==========================================
-- 1. ПОИСК ВСЕХ RemoteEvent/RemoteFunction
-- ==========================================
local function FindAllRemotes(folder, path)
    path = path or ""
    local results = {}
    
    for _, child in pairs(folder:GetChildren()) do
        local currentPath = path .. "/" .. child.Name
        
        if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
            table.insert(results, {
                name = child.Name,
                class = child.ClassName,
                path = currentPath,
                parent = child.Parent.Name,
                ref = child
            })
        end
        
        if child:IsA("Folder") or child:IsA("Model") or child:IsA("ScreenGui") then
            local subResults = FindAllRemotes(child, currentPath)
            for _, sub in pairs(subResults) do
                table.insert(results, sub)
            end
        end
    end
    
    return results
end

print("[СКАНИРУЮ] Все папки...")

local allRemotes = {}
local foldersToScan = {RS, SS, WS, StarterGui, game:GetService("Players"), game:GetService("StarterPack")}

for _, folder in pairs(foldersToScan) do
    local remotes = FindAllRemotes(folder)
    for _, r in pairs(remotes) do
        table.insert(allRemotes, r)
    end
end

print("[НАЙДЕНО] "..#allRemotes.." RemoteEvent/RemoteFunction")

-- ==========================================
-- 2. ПОКАЗЫВАЕМ ВСЕ НАЙДЕННЫЕ
-- ==========================================
for i, remote in pairs(allRemotes) do
    print(string.format("[%d] %s (%s) — %s", i, remote.name, remote.class, remote.path))
end

-- ==========================================
-- 3. ИЩЕМ ПЕРЕМЕННЫЕ В _G И getgenv()
-- ==========================================
print("[СКАНИРУЮ] Глобальные переменные...")

local globalVars = {}
for k, v in pairs(getgenv()) do
    if type(v) ~= "function" then
        globalVars[k] = v
        print("[_G] "..k.." = "..tostring(v))
    end
end

for k, v in pairs(_G) do
    if globalVars[k] == nil and type(v) ~= "function" then
        globalVars[k] = v
        print("[_G] "..k.." = "..tostring(v))
    end
end

-- ==========================================
-- 4. ИЩЕМ АДМИН-ПАНЕЛИ В GUI
-- ==========================================
print("[СКАНИРУЮ] GUI...")

local function FindAdminPanels(gui)
    for _, child in pairs(gui:GetDescendants()) do
        if child:IsA("Frame") or child:IsA("ScreenGui") then
            local name = child.Name:lower()
            if string.find(name, "admin") or 
               string.find(name, "mod") or 
               string.find(name, "panel") or
               string.find(name, "control") or
               string.find(name, "owner") then
                print("[GUI] Найдена панель: "..child:GetFullName())
                
                -- Пытаемся открыть
                pcall(function()
                    child.Enabled = true
                    child.Visible = true
                    if child:IsA("ScreenGui") then
                        child.Enabled = true
                    end
                end)
            end
        end
    end
end

FindAdminPanels(plr.PlayerGui)

-- ==========================================
-- 5. ИЩЕМ АДМИН-СКРИПТЫ
-- ==========================================
print("[СКАНИРУЮ] Скрипты с админ-командами...")

local function FindAdminScripts(folder)
    for _, child in pairs(folder:GetDescendants()) do
        if child:IsA("Script") or child:IsA("LocalScript") or child:IsA("ModuleScript") then
            if child:IsA("ModuleScript") then
                -- ModuleScript можно прочитать
                pcall(function()
                    local source = child.Source
                    if source and string.find(source:lower(), "admin") then
                        print("[MODULE] "..child:GetFullName().." содержит admin")
                        print("  "..string.sub(source, 1, 200).."...")
                    end
                end)
            end
        end
    end
end

FindAdminScripts(RS)
FindAdminScripts(SS)

-- ==========================================
-- 6. ХУКАЕМ ВСЕ RemoteEvent ДЛЯ ПЕРЕХВАТА
-- ==========================================
print("[ХУК] Перехватываю все RemoteEvent...")

local hookedRemotes = {}

for _, remote in pairs(allRemotes) do
    if remote.class == "RemoteEvent" then
        local remoteRef = remote.ref
        if not hookedRemotes[remoteRef] then
            local oldFire
            oldFire = hookfunction(remoteRef.FireServer, function(self, ...)
                local args = {...}
                print("[ПЕРЕХВАТ] "..remoteRef.Name.." вызван с аргументами:")
                for i, v in pairs(args) do
                    print("  ["..i.."] "..type(v).." = "..tostring(v))
                end
                
                -- Если видим что-то похожее на проверку админа - подменяем
                if args[1] == "IsAdmin" or args[1] == "CheckPerms" or args[1] == "GetRank" then
                    print("[!] Обнаружена проверка прав! Попытка подмены...")
                    return
                end
                
                return oldFire(self, ...)
            end)
            hookedRemotes[remoteRef] = true
        end
    end
end

-- ==========================================
-- 7. АВТОМАТИЧЕСКАЯ АТАКА НА ВСЕ RemoteEvent
-- ==========================================
print("[АТАКА] Пытаюсь взломать все RemoteEvent...")

local function TryAllCommands(remote)
    if not remote then return end
    
    local commands = {
        -- Стандартные
        "makeadmin", "addadmin", "setadmin", "giveadmin", "removeadmin",
        "rank", "setrank", "promote", "demote", "admin", "mod", "owner",
        "god", "vip", "moderator", "operator", "sudo", "op",
        
        -- С префиксами
        "admin_"..plr.Name, "add_"..plr.Name, "set_"..plr.Name,
        "give_"..plr.Name, "rank_"..plr.Name, "promote_"..plr.Name,
        
        -- Команды с параметрами
        "admin", plr.Name,
        "addadmin", plr.Name,
        "setadmin", plr.Name, true,
        "rank", plr.Name, "Owner",
        "setrank", plr.Name, "Admin",
        
        -- Через таблицу
        {cmd = "admin", player = plr.Name},
        {action = "makeadmin", target = plr.Name},
        {command = "rank", user = plr.Name, rank = "Owner"},
        {type = "admin", name = plr.Name, value = true},
        
        -- Через UserId
        "admin", plr.UserId,
        "addadmin", plr.UserId,
        plr.UserId, "admin",
        
        -- Через имя и ID
        {plr.Name, plr.UserId, "admin"},
        {plr.UserId, plr.Name, "setrank", "Owner"},
        
        -- Специальные
        "grant_permissions", plr.Name,
        "set_permissions", plr.Name, "all",
        "allow", plr.Name,
        "enable_admin", plr.Name,
        "activate_admin", plr.Name,
    }
    
    for _, args in pairs(commands) do
        pcall(function()
            if type(args) == "table" then
                remote:FireServer(unpack(args))
            else
                remote:FireServer(args)
            end
            task.wait(0.02)
        end)
    end
end

-- Атакуем все найденные RemoteEvent
for _, remote in pairs(allRemotes) do
    if remote.class == "RemoteEvent" then
        print("[АТАКА] "..remote.name)
        TryAllCommands(remote.ref)
    end
end

-- ==========================================
-- 8. АТАКА НА RemoteFunction
-- ==========================================
print("[АТАКА] Пытаюсь взломать RemoteFunction...")

for _, remote in pairs(allRemotes) do
    if remote.class == "RemoteFunction" then
        local func = remote.ref
        print("[FUNC] "..remote.name)
        
        local testCalls = {
            {plr.Name},
            {plr.UserId},
            {"admin", plr.Name},
            {"check", plr.Name},
            {"getrank", plr.Name},
            {"isadmin", plr.Name},
            {plr.Name, "getinfo"},
            {plr.UserId, "status"},
            {"ping"},
            {"test"},
            {plr.Name, "admin"},
            {plr.Name, "rank"},
            {plr.Name, "permissions"},
        }
        
        for _, args in pairs(testCalls) do
            pcall(function()
                local result = func:InvokeServer(unpack(args))
                if result then
                    print("[FUNC ОТВЕТ] "..tostring(result))
                    if type(result) == "boolean" and result == true then
                        print("[!!!!!] НАШЁЛ! RemoteFunction вернул true!")
                    end
                end
            end)
            task.wait(0.05)
        end
    end
end

-- ==========================================
-- 9. ПОИСК СКРЫТЫХ КОМАНД В СКРИПТАХ
-- ==========================================
print("[СКАНИРУЮ] Поиск скрытых команд...")

local function FindHiddenCommands()
    local found = {}
    
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") then
            pcall(function()
                local src = obj.Source
                if src then
                    -- Ищем команды
                    local patterns = {
                        "FireServer%s*%(%s*\"[%w_]+\"%s*,%s*\"[%w_]+\"%s*%)",
                        "RemoteEvent.*FireServer",
                        "command%s*=",
                        "cmd%s*=",
                        "action%s*=",
                        "admin.*FireServer",
                        "makeadmin",
                        "setadmin",
                        "addadmin",
                    }
                    
                    for _, pattern in pairs(patterns) do
                        local matches = string.gmatch(src, pattern)
                        for match in matches do
                            if not found[match] then
                                found[match] = true
                                print("[КОМАНДА] Найдена в "..obj.Name..": "..match)
                            end
                        end
                    end
                end
            end)
        end
    end
end

FindHiddenCommands()

-- ==========================================
-- 10. ПОПЫТКА ВЗЛОМАТЬ ЧЕРЕЗ СВОЙСТВА
-- ==========================================
print("[СКАНИРУЮ] Свойства игрока...")

-- Пытаемся изменить атрибуты игрока
local attributes = {
    "Admin", "IsAdmin", "Rank", "Permissions", "Moderator",
    "Owner", "VIP", "God", "Staff", "Trusted", "Level"
}

for _, attr in pairs(attributes) do
    pcall(function()
        plr:SetAttribute(attr, true)
        plr:SetAttribute(attr, "Owner")
        plr:SetAttribute(attr, 999)
        print("[АТРИБУТ] Установлен "..attr)
    end)
end

-- Пытаемся изменить значения в папке Properties
local props = RS:FindFirstChild("Properties")
if props then
    for _, child in pairs(props:GetChildren()) do
        if child:IsA("BoolValue") or child:IsA("StringValue") or child:IsA("NumberValue") then
            local name = child.Name:lower()
            if string.find(name, "admin") or string.find(name, "rank") or string.find(name, "perm") then
                pcall(function()
                    if child:IsA("BoolValue") then child.Value = true end
                    if child:IsA("StringValue") then child.Value = "Owner" end
                    if child:IsA("NumberValue") then child.Value = 999 end
                    print("[PROP] Изменён "..child.Name)
                end)
            end
        end
    end
end

-- ==========================================
-- 11. ПОИСК АДМИН-ЧАТА
-- ==========================================
local chat = RS:FindFirstChild("DefaultChatSystemChatEvents")
if chat then
    local say = chat:FindFirstChild("SayMessageRequest")
    if say then
        print("[ЧАТ] Пробую админ-команды...")
        local chatCmds = {
            "/admin "..plr.Name,
            "/makeadmin "..plr.Name,
            "/setadmin "..plr.Name,
            "/rank "..plr.Name.." Owner",
            "/op "..plr.Name,
            "/god "..plr.Name,
            "/adminme",
            "/opme",
            "/setrank Owner",
            "/addadmin "..plr.Name,
            "!"..plr.Name.." admin",
            "."..plr.Name.." makeadmin",
            "-admin "..plr.Name,
            "/giveadmin "..plr.Name,
            "/addmod "..plr.Name,
        }
        
        for _, cmd in pairs(chatCmds) do
            pcall(function()
                say:FireServer(cmd, "All")
                print("[ЧАТ] "..cmd)
            end)
            task.wait(0.05)
        end
    end
end

-- ==========================================
-- 12. ФИНАЛЬНАЯ ПРОВЕРКА
-- ==========================================
print("=========================================")
print("[ПРОВЕРКА] Стал ли я админом?")

-- Проверяем по атрибутам
local isAdmin = false
for _, attr in pairs(attributes) do
    local val = plr:GetAttribute(attr)
    if val and (val == true or val == "Owner" or val == "Admin" or val == "Staff") then
        print("[УСПЕХ] Найден атрибут "..attr.." = "..tostring(val))
        isAdmin = true
    end
end

-- Проверяем через _G
if _G.AdminList and (_G.AdminList[plr.UserId] or _G.AdminList[plr.Name]) then
    print("[УСПЕХ] Я в _G.AdminList!")
    isAdmin = true
end

-- Проверяем через getgenv()
if getgenv().AdminList and (getgenv().AdminList[plr.UserId] or getgenv().AdminList[plr.Name]) then
    print("[УСПЕХ] Я в getgenv().AdminList!")
    isAdmin = true
end

if isAdmin then
    print("=========================================")
    print("[!!!!!] ТЫ СТАЛ АДМИНОМ, ЕБЛАН! УРА!") 
    print("[!!!!!] ПРОВЕРЬ ИГРУ - ДОЛЖНЫ БЫТЬ КОМАНДЫ!")
    print("=========================================")
else
    print("=========================================")
    print("[НЕТ] Ты НЕ стал админом :(")
    print("[ВЫВОД] Игра ЗАЩИЩЕНА! Забей хуй.")
    print("=========================================")
end

print("[ГОТОВО] СКАНЕР ЗАВЕРШИЛ РАБОТУ, ЕБЛАН!")
