while wait() do
    for i, v in pairs(game.Players:GetPlayers()) do
        if v == game.Players.LocalPlayer then
            continue
        end

        local char = v.Character
        if not char then continue end   

        if not char:FindFirstChild("Punch") then
            continue
        end 

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end    

        local hum = char:FindFirstChild("Humanoid")
        if not hum then continue end    

        local dist = game.Players.LocalPlayer:DistanceFromCharacter(hrp.Position)
        if dist < 20 then
            local Event = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild("ClientToServer")
            Event:FireServer(
                "Attack",
                "Punch"
            )

            local Event = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild("ClientToServer")
            Event:FireServer(
                "PlayerHit",
                "Punch",
                hum
            )
        end
    end
end
