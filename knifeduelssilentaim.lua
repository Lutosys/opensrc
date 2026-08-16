if not hookfunction then
    game.Players.LocalPlayer:Kick("Unsupported executor (missing hookfunction), use real/madium/volt/synapsez")
end

if not cloneref then
    game.Players.LocalPlayer:Kick("Unsupported executor (missing cloneref), use real/madium/volt/synapsez")
end

local services = {
	Players = cloneref(game:GetService("Players")),
	Workspace = cloneref(game:GetService("Workspace")),
	RunService = cloneref(game:GetService("RunService")),
}

local vars = {
	LocalPlayer = services.Players.LocalPlayer,
	Camera = services.Workspace.CurrentCamera
}

vars.PlayerScripts = vars.LocalPlayer.PlayerScripts

local utility = {
	MatchController = require(vars.PlayerScripts.Controllers.Match.MatchController),
	target = nil
}

utility._index = utility

utility.isVisible = function(target)
	local camera = vars.Camera or services.Workspace.CurrentCamera
	local origin = camera.CFrame
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {vars.LocalPlayer.Character}
	params.IgnoreWater = true

	local direction = (target.Position - origin.Position)
	local result = services.Workspace:Raycast(origin.Position, direction, params)

	if result then
		return services.Players:GetPlayerFromCharacter(result.Instance:FindFirstAncestorOfClass("Model")) ~= nil
	else
		return true
	end
end

utility.GetClosestPlayer = function(self)
	local closestDistance = math.huge
	local closest = nil
	local camera = vars.Camera or services.Workspace.CurrentCamera

	for _, v in pairs(services.Players:GetPlayers()) do
		if v == vars.LocalPlayer then continue end
		
		local char = v.Character
		if not char then continue end

        if char:GetAttribute("Dead") then continue end
        if char:GetAttribute("Health") and char:GetAttribute("Health") <= 0 then continue end

		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then continue end

		local head = char:FindFirstChild("Head")
		if not head then continue end

		if self.MatchController:IsPlayerEnemy(v) then
			local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
			if onScreen then
				local distance = (Vector2.new(screenPos.X, screenPos.Y) - camera.ViewportSize / 2).Magnitude
				if distance < closestDistance then
					if not self.isVisible(head) then continue end
					closestDistance = distance
					closest = head
				end
			end
		end
	end

	return closest
end

services.RunService.RenderStepped:Connect(function()
	utility.target = utility:GetClosestPlayer()
end)

local _, errormessage = pcall(function(...)
	utility.oldhook = hookfunction(os.clock, function(...)
		if debug.info(debug.info(3, "f"), "n") == "AttemptThrow" then
			if utility.target then
				local camera = vars.Camera or services.Workspace.CurrentCamera
				local oldcf = camera.CFrame
				camera.CFrame = CFrame.lookAt(camera.CFrame.Position, utility.target.Position)
				local result = utility.oldhook(...)
				task.defer(function()
					services.RunService.RenderStepped:Wait()
					camera.CFrame = oldcf
				end)
				return result
			end
		end
		return utility.oldhook(...)
	end)
end)

if utility.oldhook then
	print("success")
else
	warn("error: "..tostring(errormessage))
end
