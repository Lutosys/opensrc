local utility = {
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
}

utility.Shared =  utility.ReplicatedStorage:WaitForChild("Shared")
utility.Core = utility.Shared:WaitForChild("Core")
utility.TEvent = require(utility.Core:WaitForChild("TEvent"))
utility.LocalPlayer = utility.Players.LocalPlayer
 
utility.DoAttack = function(self)
    local s, r = pcall(function(...)
        local c = self.LocalPlayer.Character
        if not c then return false end

        local h = c:FindFirstChild("HumanoidRootPart")
        if not h then return false end
    
        self.TEvent.FireEvent("MakeAHit", self.TEvent.UnixTimeFloat(), 1, h.CFrame)

        return true
    end)

    if s then
        return r
    end

    return false
end 

utility.GetClosetPlayer = function(self)
    local s, r = pcall(function(...)
        local cl = nil
        local cd = math.huge
        
        for _, p in next, self.Players:GetPlayers() do  
            if p == self.LocalPlayer then
                continue
            end

            if self.LocalPlayer.Team and self.LocalPlayer.Team.Name == "Lobby" then
                continue
            end
 
            if p.Team and p.Team.Name == self.LocalPlayer.Team and self.LocalPlayer.Team.Name then
                continue
            end

            local c = p.Character
            if not c then
                continue
            end

            local h = c:FindFirstChild("HumanoidRootPart")
            if not h then
                continue
            end

            local hu = c:FindFirstChild("Humanoid")
            if not hu or hu.Health <= 0 then
                continue
            end

            local d = self.LocalPlayer:DistanceFromCharacter(h.Position)
            if d < cd then
                cl = {
                    h = h,
                    hu = hu,
                }
                cd = d                         
            end
        end

        return cl
    end)

    if s then
        return r
    end

    return nil
end 

while task.wait() do
    local data = utility:GetClosetPlayer()
    if data and typeof(data) == "table" and data.h and data.hu then
        utility:DoAttack()
    end
end
