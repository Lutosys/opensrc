local services = {
    ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage")),
    Workspace = cloneref(game:GetService("Workspace")),
    Players = cloneref(game:GetService("Players")),
    RunService = cloneref(game:GetService("RunService")),
    UserInputService = cloneref(game:GetService("UserInputService"))
}

local vars = {
    WeaponsSystems = services.ReplicatedStorage.WeaponsSystem,
    LocalPlayer = services.Players.LocalPlayer,
    Camera = services.Workspace.CurrentCamera,
}

vars.Libraries = vars.WeaponsSystems.Libraries

local utility = {
    BaseWeapon = require(vars.Libraries.BaseWeapon),
    target = nil
}

utility.isVisible = function(part)
    local origin = vars.Camera.CFrame

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {vars.LocalPlayer.Character}
    params.IgnoreWater = true

    local direction = (part.Position - origin.Position)
    local result = services.Workspace:Raycast(origin.Position, direction, params)

    if result then
        return services.Players:GetPlayerFromCharacter(result.Instance:FindFirstAncestorOfClass("Model")) ~= nil
    else
        return false
    end
end

utility.GetClosestPlayer = function(self)
    local closestDistance = math.huge
    local closest = nil

    for _, plr in pairs(services.Players:GetPlayers()) do
        if plr == vars.LocalPlayer then continue end
        
        local char = plr.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local head = char:FindFirstChild("Head")
        if not head then continue end

        local screenPos, onScreen = vars.Camera:WorldToViewportPoint(hrp.Position)
        if onScreen then
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - services.UserInputService:GetMouseLocation()).Magnitude
            if distance < closestDistance then
                if not self.isVisible(head) then continue end
                closestDistance = distance
                closest = head
            end
        end
    end

    return closest
end

services.RunService.RenderStepped:Connect(function()
    utility.target = utility:GetClosestPlayer()
end)

utility.hook = hookfunction(utility.BaseWeapon.fire, function(p1,p2,p3,p4)
    if utility.target then
        p3 = (utility.target.Position - p2).Unit
    end
    return utility.hook(p1,p2,p3,p4)
end)
