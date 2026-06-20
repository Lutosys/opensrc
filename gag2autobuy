local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Networking = require(ReplicatedStorage.SharedModules.Networking)

local PurchaseSeeds = Networking.SeedShop.PurchaseSeed
local SeedsStock = ReplicatedStorage.StockValues.SeedShop.Items

local PurchaseGears = Networking.GearShop.PurchaseGear
local GearsStock = ReplicatedStorage.StockValues.GearShop.Items

local PurchaseCrates = Networking.CrateShop.PurchaseCrate
local CratesStock = ReplicatedStorage.StockValues.CrateShop.Items

local prices = {}
local playerdata = nil
for i,v in pairs(getgc()) do
    if type(v) == "function" then
        if debug.info(v, "s"):match("RestockStoreController") then
            if debug.info(v, "l") == 575 then
                pcall(function()
                    table.insert(prices, debug.getupvalue(v, 3))
                    playerdata = debug.getupvalue(v, 9)
                end)
            end
        end 
    end
end

local function canAfford(item)
    if not prices or not playerdata then
        return false
    end
    
    for _, options in pairs(prices) do
        local success, result = pcall(function(...)
            local itemData = options[item]
            if not itemData then
                return false
            end
            return (playerdata.Data.Sheckles or 0) >= itemData.price
        end)
        if success  and result then
            return true
        end
    end
    return false
end

--local exclude = {"Apple", "Crate", "RAndom idk"} put the stuff here that you want excluded from auto buy
local exclude = {}

while wait(0.05) do
    for _,seed in pairs(SeedsStock:GetChildren()) do
        if seed and typeof(seed) == "Instance" then
            if seed.Value > 0 then
                if table.find(exclude, seed.Name) then
                    continue
                end
                if canAfford(seed.Name) then
                    pcall(function(...)
                        if seed:GetFullName():match("SeedShop") then
                            PurchaseSeeds:Fire(seed.Name)
                        end
                        if seed:GetFullName():match("GearShop") then
                            PurchaseGears:Fire(seed.Name)
                        end
                        if seed:GetFullName():match("CrateShop") then
                            PurchaseCrates:Fire(seed.Name)
                        end
                    end)
                end 
            end 
        end
    end
end 
