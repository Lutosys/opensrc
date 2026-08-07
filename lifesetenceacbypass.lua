local GetPlayerBanned = filtergc("function", {Name = "GetPlayerBanned"}, true)

hookfunction(GetPlayerBanned, function()
    warn("tried to ban you")
end)
