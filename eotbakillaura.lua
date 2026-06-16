local LocalPlayer = game.Players.LocalPlayer

local targets = {
    ["British Forces"] = true,
    ["Allies of Britain"] = true,
    ["American Forces"] = false,
    ["Visitors & Civilians"] = true,
}

local function isHorse(plr)
    for _, v in ipairs(workspace:GetChildren()) do
        if v.Name == "EBI-Horse" then
            local seat = v:FindFirstChild("Seat")
            if seat then
                local occp = seat.Occupant
                if occp and occp.Parent then
                    if game.Players:GetPlayerFromCharacter(occp.Parent) == plr then
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function anyValidTargets()
    for _, player in pairs(game.Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local char = player.Character
        if not char then continue end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        
        local humanoid = char:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        
        local playerTeam = player.Team and player.Team.Name
        if not targets[playerTeam] then continue end
        
        local forcefield = char:FindFirstChildOfClass("ForceField")
        if forcefield then continue end
        
        if isHorse(player) then continue end
        
        return true
    end
    return false 
end

local function findClosestTarget(myhrp)
    local closestPlayer = nil
    local closestDistance = math.huge
    
    for _, player in pairs(game.Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local char = player.Character
        if not char then continue end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        
        local humanoid = char:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        
        local playerTeam = player.Team and player.Team.Name
        if not targets[playerTeam] then continue end
        
        local forcefield = char:FindFirstChildOfClass("ForceField")
        if forcefield then continue end
        
        if isHorse(player) then continue end
        
        local distance = (myhrp.Position - hrp.Position).Magnitude
        if distance < closestDistance then
            closestDistance = distance
            closestPlayer = {
                player = player,
                char = char,
                hrp = hrp,
                humanoid = humanoid
            }
        end
    end
    
    return closestPlayer
end

local function teleportToSpawn()
    local mychar = LocalPlayer.Character
    if not mychar then return end
    
    local myhrp = mychar:FindFirstChild("HumanoidRootPart")
    if not myhrp then return end
    
    myhrp.CFrame = CFrame.new(Vector3.new(0, 1000, 0))
end

for i = 1, 3 do  
    task.spawn(function()
        while true do
            task.wait()
            
            if not anyValidTargets() then
                teleportToSpawn()
                task.wait()
                continue
            end
            
            local mychar = LocalPlayer.Character
            if not mychar then continue end
            
            local myhrp = mychar:FindFirstChild("HumanoidRootPart")
            if not myhrp then continue end
            
            local myHumanoid = mychar:FindFirstChild("Humanoid")
            if not myHumanoid or myHumanoid.Health <= 0 then continue end
            
            local sabre = mychar:FindFirstChild("InfantrySabre")
            if not sabre then
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                if backpack then
                    sabre = backpack:FindFirstChild("InfantrySabre")
                    if sabre then
                        sabre.Parent = mychar
                    end
                end
            end
            
            if not sabre then continue end
            
            local swordremote = sabre:FindFirstChild("SwordRemoteEvent")
            if not swordremote then continue end
            
            local SwordUnrelRemoteEvent = sabre:FindFirstChild("SwordUnrelRemoteEvent")
            if not SwordUnrelRemoteEvent then continue end

            local closestPlayer = findClosestTarget(myhrp)
            
            if not closestPlayer then 
                teleportToSpawn()
                task.wait()
                continue
            end
            
            myhrp.CFrame = closestPlayer.hrp.CFrame * CFrame.new(0, 0, 3) 
            SwordUnrelRemoteEvent:FireServer("L")
            swordremote:FireServer(closestPlayer.humanoid)
        end
    end)
end
