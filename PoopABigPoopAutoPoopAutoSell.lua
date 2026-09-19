local utility = {
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
}

function utility:getremote(n)
    local s, r = pcall(function(...)
        return self.ReplicatedStorage:FindFirstChild(n, true)
    end)
    if s and r then
        return r
    end
    return nil
end

function utility:init()
    self.RemoteEvent = self:getremote("RemoteEvent")
    if not self.RemoteEvent then
        return warn("Failed to get remoteevent")
    end

    task.spawn(function()
        while task.wait(0.3) do
            self.RemoteEvent:FireServer(
                buffer.fromstring("\x00\x00\x00\x00")
            )

            self.RemoteEvent:FireServer(
                buffer.fromstring("\x03\x00")
            )
        end
    end)

    return warn('success init')
end

utility:init()
