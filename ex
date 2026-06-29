print("[ЗАПУСК] ЕБАШИМ ВСЕ ВАРИАНТЫ!")

local RS = game:GetService("ReplicatedStorage")
local plr = game.Players.LocalPlayer

-- ==========================================
-- ВАРИАНТЫ АРГУМЕНТОВ ДЛЯ RemoteEvent
-- ==========================================
local argumentSets = {
    -- Вариант 1: команда и имя
    {"admin", plr.Name},
    {"makeadmin", plr.Name},
    {"setadmin", plr.Name, true},
    {"rank", plr.Name, "Owner"},
    {"setrank", plr.Name, "Admin"},
    {"promote", plr.Name},
    {"owner", plr.Name},
    {"mod", plr.Name},
    {"god", plr.Name},
    {"vip", plr.Name},
    
    -- Вариант 2: имя и команда
    {plr.Name, "admin"},
    {plr.Name, "makeadmin"},
    {plr.Name, "setadmin"},
    {plr.Name, "rank", "Owner"},
    {plr.Name, "promote"},
    
    -- Вариант 3: UserId и команда
    {plr.UserId, "admin"},
    {plr.UserId, "makeadmin"},
    {plr.UserId, "setadmin"},
    {plr.UserId, "rank", "Owner"},
    
    -- Вариант 4: таблица
    {{player = plr.Name, command = "admin"}},
    {{target = plr.Name, action = "makeadmin"}},
    {{user = plr.Name, rank = "Owner"}},
    {{id = plr.UserId, perm = "admin"}},
    
    -- Вариант 5: строка с командой
    {"admin "..plr.Name},
    {"makeadmin "..plr.Name},
    {"rank "..plr.Name.." Owner"},
    {"/admin "..plr.Name},
    {"/makeadmin "..plr.Name},
    
    -- Вариант 6: два аргумента (команда, таблица)
    {"admin", {player = plr.Name}},
    {"setrank", {player = plr.Name, rank = "Owner"}},
    
    -- Вариант 7: пустой вызов
    {},
}

-- ==========================================
-- ПРОБУЕМ Set RemoteEvent
-- ==========================================
local setRemote = RS:FindFirstChild("Set RemoteEvent")
if setRemote then
    print("[АТАКА] Set RemoteEvent - "..#argumentSets.." вариантов")
    
    for i, args in pairs(argumentSets) do
        pcall(function()
            setRemote:FireServer(unpack(args))
            print("[ОК] Вариант "..i.." отправлен")
        end)
        task.wait(0.05)
    end
end

-- ==========================================
-- ПРОБУЕМ PushEvent_RemoteEvent (повторно)
-- ==========================================
local push = RS:FindFirstChild("PushEvent_RemoteEvent")
if push then
    print("[АТАКА] PushEvent_RemoteEvent")
    
    -- Специфичные для Push команды
    local pushArgs = {
        {"push", "admin", plr.Name},
        {"push", "makeadmin", plr.Name},
        {"push", "setadmin", plr.Name, true},
        {"event", "admin", plr.Name},
        {"pushEvent", plr.Name, "admin"},
        {plr.Name, "push", "admin"},
    }
    
    for _, args in pairs(pushArgs) do
        pcall(function()
            push:FireServer(unpack(args))
        end)
        task.wait(0.05)
    end
end

-- ==========================================
-- ПРОБУЕМ Ragdoll_RemoteEvent (повторно)
-- ==========================================
local ragdoll = RS:FindFirstChild("Ragdoll_RemoteEvent")
if ragdoll then
    print("[АТАКА] Ragdoll_RemoteEvent")
    
    local ragdollArgs = {
        {"ragdoll", "admin", plr.Name},
        {"setragdoll", plr.Name, "admin"},
        {"command", "admin", plr.Name},
        {"exec", "makeadmin", plr.Name},
        {"run", "rank", plr.Name, "Owner"},
        {plr.Name, "admin", true},
    }
    
    for _, args in pairs(ragdollArgs) do
        pcall(function()
            ragdoll:FireServer(unpack(args))
        end)
        task.wait(0.05)
    end
end

-- ==========================================
-- ПРОБУЕМ Send RemoteFunction (разные варианты)
-- ==========================================
local sendFunc = RS:FindFirstChild("Send RemoteFunction")
if sendFunc then
    print("[АТАКА] Send RemoteFunction")
    
    local functionCalls = {
        {plr.Name},
        {plr.UserId},
        {"admin", plr.Name},
        {"check", plr.Name},
        {"getinfo", plr.Name},
        {"status", plr.UserId},
        {plr.Name, "rank"},
        {"setadmin", plr.Name, true},
        {plr.Name, "getadmin"},
        {"ping"},
        {"test"},
        {"", plr.Name},
    }
    
    for _, args in pairs(functionCalls) do
        pcall(function()
            local result = sendFunc:InvokeServer(unpack(args))
            if result then
                print("[УСПЕХ!] Ответ от Send: "..tostring(result))
                if type(result) == "boolean" and result == true then
                    print("[НАШЁЛ!] true - возможно, мы админы!")
                end
            end
        end)
        task.wait(0.1)
    end
end

print("[ГОТОВО] ВСЁ ПРОВЕРИЛИ, ЕБЛАН!")
