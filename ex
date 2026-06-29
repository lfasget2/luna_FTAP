local RS = game:GetService("ReplicatedStorage")
local plr = game.Players.LocalPlayer

-- Пробуем все варианты
local push = RS:FindFirstChild("PushEvent_RemoteEvent")

if push and push:IsA("RemoteEvent") then
    print("[ПЫТАЮСЬ] PushEvent_RemoteEvent")
    
    -- Вариант 1: сделать себя админом
    push:FireServer("makeadmin", plr.Name)
    push:FireServer("setadmin", plr.Name, true)
    push:FireServer("addadmin", plr.Name)
    
    -- Вариант 2: отправить команду
    push:FireServer("command", "makeadmin", plr.Name)
    push:FireServer("cmd", "admin", plr.Name)
    
    -- Вариант 3: если через таблицу
    push:FireServer({cmd = "makeadmin", target = plr.Name})
    push:FireServer({action = "rank", player = plr.Name, rank = "Owner"})
end
