while wait() do
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr == game.Players.LocalPlayer then continue end    

        local char = plr.Character
        if not char then continue end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        local mychar = game:GetService("Players").LocalPlayer.Character
        if not mychar then continue end

        local AR = game:GetService("Players").LocalPlayer:FindFirstChild("Backpack"):FindFirstChild("AR")
        if not AR then
            AR = mychar:FindFirstChild("AR")
            if not AR then
                continue
            end
        end

        local WeaponHit = game:GetService("ReplicatedStorage"):FindFirstChild("WeaponsSystem"):FindFirstChild("Network"):FindFirstChild("WeaponHit")
        WeaponHit:FireServer(
            AR,
            {
                p = hrp.Position,
                pid = 1,
                part = hrp,
                d = 0,
                maxDist = 0,
                h = hrp,
                m = Enum.Material.SmoothPlastic,
                n = Vector3.new(0,0,0),
                t = 0,
                sid = 41
            }
        )
    end
end
