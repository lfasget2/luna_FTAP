-- КАСТОМНЫЙ ОПТИМИЗИРОВАННЫЙ ИНЖЕКТОР ВНУТРИ ИГРЫ (До 100k строк)
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local pgui = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Удаляем старую версию при перезапуске
if pgui:FindFirstChild("CustomExecutorUI") then
    pgui.CustomExecutorUI:Destroy()
end

-- Создаем контейнер интерфейса
local sg = Instance.new("ScreenGui", pgui)
sg.Name = "CustomExecutorUI"
sg.ResetOnSpawn = false
sg.DisplayOrder = 9999

-- Главное окно инжектора
local mainFrame = Instance.new("Frame", sg)
mainFrame.Size = UDim2.new(0, 550, 0, 350)
mainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
mainFrame.BackgroundTransparency = 0.2 -- Стильная полупрозрачность
mainFrame.BorderSizePixel = 0

local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(80, 80, 120)
stroke.Thickness = 1.5
stroke.Transparency = 0.4

-- Шапка окна (Зона перетаскивания)
local header = Instance.new("Frame", mainFrame)
header.Size = UDim2.new(1, 0, 0, 35)
header.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
header.BackgroundTransparency = 0.3
header.BorderSizePixel = 0

local hCorner = Instance.new("UICorner", header)
hCorner.CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "My Custom Executor v1.0 | LuaU"
title.TextColor3 = Color3.fromRGB(230, 230, 255)
title.TextSize = 13
title.Font = Enum.Font.Code
title.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопка Свернуть/Развернуть (_)
local minBtn = Instance.new("TextButton", header)
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -35, 0, 2)
minBtn.BackgroundTransparency = 1
minBtn.Text = "—"
minBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
minBtn.TextSize = 14
minBtn.Font = Enum.Font.Code

-- Контейнер для текстового поля со скроллом
local scroll = Instance.new("ScrollingFrame", mainFrame)
scroll.Size = UDim2.new(1, -20, 1, -95)
scroll.Position = UDim2.new(0, 10, 0, 45)
scroll.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
scroll.BackgroundTransparency = 0.5
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 5
scroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)

local sCorner = Instance.new("UICorner", scroll)
sCorner.CornerRadius = UDim.new(0, 6)

-- Сверхмощное текстовое поле для кода (TextBox)
local editor = Instance.new("TextBox", scroll)
editor.Size = UDim2.new(1, -10, 1, 0)
editor.Position = UDim2.new(0, 5, 0, 5)
editor.BackgroundTransparency = 1
editor.MultiLine = true -- Позволяет вставлять огромные абзацы текста
editor.ClearTextOnFocus = false -- Код не сотрется случайно при клике
editor.Text = "-- Вставь свой огромный скрипт сюда..."
editor.TextColor3 = Color3.fromRGB(200, 255, 200) -- Красивый зеленый хакерский цвет текста
editor.TextSize = 12
editor.Font = Enum.Font.Code
editor.TextXAlignment = Enum.TextXAlignment.Left
editor.TextYAlignment = Enum.TextYAlignment.Top

-- Динамическое расширение редактора под размер кода, чтобы скролл не багался
editor:GetPropertyChangedSignal("TextBounds"):Connect(function()
    scroll.CanvasSize = UDim2.new(0, editor.TextBounds.X + 20, 0, editor.TextBounds.Y + 20)
    editor.Size = UDim2.new(1, -10, 0, math.max(scroll.AbsoluteSize.Y, editor.TextBounds.Y))
end)

-- Панель под кнопки (Внизу)
local footer = Instance.new("Frame", mainFrame)
footer.Size = UDim2.new(1, 0, 0, 40)
footer.Position = UDim2.new(0, 0, 1, -45)
footer.BackgroundTransparency = 1

-- Кнопка EXECUTE (ИНЖЕКТ)
local execBtn = Instance.new("TextButton", footer)
execBtn.Size = UDim2.new(0, 120, 0, 32)
execBtn.Position = UDim2.new(0, 10, 0, 4)
execBtn.BackgroundColor3 = Color3.fromRGB(35, 85, 45)
execBtn.Text = "Execute"
execBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
execBtn.Font = Enum.Font.Code
execBtn.TextSize = 13
local eCorner = Instance.new("UICorner", execBtn) eCorner.CornerRadius = UDim.new(0, 5)

-- Кнопка CLEAR (ОЧИСТИТЬ)
local clearBtn = Instance.new("TextButton", footer)
clearBtn.Size = UDim2.new(0, 100, 0, 32)
clearBtn.Position = UDim2.new(0, 140, 0, 4)
clearBtn.BackgroundColor3 = Color3.fromRGB(85, 35, 35)
clearBtn.Text = "Clear"
clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clearBtn.Font = Enum.Font.Code
clearBtn.TextSize = 13
local cCorner = Instance.new("UICorner", clearBtn) cCorner.CornerRadius = UDim.new(0, 5)

----------------=======================================================
-- ЛОГИКА РАБОТЫ КНОПОК
----------------=======================================================

-- Кнопка выполнения скрипта через внутренний компилятор
execBtn.MouseButton1Click:Connect(function()
    local code = editor.Text
    if code and code ~= "" then
        local success, err = pcall(function()
            local func = loadstring(code)
            if func then
                task.spawn(func)
            else
                error("Ошибка компиляции: Неверный синтаксис LuaU")
            end
        end)
        if not success then
            warn("🚨 Ошибка выполнения внутри кастомного инжектора: " .. tostring(err))
        end
    end
end)

-- Кнопка мгновенной очистки поля
clearBtn.MouseButton1Click:Connect(function()
    editor.Text = ""
end)

-- Логика сворачивания окна в маленькую кнопку на экране
local isMinimized = false
minBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        mainFrame.Size = UDim2.new(0, 150, 0, 35)
        scroll.Visible = false
        footer.Visible = false
        minBtn.Text = " +"
        title.Text = "Open Executor"
    else
        mainFrame.Size = UDim2.new(0, 550, 0, 350)
        scroll.Visible = true
        footer.Visible = true
        minBtn.Text = "—"
        title.Text = "My Custom Executor v1.0 | LuaU"
    end
end)

----------------=======================================================
-- НЕБАГУЮЩЕЕСЯ ПЛАВНОЕ ПЕРЕТАСКИВАНИЕ ОКНА ЗА ШАПКУ
----------------=======================================================
local dragging, dragInput, dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

print("🚀 Твой личный внутренний инжектор успешно запущен!")
