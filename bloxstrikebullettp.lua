local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local ShootWeapon = game:GetService("ReplicatedStorage").NetworkRemotes.Inventory.ShootWeapon

local target = nil

local function GetClosestPlayer()
    local closestDistance = math.huge
    local closest = nil
    local camera = Workspace.CurrentCamera
    local myTeam = LocalPlayer:GetAttribute("Team")

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

local oldhook
oldhook = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    -- credits to phem for the namecall bypass

    local m = getnamecallmethod()
    local args = {...}

    if self == game and m == "WaitForChild" then
        if typeof(args[1]) == "table" then
            return false, "invalid argument #1 to 'WaitForChild' (string expected got table)"
        end
    end
    if (self == game and m == "OmgUnvirNamecall") or m == "FakeIndex" or not self[m] then
        return false, m .. ' is not a valid member of DataModel "Ugc"'
    end

    if self == ShootWeapon and m == "FireServer" and args[1] and args[1].Bullets and target then
        local bullet = args[1].Bullets[1]

        bullet.Hits[1].Instance = target
        bullet.Hits[1].Position = target.Position + Vector3.new(0,8,0)
        bullet.Hits[1].Distance = 0
        bullet.Hits[1].Normal = Vector3.new(0, 0, 0)
    end

    return oldhook(self, ...)
end))

print("!!!ran!!!")
