local Event = game:GetService("ReplicatedStorage").Events.WeaponEvent

task.spawn(function()
    while true do
        game:GetService("RunService").RenderStepped:Wait()
        Event:FireServer(
            "Swing"
        )
    end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    for _, plr in pairs(game.Players:GetPlayers()) do   
        if plr == game.Players.LocalPlayer then continue end

        local backpack = plr.Backpack
        if not backpack then continue end

        local stats = backpack:FindFirstChild("Stats")
        if not stats then continue end

        local deadvalue = stats:FindFirstChild("Dead")
        if not deadvalue or deadvalue.Value == true then continue end

        local BeingCarried = stats:FindFirstChild("BeingCarried")
        if not BeingCarried or BeingCarried.Value == true then continue end

        local Downed = stats:FindFirstChild("Downed")
        if not Downed or Downed.Value == true then continue end

        local char = plr.Character
        if not char then continue end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local distance = game.Players.LocalPlayer:DistanceFromCharacter(hrp.Position)

        if distance < 25 then
            local mychar = game.Players.LocalPlayer.Character
            if not mychar then continue end

            local weapon = mychar:FindFirstChildOfClass("Tool")
            if not weapon then continue end

            local handle = weapon:FindFirstChild("Handle")
            if not handle then continue end

            firetouchinterest(handle, hrp, 0)
            firetouchinterest(handle, hrp, 1)
        end
    end 
end)
