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

    self.getenergygc, self.GetEnergy = pcall(function(...)
        return filtergc("function", {Name = 'GetEnergy'}, true)    
    end)

    self.addenergygc, self.AddEnergy = pcall(function(...)
        return filtergc("function", {Name = 'AddEnergy'}, true)    
    end)

    if not self.getenergygc then
        return warn("failed to get GetEnergy func err: "..tostring(self.GetEnergy))
    end

    if not self.addenergygc then
        return warn("failed to get AddEnergy func err: "..tostring(self.AddEnergy))
    end

    local _, getresult = pcall(function(...)
        self.GetEnergyHook = hookfunction(self.GetEnergy, function(...)
            local iscaller = debug.getinfo(2).source and debug.getinfo(2).source:find("SetUpDash")
            if iscaller then
                return 100
            end
            return self.GetEnergyHook(...)
        end)
    end)

    local _, addresult = pcall(function(...)
        self.AddEnergyHook = hookfunction(self.AddEnergy, function(...)
            local iscaller = debug.getinfo(2).source and debug.getinfo(2).source:find("SetUpDash")
            if iscaller then
                return self.AddEnergyHook(0)
            end
            return self.AddEnergyHook(...)
        end)
    end)

    if not self.AddEnergyHook  then
        return warn("failed to hook addenergy err: "..tostring(addresult))
    end

    if not self.GetEnergyHook then
        return warn("failed to hook getenergy err: "..tostring(getresult))
    end

    return warn("success")
end

utility:Init()
