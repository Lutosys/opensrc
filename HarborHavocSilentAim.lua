print("by yours truly l10scripts")

local utility = {
    target = nil,
    UserInputService = cloneref(game:GetService("UserInputService")),
    Players = cloneref(game:GetService("Players")),
    ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage")),
    Workspace = cloneref(game:GetService("Workspace")),
    RunService = cloneref(game:GetService("RunService")),
}

utility.CreateParams = function(self)
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

    if s then
        return r
    end

    return nil
end

utility.GetOrigin = function(self)
    local s, r = pcall(function(...)
        return self.Camera.CFrame
    end)

    if s then
        return r
    end

    return nil
end

utility.isVisible = function(self, t)
    local origin = self:GetOrigin()
    if not origin then
        return false
    end
    local params = self:CreateParams()
    if not params then
        return false
    end

    local direction = (t.Position - origin.Position)
    local result = self.Workspace:Raycast(origin.Position, direction, params)

    if result then
        return self.Players:GetPlayerFromCharacter(result.Instance:FindFirstAncestorOfClass("Model")) ~= nil
    else
        return false
    end
end

utility.GetClosestPlayer = function(self)
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

        local mT = self.LocalPlayer.Team and self.LocalPlayer.Team.Name
        local tT = v.Team and v.Team.Name

        if tT == "Deciding" then
            continue
        end

        if mT == tT then
            continue
        end 

        local head = char:FindFirstChild("Head")
        if not head then continue end

        local screenPos, onScreen = self.Camera:WorldToViewportPoint(hrp.Position)
        if onScreen then
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - self.UserInputService:GetMouseLocation()).Magnitude
            if distance < closestDistance then
                if not self:isVisible(head) then continue end
                closestDistance = distance
                closest = head
            end
        end
    end

    return closest
end

utility.Init = function(self)
    self.LocalPlayer = self.Players.LocalPlayer
    if not self.LocalPlayer then
        return warn("failed to get local player")
    end

    self.Camera = self.Workspace.CurrentCamera
    if not self.Camera then
        return warn("failed to get camera")
    end

    if not filtergc then
        return self.LocalPlayer:Kick("filtergc is not a function bad executor")
    end

    if not hookfunction then
        return self.LocalPlayer:Kick("hookfunction is not a function bad executor")
    end

    self.GetHit = filtergc("function", {Name = "GetHit"}, true)
    if not self.GetHit then
        return warn('failed to get gethit function')
    end

    self.targetconn = self.RunService.RenderStepped:Connect(function()
        self.target = self:GetClosestPlayer()
    end)

    self.gethithook = hookfunction(self.GetHit, function(...)
        if self.target then
            return self.target.CFrame, self.target
        end
        return self.gethithook(...)
    end)    

    if self.gethithook and self.targetconn then
        return warn("success")
    else
        return warn("failed")
    end
end

utility:Init()
