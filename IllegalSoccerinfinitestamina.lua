local utility = {
    hookhistory = {},
    Players = game:GetService("Players"),
}

pcall(function(...)
    getgenv().enabled = true
end)

function utility:safeFilterGc(t, d, i)
    local s, r = pcall(function(...)
        local f = filtergc(t, d, i)
        return f
    end)

    if s and r then
        return r    
    end

    return warn('failed to filtergc reason: '..tostring(r))
end

utility.gupv = function(f, i)
    local s, r = pcall(function()
        return debug.getupvalue(f, i)
    end)

    if s and r then
        return r
    end

    return warn('failed to getupvalue err: '..tostring(r))
end

function utility:safehook(o, n)
    local s, r = pcall(function(...)
        local h = hookfunction(o, n)
        self.hookhistory[h] = o
        return h
    end)

    if s and r then
        return r    
    end

    return warn('failed to hookfunction err: '..tostring(r))
end

function utility:unhook(f)
    if not self.Update then
        return warn("Update func reference is nil")
    end

    if not self.hookhistory[f] then
        return warn("function is not in hookhistory")
    end

    if not isfunctionhooked(self.hookhistory[f]) then
        return warn("function failed isfunctionhooked")
    end

    pcall(function()
        restorefunction(self.hookhistory[f])
        self.hookhistory[f] = nil
    end)

    return warn('success unload')
end

function utility:unload()
    for f, _ in next, self.hookhistory do
        self:unhook(f)
    end
end

function utility:init()
    self.LocalPlayer = self.Players.LocalPlayer
    if not self.LocalPlayer then
        return warn("failed to get localplayer")
    end

    if not hookfunction then
        return self.LocalPlayer:Kick("unsupported executor missing: hookfunction")
    end

    if not filtergc then
        return self.LocalPlayer:Kick("unsupported executor missing: filtergc")
    end

    if not debug.getupvalue then
        return self.LocalPlayer:Kick("unsupported executor missing: getupvalue")
    end

    if not getgenv then
        return self.LocalPlayer:Kick("unsupported executor missing: getgenv")
    end

    self.updateSprint = self:safeFilterGc("function", {Name = "updateSprint"}, true)
    if not self.updateSprint then
        return
    end

    self.module = self.gupv(self.updateSprint, 14)
    if not self.module then
        return
    end

    self.Update = self.module.Update
    if not self.Update then
        return warn("failed to get Update func")
    end

    self.hook = self:safehook(self.Update, function(...)
        if getgenv().enabled then
            local data = select(2, ...)
            if data and rawget(data, "HasUnlimitedStamina") ~= nil then
                rawset(data, "HasUnlimitedStamina", true)
            end
        end 
        return self.hook(...)
    end)

    if not self.hook then
        return
    end

    return warn("success")
end

utility:init()
