local utility = {
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
}

function utility:GetTreadmils()
    local s, r = pcall(function(...)
        local d = self.Save.Get()
        local o = {}
        local l = d.TreadmillUpgradeLevel
        for id, t in next, self.Treadmills.Directory do
            if self.Treadmills.GetUpgradeLevel(id) > l and self.CanAfford(d.Money, t.Price) then
                table.insert(o, id)
            end
        end
        return o
    end)

    if s and r then
        return r    
    end
    return nil
end

function utility:GetBaseUpgradeable()
    local s, r = pcall(function(...)
        local d = self.Save.Get()
        local l = d.BaseUpgradeLevel + 1
        local n = self.Bases.BASES[l]

        if self.CanAfford(d.Money, n.Cost) then
            return true
        end

        return false
    end)

    if s and r then
        return r    
    end
    return false
end

function utility:GetTrails()
    local s, r = pcall(function(...)
        local d = self.Save.Get()
        local o = {}
        for _, trial in next, self.Trails.Directory do
            if not d.TrailInventory[trial._id] and self.CanAfford(d.Money, trial.Price) then
                table.insert(o, trial._id)
            end
        end
        return o
    end)

    if s and r then
        return r    
    end
    return nil
end

utility.CanAfford = function(m, c)
    local s, r = pcall(function(...)
        return m >= c
    end)
    if s and r then
        return r
    end
    return false
end

function utility:Purchase(remote, id)
    local s, r = pcall(function(...)
        warn("purchased: "..tostring(id))
        return remote:InvokeServer(id)
    end)
    if s and r then
        return r    
    end
    return false
end

function utility:Init()
    self.Data = self.ReplicatedStorage:FindFirstChild("Data")
    if not self.Data then
        return warn("Couldnt get data")
    end

    self.Treadmills = require(self.Data:FindFirstChild("Treadmills"))
    if not self.Treadmills then
        return warn("failed to get Treadmills")
    end

    self.Trails = require(self.Data:FindFirstChild("Trails"))
    if not self.Trails then
        return warn("Couldnt get Trails")
    end

    self.Bases = require(self.Data:FindFirstChild("Bases"))
    if not self.Bases then
        return warn("Couldnt get Bases")
    end

    self.Shared = self.ReplicatedStorage:FindFirstChild("Shared")
    if not self.Shared then
        return warn("couldnt get Shared")
    end

    self.Save = require(self.Shared:FindFirstChild("Save"))
    if not self.Save then
        return warn("couldnt get Shared")
    end

    self.Packages = self.ReplicatedStorage:FindFirstChild("Packages")
    if not self.Packages then
        return warn("couldnt get Packages")
    end

    self.Networking = self.Packages:FindFirstChild("Networking")
    if not self.Networking then
        return warn("couldnt get Networking")
    end

    self["RF/Trailwear/AskPurchase"] = self.Networking:FindFirstChild("RF/Trailwear/AskPurchase")
    if not self["RF/Trailwear/AskPurchase"] then
        return warn("couldnt get RF/Trailwear/AskPurchase")
    end

    self["RF/Treadmill/AskTierRaise"] = self.Networking:FindFirstChild("RF/Treadmill/AskTierRaise")
    if not self["RF/Treadmill/AskTierRaise"] then
        return warn("couldnt get RF/Treadmill/AskTierRaise")
    end

    self["RE/Homestead/AskBaseTierRaise"] = self.Networking:FindFirstChild("RE/Homestead/AskBaseTierRaise")
    if not self["RE/Homestead/AskBaseTierRaise"] then
        return warn("couldnt get RE/Homestead/AskBaseTierRaise")
    end

    task.spawn(function()
        while task.wait(0.1) do
            local trials = self:GetTrails()

            if typeof(trials) == "table" then
                for _, trail in next, trials do
                    self:Purchase(self["RF/Trailwear/AskPurchase"], trail)
                    task.wait(0.1)
                end
            end
            local treadmils = self:GetTreadmils()

            if typeof(treadmils) == "table" then
                for _, treadmil in next, treadmils do
                    self:Purchase(self["RF/Treadmill/AskTierRaise"], treadmil)
                    task.wait(0.1)
                end
            end
            local upgradeable = self:GetBaseUpgradeable()

            if upgradeable then
                self["RE/Homestead/AskBaseTierRaise"]:FireServer()
            end
        end
    end)
    return warn("success")
end

utility:Init()
