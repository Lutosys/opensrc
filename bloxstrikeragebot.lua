assert(oth.hook, "your executor doesnt support oth.hook you can try to change it to hookfunc")
assert(hookfunction, "your executor doesnt support hookfunction, no xeno verison sorry")
assert(getgc, "your executor doesnt support getgc, you can get the .cast func with module")
assert(rawget, "your executor doesnt support rawget, might be able to work without rawget")

local old
old = oth.hook(getfenv, function(l)
    local result = old(1)
    result.hookfunction = nil
    result.getgenv = nil
    return result
end)

local old2
old2 = oth.hook(debug.info, function(f, t)
    for i = 1, 10 do
        if type(f) == "number" and f == i and t == "f" then
            return nil
        end
    end
    return old2(f, t)
end)

setstackhidden(old2, true)
setstackhidden(old, true)

print("if your executor is shit then the bypass above will not work")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local target = nil
local direction = nil

local function isVisible(target)
    local origin = Workspace.CurrentCamera.CFrame
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {Players.LocalPlayer.Character}
    params.IgnoreWater = true

    local direction = (target.Position - origin.Position)
    local result = Workspace:Raycast(origin.Position, direction, params)

    if result then
        return Players:GetPlayerFromCharacter(result.Instance:FindFirstAncestorOfClass("Model")) ~= nil
    else
        return true
    end
end


local function GetClosestPlayer()
    local camera = Workspace.CurrentCamera
    local myTeam = LocalPlayer:GetAttribute("Team")

    local lchar = Players.LocalPlayer.Character
    if not lchar then return end

    local lhrp = lchar:FindFirstChild("Head")
    if not lhrp then return end

    for _, v in pairs(Players:GetPlayers()) do
        if v == LocalPlayer then continue end
        local char = v.Character
        if not char then continue end
        if char:GetAttribute("Dead") then continue end
        if v:GetAttribute("Team") == myTeam then continue end

        local hrp = char:FindFirstChild("Head")
        if not hrp then continue end

        if isVisible(hrp) then
            return hrp
        end 
    end
end

RunService.RenderStepped:Connect(function()
    target = GetClosestPlayer()
end)

for _,v in next, getgc(true) do
    if type(v) == "table" and rawget(v, "cast") then
        local old
        old = hookfunction(v.cast, function(...)
            local args = {...}
            
            if args[2] and typeof(args[2]) == "Vector3" and target then
                local origin = args[1]
                args[2] = (target.Position - origin)
            end
            
            return old(unpack(args))
        end)
    end
end

local invhandler = require(game:GetService("ReplicatedStorage"):WaitForChild("Controllers"):WaitForChild("InventoryController"))
local weapon = nil

task.spawn(function()
    while wait(1) do
        weapon = invhandler.getCurrentEquipped()
    end
end)

task.spawn(function()
    while true do
        game:GetService("RunService").PreRender:Wait()
        if target and weapon and weapon.IsEquipped and weapon.Rounds > 0 then
            weapon:shoot()
        end
    end
end)

game:GetService("RunService").PreRender:Connect(function(a0: number)
    game.Workspace.CurrentCamera.FieldOfView = 120
end)
