task.spawn(function()
    while wait() do
        pcall(function(...)
            task.spawn(function()
                pcall(function()
                    game.Players.LocalPlayer.Character.Fight:FindFirstChildOfClass("LocalScript").RemoteEvent:FireServer(1, "Stomp")
                end)
            end)
            task.spawn(function()
                pcall(function()
                    game.Players.LocalPlayer.Character.Fight:FindFirstChildOfClass("LocalScript").RemoteEvent:FireServer(1, "Slam")
                end)
            end)
            task.spawn(function()
                pcall(function()
                    game.Players.LocalPlayer.Character.Fight:FindFirstChildOfClass("LocalScript").RemoteEvent:FireServer(1, "Heavy")
                end)
            end)
            task.spawn(function()
                pcall(function()
                    game.Players.LocalPlayer.Character.Fight:FindFirstChildOfClass("LocalScript").RemoteEvent:FireServer(1, "Push")
                end)
            end)
            task.spawn(function()
                pcall(function()
                    game.Players.LocalPlayer.Character.Fight:FindFirstChildOfClass("LocalScript").RemoteEvent:FireServer(1, "Combat")
                end)
            end)
        end)
    end
end)

while wait() do
    for _, v in next, game.Players:GetPlayers() do
        if v == game.Players.LocalPlayer then 
            pcall(function(...)
                v.Character.Humanoid.WalkSpeed = 30
            end)
            continue
        end

        local char = v.Character
        if not char then continue end   

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end    

        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health == 0 then 
            hrp.Size = Vector3.new(2,2,2) 
            continue 
        end 

        if char:FindFirstChild("PadHighlight") then
            hrp.Size = Vector3.new(2,2,2) 
            continue 
        end

        hrp.Size = Vector3.new(20,20,20)
    end
end
