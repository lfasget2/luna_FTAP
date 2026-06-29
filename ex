-- ADVANCED LUNA EXECUTOR v2.0 (MONOLITH OPTIMIZED)
local UIS = game:GetService("UserInputService")
local pgui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
if pgui:FindFirstChild("LunaExecutor") then pgui.LunaExecutor:Destroy() end

local sg = Instance.new("ScreenGui", pgui)
sg.Name = "LunaExecutor"
sg.ResetOnSpawn = false
sg.DisplayOrder = 9999

local playerHWID = (gethwid and gethwid()) or (game:GetService("RbxAnalyticsService"):GetClientId())
local saveFolder = "Luna_Scripts_" .. string.sub(playerHWID, 1, 12)

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 600, 0, 380)
main.Position = UDim2.new(0.5, -300, 0.5, -190)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
main.BorderSizePixel = 0
local mCorner = Instance.new("UICorner", main) mCorner.CornerRadius = UDim.new(0, 8)
local mStroke = Instance.new("UIStroke", main) mStroke.Color = Color3.fromRGB(90, 80, 150) mStroke.Thickness = 1.5

local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
header.BorderSizePixel = 0
local hCorner = Instance.new("UICorner", header) hCorner.CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🌙 LUNA EXECUTOR v2.0 | Secured by HWID"
title.TextColor3 = Color3.fromRGB(210, 210, 255)
title.TextSize = 12
title.Font = Enum.Font.Code
title.TextXAlignment = Enum.TextXAlignment.Left

local minBtn = Instance.new("TextButton", header)
minBtn.Size = UDim2.new(0, 30, 1, 0)
minBtn.Position = UDim2.new(1, -30, 0, 0)
minBtn.BackgroundTransparency = 1
minBtn.Text = "—"
minBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
minBtn.TextSize = 14

local tabSidebar = Instance.new("ScrollingFrame", main)
tabSidebar.Size = UDim2.new(0, 110, 1, -75)
tabSidebar.Position = UDim2.new(0, 8, 0, 38)
tabSidebar.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
tabSidebar.BorderSizePixel = 0
tabSidebar.ScrollBarThickness = 2
local tsCorner = Instance.new("UICorner", tabSidebar) tsCorner.CornerRadius = UDim.new(0, 6)
local tabLayout = Instance.new("UIListLayout", tabSidebar) tabLayout.SortOrder = Enum.SortOrder.LayoutOrder tabLayout.Padding = UDim.new(0, 4)

local editorScroll = Instance.new("ScrollingFrame", main)
editorScroll.Size = UDim2.new(1, -135, 1, -75)
editorScroll.Position = UDim2.new(0, 125, 0, 38)
editorScroll.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
editorScroll.BorderSizePixel = 0
editorScroll.ScrollBarThickness = 5
local esCorner = Instance.new("UICorner", editorScroll) esCorner.CornerRadius = UDim.new(0, 6)

local linesLabel = Instance.new("TextLabel", editorScroll)
linesLabel.Size = UDim2.new(0, 30, 1, 0)
linesLabel.Position = UDim2.new(0, 5, 0, 5)
linesLabel.BackgroundTransparency = 1
linesLabel.Text = "1"
linesLabel.TextColor3 = Color3.fromRGB(80, 80, 100)
linesLabel.TextSize = 12
linesLabel.Font = Enum.Font.Code
linesLabel.TextYAlignment = Enum.TextYAlignment.Top
linesLabel.TextXAlignment = Enum.TextXAlignment.Right

local box = Instance.new("TextBox", editorScroll)
box.Size = UDim2.new(1, -45, 1, 0)
box.Position = UDim2.new(0, 42, 0, 5)
box.BackgroundTransparency = 1
box.MultiLine = true
box.ClearTextOnFocus = false
box.Text = ""
box.TextColor3 = Color3.fromRGB(180, 240, 180)
box.TextSize = 12
box.Font = Enum.Font.Code
box.TextXAlignment = Enum.TextXAlignment.Left
box.TextYAlignment = Enum.TextYAlignment.Top

local tabs = {}
local activeTab = nil

local function getSavedCode(tabName)
    local filename = saveFolder .. "_" .. tabName .. ".txt"
    if readfile then local s, c = pcall(function() return readfile(filename) end) if s then return c end end
    return ""
end

local function saveCodeToFile(tabName, text)
    local filename = saveFolder .. "_" .. tabName .. ".txt"
    if writefile then pcall(function() writefile(filename, text) end) end
end

local function selectTab(tabId)
    if activeTab then
        tabs[activeTab].code = box.Text
        saveCodeToFile(tabs[activeTab].name, box.Text)
        tabs[activeTab].button.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
        tabs[activeTab].button.UIStroke.Color = Color3.fromRGB(40, 40, 50)
    end
    activeTab = tabId
    box.Text = tabs[tabId].code
    tabs[tabId].button.BackgroundColor3 = Color3.fromRGB(45, 40, 75)
    tabs[tabId].button.UIStroke.Color = Color3.fromRGB(120, 100, 200)
end

local function createTab(name, initialCode)
    local tabId = #tabs + 1
    local codeContent = (initialCode and initialCode ~= "") and initialCode or getSavedCode(name)
    local btn = Instance.new("TextButton", tabSidebar)
    btn.Size = UDim2.new(1, -4, 0, 25)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    btn.Text = "  " .. name
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.Font = Enum.Font.Code
    btn.TextSize = 11
    btn.TextXAlignment = Enum.TextXAlignment.Left
    local bCorner = Instance.new("UICorner", btn) bCorner.CornerRadius = UDim.new(0, 4)
    local bStroke = Instance.new("UIStroke", btn) bStroke.Color = Color3.fromRGB(40, 40, 50) bStroke.Thickness = 1
    tabs[tabId] = {name = name, code = codeContent, button = btn}
    btn.MouseButton1Click:Connect(function() selectTab(tabId) end)
    if #tabs == 1 then selectTab(tabId) end
end

createTab("Script_1", "")
createTab("Script_2", "")
createTab("Script_3", "")

box:GetPropertyChangedSignal("Text"):Connect(function()
    if activeTab then tabs[activeTab].code = box.Text saveCodeToFile(tabs[activeTab].name, box.Text) end
    local _, lines = box.Text:gsub("\n", "") lines = lines + 1
    local lineStr = "" for i = 1, lines do lineStr = lineStr .. i .. "\n" end
    linesLabel.Text = lineStr
    editorScroll.CanvasSize = UDim2.new(0, box.TextBounds.X + 60, 0, math.max(box.TextBounds.Y, linesLabel.TextBounds.Y) + 30)
    box.Size = UDim2.new(1, -45, 0, math.max(editorScroll.AbsoluteSize.Y, box.TextBounds.Y))
    linesLabel.Size = UDim2.new(0, 30, 0, linesLabel.TextBounds.Y)
end)

local footer = Instance.new("Frame", main)
footer.Size = UDim2.new(1, 0, 0, 35)
footer.Position = UDim2.new(0, 0, 1, -35)
footer.BackgroundTransparency = 1

local play = Instance.new("TextButton", footer)
play.Size = UDim2.new(0, 90, 0, 26)
play.Position = UDim2.new(0, 125, 0, 2)
play.BackgroundColor3 = Color3.fromRGB(35, 100, 45)
play.TextColor3 = Color3.fromRGB(255, 255, 255)
play.Text = "▶ PLAY"
play.Font = Enum.Font.Code
local pCorner = Instance.new("UICorner", play) pCorner.CornerRadius = UDim.new(0, 4)
play.MouseButton1Click:Connect(function() if box.Text ~= "" then local f, err = loadstring(box.Text) if f then task.spawn(f) else warn("Ошибка: " .. tostring(err)) end end end)

local clear = Instance.new("TextButton", footer)
clear.Size = UDim2.new(0, 90, 0, 26)
clear.Position = UDim2.new(0, 225, 0, 2)
clear.BackgroundColor3 = Color3.fromRGB(110, 35, 35)
clear.TextColor3 = Color3.fromRGB(255, 255, 255)
clear.Text = "🗑️ CLEAR"
clear.Font = Enum.Font.Code
local cCorner = Instance.new("UICorner", clear) cCorner.CornerRadius = UDim.new(0, 4)
clear.MouseButton1Click:Connect(function() box.Text = "" end)

local addTab = Instance.new("TextButton", footer)
addTab.Size = UDim2.new(0, 110, 0, 26)
addTab.Position = UDim2.new(0, 8, 0, 2)
addTab.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
addTab.TextColor3 = Color3.fromRGB(255, 255, 255)
addTab.Text = "+ NEW TAB"
addTab.Font = Enum.Font.Code
local atCorner = Instance.new("UICorner", addTab) atCorner.CornerRadius = UDim.new(0, 4)
addTab.MouseButton1Click:Connect(function() createTab("Script_" .. (#tabs + 1), "") end)

local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        main.Size = UDim2.new(0, 160, 0, 30)
        tabSidebar.Visible = false editorScroll.Visible = false footer.Visible = false
        minBtn.Text = "+" title.Text = "Luna Hidden"
    else
        main.Size = UDim2.new(0, 600, 0, 380)
        tabSidebar.Visible = true editorScroll.Visible = true footer.Visible = true
        minBtn.Text = "—" title.Text = "🌙 LUNA EXECUTOR v2.0 | Secured by HWID"
    end
end)

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
