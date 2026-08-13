local utility = {
    bots = workspace.bots,
    request_fire = filtergc("function", {Name = "request_fire"}, true)
}
utility.zap = debug.getupvalue(utility.request_fire, 7)
utility.target = nil

getgenv().config = {
	wallbang = true,
	enabled = true,
}

utility.isVisible = function(target)
    local origin = workspace.CurrentCamera.CFrame.Position
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {game.Players.LocalPlayer.Character}
    params.IgnoreWater = true

    local result = workspace:Raycast(origin, (target.Position - origin), params)
    if not result then
        return true
    end
    local model = result.Instance:FindFirstAncestorOfClass("Model")
    if not model then
        return false
    end

    if game.Players:GetPlayerFromCharacter(model) then
        return true
    end

    return model:IsDescendantOf(utility.bots)
end

utility.GetClosest = function()
    local closestDistance = math.huge
    local closest = nil
    local camera = workspace.CurrentCamera

    for _, char in pairs(utility:GetPlayers()) do
        if not char then continue end
        if char.Name == game.Players.LocalPlayer.Name then continue end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end

        local head = char:FindFirstChild("Head")
        if not head then continue end
        local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
        if onScreen then
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - camera.ViewportSize / 2).Magnitude
            if distance < closestDistance then
                if not getgenv().wallbang then
					if not utility.isVisible(head) then continue end
				end
                closestDistance = distance
                closest = head
            end
        end
    end

    return closest
end

utility.GetPlayers = function(self)
    local success, result = pcall(function()
        local total = {}

        if self.bots then
            for _, bot in ipairs(self.bots:GetChildren()) do
                table.insert(total, bot)
            end
        end

        for _, plr in ipairs(game.Players:GetPlayers()) do
            table.insert(total, plr.Character)
        end

        return total
    end)

    if success then
        return result
    end

    return {}
end

game:GetService("RunService").RenderStepped:Connect(function()
    utility.target = utility.GetClosest()
end)

local oldfire
oldfire = hookfunction(utility.zap.shoot.fire, function(t)
	if getgenv().config.enabled then
		if rawget(t, "direction") and rawget(t, "origin") and utility.target then
			local dummy = utility.target.Parent
			if dummy and dummy:IsDescendantOf(utility.bots) then
				utility.zap.shoot_dummy.fire({
					dummy = dummy,
					is_headshot = true,
					origin = rawget(t, "origin"),
					direction = (utility.target.Position - rawget(t, "origin")).unit,
					is_airborne = rawget(t, "is_airborne"),
				})
				return
			end
			local plr = game.Players:GetPlayerFromCharacter(utility.target.Parent)
			if plr then
				rawset(t, "target", plr)
				rawset(t, "is_headshot", true)
				rawset(t, "direction", (utility.target.Position - rawget(t, "origin")).unit)
			end
		end
	end
    return oldfire(t)
end)
