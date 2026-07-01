-- for high end executors method 1

--[[for _, func in next, getgc() do
    if type(func) == "function" and debug.getinfo(func).name == "sprintInput" then
        game:GetService("RunService").RenderStepped:Connect(function()

            pcall(function()
                debug.setupvalue(func, 6, 100)
            end)
        end)
    end
end--]]

-- works on xeno ( didnt test ) method 2

game:GetService("RunService").RenderStepped:Connect(function()
    pcall(function(...)
        game.Players.LocalPlayer.PlayerGui.GameGui.MainHUD.Values.CurrStamina.Value = 100
    end)
end)
