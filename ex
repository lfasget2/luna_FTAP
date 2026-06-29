-- RAGDOLL ENGINE CONTROL PANEL + USERID SPOOFER (MONOLITH)
local UIS = game:GetService("UserInputService")
local repStorage = game:GetService("ReplicatedStorage")
local pgui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local plr = game.Players.LocalPlayer

-- 1. ТВОЙ ХУК МЕТАМЕТОДА ДЛЯ ПОДМЕНЫ USERID
local hook
local propname = "UserId"

hook = hookmetamethod(game, "__index", function(self, property)
    if not checkcaller() and self == plr and property == propname then
        return game.CreatorId -- Возвращаем ID создателя игры для всех скриптов плейса
    end
    return hook(self, property)
end)

print("✅ Хук метаметода UserId (game.CreatorId) успешно запущен!")

-- Удаляем старое меню, если оно было
if pgui:FindFirstChild("RagdollAdminUI") then pgui.RagdollAdminUI:Destroy() end

-- 2. СОЗДАНИЕ КРАСИВОГО АДМИН-GUI
local sg = Instance.new("ScreenGui", pgui)
sg.Name = "RagdollAdminUI"
sg.ResetOnSpawn = false
sg.DisplayOrder = 9999

-- Главное окно
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 450, 0, 280)
main.Position = UDim2.new(0.5, -225, 0.5, -140)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
main.BackgroundTransparency = 0.25
main.BorderSizePixel = 0
local mCorner = Instance.new("UICorner", main) mCorner.CornerRadius = UDim.new(0, 6)
local mStroke = Instance.new("UIStroke", main) mStroke.Color = Color3.fromRGB(110, 90, 180) mStroke.Thickness = 1.5

-- Шапка (Перетаскивание)
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 28)
header.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
header.BackgroundTransparency = 0.4
local hCorner = Instance.new("UICorner", header) hCorner.CornerRadius = UDim.new(0, 6)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "⚡ Ragdoll Engine Admin Panel | Owner Mode"
title.TextColor3 = Color3.fromRGB(220, 220, 255)
title.TextSize = 12
title.Font = Enum.Font.Code
title.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопка Свернуть [_]
local minBtn = Instance.new("TextButton", header)
minBtn.Size = UDim2.new(0, 28, 1, 0)
minBtn.Position = UDim2.new(1, -28, 0, 0)
minBtn.BackgroundTransparency = 1
minBtn.Text = "—"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.TextSize = 12

-- Контейнер для вкладок/кнопок
local container = Instance.new("Frame", main)
container.Size = UDim2.new(1, -20, 1, -45)
container.Position = UDim2.new(0, 10, 0, 38)
container.BackgroundTransparency = 1

local layout = Instance.new("UIGridLayout", container)
layout.CellSize = UDim2.new(0, 135, 0, 32)
layout.Padding = UDim2.new(0, 10, 0, 10)

-- Функция создания админ-кнопок с неоновым эффектом
local function createAdminButton(text, color, callback)
    local btn = Instance.new("TextButton", container)
    btn.BackgroundColor3 = color
    btn.BackgroundTransparency = 0.3
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Code
    btn.TextSize = 11
    
    local bCorner = Instance.new("UICorner", btn) bCorner.CornerRadius = UDim.new(0, 4)
    local bStroke = Instance.new("UIStroke", btn) bStroke.Color = color bStroke.Thickness = 1
    
    btn.MouseButton1Click:Connect(callback)
end

----------------=======================================================
-- ФУНКЦИОНАЛ КНОПОК УПРАВЛЕНИЯ
----------------=======================================================

-- 1. Вызов оригинальных системных функций с поддельным ID
createAdminButton("📡 EXECUTE ASYNC", Color3.fromRGB(75, 50, 130), function()
    local adminEvents = repStorage:FindFirstChild("AdminEvents")
    if adminEvents and adminEvents:FindFirstChild("ExecuteAsync") then
        adminEvents.ExecuteAsync:FireServer("admin", plr.Name)
        adminEvents.ExecuteAsync:FireServer("owner", plr.Name)
        print("🚀 Пакеты личного ранка отправлены в ExecuteAsync!")
    end
end)

createAdminButton("🛠️ EXEC ENGINE", Color3.fromRGB(50, 80, 130), function()
    local adminEvents = repStorage:FindFirstChild("AdminEvents")
    if adminEvents and adminEvents:FindFirstChild("ExecuteManagerAsync") then
        adminEvents.ExecuteManagerAsync:FireServer("GiveAdmin", plr.Name)
        print("🚀 Пакеты отправлены в ExecuteManagerAsync!")
    end
end)

-- 2. Локальные чит-функции (Встроенный админка-мод)
local flyMode = false
createAdminButton("✈️ TOGGLE FLY", Color3.fromRGB(40, 110, 40), function()
    flyMode = not flyMode
    if flyMode then
        -- Быстрый запуск локального полета
        local bg = Instance.new("BodyGyro", plr.Character.HumanoidRootPart)
        bg.maxTorque = Vector3.new(4e5, 4e5, 4e5)
        bg.cframe = plr.Character.HumanoidRootPart.Cframe
        local bv = Instance.new("BodyVelocity", plr.Character.HumanoidRootPart)
        bv.maxForce = Vector3.new(4e5, 4e5, 4e5)
        bv.velocity = Vector3.new(0, 50, 0) -- Плавный взлет вверх
        task.spawn(function()
            while flyMode and task.wait() do
                bv.velocity = plr.Character.Humanoid.MoveDirection * 80
                bg.cframe = workspace.CurrentCamera.Cframe
            end
            bg:Destroy() bv:Destroy()
        end)
    end
end)

local antiRagdoll = false
createAdminButton("🛡️ ANTI RAGDOLL", Color3.fromRGB(110, 80, 30), function()
    antiRagdoll = not antiRagdoll
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, not antiRagdoll)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not antiRagdoll)
    end
end)

createAdminButton("💥 FLING ALL", Color3.fromRGB(120, 30, 30), function()
    -- Мощная локальная атака на физику других игроков
    task.spawn(function()
        local root = plr.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local oldV = root.Velocity
            for i = 1, 50 do
                root.Velocity = Vector3.new(500000, 500000, 500000)
                task.wait(0.02)
            end
            root.Velocity = oldV
        end
    end)
end)

createAdminButton("🗑️ CLEAR EFFECTS", Color3.fromRGB(60, 60, 60), function()
    -- Очистка лагов и эффектов на экране
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("Explosion") or v:IsA("ForceField") then v:Destroy() end
    end
end)

-- Логика сворачивания в компактную полоску
local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        main.Size = UDim2.new(0, 160, 0, 28)
        container.Visible = false
        minBtn.Text = "+"
    else
        main.Size = UDim2.new(0, 450, 0, 280)
        container.Visible = true
        minBtn.Text = "—"
    end
end)

-- Небаганное плавное перемещение
local dragging, dragInput, dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true dragStart = input.Position startPos = main.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
header.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

print("🚀 Админ-хаб Ragdoll Engine успешно развернут на экране!")
