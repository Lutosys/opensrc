--do self:unbind(connection) for toggleing

local utility = {
    ProximityPromptService = game:GetService("ProximityPromptService"),
    Players = game:GetService("Players"),
    conns = {},
}

function utility:bind(connection, callback)
    local s, r = pcall(function(...)
        local conn = connection:Connect(callback)
        self.conns[conn] = conn
        return self.conns[conn]
    end)
    if s and r then
        return r
    end
    return warn('failed to bind connection error: '..tostring(r))
end

function utility:unbind(connection)
    local s, r = pcall(function(...)
        local conn = self.conns[connection]
        if conn then
            conn:Disconnect()
            conn = nil

            return true
        end
        return false
    end)
    if s and r then
        return true
    end
    return warn("failed to unbind")
end

function utility:init()
    self.LocalPlayer = self.Players.LocalPlayer
    if not self.LocalPlayer then
        return warn('failed to get localplayer')
    end

    local connection = self:bind(self.ProximityPromptService.PromptButtonHoldBegan, function(ProximityPrompt, Player)
        if Player == self.LocalPlayer and tostring(ProximityPrompt) == "CarryAreaEgg" then
            ProximityPrompt.HoldDuration = 0
        end
    end)

    if not connection then
        return warn("some how failed to create conn")
    end

    return warn("Success init")
end

utility:init()
