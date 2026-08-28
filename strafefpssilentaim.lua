local utility = {
    target = nil,
    Players = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Workspace = game:GetService("Workspace"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService")
}

function utility:isFriendlyCharacter(c)
    local s, r = pcall(function(...)
        if not c then
            return false
        end
        
        local a = c:GetAttribute("BotUniqueId")
        if a then
            return self.GameState.isTeammate(a)
        end

        local p = self.Players:GetPlayerFromCharacter(c)
        if p then
            return self.GameState.isTeammate(p.UserId)
        end

        return false
    end)

    if s and r then
        return true
    end

    return false
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

function utility:GetCameraCFrame()
    local s, r = pcall(function(...)
        return self.Camera.CFrame or self:GetCamera().CFrame
    end)
    if s and r then
        return r
    end
    return nil
end

function utility:CreateParams()
    local s, r = pcall(function(...)
        local c = self.LocalPlayer.Character
        if not c then
            return nil
        end

        local p = RaycastParams.new()
        p.FilterType = Enum.RaycastFilterType.Exclude
        p.FilterDescendantsInstances = {c}
        p.IgnoreWater = true

        return p
    end)
    if s and r then
        return r
    end
    return nil
end

utility.ComputeeDirection = function(o, e)
    local s, r = pcall(function(...)
        return (e - o)
    end)
    if s and r then
        return r
    end
    return nil
end

function utility:isVisible(t)
    if not t.Parent then
        return false
    end

    local o = self:GetCameraCFrame()
    if not o then
        return false
    end

    local p = self:CreateParams()
    if not p then
        return false
    end

    local d = self.ComputeeDirection(o.Position, t.Position)
    if not d then
        return false
    end

    local result = self.Workspace:Raycast(o.Position, d, p)

    if result then
        local c = result.Instance:FindFirstAncestorOfClass("Model")
        if c then
            local a = c:GetAttribute("BotUniqueId")
            if a then
                return true
            end

            local pl = self.Players:GetPlayerFromCharacter(c)
            if pl then
                return true
            end
        end
    else
        return false
    end

    return false
end

function utility:getPlayers()
    local s, r = pcall(function(...)
        local c = {}
        local hu = self.Workspace:QueryDescendants("Humanoid")
        for _, h in hu do    
            table.insert(c, h.Parent)
        end
        return c
    end)

    if s and r then
        return r
    end
    return {}
end

function utility:GetClosestPlayer()
    local closestDistance = math.huge
    local closest = nil
    local camera = self.Camera or self:GetCamera()

    for _, char in pairs(self:getPlayers()) do
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local head = char:FindFirstChild("Head")
        if not head then continue end

        if self:isFriendlyCharacter(char) then
            continue
        end

        local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
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

function utility:hook()
    self.fireHitscanShot = filtergc("function", {Name = "fireHitscanShot"}, true)
    while not self.fireHitscanShot do
        task.wait(0.5)
        warn('failed to get fireHitscanShot enter arena or game might have updated')
        self.fireHitscanShot = filtergc("function", {Name = "fireHitscanShot"}, true)
    end

    self.firehook = hookfunction(self.fireHitscanShot, function(...)
        if self.target then
            local oldcf = self.Camera.CFrame
            self.Camera.CFrame = CFrame.lookAt(self.Camera.CFrame.Position, self.target.Position)
            local result = self.firehook(...)
            self.Camera.CFrame = oldcf
            return result
        end
        return self.firehook(...)
    end)

    if not self.firehook then
        return warn("failed to hook")
    end

    return warn("success hooking")
end

function utility:init()
    self.LocalPlayer = self.Players.LocalPlayer
    if not self.LocalPlayer then
        return warn("failed to get localplayer")
    end

    if not hookfunction then
        return self.LocalPlayer:Kick("Unsupported executor missing hookfunction")
    end

    if not filtergc then
        return self.LocalPlayer:Kick("Unsupported executor missing filtergc")
    end

    self.Classes = self.ReplicatedStorage:FindFirstChild("Classes")
    if not self.Classes then
        return warn('failed to get Classes')
    end

    self.UserInterface = self.Classes:FindFirstChild("UserInterface")
    if not self.UserInterface then
        return warn('failed to get UserInterface')
    end

    self.ReactApp = self.UserInterface:FindFirstChild("ReactApp")
    if not self.ReactApp then
        return warn('failed to get ReactApp')
    end

    self.GameState = self.ReactApp:FindFirstChild("GameState")
    if not self.GameState then
        return warn('failed to get GameState')
    end

    self.GameState = require(self.GameState)
    if not self.GameState then
        return warn('failed to require GameState')
    end    

    self.Camera = self:GetCamera()
    if not self.Camera then
        return warn("failed to get camera")
    end

    self.GetTargetConn = self.RunService.RenderStepped:Connect(function()
        self.target = self:GetClosestPlayer()
    end)

    if not self.GetTargetConn then
        return warn("failed to create runservice conn")
    end

    self:hook()

    return warn("success init")
end

utility:init()
