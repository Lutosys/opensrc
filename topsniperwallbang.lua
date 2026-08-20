if typeof(filtergc) ~= "function" then
	game:GetService("Players").LocalPlayer:Kick("unsupported executor reason filtergc nil")
	return
end

if typeof(hookfunction) ~= "function" then
	game:GetService("Players").LocalPlayer:Kick("unsupported executor reason hookfunction nil")
	return
end

if typeof(cloneref) ~= "function" then
	game:GetService("Players").LocalPlayer:Kick("unsupported executor reason cloneref nil")
	return
end

if typeof(isfunctionhooked) ~= "function" then
	if typeof(is_function_hooked) ~= "function" then
		game:GetService("Players").LocalPlayer:Kick("unsupported executor reason is_function_hooked nil")
		return
	end
end

if typeof(restorefunction) ~= "function" then
	game:GetService("Players").LocalPlayer:Kick("unsupported executor reason restorefunction nil")
	return
end


local utility = {
	CastRays = filtergc("function", {Name = "CastRays"}, true),
	target = nil,
	Players = cloneref(game:GetService("Players")),
	UserInputService = cloneref(game:GetService("UserInputService")),
	Workspace = cloneref(game:GetService("Workspace")),
	RunService = cloneref(game:GetService("RunService")),
    wallbang = true,
}

utility.Camera = utility.Workspace.CurrentCamera
utility.LocalPlayer = utility.Players.LocalPlayer

utility.CreateParam = function(self)
	local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {self.LocalPlayer.Character}
    params.IgnoreWater = true

	return params or nil
end

utility.isVisible = function(self, t)
    local origin = self.Camera.CFrame
	local params = self:CreateParam()
    local direction = (t.Position - origin.Position)
    local result = self.Workspace:Raycast(origin.Position, direction, params)

    if result then
        local model = result.Instance:FindFirstAncestorOfClass("Model")
        if model and model:FindFirstAncestor("BotFolder") then
            return true
        else
            return self.Players:GetPlayerFromCharacter(model) ~= nil
        end
    else
        return false
    end
end

utility.getallcharacters = function(self)
    local r = {}
    pcall(function(...)
        for key, char in pairs(self.Workspace.BattleArea.MapRootModel.BotFolder:GetChildren()) do
            table.insert(r, char)
        end
    end)
    for key, plr in pairs(self.Players:GetPlayers()) do
        table.insert(r, plr.Character)
    end
    return r
end

utility.GetClosestPlayer = function(self)
    local closestDistance = math.huge
    local closest = nil
    local camera = self.Camera or self.Workspace.CurrentCamera

    for _, char in pairs(self:getallcharacters()) do
        if not char or char.Name == self.LocalPlayer.Name then continue end
        if char:FindFirstChildOfClass("ForceField") then
            continue
        end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end

		local plr = self.Players:GetPlayerFromCharacter(char)
		if plr then
			local theirTeam = plr:GetAttribute("DuelTeam") 
			local myTeam = self.LocalPlayer:GetAttribute("DuelTeam")

			if theirTeam and myTeam and theirTeam == myTeam then
				local theriguid = plr:GetAttribute("DuelGuid")
				local myguid = self.LocalPlayer:GetAttribute("DuelGuid")
				if theriguid and myguid and theriguid == myguid then
					continue
				end
			end
		end

        local head = char:FindFirstChild("Head")
        if not head then continue end
        local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
        if onScreen then
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - self.UserInputService:GetMouseLocation()).Magnitude
            if distance < closestDistance then
                if not self.wallbang then
                    if not self:isVisible(head) then continue end
                end
                closestDistance = distance
                closest = head
            end
        end
    end

    return closest
end

utility.ClosetPlayerConn = utility.RunService.RenderStepped:Connect(function()
    utility.target = utility:GetClosestPlayer()
end)

local _, result = pcall(function(...)
	utility.castrayshook = hookfunction(utility.CastRays, function(...)
		if utility.target and utility.target.Parent and utility.target.Parent:FindFirstChildOfClass("Humanoid") then
			return {
				{
					position = utility.target.Position,
					normal = Vector3.new(0,0,0),
					instance = utility.target,
					taggedHumanoid = utility.target.Parent:FindFirstChildOfClass("Humanoid")
				}
			}
		end 
		return utility.castrayshook(...)
	end)
end)

utility.Unload = function(self)
	if self.castrayshook and isfunctionhooked(self.CastRays) then
		pcall(function(...)
			restorefunction(self.CastRays)
		end)
	end
	if self.ClosetPlayerConn then
		self:Disconnect()
		self = nil
	end
	utility.target = nil
end

if utility.castrayshook then
	print("hooked successfully")
else
	warn("error: "..tostring(result))
end 
