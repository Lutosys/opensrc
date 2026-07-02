-- infinite fuel

pcall(function()
    local vehicles = workspace.Vehicles

    local function getLocalCar()
        for _, car in next, vehicles:GetChildren() do
            if car:GetAttribute("Owner") and car:GetAttribute("Owner") == game.Players.LocalPlayer.Name then
                return car
            end
        end
        return nil 
    end

    task.spawn(function()
        while wait(1) do
            pcall(function(...)
                getLocalCar().Control_Values.CurrentFuel.Value = math.huge
            end)
        end
    end)
end)
