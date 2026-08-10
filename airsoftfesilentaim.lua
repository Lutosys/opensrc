local target = nil

local function isVisible(target)
    local origin = game.workspace.CurrentCamera.CFrame
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {game.Players.LocalPlayer.Character}
    params.IgnoreWater = true

    local direction = (target.Position - origin.Position)
    local result = workspace:Raycast(origin.Position, direction, params)

    if result then
        return game.Players:GetPlayerFromCharacter(result.Instance:FindFirstAncestorOfClass("Model")) ~= nil
    else
        return true
    end
end

local function GetClosestPlayer()
    local closestDistance = math.huge
    local closest = nil
    local camera = workspace.CurrentCamera

    for _, v in pairs(game.Players:GetPlayers()) do
        if v == game.Players.LocalPlayer then continue end
        
        local char = v.Character
        if not char then continue end
        if char:FindFirstChildOfClass("ForceField") then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end

        local myteam = game.Players.LocalPlayer.Team and game.Players.LocalPlayer.Team.Name
        local theirTeam = v.Team and v.Team.Name

        if myteam == theirTeam then
            continue
        end 

        local head = char:FindFirstChild("Head")
        if not head then continue end
        local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
        if onScreen then
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - camera.ViewportSize / 2).Magnitude
            if distance < closestDistance then
                if not isVisible(head) then continue end
                closestDistance = distance
                closest = head
            end
        end
    end

    return closest
end

game:GetService("RunService").RenderStepped:Connect(function()
    target = GetClosestPlayer()
end)

local RunProjectile = filtergc("function", {Name = "RunProjectile"}, true)

local old
old = hookfunction(RunProjectile, function(self, info)
    if target then
      if info and typeof(info) == "table" and rawget(info, "CastRayDirection") and rawget(info, "Origin") then
          rawset(info, "CastRayDirection", (target.Position - info.Origin))
      end
    end
    return old(self, info)
end)
