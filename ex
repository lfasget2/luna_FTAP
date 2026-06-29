-- ХУКАЕМ СРАЗУ НЕСКОЛЬКО МЕТОДОВ
local plr = game.Players.LocalPlayer

-- 1. Хук на __index (для UserId)
local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if not checkcaller() and self == plr and key == "UserId" then
        return game.CreatorId
    end
    return oldIndex(self, key)
end)

-- 2. Хук на __namecall (для вызовов методов)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if not checkcaller() and method == "FireServer" then
        local args = {...}
        -- Если пытаются вызвать что-то, связанное с проверкой прав
        if args[1] == "IsAdmin" or args[1] == "CheckPerms" then
            return
        end
    end
    return oldNamecall(self, ...)
end)

print("[ХУК] Готов, блять!")
