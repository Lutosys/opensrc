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
	IsInSameTeam = filtergc("function", {Name = "IsInSameTeam"}, true),
	target = nil,
	Workspace = services.Workspace,
	Players = services.Players,
	RunService = services.RunService,
	UserInputService = services.UserInputService,
	oldShoot = nil,
	wallcheck = true,
}

utility.SilentFovCircle = Drawing.new("Circle")
utility.SilentFovCircle.Position = utility.UserInputService:GetMouseLocation()
utility.SilentFovCircle.Radius = 320
utility.SilentFovCircle.Color = Color3.fromRGB(0, 255, 255)
utility.SilentFovCircle.Filled = false
utility.SilentFovCircle.NumSides = 128
utility.SilentFovCircle.Thickness = 1
utility.SilentFovCircle.Visible = true

utility.Highlight = Instance.new("Highlight")
utility.Highlight.FillColor = Color3.fromRGB(255, 0, 0)
utility.Highlight.FillTransparency = 1  
utility.Highlight.OutlineColor = Color3.fromRGB(255, 0, 0)  
utility.Highlight.OutlineTransparency = 0  
utility.Highlight.DepthMode = Enum.HighlightDepthMode.Occluded

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

	local result = self.Workspace:Raycast(origin.Position, (target.Position - origin.Position), params)
	if result then
		return result.Instance:FindFirstAncestorOfClass("Model") == target.Parent
	end
	return false
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

utility.IsSameTeam = function(self, char, owner)
	local myChar = self.Player.Character
	local myTeam = (myChar and myChar:GetAttribute("MatchTeamId")) or self.Player:GetAttribute("MatchTeamId")
	local myGroup = (myChar and myChar:GetAttribute("MatchGroupId")) or self.Player:GetAttribute("MatchGroupId")
	local team = char:GetAttribute("MatchTeamId")
	local group = char:GetAttribute("MatchGroupId")
	if myTeam == nil or myGroup == nil or team == nil or group == nil then
		return false
	end
	return myGroup == group and myTeam == team
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

		if self:IsSameTeam(char, self.Players:GetPlayerFromCharacter(char)) then continue end
		
		local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
		if onScreen then
			local distance = (Vector2.new(screenPos.X, screenPos.Y) - self.UserInputService:GetMouseLocation()).Magnitude
			if distance <= utility.SilentFovCircle.Radius and distance < closestDistance then
				local visiblePart = nil
				
				if self.wallcheck then
					if self:isVisible(head) then
						visiblePart = head
					else
						for _, bodypart in ipairs(char:GetChildren()) do
							if bodypart:IsA("BasePart") and self:isVisible(bodypart) then
								visiblePart = bodypart
								break
							end
						end
					end
					
					if visiblePart then
						closestDistance = distance
						closest = visiblePart
					end
				else
					closestDistance = distance
					closest = head
				end
			end
		end
	end

	return closest
end

utility.RunService.RenderStepped:Connect(function()
    utility.target = utility:GetClosestPlayer()
    utility.SilentFovCircle.Position = utility.UserInputService:GetMouseLocation()
		if utility.target then
				utility.Highlight.Parent = utility.target.Parent
		else
				utility.Highlight.Parent = nil
		end
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
