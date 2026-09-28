local utility = {
    Workspace = game:GetService("Workspace"),
    Players = game:GetService("Players")
}

function utility:resetadmins()
    pcall(function(...)
        local regen = self.Workspace.Terrain._Game.Admin.Regen.ClickDetector
        if regen then
            fireclickdetector(regen)
        end
    end)
end

function utility:GetAdmin()
    local s, _ = pcall(function(...)
        self:resetadmins()

        local pads = workspace.Terrain._Game.Admin.Pads
        for _, pad in pairs(pads:GetChildren()) do
            local head = pad.Head
            firetouchinterest(self.LocalPlayer.Character.HumanoidRootPart, head, 0)
            firetouchinterest(self.LocalPlayer.Character.HumanoidRootPart, head, 1)
        end

        return true
    end)

    if s then
        return true
    end

    return false
end

function utility:initget()
    self.LocalPlayer = self.Players.LocalPlayer
    if not self.LocalPlayer then
        return warn("didnt get localplayer")
    end

    if not fireclickdetector then
        return self.LocalPlayer:Kick("unsupport missing fireclickdetector")
    end

    if not firetouchinterest then
        return self.LocalPlayer:Kick("unsupport missing firetouchinterest")
    end

    task.spawn(function()
        while wait(0.05) do
            self:GetAdmin()
        end
    end)

    return warn("success init")
end

utility:initget()
