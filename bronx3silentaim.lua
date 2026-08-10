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
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end

        local myteam = game.Players.LocalPlayer.Team and game.Players.LocalPlayer.Team.Name
        local theirTeam = v.Team and v.Team.Name

        local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
        if onScreen then
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - camera.ViewportSize / 2).Magnitude
            if distance < closestDistance then
                --if not isVisible(head) then continue end
                closestDistance = distance
                closest = hrp
            end
        end
    end

    return closest
end

game:GetService("RunService").RenderStepped:Connect(function()
    target = GetClosestPlayer()
end)

local VisualizeBullet = filtergc("function", {Name = "VisualizeBullet"})
for _, func in pairs(VisualizeBullet) do
    local old
    old = hookfunction(func, function(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14)
        if target then
            p3 = (target.Position - workspace.CurrentCamera.CFrame.Position).Unit
            print("CHANGED")
        end
        return old(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14)
    end)
end

while wait(1) do
    local Get3DPosition = filtergc("function", {Name = "Get3DPosition"})

    for _, func in ipairs(Get3DPosition) do
        rawset(debug.getupvalue(func, 1), "SpreadX", 0)
        rawset(debug.getupvalue(func, 1), "SpreadY", 0)
        rawset(debug.getupvalue(func, 1), "SpreadRedutionIS", 0)
        rawset(debug.getupvalue(func, 1), "SpreadRedutionS", 0)
    end
end 
