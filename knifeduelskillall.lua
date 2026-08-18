local desynced = CFrame.new(0,0,0)
local plr = game.Players.LocalPlayer
local ReportHit = game:GetService("ReplicatedStorage").CombatService.RE.ReportHit
local MatchController = require(game.Players.LocalPlayer.PlayerScripts.Controllers.Match.MatchController)

task.spawn(function()
    while true do
        game:GetService("RunService").Heartbeat:Wait()
        for _, targetPlr in next, game.Players:GetPlayers() do
            if targetPlr == game.Players.LocalPlayer then continue end
            local char = targetPlr.Character
            if not char then continue end

            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end    
            
            if char:GetAttribute("Dead") then continue end
            if char:GetAttribute("HP") and char:GetAttribute("HP") <= 0 then continue end
            
            if not MatchController:IsPlayerEnemy(targetPlr) then desynced = nil; continue end
            
            repeat 
                task.wait()
                
                if not char or not char.Parent or not hrp or not hrp.Parent then break end
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health <= 0 then break end

                desynced = hrp.CFrame
                ReportHit:FireServer(
                    char,
                    "Knife",
                    true,
                    nil,
                    game:GetService("HttpService"):GenerateGUID(false),
                    hrp.Position,
                    3
                )
            until (char:GetAttribute("HP") and char:GetAttribute("HP") <= 0) or char:GetAttribute("Dead")

            desynced = nil
        end
    end
end)

game:GetService("RunService").Heartbeat:Connect(function()
    local char = plr.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end    

    if desynced ~= nil then
        local old = hrp.CFrame
        hrp.CFrame = desynced * CFrame.new(0,-10,0)
        game:GetService("RunService"):BindToRenderStep("saas", 101, function()
            hrp.CFrame = old
            game:GetService("RunService"):UnbindFromRenderStep("saas")
        end)
    end
end)
