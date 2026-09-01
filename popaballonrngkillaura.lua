local utility = {
    Workspace = game:GetService("Workspace"),
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    target = nil
}

function utility:GetPlot()
    local s, r = pcall(function(...)
        return self.Plots:QueryDescendants('[$plotOwnerId = '..self.LocalPlayer.UserId..']')[1]
    end)
    if s and r then
        return r    
    end
    return nil 
end

function utility:GetClosetEnemy()
    local closet = nil
    local closetdistance = math.huge

    for _, enemy in next, self.Enemies:GetChildren() do 
        local hrp = enemy:FindFirstChild("HumanoidRootPart")
        if not hrp then 
            continue
        end

        local dist = self.LocalPlayer:DistanceFromCharacter(hrp.Position)
        if dist < closetdistance then
            closetdistance = dist
            closet = enemy.Name
        end
    end

    return closet
end

function utility:attack(n)
    local s, r = pcall(function(...)
        return self.SwordHit:FireServer({n})
    end)
    if s and r then
        return r
    end
    return nil
end

function utility:init()
    self.LocalPlayer = self.Players.LocalPlayer
    if not self.LocalPlayer then
        return warn("failed to get localplayer")
    end

    self.Plots = self.Workspace:FindFirstChild("Plots")
    if not self.Plots then
        return warn('failed to get Plots')
    end

    self.plot = self:GetPlot()
    repeat
        task.wait()
        self.plot = self:GetPlot()
    until self.plot

    self.Enemies = self.plot:FindFirstChild('Enemies')
    if not self.Enemies then
        return warn("failed to get Enemies")
    end

    self.Networking = self.ReplicatedStorage:FindFirstChild("Networking")
    if not self.Networking then
        return warn("failed to get Networking")
    end

    self.Remotes = self.Networking:FindFirstChild("Remotes")
    if not self.Remotes then
        return warn("failed to get Networking")
    end

    self.Fight = self.Remotes:FindFirstChild("Fight")
    if not self.Fight then
        return warn("failed to get Fight")
    end

    self.SwordHit = self.Fight:FindFirstChild("SwordHit")
    if not self.SwordHit then
        return warn("failed to get SwordHit")
    end

    self.l = tick()
    self.conn = self.RunService.RenderStepped:Connect(function()
        self.target = self:GetClosetEnemy()
        if self.target then
            if tick() - self.l >= 0.1 then
                self:attack(self.target)
                self.l = tick()
            end
        end
    end)

    if not self.conn then
        return warn("failed to create connection")
    end

    return warn("success init")
end

utility:init()
