local utility = {
    ReplicatedStorage = game:GetService("ReplicatedStorage")
}

getgenv().SellConfig = getgenv().SellConfig or {
    "Common",
    "Uncommon",
    "Rare",
    "Epic",
    "Legendary",
    "Mythic"   
}

function utility:init()
    self.Shared = self.ReplicatedStorage:FindFirstChild("Shared")
    if not self.Shared then
        return warn("failed to get Shared")
    end

    self.Data = self.ReplicatedStorage:FindFirstChild("Data")
    if not self.Data then
        return warn("failed to get Data")
    end

    self.Save = require(self.Shared:FindFirstChild("Save"))
    if not self.Save then
        return warn("failed to get Save")
    end

    self.Assets = require(self.Data:FindFirstChild("Assets"))
    if not self.Assets then
        return warn("failed to get Assets")
    end

    self.Packages = self.ReplicatedStorage:FindFirstChild("Packages")
    if not self.Packages then
        return warn("failed to get Packages")
    end

    self.Networking = self.Packages:FindFirstChild("Networking")
    if not self.Networking then
        return warn("failed to get Networking")
    end

    self["RF/EggWorld/AskWearTool"] = self.Networking:FindFirstChild("RF/EggWorld/AskWearTool")
    if not self["RF/EggWorld/AskWearTool"] then
        return warn("failed to get RF/EggWorld/AskWearTool")
    end

    self["RE/PetSatchel/SellPet"] = self.Networking:FindFirstChild("RE/PetSatchel/SellPet")
    if not self["RE/PetSatchel/SellPet"] then
        return warn("failed to get RE/PetSatchel/SellPet")
    end

    self.data = self.Save.Get()
    if not self.data then
        return warn("failed to get data")
    end

    self.inv = self.data.EggInventory
    if not self.inv then
        return warn("failed to get egg inv")
    end

    task.spawn(function()
        pcall(function(...)
            while true do 
                task.wait(1)
                self.data = self.Save.Get()
                self.inv = self.data.EggInventory
                for Uid, eggdata in next, self.inv do
                    if eggdata.Placement then continue end
                    local rarity = self.Assets.Directory[eggdata.AssetCategory].Rarity.DisplayName
                    if table.find(getgenv().SellConfig, rarity) then
                        self["RF/EggWorld/AskWearTool"]:InvokeServer(Uid)
                        self["RE/PetSatchel/SellPet"]:FireServer({Uid})
                        wait(0.1)
                    end
                end
            end
        end)
    end)

    return warn("success init")
end

utility:init()
