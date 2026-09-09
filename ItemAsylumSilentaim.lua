local utility = {
    target = nil,
    Workspace = game:GetService("Workspace"),
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
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

function utility:ReturnCameraCFrame()
    local s, r = pcall(function(...)
        return self.Camera.CFrame
    end)

    if s and r then
        return r
    end

    return nil
end

function utility:isVisible(t)
    if not t then
        return false
    end

    local origin = self:ReturnCameraCFrame()
    if not origin then
        return false
    end

    local direction = (t.Position - origin.Position)
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
        return false
    end
end

function utility:GetClosestPlayer()
    local closestDistance = math.huge
    local closest = nil

    for _, plr in pairs(self.Players:GetPlayers()) do
        if plr == self.LocalPlayer then continue end
        
        local char = plr.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local head = char:FindFirstChild("Head")
        if not head then continue end
        local myteam = self.LocalPlayer.Team and self.LocalPlayer.Team.TeamColor
        local theirteam = plr.Team and plr.Team.TeamColor

        if myteam ~= Color3.new(1, 1, 1) then
            if myteam == theirteam then
                continue
            end
        end

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

utility.pcallfiltergc = function(option, options, includeone)
    local s, r = pcall(function(...)
        return filtergc(option, options, includeone)
    end)
    
    if s and r then
        return r
    end

    warn("failed to get reason: "..tostring(r))

    return nil
end


utility.pcallhook = function(original, callback)
    local s, r = pcall(function(...)
        return hookfunction(original, callback)
    end)

    if s and r then
        return r
    end

    warn("failed to hook err: "..tostring(r))

    return nil
end

function utility:init()
    self.LocalPlayer = self.Players.LocalPlayer
    if not self.LocalPlayer then
        return warn("couldnt get localplayer")
    end

    if not filtergc then
        return self.LocalPlayer:Kick("Unsupported executor: reason filtergc")
    end

    if not hookfunction then
        return self.LocalPlayer:Kick("Unsupported executor: reason hookfunction")
    end

    self.Camera = self.Workspace.CurrentCamera
    if not self.Camera then
        return warn("couldnt get Camera")
    end

    self.RunService.RenderStepped:Connect(function()
        self.target = self:GetClosestPlayer()
    end)

    self.GetMousePosition = self.pcallfiltergc("function", {Name = "GetMousePosition"}, true)
    if not self.GetMousePosition then
        return
    end

    self.hook = self.pcallhook(self.GetMousePosition, function(...)
        if self.target then
            return self.target.Position, self.target, Vector3.new(0,0,0)
        end
        return self.hook(...)
    end)

    if not self.hook then
        return
    end

    return warn('success init')
end

utility:init()
