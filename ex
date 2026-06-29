-- ЕБАШИМ coroutine, чтобы анти-чит не отследил
local plr = game.Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")

-- Создаём новый поток
local function ExploitThread()
    -- Ждём рандомное время (чтобы не спалиться)
    task.wait(math.random(1, 5))
    
    -- Ищем все RemoteEvent
    for _, remote in pairs(RS:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            -- Пытаемся вызвать с рандомными аргументами
            coroutine.wrap(function()
                remote:FireServer("am_i_admin", plr.Name)
                task.wait(0.5)
                remote:FireServer("checkperms", plr.UserId)
                task.wait(0.5)
                remote:FireServer("getrank", plr.Name)
            end)()
        end
    end
end

-- Запускаем 5 потоков одновременно, чтобы заспамить
for i = 1, 5 do
    coroutine.wrap(ExploitThread)()
end
