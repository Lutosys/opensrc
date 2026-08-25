local utility = {}

utility.Init = function(self)
    self.LocalPlayer = game:GetService("Players").LocalPlayer

    if not hookfunction then
        return self.LocalPlayer:Kick("executor doesnt have hookfunction")
    end

    if not filtergc then
        return self.LocalPlayer:Kick("executor doesnt have filtergc")
    end

    if not debug.getinfo then
        return self.LocalPlayer:Kick("executor doesnt have debug.getinfo")
    end

    self.addenergygc, self.AddEnergy = pcall(function(...)
        return filtergc("function", {Name = 'AddEnergy'}, true)    
    end)

    if not self.AddEnergy then
        return warn("failed to get AddEnergy func err: "..tostring(self.AddEnergy))
    end

    local _, addresult = pcall(function(...)
        self.AddEnergyHook = hookfunction(self.AddEnergy, function(...)
            return self.AddEnergyHook(0)
        end)
    end)

    if not self.AddEnergyHook  then
        return warn("failed to hook addenergy err: "..tostring(addresult))
    end

    return warn("success")
end

utility:Init()
