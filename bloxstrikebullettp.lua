assert(oth.hook, "your executor doesnt support oth.hook you can try to change it to hookfunc")
assert(hookfunction, "your executor doesnt support hookfunction, no xeno verison sorry")
assert(getgc, "your executor doesnt support getgc, you can get the .cast func with module")
assert(rawget, "your executor doesnt support rawget, might be able to work without rawget")

local l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_old
l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_old = oth.hook(getfenv, function(l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_l)
    local l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_result = l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_old(1)
    l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_result.hookfunction = nil
    l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_result.getgenv = nil
    return l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_result
end)

local l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_old2
l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_old2 = oth.hook(debug.info, function(l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_f, l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_t)
    for l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_i = 1, 10 do
        if type(l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_f) == "number" and l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_f == l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_i and l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_t == "f" then
            return nil
        end
    end
    return l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_old2(l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_f, l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_t)
end)

setstackhidden(l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_old2, true)
setstackhidden(l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_old, true)

print("if your executor is shit then the bypass above will not work")

local l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_Players = game:GetService("Players")
local l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_LocalPlayer = l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_Players.LocalPlayer
local l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_Workspace = game:GetService("Workspace")
local l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_RunService = game:GetService("RunService")

local l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_ShootWeapon = game:GetService("ReplicatedStorage").NetworkRemotes.Inventory.ShootWeapon

local l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_target = nil
local l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_direction = nil

local function l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_GetClosestPlayer()
    local l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_closestDistance = math.huge
    local l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_closest = nil
    local l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_camera = l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_Workspace.CurrentCamera
    local l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_myTeam = l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_LocalPlayer:GetAttribute("Team")

    local l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_lchar = l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_Players.LocalPlayer.Character
    if not l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_lchar then return end

    local l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_lhrp = l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_lchar:FindFirstChild("Head")
    if not l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_lhrp then return end

    for _, l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_v in pairs(l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_Players:GetPlayers()) do
        if l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_v == l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_LocalPlayer then continue end
        local l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_char = l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_v.Character
        if not l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_char then continue end
        if l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_char:GetAttribute("Dead") then continue end
        if l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_v:GetAttribute("Team") == l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_myTeam then continue end

        local l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_hrp = l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_char:FindFirstChild("Head")
        if not l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_hrp then continue end

        local l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_screenPos, l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_onScreen = l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_camera:WorldToViewportPoint(l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_hrp.Position)
        if not l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_onScreen then continue end

        local l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_dist = (Vector2.new(l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_screenPos.X, l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_screenPos.Y) - l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_camera.ViewportSize / 2).Magnitude
        if l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_dist < l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_closestDistance then
            l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_closestDistance = l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_dist
            l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_closest = l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_hrp
        end
    end

    return l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_closest
end

l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_RunService.RenderStepped:Connect(function()
    l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_target = l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_GetClosestPlayer()
end)

for l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_, l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_v in next, getgc(true) do
    if type(l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_v) == "table" and rawget(l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_v, "cast") then
        local l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_old
        l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_old = hookfunction(l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_v.cast, function(...)
            local l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_args = {...}
            
            if l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_args[2] and typeof(l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_args[2]) == "Vector3" and l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_target then
                local l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_origin = l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_args[1]
                l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_args[2] = (l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_target.Position - l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_origin)
            end
            
            return l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_old(unpack(l10src_BlAhBlAhBlAh_XYZ_69420_ULTRA_MEGA_SIGMA_args))
        end)
    end
end

print("finished execution")
