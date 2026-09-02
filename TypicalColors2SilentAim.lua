local utility = {
    target = nil,
    ReplicatedFirst = game:GetService("ReplicatedFirst"),
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    Workspace = game:GetService("Workspace"),
}

function utility:CreateParams()
    local s, r = pcall(function(...)
        local char = self.LocalPlayer.Character
        if not char then
            return nil
        end

        local p = RaycastParams.new()
        p.FilterType = Enum.RaycastFilterType.Exclude
        p.FilterDescendantsInstances = {char}
        p.IgnoreWater = true
    
        return p
    end)
    if s and r then
        return r    
    end
    return nil
end

function utility:GetCamera()
    local s, r = pcall(function(...)
        return self.Workspace.CurrentCamera
    end)
    if s and r then
        return r    
    end
    return nil
end

function utility:GetOrigin()
    local s, r = pcall(function(...)
        return self.Camera.CFrame
    end)
    if s and r then
        return r    
    end
    return nil
end

function utility:GetDirection(t)
    local s, r = pcall(function(...)
        return (t - self:GetOrigin().Position)
    end)
    if s and r then
        return r    
    end
    return nil
end

function utility:isVisible(t)
    local origin = self:GetOrigin()
    if not origin then
        return false
    end
    local direction = self:GetDirection(t.Position)
    if not direction then
        return false
    end
    local params = self:CreateParams()
    if not params then
        return false
    end

    local result = self.Workspace:Raycast(origin.Position, direction, params)

    if result then
        return self.Players:GetPlayerFromCharacter(result.Instance:FindFirstAncestorOfClass("Model")) ~= nil
    else
        return true
    end
end

function utility:IsOnTeam(c)
    local s, r = pcall(function(...)
        local m = self.LocalPlayer.Character
        if not m then
            return false
        end
        return self.tcSoulService:GetSoulFromCharacter(c).Attributes.CurrentTeam == self.tcSoulService:GetSoulFromCharacter(m).Attributes.CurrentTeam
    end)
    if s and r then
        return r    
    end
    return false
end

function utility:GetClosestPlayer()
    local closestDistance = math.huge
    local closest = nil

    for _, v in pairs(self.Players:GetPlayers()) do
        if v == self.LocalPlayer then continue end
    
        local char = v.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end

        if self:IsOnTeam(char) then
            continue
        end

        local head = char:FindFirstChild("Head")
        if not head then continue end
        local screenPos, onScreen = self.Camera:WorldToViewportPoint(hrp.Position)
        if onScreen then
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - self.Camera.ViewportSize / 2).Magnitude
            if distance < closestDistance then
                if not self:isVisible(head) then continue end
                closestDistance = distance
                closest = head
            end
        end
    end

    return closest
end

utility.GetFunctionInModule = function(n)
    local s, r = pcall(function(...)
        local m = filtergc("table", {Keys = {n}}, true)
        if m and m[n] then
            return m[n]
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

    self.Camera = self:GetCamera()
    if not self.Camera then
        return warn("failed to get Camera")
    end

    self.tcSoulService = require(self.ReplicatedFirst:FindFirstChild("tcSoulService"))
    if not self.tcSoulService then
        return warn("failed to get tcSoulService")
    end

    self.GetTarget = self.RunService.RenderStepped:Connect(function()
        self.target = self:GetClosestPlayer()
    end)

    self.GetCameraAimCFrame = self.GetFunctionInModule("GetCameraAimCFrame")
    if not self.GetCameraAimCFrame then
        return warn("failed to get self.GetCameraAimCFrame")
    end

    self.hook = hookfunction(self.GetCameraAimCFrame, function(...)
        local r = self.hook(...)
        if self.target then
            return CFrame.lookAt(r.Position, self.target.Position)
        end 
        return r
    end)

    if not self.hook then
        return warn("failed to hook GetCameraAimCFrame")
    end

    return warn("success")
end

utility:init()
