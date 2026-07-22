local Tools = game:GetService("ReplicatedStorage").Tools
local RewTools = game:GetService("ReplicatedStorage").RewTools
local PDweapons = game:GetService("ReplicatedStorage").PDWeapons
local onetaps = game:GetService("ReplicatedStorage").OneTaps

local names = {}
for _, v in pairs(Tools:GetChildren()) do
    table.insert(names, v.Name)
end
for _, v in pairs(RewTools:GetChildren()) do
    table.insert(names, v.Name)
end
for _, v in pairs(PDweapons:GetChildren()) do
    table.insert(names, v.Name)
end
for _, v in pairs(onetaps:GetChildren()) do
   table.insert(names, v.Name)
end

local target = nil
local tracked = {}

local function isVisible(target)
    local origin = game.workspace.CurrentCamera.CFrame
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {game.Players.LocalPlayer.Character}
    params.IgnoreWater = true

    local direction = (target.Position - origin.Position)
    local result = workspace:Raycast(origin.Position, direction, params)

    if result then
        return game.Players:GetPlayerFromCharacter(result.Instance:FindFirstAncestorOfClass("Model")) ~= nil
    else
        return true
    end
end

local function GetClosestPlayer()
    local closestDistance = math.huge
    local closest = nil
    local camera = workspace.CurrentCamera

    for _, v in pairs(game.Players:GetPlayers()) do
        if v == game.Players.LocalPlayer then continue end
        
        local char = v.Character
        if not char then continue end
        if char:FindFirstChild("Safezone") then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        if table.find(tracked, char) then
            local head = char:FindFirstChild("Head")
            if not head then continue end
            local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - camera.ViewportSize / 2).Magnitude
                if distance < closestDistance then
                    if not isVisible(head) then continue end
                    closestDistance = distance
                    closest = head
                end
            end
        end
    end

    return closest
end

local function trackChar(char)
    for _, child in pairs(char:GetChildren()) do
        if table.find(names, child.Name) then
            if not table.find(tracked, char) then
                table.insert(tracked, char)
            end
            break
        end
    end

    char.ChildAdded:Connect(function(ch)
        if table.find(names, ch.Name)then
            if not table.find(tracked, char) then
                table.insert(tracked, char)
            end
        end
    end)
end

for _, player in pairs(game.Players:GetPlayers()) do
    if player == game.Players.LocalPlayer then continue end

    if player.Character then
        trackChar(player.Character)
    end

    player.CharacterAdded:Connect(trackChar)
end

game.Players.PlayerAdded:Connect(function(player)
    if player == game.Players.LocalPlayer then return end
    player.CharacterAdded:Connect(trackChar)
end)

game:GetService("RunService").RenderStepped:Connect(function()
    target = GetClosestPlayer()
end)

local hooked = {}

local function hook()
    pcall(function(...)
        wait(1)

        local CastRay = filtergc("function", {Name = "CastRay"})
        local OnFiring = filtergc("function", {Name = "OnFiring"})

        for _, cast in next, CastRay do
            if cast and typeof(cast) == "function" then
                if not hooked[cast] then
                    hooked[cast] = true
                    print("HOOKED")
                    local old
                    old = hookfunction(cast, function(...)
                        if target then
                            local origin = workspace.CurrentCamera.CFrame.Position
                            local direction = (target.Position - origin).Unit
                            return target, target.Position, Ray.new(origin, direction), Vector3.new(0,1,0)
                        end
                        return old(...)
                    end)
                end
            end
        end

        for _, firing in next, OnFiring do
            local weapondata = debug.getupvalue(firing, 1)
            weapondata.Spread = 0
        end
    end)
end

hook()

game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
    pcall(function()
        char.ChildAdded:Connect(function(ch)
            if table.find(names, ch.Name) then
                hook()
            end
        end)
    end)
end)

game.Players.LocalPlayer.Backpack.ChildAdded:Connect(function(ch)
    if table.find(names, ch.Name) then
        hook()
    end
end)

print("finished")
