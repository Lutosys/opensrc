pcall(function(...)
    if not cloneref then
        game:GetService("Players").LocalPlayer:Kick("Unsupported executor missing cloneref")
        task.wait(1)
        game:Shutdown()
    end
    if not hookfunction then
        cloneref(game:GetService("Players")).LocalPlayer:Kick("Unsupported executor missing hookfunction")
        task.wait(1)
        game:Shutdown()
    end
    if not filtergc then
        cloneref(game:GetService("Players")).LocalPlayer:Kick("Unsupported executor missing filtergc")
        task.wait(1)
        game:Shutdown()
    end
end)

local utility = {
    target = nil,
    Players = cloneref(game:GetService("Players")),
    UserInputService = cloneref(game:GetService("UserInputService")),
    Workspace = cloneref(game:GetService("Workspace")),
    RunService = cloneref(game:GetService("RunService")),
}

utility.isVisible = function(self, t)
    local origin = self.Camera.CFrame
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {self.LocalPlayer.Character}
    params.IgnoreWater = true

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

        local myteam = self.LocalPlayer.Team and self.LocalPlayer.Team.Name
        local theirTeam = v.Team and v.Team.Name

        if myteam == "" then
            continue
        end

        if myteam == theirTeam then
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

utility.RunConn = utility.RunService.RenderStepped:Connect(function()
    utility.target = utility:GetClosestPlayer()
end)

utility.Init = function(self)
    self.LocalPlayer = self.Players.LocalPlayer
    self.Camera = self.Workspace.CurrentCamera
    self.GetAimDirection = filtergc("function", {Name = "GetAimDirection"}, true)
    local _, err = pcall(function()
        self.hook = hookfunction(self.GetAimDirection, function(...)
            if utility.target then
                local char = self.LocalPlayer.Character
                if char then
                    local head = char:FindFirstChild("Head")
                    if head then
                        return (utility.target.Position - head.Position).Unit , head.Position
                    end
                end
            end
            return self.hook(...)
        end)
    end)
    if not self.hook then
        warn("failed to hook err: "..tostring(err))
    else
        warn("success")
    end
end

utility:Init()
