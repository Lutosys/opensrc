local utility = {
    target = nil,
    RunService = cloneref(game:GetService("RunService")),
    Workspace = cloneref(game:GetService("Workspace")),
    Players = cloneref(game:GetService("Players")),
    UserInputService = cloneref(game:GetService("UserInputService")),
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
        if v == self.LocalPlayer then 
            continue 
        end
        
        local char = v.Character
        if not char then 
            continue 
        end
        
        local bodyeffects = char:FindFirstChild("BodyEffects")
        if not bodyeffects then 
            continue 
        end

        local ko = bodyeffects:FindFirstChild("K.O")
        if not ko then
            continue
        end

        if ko.Value == true then
            continue
        end

        local grabbed = bodyeffects:FindFirstChild("Grabbed")
        if not grabbed then
            continue
        end

        if grabbed.Value ~= nil then
            continue
        end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then 
            continue 
        end

        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then 
            continue 
        end

        if self.LocalPlayer.Team and self.LocalPlayer.Team.Name ~= "" then
            if v.Team and v.Team.Name == self.LocalPlayer.Team and self.LocalPlayer.Team.Name then
                continue
            end
        end

        local head = char:FindFirstChild("Head")
        if not head then 
            continue 
        end

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

utility.init = function(self)
    self.Camera = self.Workspace.CurrentCamera
    self.LocalPlayer = self.Players.LocalPlayer
    self.getMouseWorldHit = filtergc("function", {Name = "getMouseWorldHit"}, true)
    if not self.getMouseWorldHit or typeof(self.getMouseWorldHit) ~= "function" then
        return warn("failed to get 'getMouseWorldHit' function wait for update!")
    end
    self.RunConn = self.RunService.RenderStepped:Connect(function()
        self.target = self:GetClosestPlayer()
    end)
    local _, err = pcall(function(...)
        self.SilentAimHook = hookfunction(self.getMouseWorldHit, function(...)
            if self.target then
                return self.target, self.target.Position, Vector3.new(0,1,0)
            end
            return self.SilentAimHook(...)
        end)
    end)
    if not self.SilentAimHook then
        return warn("failed to hook error: "..tostring(err))
    else
        return warn("success")
    end
end

utility:init()
