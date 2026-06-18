print("RAN")

local attackdelay = 0.05 -- you can change this to 0 but your tools will lose all durability in 2 seconds

local sendstate = game.ReplicatedStorage:FindFirstChild("SendState")
if not sendstate then
    warn("SendState not found!")
    return
end

local getnearbyentities = filtergc("function", {Name = "getNearbyEntities"}, true)
local playerdata = debug.getupvalue(getnearbyentities, 2)

local function isimmune(playername)
    for player, data in pairs(playerdata) do
        if tostring(player) == playername then
            if data.spawnImmunity then
                return true
            end 
        end
    end
    return false
end

local function getclosestplr()
    local closest = nil
    local closestdistance = math.huge
    local myhrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myhrp then return nil end

    for _, player in pairs(game.Players:GetPlayers()) do
        if player == game.Players.LocalPlayer then continue end
        local char = player.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        if isimmune(player.Name) then continue end
        local distance = (myhrp.Position - hrp.Position).Magnitude
        if distance < closestdistance and distance < 50 then
            closest = player
            closestdistance = distance
        end
    end
    return closest
end
local target = nil
game:GetService("RunService").RenderStepped:Connect(function()
    target = getclosestplr()
end)
local lastattack = 0
local oldsend 
oldsend = hookmetamethod(game, "__namecall", function(self, ...)
    if self == sendstate then
        local args = {...}
        if args and args[1] and type(args[1]) == "table" then
            local packet = args[1]
            if target then
                local current = tick()
                if current - lastattack >= attackdelay then
                    lastattack = current
                    packet.iattack = true
                    packet.targetEntity = target.Name
                end
           end
            packet.Fell = 0
            return oldsend(self, unpack(args))
        end
    end
    return oldsend(self, ...)
end)

local oldsend2
oldsend2 = hookmetamethod(game, "__namecall", function(self,...)
    if self == game.ReplicatedStorage.UpdatePlayer then
        local args = {...}
        if args[1] and args[1] == "damage" then
            return
        end
    end
    return oldsend2(self, ...)
end)
