local utility = {
    ReplicatedStorage = game:GetService("ReplicatedStorage")
}

function utility:GetRemote()
    local s, r = pcall(function(...)
        return self.ReplicatedStorage:FindFirstChild("GolfRemotes"):FindFirstChild("Swing")
    end)
    if s and r then
        return r
    end
    warn("failed to get remote: "..tostring(r))
    return nil
end

utility.hookmethod = function(obj, metamethod, callback)
    local s, r = pcall(function()
        return hookmetamethod(obj, metamethod, callback)
    end)
    if s and r then
        return r    
    end
    warn("failed to hook: "..tostring(r))
    return nil
end

function utility:init()
    self.Swing = self:GetRemote()
    if not self.Swing then
        return
    end

    self.hook = self.hookmethod(game, "__namecall", function(...)
        local args = {select(2, ...)}
        local s = select(1, ...)

        if rawequal(s, self.Swing) then
            if args[1] and typeof(args[1]) == "number" then
                args[1] = 1
            end
        end
        return self.hook(s, unpack(args))
    end)

    if not self.hook then
        return 
    end

    return warn("success init")
end

utility:init()
