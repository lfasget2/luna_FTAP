local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local me = Players.LocalPlayer

local anim = Instance.new("Animation")
local JerkFlag = false
local jerkoff = nil
local jerkSpeed = 0.1 -- Базовая скорость (100 ms)

local R6 = "rbxassetid://168268306"
local R15 = "rbxassetid://698251653"

-- Функция управления анимацией
local function UpdateJerk()
    if JerkFlag then
        local character = me.Character or me.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        local animator = humanoid:WaitForChild("Animator")
        
        if humanoid.RigType == Enum.HumanoidRigType.R6 then 
            anim.AnimationId = R6 
        else 
            anim.AnimationId = R15 
        end
        
        local timepos = (anim.AnimationId == R6) and 0.3 or 0.55
        jerkoff = animator:LoadAnimation(anim)
        jerkoff:Play()
        
        task.spawn(function()
            while JerkFlag and jerkoff do
                jerkoff.TimePosition = timepos
                task.wait(math.max(0.001, jerkSpeed)) 
            end
        end)
    else
        if jerkoff then
            jerkoff:Stop()
            jerkoff:Destroy()
            jerkoff = nil
        end
    end
end

-- Отслеживание нажатия клавиши Q
UIS.InputBegan:Connect(function(input, processed)
    -- Если игрок пишет в чат, скрипт не сработает
    if processed then return end 
    
    if input.KeyCode == Enum.KeyCode.Q then
        JerkFlag = not JerkFlag
        UpdateJerk()
    end
end)
