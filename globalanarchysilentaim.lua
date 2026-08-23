local utility = {
    target = nil,
    ReplicatedFirst = cloneref(game:GetService("ReplicatedFirst")),
    Workspace = cloneref(game:GetService("Workspace")),
    Players = cloneref(game:GetService("Players")),
    UserInputService = cloneref(game:GetService("UserInputService")),
    RunService = cloneref(game:GetService("RunService")),
}

utility.GetEnemies = function(self)
    local enemies = self.LocalFriendlyService:GetEnemyPlayers()
    local result = {}   

    for _, player in enemies do
        local char = self.CustomMeshCharacter:GetWorldCharacterFromPlayer(player)
        if char and char:FindFirstChild("Hitbox") then
            table.insert(result, {player = player, char = char.Hitbox})
        end
    end

    return result
end

utility.GetClosestPlayer = function(self)
    local closestDistance = math.huge
    local closest = nil

    for _, entry in pairs(self:GetEnemies()) do        
		if entry.player:GetAttribute("Dead") then continue end
        local screenPos, onScreen = self.camera:WorldToViewportPoint(entry.char.Parent:GetPivot().Position)
        if onScreen then
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - self.UserInputService:GetMouseLocation()).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closest = entry.char.Parent:GetPivot().Position
            end
        end
    end

    return closest
end

utility.Init = function(self)
    self.Core = self.ReplicatedFirst:WaitForChild("Core", 3)
    if not self.Core then
        return warn("failed to get core")
    end
    self.Services = self.Core:WaitForChild("Services")
    if not self.Services then
        return warn("failed to get services")
    end
    self.LocalFriendlyService = require(self.Services:WaitForChild("LocalFriendlyService"))
    if not self.LocalFriendlyService then
        return warn("failed to get LocalFriendlyService")
    end
    self.GunSystemPlugins = self.ReplicatedFirst:WaitForChild("GunSystemPlugins")
    if not self.GunSystemPlugins then
        return warn("failed to get GunSystemPlugins")
    end
    self.CustomMeshCharacter = require(self.GunSystemPlugins:WaitForChild("CustomMeshCharacter"))
    if not self.CustomMeshCharacter then
        return warn("failed to get CustomMeshCharacter")
    end
    self.camera = self.Workspace.CurrentCamera
    if not self.camera then
        return warn("failed to get camera")
    end
    self.CamerasTable = filtergc("table", {Keys = {"LookCamera"}}, true)
    if not self.CamerasTable then
        return warn("failed to get cameratable")
    end

    self.runconn = self.RunService.RenderStepped:Connect(function()
        self.target = self:GetClosestPlayer()
    end)

    self.RunService:BindToRenderStep("silentaim", 9999, function(delta: number)
        self.looped = true
        if self.target then
            local camcf = self.camera.CFrame
            local cf = CFrame.lookAt(camcf.Position, self.target)
            local pitch, yaw = cf:ToEulerAnglesYXZ()

            local lookcamera = self.CamerasTable.LookCamera
            lookcamera.Orientation.Pitch = pitch
            lookcamera.Orientation.Yaw = yaw
            lookcamera.Orientation.Roll = 0
            lookcamera.ComputedOrientation.Pitch = pitch + lookcamera.OrientationOffset.Pitch
            lookcamera.ComputedOrientation.Yaw = yaw + lookcamera.OrientationOffset.Yaw
            lookcamera.ComputedOrientation.Roll = lookcamera.OrientationOffset.Roll
        end
    end)

    task.wait(0.01)

    if self.runconn and self.looped then
        return warn("success")
    else
        return warn("failed to create loops")
    end
end

utility:Init()
