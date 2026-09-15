local utility = {
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
}

function utility:getremote(Name)
    local s, r = pcall(function(...)
        return self.ReplicatedStorage:FindFirstChild(Name, true)
    end)
    if s and r then
        return r    
    end

    warn(s, r)

    return nil
end

function utility:init()
    self.RedeemAll = self:getremote("RF/Codex/AskRedeemAll")
    if not self.RedeemAll then
        return warn('failed to get remote')
    end

    task.spawn(function()
        while task.wait(1) do
            pcall(function(...)
                self.RedeemAll:InvokeServer()
            end)
        end
    end)

    return warn("success init")
end

utility:init()
