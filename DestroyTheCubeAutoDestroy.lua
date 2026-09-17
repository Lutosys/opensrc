local utility = {
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Workspace = game:GetService("Workspace"),
    Players = game:GetService("Players"),
}

function utility:getclosetcube()
    local s, r = pcall(function(...)
        local c = nil
        local cd = math.huge

        for _, cube in self.Cube:GetChildren() do
            local dist = self.LocalPlayer:DistanceFromCharacter(cube.Position)
            if dist < cd then
                cd = dist
                c = cube
            end
        end

        return c
    end)

    if s and r then
        return r
    end

    return nil
end

function utility:init()
    self.LocalPlayer = self.Players.LocalPlayer
    if not self.LocalPlayer then
        return warn("failed to get localplayer")
    end

    self.Cube = self.Workspace:FindFirstChild("Cube")
    if not self.Cube then
        return warn('failed to get cube')
    end

    self.CubeRemotes = self.ReplicatedStorage:FindFirstChild("CubeRemotes")
    if not self.CubeRemotes then
        return warn('failed to get CubeRemotes')
    end

    self.Hit = self.CubeRemotes:FindFirstChild("Hit")
    if not self.Hit then
        return warn('failed to get Hit')
    end

    task.spawn(function()
        while task.wait() do
            self.cu = self:getclosetcube()
            if self.cu then
                self.Hit:FireServer(
                    self.cu,
                    self.cu.Position,
                    Vector3.new(0.014110449701548, 0.16652980446815, 0.98593550920486)
                )
            end
        end
    end)

    return warn("success init")
end

utility:init()
