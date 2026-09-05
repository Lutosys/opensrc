local utility = {
    RunService = game:GetService("RunService"),
    Players = game:GetService("Players")
}

utility.collectgarbage = function()
    local s, r = pcall(function(...)
        return getgc()
    end)
    if s and r then
        return r    
    end
    return warn("failed to get garbage: "..tostring(r))
end

utility.safehook = function(f, c)
    local s, r = pcall(function(...)
        return hookfunction(f, newlclosure(c))
    end)
    if s and r then
        return r    
    end
    return warn("failed to hook function: "..tostring(r))
end

function utility:findfunction(nups, linedefined)
    local s, r = pcall(function(...)
        for _, f in next, self.collectgarbage() do
            if typeof(f) == 'function' and islclosure(f) then
                local upvs = debug.getupvalues(f)
                local line = debug.info(f, "l")

                if upvs and #upvs == nups and line == linedefined then
                    if nups == 10 then
                        local t = debug.getupvalue(f, 3)
                        if typeof(t) == "table" and rawget(t, "Humanoid") then
                            return f
                        end
                    else
                        return f
                    end
                end
            end
        end

        return nil
    end)

    if s and r then
        return r
    end

    return nil
end

function utility:initbypass()
    self.LocalPlayer = self.Players.LocalPlayer
    if not self.LocalPlayer then
        return warn("failed to get localplayer")
    end

    if not getgc then
        self.LocalPlayer:Kick("UNSUPPORT EXECUTOR MISSING getgc")
    end

    if not hookfunction then
        self.LocalPlayer:Kick("UNSUPPORT EXECUTOR MISSING hookfunction")
    end

    if not islclosure then
        self.LocalPlayer:Kick("UNSUPPORT EXECUTOR MISSING islclosure")
    end

    local func3 = self:findfunction(19, 605)

    if not func3 then
        return warn("failed to get function 3")
    end

    local v7 = debug.getupvalue(func3, 2)
    if not v7 then
        return warn("failed to get v7")
    end

    local hookedfunc3; hookedfunc3 = self.safehook(v7, function(p1, p2)
        if p2 and typeof(p2) == "table" then
            setmetatable(p2, {})
        end
        return hookedfunc3(p1,p2)
    end)

    self.speedconn = self.RunService.Heartbeat:Connect(function()
        local char = self.LocalPlayer.Character
        if not char then 
            return
        end

        local hum = char:FindFirstChild("Humanoid")
        if not hum then 
            return
        end

        hum.WalkSpeed = 500
    end)

    return
end

utility:initbypass()
