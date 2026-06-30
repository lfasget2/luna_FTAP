local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Настройки механики Evade
local MAX_SPEED = 1000
local ACCELERATION = 40 -- Чуть увеличил, чтобы быстрее ловить разгон для взлета
local BASE_SPEED = 16
local JUMP_BOOST_MULTIPLIER = 0.4 -- Какая часть твоей скорости конвертируется в высоту взлета

-- Создание HUD
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EvadeBhopHud"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0, 200, 0, 30)
SpeedLabel.Position = UDim2.new(0.5, -100, 0.7, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.TextSize = 24
SpeedLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
SpeedLabel.Text = "SPEED: 0"
SpeedLabel.Parent = ScreenGui

local BarBackground = Instance.new("Frame")
BarBackground.Size = UDim2.new(0, 200, 0, 8)
BarBackground.Position = UDim2.new(0.5, -100, 0.73, 0)
BarBackground.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
BarBackground.BorderSizePixel = 0
BarBackground.Parent = ScreenGui

local BarProgress = Instance.new("Frame")
BarProgress.Size = UDim2.new(0, 0, 1, 0)
BarProgress.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
BarProgress.BorderSizePixel = 0
BarProgress.Parent = BarBackground

print("🌌 EVADE MECHANICS INJECTED 🌌")

local currentBhopSpeed = BASE_SPEED
local lastFloorMaterial = Enum.Material.Air

RunService.Heartbeat:Connect(function(dt)
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end

    -- Текущая скорость
    local vel = rootPart.Velocity
    local currentSpeed = math.floor(Vector3.new(vel.X, 0, vel.Z).Magnitude)

    -- Обновление UI
    SpeedLabel.Text = "SPEED: " .. tostring(currentSpeed)
    local progress = math.clamp(currentSpeed / MAX_SPEED, 0, 1)
    BarProgress.Size = UDim2.new(progress, 0, 1, 0)
    
    local speedColor = Color3.fromHSV((1 - progress) * 0.35, 1, 1)
    SpeedLabel.TextColor3 = speedColor
    BarProgress.BackgroundColor3 = speedColor

    -- Кнопки управления
    local isMovingForward = UserInputService:IsKeyDown(Enum.KeyCode.W)
    local isJumping = UserInputService:IsKeyDown(Enum.KeyCode.Space)

    if isJumping and isMovingForward then
        -- Фиксация момента прыжка с кочки / объекта
        if humanoid.FloorMaterial ~= Enum.Material.Air and lastFloorMaterial == Enum.Material.Air then
            -- Если мы летели на скорости и врезались в землю/кочку/клона
            if currentSpeed > 40 then
                -- Считаем бонус к прыжку вверх, зависящий от твоей горизонтальной скорости
                local jumpBoost = currentSpeed * JUMP_BOOST_MULTIPLIER
                -- Ограничиваем максимальный полет вверх, чтобы не улететь в стратосферу
                jumpBoost = math.clamp(jumpBoost, 20, 120) 
                
                -- Даем мощный пинок вверх (ось Y), сохраняя инерцию движения вперед
                rootPart.Velocity = Vector3.new(rootPart.Velocity.X, jumpBoost, rootPart.Velocity.Z)
            end
        end

        -- Обычный автопрыжок
        if humanoid.FloorMaterial ~= Enum.Material.Air then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
        
        -- Тяжелый разгон вперед
        if currentBhopSpeed < MAX_SPEED then
            currentBhopSpeed = currentBhopSpeed + (ACCELERATION * dt)
        end

        local look = rootPart.CFrame.LookVector
        -- Применяем скорость вперед, не зануляя прыжок по Y
        rootPart.Velocity = Vector3.new(look.X * currentBhopSpeed, rootPart.Velocity.Y, look.Z * currentBhopSpeed)
    else
        -- Сброс скорости при полной остановке на земле
        if humanoid.FloorMaterial ~= Enum.Material.Air then
            currentBhopSpeed = BASE_SPEED
        end
    end

    -- Запоминаем состояние пола для следующего кадра
    lastFloorMaterial = humanoid.FloorMaterial
end)
