local InventoryHandler = require(game:GetService("ReplicatedStorage").TS.inventory["inventory-util"])
local InventoryUtil = InventoryHandler.InventoryUtil
local SwordEvent = game:GetService("ReplicatedStorage").rbxts_include.node_modules["@rbxts"].net.out._NetManaged.SwordHit

local function getHandTool()
    local success, result = pcall(function()
        return InventoryUtil.getInventory(game.Players.LocalPlayer).hand.tool
    end)
    if success and result then  
        return result
    end 
    return nil
end 

local function getLocalRoot()
    local success, result = pcall(function()
        return game.Players.LocalPlayer.Character.HumanoidRootPart
    end)
    if success and result then  
        return result
    end 
    return nil
end 

local function getDistance(target)
    local root = getLocalRoot()
    if not root then return math.huge end
    
    local success, result = pcall(function()
        return (root.Position - target.Position).Magnitude
    end)
    if success and result then  
        return result
    end 
    return math.huge
end 

local function teamCheck(plr)
    local localTeam = game.Players.LocalPlayer:GetAttribute("Team")
    local targetTeam = plr:GetAttribute("Team")
    if localTeam == nil or targetTeam == nil then return false end
    return localTeam == targetTeam
end 

local function isAlive(char)
    local success, result = pcall(function()
        local humanoid = char:FindFirstChild("Humanoid")
        if not humanoid then return false end
        return humanoid.Health > 0
    end)
    if success and result then  
        return result
    end 
    return false
end 

local function swordattack(target)
    pcall(function()
        local tool = getHandTool()
        if not tool then return end
        
        local name = tool.Name
        if not name or not name:lower():match("sword") then 
            warn(name .. " is not a valid KA tool")
            return 
        end

        local myRoot = getLocalRoot()
        if not myRoot then return end

        local plrChar = target:FindFirstAncestorOfClass("Model")
        if not plrChar then return end

        local args = {
            chargedAttack = {
                chargeRatio = 0
            },
            entityInstance = plrChar,
            validate = {
                selfPosition = {
                    value = myRoot.Position
                },
                targetPosition = {
                    value = target.Position
                }
            },
            weapon = tool
        }

        SwordEvent:FireServer(args)
    end)
end 

while true do
    wait()

    local closest = nil
    local closestdistance = math.huge

    for _, plr in next, game.Players:GetPlayers() do    
        if plr == game.Players.LocalPlayer then continue end

        local char = plr.Character
        if not char then continue end

        if isAlive(char) and not teamCheck(plr) then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end

            local distance = getDistance(hrp)
            if distance <= 16 and distance < closestdistance then
                closest = hrp
                closestdistance = distance
            end
        end 
    end 

    if closest then
        swordattack(closest)
        task.wait(0.07)
    end
end
