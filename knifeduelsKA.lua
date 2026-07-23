local ReportHit = game:GetService("ReplicatedStorage").CombatService.RE.ReportHit

local MatchController = require(game.Players.LocalPlayer.PlayerScripts.Controllers.Match.MatchController)

game:GetService("RunService").Heartbeat:Connect(function()
    for _, plr in next, game.Players:GetPlayers() do
        if plr == game.Players.LocalPlayer then continue end
        local char = plr.Character
        if not char then continue end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end    
        
        if char:GetAttribute("Dead") then continue end
        if char:GetAttribute("Health") and char:GetAttribute("Health") <= 0 then continue end

        if MatchController:IsPlayerEnemy(plr) then
            if game.Players.LocalPlayer:DistanceFromCharacter(hrp.Position) < 30 then
                ReportHit:FireServer(
                    char,
                    "Knife",
                    true,
                    nil,
                    game:GetService("HttpService"):GenerateGUID(false),
                    hrp.Position,
                    3
                )
            end
        end
    end
end)
