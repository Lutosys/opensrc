local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

while task.wait(0.01) do
    local mychar = LocalPlayer.Character
    if not mychar then 
        continue 
    end

    local myHrp = mychar:FindFirstChild("HumanoidRootPart")
    if not myHrp then 
        continue 
    end

    local tool = mychar:FindFirstChildOfClass("Tool")
    if not tool then 
        continue 
    end

    local glove = tool:FindFirstChild("Glove")
    if not glove then 
        continue 
    end

    local conns = getconnections(glove.Touched)
    if typeof(conns) ~= "table" or #conns == 0 then 
        continue 
    end

    local closestPlr = nil
    local closetdistance = math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end

        local char = plr.Character
        if not char then continue end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        local dist = (myHrp.Position - hrp.Position).Magnitude
        if dist < closetdistance and dist < 30 then
            closetdistance = dist
            closestPlr = hrp
        end
    end

    if closestPlr then
        if conns[2].Function then
            pcall(function()
                debug.setupvalue(conns[2].Function, 1, false)
                debug.setupvalue(conns[2].Function, 2, true)
                conns[2].Function(closestPlr)

                task.wait(0.1)
            end)
        end
    end
end
