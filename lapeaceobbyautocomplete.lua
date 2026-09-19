local utility = {
    Workspace = game:GetService("Workspace"),
    Players = game:GetService('Players'),
    RunService = game:GetService("RunService")
}

function utility:touchcheckpoint(stage)
    local s, r = pcall(function(...)
        self.LocalPlayer.Character:MoveTo(stage.Touch.Position)
    end)

    if not s then
        warn("error: "..tostring(r))
    end

    return
end

function utility:getnextstage()
    local s, r = pcall(function(...)
        if self.Stage.Value ~= 110 then
            return self.Checkpoints:FindFirstChild(tostring(self.Stage.Value + 1))
        end
        return nil
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

    self.leaderstats = self.LocalPlayer:FindFirstChild("leaderstats")
    if not self.leaderstats then
        return warn("failed to get leaderstats")
    end

    self.Stage = self.leaderstats:FindFirstChild("Stage")
    if not self.Stage then
        return warn("failed to get Stage")
    end

    self.Checkpoints = self.Workspace:FindFirstChild("Checkpoints")
    if not self.Checkpoints then
        return warn("failed to get Checkpoints")
    end

    self.l = tick()
    self.conn = self.RunService.Heartbeat:Connect(function()
        self.nextstage = self:getnextstage()
        if tick() - self.l >= 0.5 then
            self.l = tick()
            if self.nextstage then
                self:touchcheckpoint(self.nextstage)
            end
        end
    end)

    if not self.conn then
        return warn("failed to create conn")
    end

    return warn('sucess init')
end

utility:init()
