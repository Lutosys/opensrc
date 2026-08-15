local services = setmetatable({}, {
	__index = function(self, servicename)
		local success, service = pcall(game.GetService, game, servicename)
		if not success or not service then return nil end
		local _, cleanedservice = pcall(function()
			return cloneref(service)
		end)
		rawset(self, servicename, cleanedservice)
		return cleanedservice
	end,
})

local utility = {
	shoot = filtergc("function", {Name = 'shoot'}, true),
	isFriendlyInstance = filtergc("function", {Name = "isFriendlyInstance"}, true),
	target = nil,
	Workspace = services.Workspace,
	Players = services.Players,
	RunService = services.RunService,
	UserInputService = services.UserInputService,
	oldShoot = nil,
	wallcheck = false
}

utility.Player = utility.Players.LocalPlayer

utility.isVisible = function(self, target)
	if not target or not target:IsA("BasePart") then
		return false
	end
    local origin = self.Workspace.CurrentCamera.CFrame
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {self.Player.Character}
    params.IgnoreWater = true

    local direction = (target.Position - origin.Position)
    local result = self.Workspace:Raycast(origin.Position, direction, params)

    if result then
        return self.Players:GetPlayerFromCharacter(result.Instance:FindFirstAncestorOfClass("Model")) ~= nil
    else
        return true
    end
end

utility.getAllPlayers = function(self)
	local r = {}
	for key, data in pairs(self.Players:GetPlayers()) do
		table.insert(r, data.Character)
	end	
	for key, data in pairs(self.Workspace:GetChildren()) do
		if data.Name:find("bot") then
			table.insert(r, data)
		end
	end	
	return r
end

utility.GetClosestPlayer = function(self)
	local closestDistance = math.huge
	local closest = nil
	local camera = self.Workspace.CurrentCamera

	for _, char in pairs(self:getAllPlayers()) do
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then continue end
		local head = char:FindFirstChild("Head")
		if not head then continue end
		local hum = char:FindFirstChild("Humanoid")
		if not hum or hum.Health <= 0 then continue end

		if self.isFriendlyInstance(char) then continue end 

		local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
		if onScreen then
			local distance = (Vector2.new(screenPos.X, screenPos.Y) - self.UserInputService:GetMouseLocation()).Magnitude
			if distance < closestDistance then
				if self.wallcheck then
					if not self:isVisible(head) then
						continue
					end
				end
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

local _, errormessage = pcall(function()
	utility.oldShoot = hookfunction(utility.shoot, function(p1)
		if utility.target then
			local oldcf = utility.Workspace.CurrentCamera.CFrame
			utility.Workspace.CurrentCamera.CFrame = CFrame.lookAt(utility.Workspace.CurrentCamera.CFrame.Position, utility.target.Position)
			local result = utility.oldShoot(p1)
			utility.Workspace.CurrentCamera.CFrame = oldcf
			return result
		end
		return utility.oldShoot(p1)
	end)
end)

if utility.oldShoot ~= nil then
	warn("success")
else
	print("couldnt hook:" ..tostring(errormessage))
end
