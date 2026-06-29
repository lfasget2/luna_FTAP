--[[
    ПОЛНЫЙ ОБХОД АДМИНКИ
    ЕСЛИ НЕ СРАБОТАЕТ - ИДИ НАХУЙ
]]

local plr = game.Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local CreatorId = game.CreatorId

-- ==========================================
-- 1. ПОДМЕНА USERID (если проверка на клиенте)
-- ==========================================
local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if not checkcaller() and self == plr and key == "UserId" then
        return CreatorId  -- Подмена на ID создателя
    end
    return oldIndex(self, key)
end)

-- ==========================================
-- 2. ЗАПИСЫВАЕМСЯ В _G (если сервер тупой)
-- ==========================================
getgenv().AdminList = getgenv().AdminList or {}
getgenv().AdminList[plr.UserId] = true
getgenv().AdminList[CreatorId] = true
getgenv().AdminList[plr.Name] = "Owner"

_G.AdminList = _G.AdminList or {}
_G.AdminList[plr.UserId] = true
_G.AdminList[CreatorId] = true
_G.AdminList[plr.Name] = "Owner"

-- ==========================================
-- 3. ПОИСК ВСЕХ РЕМОУТОВ
-- ==========================================
local function FindRemotes(folder, depth)
    depth = depth or 0
    if depth > 5 then return end  -- Чтобы не уйти в рекурсию
    
    for _, child in pairs(folder:GetChildren()) do
        if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
            print("[НАЙДЕНО]", child.Name, child.ClassName)
            
            -- Пытаемся вызвать
            if child:IsA("RemoteEvent") then
                child:FireServer("makeadmin", plr.Name)
                child:FireServer("addadmin", plr.Name)
                child:FireServer("rank", plr.Name, "Owner")
                child:FireServer("admin", plr.Name)
                child:FireServer("promote", plr.Name)
                child:FireServer("setrank", plr.Name, "Owner")
                child:FireServer("addadmin", plr.UserId)
                child:FireServer("makeadmin", plr.UserId)
                child:FireServer("setadmin", plr.Name, true)
                child:FireServer("giveadmin", plr.Name)
                child:FireServer("owner", plr.Name)
                child:FireServer("setowner", plr.Name)
                child:FireServer("god", plr.Name)
            end
            
            -- Если RemoteFunction - вызываем
            if child:IsA("RemoteFunction") then
                local result = child:InvokeServer(plr.Name)
                if result then
                    print("[ОТВЕТ]", result)
                end
            end
        end
        
        -- Рекурсивно ищем в папках
        if child:IsA("Folder") or child:IsA("Model") then
            FindRemotes(child, depth + 1)
        end
    end
end

-- Ищем во всех папках
print("[СКАНИРУЮ] ReplicatedStorage")
FindRemotes(RS)

print("[СКАНИРУЮ] Workspace")
FindRemotes(workspace)

print("[СКАНИРУЮ] PlayerGui")
if plr:FindFirstChild("PlayerGui") then
    FindRemotes(plr.PlayerGui)
end

-- ==========================================
-- 4. ХУК НА ВСЕ RemoteEvent-ы (перехват)
-- ==========================================
local function HookAllRemotes(folder)
    for _, child in pairs(folder:GetChildren()) do
        if child:IsA("RemoteEvent") then
            local oldFire
            oldFire = hookfunction(child.FireServer, function(self, ...)
                print("[ПЕРЕХВАТ] "..child.Name, ...)
                return oldFire(self, ...)
            end)
            print("[ХУК] Перехватываю "..child.Name)
        end
    end
end

HookAllRemotes(RS)

-- ==========================================
-- 5. ПОДМЕНА ИМЕНИ (если проверяют по имени)
-- ==========================================
local oldNameIndex
oldNameIndex = hookmetamethod(game, "__index", function(self, key)
    if not checkcaller() and self == plr and key == "Name" then
        return "Owner"  -- Подмена имени
    end
    return oldNameIndex(self, key)
end)

-- ==========================================
-- 6. АВТОМАТИЧЕСКАЯ КОМАНДА (после загрузки)
-- ==========================================
wait(2)
print("[ЗАПУСК] Пытаюсь получить админку...")

-- Пытаемся через все команды
local commands = {
    "makeadmin", "addadmin", "setadmin", "giveadmin",
    "rank", "setrank", "promote", "owner",
    "setowner", "god", "admin", "mod", "moderator",
    "vip", "adminme", "giveperms", "op"
}

for _, cmd in pairs(commands) do
    for _, remote in pairs(RS:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            remote:FireServer(cmd, plr.Name)
            remote:FireServer(cmd, plr.UserId)
            remote:FireServer("add", plr.Name, cmd)
        end
    end
end

-- ==========================================
-- 7. ПРОВЕРКА НА КЛИЕНТСКУЮ АДМИНКУ
-- ==========================================
if _G.AdminPanel then
    _G.AdminPanel:Open()
    print("[УСПЕХ] Открыл панель!")
end

if _G.AdminGUI then
    _G.AdminGUI.Visible = true
end

-- ==========================================
-- 8. ВЫВОД ИНФЫ
-- ==========================================
print("====================================")
print("[ГОТОВО] Если есть дыра - я её нашёл!")
print("====================================")
print("Твой ID: "..plr.UserId)
print("ID создателя: "..CreatorId)
print("Твой ник: "..plr.Name)
print("====================================")

wait(1)
print("[ТЕСТ] Проверяю доступ...")
for _, remote in pairs(RS:GetDescendants()) do
    if remote:IsA("RemoteFunction") then
        local result = remote:InvokeServer("ping")
        if result then
            print("[ПИНГ] "..result)
        end
    end
end

print("[КОНЕЦ] Если нихуя не сработало - разрабы не пидоры.")
