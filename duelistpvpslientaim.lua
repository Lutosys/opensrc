local castBullet = filtergc("function", {Name = "castBullet"})

local function isOnSameTeam(player)
    local localPlayer = game.Players.LocalPlayer
    
    local myTeam = localPlayer:GetAttribute("DuelsTeam")
    local theirTeam = player:GetAttribute("DuelsTeam")
    if myTeam and theirTeam and myTeam == theirTeam then
        return true
    end

    return false
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

        if isOnSameTeam(v) then
            continue
        end 

        local head = char:FindFirstChild("Head")
        if not head then continue end
        local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
        if onScreen then
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - camera.ViewportSize / 2).Magnitude
            if distance < closestDistance then
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

local v18 = debug.getupvalue(castBullet[1], 4)

local function startSlientAim()
    castBullet = filtergc("function", {Name = "castBullet"})
    for _, func in pairs(castBullet) do
        local old
        old = hookfunction(func, function(p1, p2)
            if target and target.Parent then                
                local direction = (target.Position - p2).Unit * 500
                return workspace:Raycast(p2, direction, v18)
            end

            return old(p1, p2)
        end)
    end 
end

startSlientAim()

game.Players.LocalPlayer.CharacterAdded:Connect(function(c)
    if c.Parent then
        wait(1)
        startSlientAim()
    end
end)
