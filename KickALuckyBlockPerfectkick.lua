local utility = {
    Players = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage")
}

function utility:GetRemote(n)
    local s, r = pcall(function(...)
        return self.ReplicatedStorage:FindFirstChild(n, true)
    end)

    if s and r then
        return r
    end

    return nil
end

function utility:init()
    self["ref_KickEvent"] = self:GetRemote("ref_KickEvent")
    if not self["ref_KickEvent"] then
        return warn("failed to get ref_KickEvent")
    end

    self.LocalPlayer = self.Players.LocalPlayer
    if not self.LocalPlayer then
        return warn("failed to get localplayer")
    end

    if not hookmetamethod then
        return self.LocalPlayer:Kick("Unsupported executor missing hookmetamethod")
    end

    self.s, self.hook = pcall(function(...)
        return hookmetamethod(game, "__namecall", function(...)
            local s = select(1, ...)
            local a = {select(2, ...)}

            if getnamecallmethod() == "InvokeServer" and s == self["ref_KickEvent"] then
                if a[1] and typeof(a[1]) == "number" and a[2] and typeof(a[2]) == "number" then
                    a[1] = a[2]
                end
            end

            return self.hook(s, unpack(a))
        end)    
    end)

    if not self.s then
        return warn("failed to hook err: "..tostring(self.hook))
    end

    return warn("success init")
end

utility:init()
