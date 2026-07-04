-- credits to phemonaz for the wallbang method :)

local tryFire = filtergc("function", {Name = "tryFire"})

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

local function startSlientAim()
    tryFire = filtergc("function", {Name = "tryFire"})
    local old = debug.getupvalue(tryFire[1], 21)
    debug.setupvalue(tryFire[1],21, function(spread, origin)
        if target then
            return{
                Position = target.Position,
                Normal = Vector3.new(0,1,0),
                Distance = 1,
                Instance = target
            }
        end 
        return old(spread, origin)
    end)
end

startSlientAim()

game.Players.LocalPlayer.CharacterAdded:Connect(function(c)
    if c.Parent then
        wait(1)
        startSlientAim()
    end
end)
