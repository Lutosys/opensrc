local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Item = require(ReplicatedStorage.Content.Item)
local Knit = require(ReplicatedStorage.Packages.Knit)
local InventoryController = Knit.GetController("InventoryController")
local InventoryService = Knit.GetService("InventoryService")
local InventoryValue = InventoryController.Inventory
local inv = InventoryValue:get()

local isEquipped = require(game.ReplicatedFirst.Controllers.InventoryController.IsEquipped)

local toggled = {}
local Items = {}

local allBalls = Item:GetAllFromType(Item.Type.Ball)
for _, ball in pairs(allBalls) do
    Items[ball.Id] = true
    inv[ball.Id] = 1
end

InventoryValue:set(inv)

local old3
old3 = hookfunction(isEquipped, function(item, equippedTable, selected)
    if Items[selected] and toggled[selected] ~= nil then
        return toggled[selected]
    end
    return old3(item, equippedTable, selected)
end)

local old2
old2 = hookfunction(InventoryService.Equip, function(self, id)
    local result = old2(self, id)
    if Items[id] then
        for k, _ in pairs(toggled) do
            toggled[k] = nil
        end
        toggled[id] = true
        local eq = InventoryController.Equipped:get()
        InventoryController.Equipped:set(eq)
    end
    return result
end)

local fakeEntries = {}
for _, ball in pairs(allBalls) do
    table.insert(fakeEntries, {Name = ball.Id, Item = ball, Count = 1, IsRandom = false})
end

for _, func in getgc() do
    if typeof(func) == "function" then
        if tostring(getfenv(func).script) == "buildEntries" then
            if debug.info(func, "l") == 23 then
                local old
                old = hookfunction(func, function(p1, p2)
                    if p1.ItemType == Item.Type.Ball then
                        return fakeEntries
                    end
                    return old(p1, p2)
                end)
            end
        end
        if tostring(getfenv(func).script) == "BallController" then
            if debug.info(func, "l") == 62 then
                local old4
                old4 = hookfunction(func, function(p1)
                    if not workspace:FindFirstChild("CLIENT_BALL_" .. p1.ID) and p1.Skin then
                        for name, isToggled in pairs(toggled) do
                            if isToggled then
                                p1.Skin = name
                                break
                            end
                        end
                    end
                    return old4(p1)
                end)
            end
        end
    end
end
