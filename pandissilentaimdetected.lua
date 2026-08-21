local GetCFrame = filtergc("function", {Name = "GetCFrame"}, true)

local target = nil

local function GetTargets()
    local success, children = pcall(function(...)
        return game.Workspace.Maps:FindFirstChildOfClass("Model").Targets:GetChildren()
    end)

    if success then 
        return children
    end

    return {}
end

local function GetClosetTarget()
    local closet = nil
    local closetdistance = math.huge
    local camera = workspace.CurrentCamera

    for _, target in ipairs(GetTargets()) do
        if not target then
            continue
        end

        local primary = target:FindFirstChild("Primary")
        if not primary then 
            continue
        end

        local screenpos, onscreen = camera:WorldToViewportPoint(primary.Position)
        if onscreen then
            local distance = (Vector2.new(screenpos.X, screenpos.Y) - game:GetService("UserInputService"):GetMouseLocation()).Magnitude
            if distance < closetdistance then
                closetdistance = distance
                closet = primary
            end
        end
    end

    return closet
end

game:GetService("RunService").RenderStepped:Connect(function(a0: number)
    target = GetClosetTarget()
end)

local old; old = hookfunction(GetCFrame, function()
    if target then
        return CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, target.Position + Vector3.new(math.random(-1.5, 1.5),math.random(-1.5, 1.5),math.random(-1.5, 1.5)))
    end
    return old()
end)
