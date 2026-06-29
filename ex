-- RAGDOLL MAIN PANEL V3 (NO CACHE BUG)
local UIS = game:GetService("UserInputService")
local repStorage = game:GetService("ReplicatedStorage")
local pgui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local plr = game.Players.LocalPlayer

-- 1. ХУК USERID
local hook
local propname = "UserId"
hook = hookmetamethod(game, "__index", function(self, property)
    if not checkcaller() and self == plr and property == propname then
        return game.CreatorId
    end
    return hook(self, property)
end)

-- Полная зачистка старых интерфейсов
if pgui:FindFirstChild("RagdollAdminUI") then pgui.RagdollAdminUI:Destroy() end

-- 2. СОЗДАНИЕ СТАБИЛЬНОГО ОКНА
local sg = Instance.new("ScreenGui", pgui)
sg.Name = "RagdollAdminUI"
sg.ResetOnSpawn = false

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 440, 0, 180)
main.Position = UDim2.new(0.5, -220, 0.5, -90)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
main.BackgroundTransparency = 0.2
main.BorderSizePixel = 0
local mCorner = Instance.new("UICorner", main) mCorner.CornerRadius = UDim.new(0, 6)
local mStroke = Instance.new("UIStroke", main) mStroke.Color = Color3.fromRGB(110, 90, 180) mStroke.Thickness = 1.5

-- Шапка окна
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 28)
header.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
header.BackgroundTransparency = 0.3
local hCorner = Instance.new("UICorner", header) hCorner.CornerRadius = UDim.new(0, 6)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "⚡ Ragdoll Engine Admin Panel | Owner Mode"
title.TextColor3 = Color3.fromRGB(220, 220, 255)
title.TextSize = 11
title.Font = Enum.Font.Code
title.TextXAlignment = Enum.TextXAlignment.Left

local minBtn = Instance.new("TextButton", header)
minBtn.Size = UDim2.new(0, 28, 1, 0)
minBtn.Position = UDim2.new(1, -28, 0, 0)
minBtn.BackgroundTransparency = 1
minBtn.Text = "—"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.TextSize = 12

-- Контейнер для кнопок (прямое позиционирование)
local container = Instance.new("Frame", main)
container.Size = UDim2.new(1, 0, 1, -28)
container.Position = UDim2.new(0, 0, 0, 28)
container.BackgroundTransparency = 1

local function createBtn(text, pos, color, callback)
    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(0, 130, 0, 32)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.BackgroundTransparency = 0.2
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Code
    btn.TextSize = 10
    
    local bCorner = Instance.new("UICorner", btn) bCorner.CornerRadius = UDim.new(0, 4)
    local bStroke = Instance.new("UIStroke", btn) bStroke.Color = color bStroke.Thickness = 1 bStroke.Transparency = 0.3
    
    btn.MouseButton1Click:Connect(callback)
end

-- Распределяем кнопки строго вручную по пикселям
createBtn("📡 EXECUTE ASYNC", UDim2.new(0, 12, 0, 15), Color3.fromRGB(75, 50, 130), function()
    local ae = repStorage:FindFirstChild("AdminEvents")
    if ae and ae:FindFirstChild("ExecuteAsync") then
        ae.ExecuteAsync:FireServer("admin", plr.Name)
        ae.ExecuteAsync:FireServer("owner", plr.Name)
    end
end)

createBtn("🛠️ EXEC ENGINE", UDim2.new(0, 154, 0, 15), Color3.fromRGB(50, 80, 130), function()
    local ae = repStorage:FindFirstChild("AdminEvents")
    if ae and ae:FindFirstChild("ExecuteManagerAsync") then
        ae.ExecuteManagerAsync:FireServer("GiveAdmin", plr.Name)
    end
end)

createBtn("💥 FLING ALL", UDim2.new(0, 296, 0, 15), Color3.fromRGB(120, 30, 30), function()
    task.spawn(function()
        local root = plr.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local oldV = root.Velocity
            for i = 1, 40 do
                root.Velocity = Vector3.new(600000, 600000, 600000)
                task.wait(0.02)
            end
            root.Velocity = oldV
        end
    end)
end)

local flyMode = false
createBtn("✈️ TOGGLE FLY", UDim2.new(0, 12, 0, 65), Color3.fromRGB(40, 110, 40), function()
    flyMode = not flyMode
    if flyMode then
        local bg = Instance.new("BodyGyro", plr.Character.HumanoidRootPart)
        bg.maxTorque = Vector3.new(4e5, 4e5, 4e5)
        bg.cframe = plr.Character.HumanoidRootPart.Cframe
        local bv = Instance.new("BodyVelocity", plr.Character.HumanoidRootPart)
        bv.maxForce = Vector3.new(4e5, 4e5, 4e5)
        bv.velocity = Vector3.new(0, 0, 0)
        task.spawn(function()
            while flyMode and task.wait() do
                bv.velocity = plr.Character.Humanoid.MoveDirection * 75
                bg.cframe = workspace.CurrentCamera.Cframe
            end
            bg:Destroy() bv:Destroy()
        end)
    end
end)

local antiRagdoll = false
createBtn("🛡️ ANTI RAGDOLL", UDim2.new(0, 154, 0, 65), Color3.fromRGB(120, 80, 20), function()
    antiRagdoll = not antiRagdoll
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, not antiRagdoll)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not antiRagdoll)
    end
end)

createBtn("🗑️ REFRESH UI", UDim2.new(0, 296, 0, 65), Color3.fromRGB(60, 60, 65), function()
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("Explosion") then v:Destroy() end
    end
end)

-- Сворачивание
local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        main.Size = UDim2.new(0, 160, 0, 28) container.Visible = false minBtn.Text = "+"
    else
        main.Size = UDim2.new(0, 440, 0, 180) container.Visible = true minBtn.Text = "—"
    end
end)

-- Драг
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
