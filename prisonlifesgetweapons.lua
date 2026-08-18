local renpos = CFrame.new(820.298583984375, 87.85000610351562, 2229.396240234375)
local smgpos = CFrame.new(813.6986694335938, 87.85000610351562, 2229.396240234375)
local ak47pos = CFrame.new(-931.7928466796875, 81.27831268310547, 2039.2554931640625)
local plr = game.Players.LocalPlayer

local remote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("GiverPressed")

local remtouchgiver = nil
local smgtouchgiver = nil
local ak47giver = nil

local choicegiver = "AK-47" -- can be MP5 or AK-47 or change it to ""  if you want only shotgun right now

for key, weapongiver in ipairs(Workspace:QueryDescendants("#TouchGiver")) do
    if weapongiver and weapongiver:IsA("Model") then
        if weapongiver:GetPivot().Position == Vector3.new(820.298583984375, 97.85000610351562, 2229.396240234375) then
            remtouchgiver = weapongiver
        end
        if weapongiver:GetPivot().Position == Vector3.new(813.6986694335938, 97.85000610351562, 2229.396240234375) then
            smgtouchgiver = weapongiver
        end
        if weapongiver:GetPivot().Position == Vector3.new(-931.7928466796875, 91.27831268310547, 2039.2554931640625) then
            ak47giver = weapongiver
        end
    end
end

local targetpos = renpos
local targetweapon = remtouchgiver

local conn = game:GetService("RunService").Heartbeat:Connect(function()
    local char = plr.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end    
    local oldcf = hrp.CFrame
    hrp.CFrame = targetpos
    pcall(function()
        remote:FireServer(targetweapon)
    end)

    game:GetService("RunService"):BindToRenderStep("gotweapon", 101, function()
        hrp.CFrame = oldcf
        game:GetService("RunService"):UnbindFromRenderStep("gotweapon")
    end)
end)

game.Players.LocalPlayer.Backpack.ChildAdded:Connect(function(c)
    if conn and tostring(c) == "Remington 870" then
        if choicegiver == "MP5" then
			targetpos = smgpos
			targetweapon = smgtouchgiver
		elseif choicegiver == "AK-47" then
			targetpos = ak47pos
			targetweapon = ak47giver
		else
			conn:Disconnect()
			conn = nil
        end
    elseif conn and tostring(c) == "MP5" and choicegiver == "MP5" then
        conn:Disconnect()
        conn = nil
    elseif conn and tostring(c) == "AK-47" and choicegiver == "AK-47" then
        conn:Disconnect()
        conn = nil
    end
end)
