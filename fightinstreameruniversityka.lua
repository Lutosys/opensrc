local Event = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("Combat")

while task.wait() do
    local closet = nil
    local closetdistance = math.huge

    for i, v in pairs(game.Players:GetPlayers()) do
        if v == game.Players.LocalPlayer then
            continue
        end
        local char = v.Character
        if not char then 
            continue 
        end   
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then 
            continue 
        end    
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then 
            continue 
        end    
        if char:FindFirstChildOfClass("ForceField") then
            continue
        end
        if v:GetAttribute("OutCombat") then
            continue
        end

        local dist = game.Players.LocalPlayer:DistanceFromCharacter(hrp.Position)
        if dist < closetdistance and dist <= 15 then
            closetdistance = dist
            closet = hrp
        end
    end

    if closet then
        Event:FireServer(
            "M1"
        )
        Event:FireServer(
            "M1Hit",
            closet
        )
    end
end
