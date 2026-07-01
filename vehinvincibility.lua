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

    -- No Car Damage From Poles/etc

    task.spawn(function()
        while wait() do
            pcall(function(...)
                getLocalCar().Body.CollisionPart.CanTouch = false
            end)
        end
    end)

    -- wheel invincibility

    task.spawn(function()
        while wait() do
            pcall(function(...)
                for _, v in next, getLocalCar().Wheels:GetChildren() do
                    v.CanTouch = false
                    v.Transparency = 1
                    v.CanCollide = true
                end
            end)
        end
    end)
end)
