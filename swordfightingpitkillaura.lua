local target
local Event = game:GetService("ReplicatedStorage").Remotes.Attack

local function getcloset()
    local closest
    local closetdistance = math.huge
    local localPlayer = game.Players.LocalPlayer
    local localChar = localPlayer.Character
    
    if not localChar then return nil end
    
    local localHRP = localChar:FindFirstChild("HumanoidRootPart")
    if not localHRP then return nil end
    
    for _, obj in pairs(game.Players:GetPlayers()) do
        if obj == localPlayer then continue end

        local char = obj.Character
        if not char then continue end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        local hitbox = char:FindFirstChild("Hitbox")
        if not hitbox then continue end

        local dist = (localHRP.Position - hrp.Position).Magnitude

        if dist and dist <= 40 and dist < closetdistance then
            closest = hitbox
            closetdistance = dist 
        end
    end

    return closest
end

game:GetService("RunService").RenderStepped:Connect(function()
    target = getcloset()
    if target then
        Event:FireServer(Vector3.new(0,-1,0), target)
    end 
end)
