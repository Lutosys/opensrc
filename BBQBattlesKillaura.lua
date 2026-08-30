local utility = {
    Players = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Workspace = game:GetService("Workspace"),
    target = nil,
}

function utility:GetCamera()
    local s, r = pcall(function(...)
        return self.Workspace.CurrentCamera
    end)
    if s and r then
        return r  
    end
    return nil
end

function utility:GetCameraUnit()
    local s, r = pcall(function(...)
        return self.Camera.CFrame.LookVector.Unit
    end)
    if s and r then
        return r  
    end
    return nil
end

function utility:GetLocalPosition()
    local s, r = pcall(function(...)
        return self.LocalPlayer.Character.HumanoidRootPart.CFrame
    end)
    if s and r then
        return r  
    end
    return nil
end

function utility:attack(t)
    local s, r = pcall(function(...)
        local attackid = debug.getupvalue(self.M1, 3)
        if not attackid then
            return 'failed to get attackid'
        end

        local localpos = self:GetLocalPosition()
        if not localpos then
          return 'failed to get localpos'
        end

        local cameraunit = self:GetCameraUnit()
        if not cameraunit then
            return warn('failed to get camera unit')
        end

        local timestamp = self.SynchronizedTime.timestamp()
        if not timestamp then
            return warn('failed to get timestamp')
        end

        self.SwingInit:FireServer(attackid, cameraunit)
        self.RegisterHit:FireServer(t, timestamp, localpos, attackid, cameraunit)

        return
    end)

    if not s then
        warn('attack failed: '..tostring(r))
    end
end

function utility:ReturnCharacters()
    local s, r = pcall(function(...)
        local c = {}

        for _, bot in pairs(self.Bots:GetChildren()) do
            table.insert(c, bot)
        end

        for _, plr in pairs(self.Players:GetPlayers()) do
            table.insert(c, plr.Character)
        end

        return c  
    end)
    if s and r then
        return r  
    end

    return {}
end


function utility:GetClosestPlayer()
    local closestdist = math.huge
    local closest = nil

    for _, char in ipairs(self:ReturnCharacters()) do
        if tostring(char) == self.LocalPlayer.Name or tostring(char) == self.LocalPlayer.DisplayName then
          continue
        end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end    

        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end    

        local distance = self.LocalPlayer:DistanceFromCharacter(hrp.Position)

        if distance <= 30 and distance < closestdist then
            closest = hrp
            closestdist = distance
        end
    end

    return closest
end

function utility:init()
    self.LocalPlayer = self.Players.LocalPlayer
    if not self.LocalPlayer then
        return warn('failed to get localplayer')
    end

    if not filtergc then
        return self.LocalPlayer:Kick("unsupport executor")
    end

    self.M1 = filtergc("function", {Name = "M1"}, true)
    if not self.M1 then
        return warn('failed to get m1 function')
    end

    self.Modules = self.ReplicatedStorage:FindFirstChild("Modules")
    if not self.Modules then
        return warn("failed to get modules")
    end
    
    self.SynchronizedTime = require(self.Modules:FindFirstChild("SynchronizedTime"))
    if not self.SynchronizedTime then
        return warn('failed to require synctime')
    end

    self.Remotes = self.ReplicatedStorage:FindFirstChild("Remotes")
    if not self.Remotes then
        return warn("failed to get Remotes")
    end

    self.Hitreg = self.Remotes:FindFirstChild("Hitreg")
    if not self.Hitreg then
        return warn("failed to get Hitreg")
    end

    self.SwingInit = self.Hitreg:FindFirstChild("SwingInit")
    if not self.SwingInit then
        return warn("failed to get SwingInit")
    end

    self.RegisterHit = self.Hitreg:FindFirstChild("RegisterHit")
    if not self.RegisterHit then
        return warn("failed to get RegisterHit")
    end

    self.Camera = self:GetCamera()
    if not self.Camera then
        return warn('failed to get camera')
    end

    self.Bots = self.Workspace:FindFirstChild("Bots")
    if not self.Bots then
        return warn('failed to get bots folder')
    end

    warn('success')

    while true do
        task.wait()

        self.target = self:GetClosestPlayer()
        if self.target then
            self:attack(self.target)
        end
    end
end

utility:init()
