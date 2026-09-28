local utility = {
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    RunService = game:GetService("RunService")
}

function utility:InitAutoClick()
    self.Tap = self.ReplicatedStorage:FindFirstChild("Tap", true)
    if not self.Tap then
        return warn("failed to get tap remote")
    end

    self.l = tick()
    if not self.l then
        return warn("tick() didnt work ig")
    end

    self.conn = self.RunService.Heartbeat:Connect(function()
        if tick() - self.l >= 0.2 then
            self.l = tick()
            self.Tap:FireServer()
        end
    end)

    if not self.conn then
        return warn('failed to create conn')
    end 

    return warn("success init")
end

utility:InitAutoClick()
