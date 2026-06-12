local function getMurder()
    local storage = game:GetService("ReplicatedStorage")
    local remotes = storage:FindFirstChild("Remotes")
    local extras = remotes and remotes:FindFirstChild("Extras")
    local remote = extras and extras:FindFirstChild("GetPlayerData")
    
    if not remote then return end

    local data = remote:InvokeServer()
    if not data or type(data) ~= "table" then
        return
    end

    for i, plr in pairs(data) do
        if plr.Role == "Murderer" then
            local murd = game.Players:FindFirstChild(i)
            if not murd then return end 

            local char = murd.Character
            if not char then return end

            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            return hrp
        end
    end
end

local function getRemote()
    local backpack = game.Players.LocalPlayer.Backpack
    local character = game.Players.LocalPlayer.Character

    if backpack and backpack:FindFirstChild("Gun") then
        return backpack:FindFirstChild("Gun"):FindFirstChild("Shoot", true)
    elseif character and character:FindFirstChild("Gun") then
        return character:FindFirstChild("Gun"):FindFirstChild("Shoot", true)
    end
end

local remote = nil
local currentTarget = nil
game:GetService("RunService").RenderStepped:Connect(function()
    remote = getRemote()
    currentTarget = getMurder()
end)

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if remote and self == remote and method == "FireServer" then
        if not currentTarget then return oldNamecall(self, ...) end

        args[1] = currentTarget.CFrame + Vector3.new(0,3,0)
        args[2] = currentTarget.CFrame

        return oldNamecall(self, unpack(args))
    end

    return oldNamecall(self, ...)
end)


print("EXECUTED")
