local utility = {
    Players = game:GetService("Players"),
}

function utility:init()
    self.LocalPlayer = self.Players.LocalPlayer
    if not self.LocalPlayer then    
        return warn("failed to get localplayer")
    end

    if not hookmetamethod then    
        return self.LocalPlayer:Kick("unsupported executor missing hookmetamethod")
    end

    local s, r = pcall(function(...)
        self.hook = hookmetamethod(game, "__namecall", function(...)
            if getnamecallmethod() == "GetAttribute" then
                local k = select(2, ...)
                if k and typeof(k) == "string" and k == "cooldown" then
                    return 0
                end
            end
            return self.hook(...)
        end)
    end)

    return warn('success init')
end

utility:init()
