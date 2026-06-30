local target = nil 

local function isVisible(part, origin)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {game.Players.LocalPlayer}
	params.IgnoreWater = true
	
	local ray = workspace:Raycast(origin.Position, (part.Position - origin.Position), params)
	
	if ray then
		local char = ray.Instance:FindFirstAncestorWhichIsA("Model")
		if game.Players:GetPlayerFromCharacter(char) then	
			return true
		else
			return false
		end
	else
		return false
	end
end

local function GetClosestPlayer()
    local closestDistance = math.huge
    local closest = nil
    local camera = workspace.CurrentCamera

    for _, v in pairs(game.Players:GetPlayers()) do
        if v == game.Players.LocalPlayer then continue end


        --local team = v.Team and v.Team.Name 
       -- if team and team ~= "Police" or team and team ~= "Sheriff" then continue end
        local char = v.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        --if not isVisible(hrp, camera.CFrame) then continue end

        local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
        if onScreen then
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - camera.ViewportSize / 2).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closest = hrp
            end
        end
    end

    return closest
end

for _, func in next, getgc() do
    if type(func) == "function" then
        if debug.getinfo(func).name == "addProjectile" and debug.getinfo(func).name ~= "addProjectileVisual"  then
            local old
            old = hookfunction(func, function(p1,p2,p3,p4,p5,p6,p7)
                if p6 == nil then
                    if target then
                        p5 = {
                            Normal = Vector3.new(0,0,-1),
                            Instance = target,
                            Position = target.Position
                        }
                    end
                end
                return old(p1,p2,p3,p4,p5,p6,p7)
            end)
        end
    end
end
