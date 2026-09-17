local utility = {
    target = nil,
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Players = game:GetService("Players"),
    Workspace = game:GetService("Workspace"),
    UserInputService = game:GetService("UserInputService"),
    RunService = game:GetService("RunService"),
}

function utility:isVisible(t)
    if not t then
        return false
    end

    local origin = self.Camera.CFrame
    if not origin then
        return false
    end

    local char = self.LocalPlayer.Character
    if not char then
        return false
    end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char}
    params.IgnoreWater = true

    if not params then
        return false
    end

    local direction = (t.Position - origin.Position)
    if not direction then
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

        if not self.MatchInfo.IsEnemy(plr.UserId) then
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

function utility:init()
    self.LocalPlayer = self.Players.LocalPlayer
    if not self.LocalPlayer then
        return warn('failed to get local player')
    end

    if not getrawmetatable then
        return self.LocalPlayer:Kick("unsupported executor missing getrawmetatable")
    end

    self.Camera = self.Workspace.CurrentCamera
    if not self.Camera then
        return warn("failed to get camera")
    end

    self.Modules = self.ReplicatedStorage:FindFirstChild("Modules")
    if not self.Modules then
        return warn('failed to get modules')
    end

    self.Weapons = self.Modules:FindFirstChild("Weapons")
    if not self.Weapons then
        return warn('failed to get Weapons')
    end

    self.MatchInfo = require(self.Weapons:FindFirstChild("MatchInfo"))
    if not self.MatchInfo then
        return warn('failed to get MatchInfo')
    end

    self.runconn = self.RunService.RenderStepped:Connect(function()
        self.target = self:GetClosestPlayer()
    end)

    local s, r = pcall(function(...)
        local mt = getrawmetatable(game)
        local index = mt.__index

        setreadonly(mt, false)

        mt.__index = function(s, key)
            if tostring(key) == "Hit" then
                if self.target then
                    return self.target.CFrame
                end
            end
            return index(s, key)
        end

        setreadonly(mt, true)
    end)

    if not s then
        return warn('err: '..tostring(r))
    end

    return warn("success init")
end

utility:init()
