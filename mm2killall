local function killAll()
    local plr = game:GetService("Players").LocalPlayer
    if not plr then return end

    local char = plr.Character
    if not char then return end

    local knife = char:FindFirstChild("Knife")
    if not knife then return end

    local events = knife:FindFirstChild("Events")
    if not events then return end 

    local HandleTouched = events:FindFirstChild("HandleTouched")
    if not HandleTouched then return end

    for i,v in pairs(game.Players:GetPlayers()) do
        if v and v.Character then   
            local primary = v.Character:FindFirstChild("HumanoidRootPart")
            if not primary then continue end    

            HandleTouched:FireServer(primary)

            wait(0.05)
        end
    end
end

game:GetService("UserInputService").InputBegan:Connect(function(key, gme)
    if key.KeyCode == Enum.KeyCode.L and not gme then
        killAll()
    end
end)
