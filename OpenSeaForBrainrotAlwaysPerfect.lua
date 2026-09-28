local utility = {
    Players = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
}

function utility:InitAlwaysPerfect()
    self.LocalPlayer = self.Players.LocalPlayer
    if not self.LocalPlayer then
        return warn("failed to get LocalPlayer")
    end

    if not hookmetamethod then
        return self.LocalPlayer:Kick("Unsupported executor missing hookmetamethod.")
    end

    self.Start = self.ReplicatedStorage:FindFirstChild("Start", true)
    if not self.Start then
        return warn("Couldnt get Start Remote")
    end

    self.s, self.hook = pcall(function()
        return hookmetamethod(game, "__namecall", function(...)
            local s = select(1, ...)
            local args = {select(2, ...)}

            if s == self.Start then
                args[1] = 9e9
            end

            return self.hook(s, unpack(args))
        end)
    end)

    if not self.s then
        return warn("failed to hook err: "..tostring(self.hook))
    end

    return warn("success init")
end

utility:InitAlwaysPerfect()
