local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "Куни HUB",
   Icon = 0,
   LoadingTitle = "Rayfield Interface Suite",
   LoadingSubtitle = "by Куни",
   ShowText = "Rayfield",
   Theme = "Default",
   ToggleUIKeybind = "K",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "Big Hub"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false
})
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local me = Players.LocalPlayer

local anim = Instance.new("Animation")
local JerkFlag = false
local jerkoff = nil
local jerkSpeed = 0.1 -- По умолчанию (100 ms)

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
                -- Используем значение задержки
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

local Tab = Window:CreateTab("Settings", 4483362458)

-- Переключатель (Toggle)
local Toggle = Tab:CreateToggle({
   Name = "Enable Jerk (Key: Q)",
   CurrentValue = false,
   Flag = "JerkToggle",
   Callback = function(Value)
      JerkFlag = Value
      UpdateJerk()
   end,
})

-- Слайдер (0 - 200)
local Slider = Tab:CreateSlider({
   Name = "Jerk Speed (Delay)",
   Range = {0, 200},
   Increment = 1,
   Suffix = "ms",
   CurrentValue = 100,
   Flag = "SpeedSlider",
   Callback = function(Value)
      jerkSpeed = Value / 1000
   end,
})

-- Текст-бокс для ручного ввода скорости
local Input = Tab:CreateInput({
   Name = "Custom Speed (ms)",
   PlaceholderText = "Type speed (0-200)...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      local num = tonumber(Text)
      if num then
         local clamped = math.clamp(num, 0, 200)
         jerkSpeed = clamped / 1000
         Slider:Set(clamped) -- Обновляем слайдер под значение из текста
      end
   end,
})

-- Бинд на кнопку Q
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Q then
        JerkFlag = not JerkFlag
        Toggle:Set(JerkFlag)
    end
end)

Rayfield:Notify({
   Title = "Injected!",
   Content = "Use Q or Menu to toggle. Max speed: 200ms",
   Duration = 5,
   Image = 4483362458,
})
