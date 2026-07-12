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

local ShootWeapon = game:GetService("ReplicatedStorage").NetworkRemotes.Inventory.ShootWeapon

local target = nil
local direction = nil

local function GetClosestPlayer()
    local closestDistance = math.huge
    local closest = nil
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

        local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
        if not onScreen then continue end

        local dist = (Vector2.new(screenPos.X, screenPos.Y) - camera.ViewportSize / 2).Magnitude
        if dist < closestDistance then
            closestDistance = dist
            closest = hrp
        end
    end

    return closest
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

print("ran")