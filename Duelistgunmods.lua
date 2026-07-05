while task.wait() do
    local char = game.Players.LocalPlayer.Character
    if not char then 
        continue
    end

    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then 
        continue  
    end

    tool:SetAttribute("FireRate", 1000)
    tool:SetAttribute("Automatic", true)
    tool:SetAttribute("Recoil", 0)
    tool:SetAttribute("Spread", 0)
end
