local utility = {
	target = nil,
	Workspace = cloneref(game:GetService("Workspace")),
	UserInputService = cloneref(game:GetService("UserInputService")),
	Players = cloneref(game:GetService("Players")),
	RunService = cloneref(game:GetService("RunService")),
	ShootFunc = filtergc("function", {Name = "shootLauncher"}, true),
}

utility.Camera = utility.Workspace.CurrentCamera
utility.NPC = utility.Workspace.NPC
utility.LocalPlayer = utility.Players.LocalPlayer

utility.CreateParams = function()
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {utility.LocalPlayer.Character}
    params.IgnoreWater = true

	return params or nil
end

utility.isVisible = function(self, target)
	if not target or typeof(target) ~= "Instance" then
		return false
	end
	if not target:IsA("BasePart") then
		return false
	end

    local origin = self.Camera.CFrame
    local direction = (target.Position - origin.Position)
	local params = self.CreateParams()
	if not params then return false end
    local result = self.Workspace:Raycast(origin.Position, direction, params)

    if result then
        return result.Instance:FindFirstAncestorOfClass("Model"):FindFirstChildOfClass("Tool") ~= nil
    else
        return false
    end
end

utility.GetAllPlayers = function(self)
	local chars = {}
	for _, plr in ipairs(self.Players:GetPlayers()) do
		if plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChildOfClass("Tool") then
			table.insert(chars, plr.Character)
		end
	end
	for _, char in ipairs(self.NPC:GetChildren()) do
		if char and char:FindFirstChild("Humanoid") and char:FindFirstChildOfClass("Tool") then
			table.insert(chars, char)
		end
	end
	return chars
end

utility.GetClosestPlayer = function(self)
    local closestDistance = math.huge
    local closest = nil

    for _, char in pairs(self:GetAllPlayers()) do
        if not char then continue end
		if char.Name == self.LocalPlayer.Name then continue end

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
                if not self:isVisible(head) then continue end
                closestDistance = distance
                closest = head
            end
        end
    end

    return closest
end

utility.RunService.RenderStepped:Connect(function()
    utility.target = utility:GetClosestPlayer()
end)

utility.shootLauncher = hookfunction(utility.ShootFunc, function(p1,p2)
	if utility.target then
		local oldcf = utility.Camera.CFrame
		utility.Camera.CFrame = CFrame.lookAt(utility.Camera.CFrame.Position, utility.target.Position)
		local result = utility.shootLauncher(p1,p2)
		utility.Camera.CFrame = oldcf
		return result
	end
	return utility.shootLauncher(p1,p2)
end)
