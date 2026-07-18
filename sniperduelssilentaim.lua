local target = nil
local IsPlayerFriendly = filtergc("function", {Name = "IsPlayerFriendly"}, true)

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
        if IsPlayerFriendly(v) then continue end
        
        local char = v.Character
        if not char then continue end
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

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MultiRaycast = require(ReplicatedStorage.Modules.Misc.MultiRaycast)

local old
old = hookfunction(MultiRaycast, function(p1,p2,p3,p4,p5,p6)
    if target then
        p2 = target.Position - p1
    end
    return old(p1,p2,p3,p4,p5,p6)
end)
