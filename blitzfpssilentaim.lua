local utility = {
    Players = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Workspace = game:GetService("Workspace"),
    UserInputService = game:GetService("UserInputService"),
    RunService = game:GetService("RunService"),
    target = nil,
    used = {"hookmetamethod", "getnamecallmethod", "hookfunction", "filtergc"},
    hooks = {}
}

function utility:GetEnemies()
    local s, r = pcall(function(...)
        local c = {}
        local myteam = self.LocalPlayer:GetAttribute("TeamId")

        for _, obj in pairs(self.Workspace:GetChildren()) do
            local t = obj:GetAttribute("TeamId") 
            if (t and t ~= myteam) or t == "FreeForAll" then
                table.insert(c, obj)
            end
        end

        for _, plr in ipairs(self.Players:GetPlayers()) do
            if plr == self.LocalPlayer then
                continue
            end
            local t = plr:GetAttribute("TeamId") 
            if (t and t ~= myteam) or t == "FreeForAll" then
                table.insert(c, plr.Character)
            end
        end

        return c 
    end)

    if s and r then
        return r
    end

    return {}
end

function utility:CreateParams()
    local s, r = pcall(function(...)
        local p = RaycastParams.new()
        p.FilterType = Enum.RaycastFilterType.Exclude
        p.FilterDescendantsInstances = {self.LocalPlayer.Character}
        p.IgnoreWater = true

        return p
    end)

    if s and r then
        return r    
    end

    return nil
end

function utility:IsVisible(t)
    if not t then
        return false
    end

    local origin = self.Camera.CFrame
    if not origin then
        return false
    end

    local params = self:CreateParams()
    if not params then
        return false
    end

    local direction = (t.Position - origin.Position)
    if not direction then
        return false
    end

    local result = self.Workspace:Raycast(origin.Position, direction, params)

    if result then
        return result.Instance:FindFirstAncestorOfClass("Model"):GetAttribute("IsSliding") ~= nil
    else
        return false
    end
end

function utility:GetClosestPlayer()
    local closestDistance = math.huge
    local closest = nil

    for _, char in pairs(self:GetEnemies()) do
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local head = char:FindFirstChild("Head")
        if not head then continue end

        local screenPos, onScreen = self.Camera:WorldToViewportPoint(hrp.Position)
        if onScreen then
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - self.UserInputService:GetMouseLocation()).Magnitude
            if distance < closestDistance then
                if not self:IsVisible(head) then continue end
                closestDistance = distance
                closest = head
            end
        end
    end

    return closest
end

function utility:dependencycheck()
	local s, r = pcall(function(...)
		local e = getgenv()

		for _, f in pairs(self.used) do
			if not e[f] then
				self.LocalPlayer:Kick("Missing: "..tostring(f))
			end
		end
	end)

	if not s then
		return warn("failed: "..tostring(r))
	end

	return
end

function utility:wraphook(o, c)
    local s, r = pcall(function(...)
        local t = hookfunction(o, c)
        self.hooks[o] = t
        return t
    end)

    if s and r then
        return r    
    end

    warn("failed to hook reason: "..tostring(r))

    return nil
end

function utility:safefiltergc(a, b, c)
    local s, r = pcall(function(...)
        return filtergc(a, b, c)
    end)

    if s and r then
        return r    
    end

    warn("faild to use filtergc err: "..tostring(r))

    return nil
end

function utility:init()
    self.LocalPlayer = self.Players.LocalPlayer
    if not self.LocalPlayer then
        return warn("failed to get LocalPlayer")
    end

    self.Camera = self.Workspace.CurrentCamera
    if not self.Camera then
        return warn("failed to get Camera")
    end

    self:dependencycheck()

    self.gettargetconn = self.RunService.Heartbeat:Connect(function()
        self.target = self:GetClosestPlayer()
    end)

    if not self.gettargetconn then
        return warn("failed to create runservice conn")
    end

    self.SharedModules = self.ReplicatedStorage:FindFirstChild("SharedModules")
    if not self.SharedModules then
        return warn("Failed to get SharedModules")
    end

    self.Communicator = self.SharedModules:FindFirstChild("Communicator")
    if not self.Communicator then
        return warn("Failed to get Communicator")
    end

    self.CommFolder = self.Communicator:FindFirstChild("CommFolder")
    if not self.CommFolder then
        return warn("Failed to get CommFolder")
    end

    self.ShooterService = self.CommFolder:FindFirstChild("ShooterService")
    if not self.ShooterService then
        return warn("Failed to get ShooterService")
    end

    self.RE = self.ShooterService:FindFirstChild("RE")
    if not self.RE then
        return warn("Failed to get RE")
    end

    self.FireShot = self.RE:FindFirstChild("FireShot")
    if not self.FireShot then
        return warn("Failed to get FireShot")
    end

    self.s, self.metahook = pcall(function(...)
        return hookmetamethod(game, "__namecall", function(...)
            local s = select(1,...)
            local a = {select(2, ...)}
            local m = getnamecallmethod()

            if m == "FireServer" and s == self.FireShot then
                if a[3] then
                    if self.target then
                        a[3] = (self.target.Position - a[2]).Unit
                    end
                end
            end

            return self.metahook(s, unpack(a))
        end)
    end)

    if not self.s then
        return warn('hookmetamethod err: '..tostring(self.metahook))
    end

    self.FireLocal = self:safefiltergc("function", {Name = "FireLocal"}, true)
    if not self.FireLocal then
        return
    end

    self.FireLocalHook = self:wraphook(self.FireLocal, function(p1, p2, p3, p4)
        if self.target then
            p2 = self.target.Position
        end
        return self.FireLocalHook(p1,p2,p3,p4)
    end)

    if not self.FireLocalHook then
        return
    end

    return warn("success init")
end

utility:init()
