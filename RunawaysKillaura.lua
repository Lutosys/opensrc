local utility = {
    Workspace = game:GetService("Workspace"),
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    target = nil,
}

getgenv().config = getgenv().config or {
    range = 30, -- not tested but can be really high like 100+
    damage = 20, -- can be 1000 for instant kill,
    onlypolice = false,
}

function utility:GetValidNPCs()
    local s, r = pcall(function(...)
        local c = {}
        for _, n in next, self.NPCs:GetChildren() do 
            local name = n.Name
            if name and getgenv().config.onlypolice and not string.find(name, "Officer") then
                continue
            end
            table.insert(c, n)
        end
        return c
    end)

    if s and r then
        return r
    end

    return {}
end

function utility:DistanceFromCharacter(p)
    local s, r = pcall(function(...)
        local mc = self.LocalPlayer.Character
        if not mc then
            return
        end

        local mh = mc:FindFirstChild("HumanoidRootPart")
        if not mh then
            return
        end
        
        return (mh.Position - p).Magnitude
    end)

    if s and r then
        return r    
    end

    return nil
end

function utility:GetClosetNPC()
    local s, r = pcall(function(...)
        local cn = nil
        local cd = math.huge

        for _, c in ipairs(self:GetValidNPCs()) do
            local h = c:FindFirstChildOfClass("Humanoid")
            if not h then
                continue
            end 

            local p = c:GetPivot().Position
            if not p then
                continue
            end

            local dist = self:DistanceFromCharacter(p)
            if dist < cd and dist <= getgenv().config.range then
                cd = dist
                cn = h
            end
        end

        return cn
    end)

    if s and r then
        return r    
    end

    return nil
end

function utility:attack(hum)
    local s, r = pcall(function(...)
        self.Event:FireServer(
            "NPCs",
            "Damage",
            hum,
            getgenv().config.damage or 10
        )
    end)

    if not s then
        return warn('attack failed: '..tostring(r))
    end

    return
end   

function utility:initka()
    self.LocalPlayer = self.Players.LocalPlayer
    if not self.LocalPlayer then
        return warn('failed to get localplayer') 
    end

    self.NPCs = self.Workspace:FindFirstChild("NPCs")
    if not self.NPCs then
        return warn("failed to get npcs in workspace")
    end

    self.FlowClient = self.ReplicatedStorage:FindFirstChild('FlowClient')
    if not self.FlowClient then
        return warn('failed to get FlowClient')
    end

    self.ClientRunner = self.FlowClient:FindFirstChild('ClientRunner')
    if not self.ClientRunner then
        return warn('failed to get ClientRunner')
    end

    self.Event = self.ClientRunner:FindFirstChild('Event')
    if not self.Event then
        return warn('failed to get Event')
    end

    self.l = tick()

    self.conn = self.RunService.Heartbeat:Connect(function()
        self.target = self:GetClosetNPC()
        if tick() - self.l >= 0.05 then
            self.l = tick()
            if self.target then
                self:attack(self.target)
            end
        end
    end)

    if not self.conn then
        return warn('failed to create runservice conn')
    end

    return warn("success init")
end

utility:initka()
