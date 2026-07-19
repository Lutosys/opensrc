local SwordEvent = game:GetService("ReplicatedStorage"):FindFirstChild("93b2718b-2b2a-4859-b36e-fd4614c7f0c9", true)

local function getHandTool()
    local success, result = pcall(function()
        return game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
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
    local localTeam = game.Players.LocalPlayer:GetAttribute("TeamId")
    local targetTeam = plr:GetAttribute("TeamId")
    if localTeam == nil or targetTeam == nil then return false end
    return localTeam == targetTeam
end 

local function isAlive(plr)
    local success, result = pcall(function()
        return plr:GetAttribute("Health") > 0
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
            return 
        end

        local myRoot = getLocalRoot()
        if not myRoot then return end

        local plrChar = target:FindFirstAncestorOfClass("Model")
        if not plrChar then return end

        local player = game.Players:GetPlayerFromCharacter(plrChar)
        if not player then return end

        SwordEvent:FireServer(player)
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

        if isAlive(plr) and not teamCheck(plr) then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end

            local distance = getDistance(hrp)
            if distance <= 20 and distance < closestdistance then
                closest = hrp
                closestdistance = distance
            end
        end 
    end 

    if closest then
        swordattack(closest)
    end
end
