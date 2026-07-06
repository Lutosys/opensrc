local SecureFire = filtergc("function", {Name = "SecureFire"}, true)
local LocalPlayer = game:GetService("Players").LocalPlayer
local character = LocalPlayer.Character
local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

if not character or not humanoidRootPart then
    return
end

task.spawn(function()
    local LocalPlayer = game:GetService("Players").LocalPlayer
    local SecureFire = filtergc("function", {Name = "SecureFire"}, true)
    local cooldowns = {}
    
    while true do
        local character = LocalPlayer.Character
        if not character then 
            task.wait(0.5)
            continue 
        end

        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then 
            task.wait(0.5)
            continue 
        end

        local weakestPlayer = nil
        local lowestHealth = math.huge
        local weakestHRP = nil
        local weakestHum = nil
        local weakestChar = nil
        
        for _, player in pairs(game:GetService("Players"):GetPlayers()) do
            if player ~= LocalPlayer then
                local targetChar = player.Character
                if targetChar then
                    if targetChar:FindFirstChildOfClass("ForceField") then
                        continue
                    end
                    if targetChar:FindFirstChild("Weave") then
                        continue
                    end
                    local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
                    local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
                    
                    if not targetHum or targetHum.Health <= 0 then 
                        continue 
                    end

                    if targetHRP then
                        local distance = (humanoidRootPart.Position - targetHRP.Position).Magnitude
                        if distance <= 8 then
                            if targetHum.Health < lowestHealth then
                                lowestHealth = targetHum.Health
                                weakestPlayer = player
                                weakestHRP = targetHRP
                                weakestHum = targetHum
                                weakestChar = targetChar
                            end
                        end
                    end
                end
            end
        end

        if weakestHRP and weakestHum then
            local hitLimb = weakestHRP
            local limbs = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
            local minDist = 8
            
            for _, limbName in ipairs(limbs) do
                local limb = weakestChar:FindFirstChild(limbName)
                if limb then
                    local limbDist = (humanoidRootPart.Position - limb.Position).Magnitude
                    if limbDist < minDist then
                        minDist = limbDist
                        hitLimb = limb
                    end
                end
            end
            
            local playerKey = tostring(weakestPlayer.UserId)
            if not cooldowns[playerKey] then
                cooldowns[playerKey] = {Grab = 0, Stomp = 0}
            end
            
            local currentTime = tick()
            local attackType = "Input"
            
            if currentTime - cooldowns[playerKey].Grab >= 18 then
                attackType = "Grab"
                cooldowns[playerKey].Grab = currentTime
            elseif currentTime - cooldowns[playerKey].Stomp >= 2 then
                attackType = "Stomp"
                cooldowns[playerKey].Stomp = currentTime
            end
            
           if attackType == "Input" then
                SecureFire({
                    Type = "Input",
                    Hit = hitLimb,
                    Limb = character:FindFirstChild("Right Arm") or character:FindFirstChild("Left Arm") or character:FindFirstChild("Torso"),
                    Humanoid = weakestHum,
                    Position = hitLimb.Position
                })
                task.wait(0.13)
            elseif attackType == "Grab" then
                SecureFire({
                    Type = "Grab",
                    Hit = hitLimb,
                    Humanoid = weakestHum,
                    Position = hitLimb.Position,
                    Limb = character:FindFirstChild("Right Arm") or character:FindFirstChild("Left Arm") or character:FindFirstChild("Torso")
                })
                task.wait(0.13)
            elseif attackType == "Stomp" then
                local stompLimb = character:FindFirstChild("Right Arm") or character:FindFirstChild("Right Leg") or character:FindFirstChild("Left Leg")
                SecureFire({
                    Type = "Stomp",
                    Hit = hitLimb,
                    Humanoid = weakestHum,
                    Position = hitLimb.Position,
                    Limb = stompLimb
                })
                task.wait(0.13)
            end
        end
        
        task.wait()
    end
end)

task.spawn(function()
    while true do
        SecureFire({
            Type = "Weave"
        })
        wait(0.45)
    end
end)

game:GetService("RunService").Heartbeat:Connect(function()
    local character = LocalPlayer.Character
    if not character then return end
    local HRP = character:FindFirstChild("HumanoidRootPart")
    local Humanoid = character:FindFirstChild("Humanoid")
    if HRP and Humanoid then
        HRP.AssemblyLinearVelocity = (HRP.AssemblyLinearVelocity * Vector3.new(0, 1, 0)) + (Humanoid.MoveDirection * 30)
    end
end)

for _, v in pairs(getgc()) do
    if type(v) == "function" and debug.info(v, "n") == "Play" and debug.info(v, "s"):match("CameraShake") then
        hookfunction(v, function()
            return
        end)
    end
end

while wait(0.10) do
    for _, player in pairs(game.Players:GetPlayers()) do
         if player ~= game.Players.LocalPlayer and player.Character then
            for _, v in pairs(player.Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
             end
        end
    end
end
