pcall(function(...)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Lutosys/opensrc/refs/heads/main/stealaeggspeedbypass.lua"))()
end)

local utility = {
    Workspace = game:GetService("Workspace"),
    Players = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
}

utility.areas = {
    "Forest", -- 1
    "Lake", -- 2
    "Desert", -- 3
    "Jungle", -- 4
    "Snow", -- 4
    "Volcano", -- 5
    "Abyss Ocean", -- 6
    "Prehistoric", -- 7
    'Cosmic', -- 8
    "Cherry Blossom", -- 9
    "Titan Temple", -- 10
}

getgenv().config = {
    minarea = 9
}

function utility:getBestEgg()
    local s, r = pcall(function(...)
        local egg = nil
        local biggestegg = 0
        for key, data in next, self.EggState.ReadFieldEggs().Records do
            local idx = table.find(self.areas, data.AreaId)
            if idx > getgenv().config.minarea then
                if data.AssetScale > biggestegg then
                    biggestegg = data.AssetScale
                    egg = data
                end
            end
        end
        return egg
    end)
    if s and r then
        return r    
    end
    return nil
end

function utility:GoTo(pos)
    pcall(function(...)
        local dist = math.huge
        repeat
            local dt = task.wait(0.01)
            local start = self.LocalPlayer.Character.HumanoidRootPart.Position
            dist = (pos.BoundsCFrame.Position - start).Magnitude
            local half = start + (pos.BoundsCFrame.Position - start).Unit * dt * 430
            self.LocalPlayer.Character:MoveTo(half)
        until dist <= 5
    end)
end

function utility:getproximitypromptforegg(egg)
    local s, r = pcall(function(...)
        local CarryAreaEggs = self.Workspace:QueryDescendants("#CarryAreaEgg")
        local closetprompt = nil
        local closetdist = math.huge
        for key, prompt in next, CarryAreaEggs do
            local p = prompt.Parent
            if p then
                local dist = (egg.BoundsCFrame.Position - p.Position).Magnitude
                if dist < closetdist then
                    closetdist = dist
                    closetprompt = prompt
                end
            end
        end
        return closetprompt
    end)
    if s and r then
        return r
    end
    return nil
end

function utility:init()
    self.LocalPlayer = self.Players.LocalPlayer
    if not fireproximityprompt then
        return self.LocalPlayer:Kick("Unsupport executor missing fireproximityprompt")
    end

    self.Client = self.ReplicatedStorage:FindFirstChild("Client")
    if not self.Client then
        return warn("failed to get Client")
    end

    self.EggState = require(self.Client:FindFirstChild("EggState"))
    if not self.EggState then
        return warn("failed to get EggState")
    end

    task.spawn(function()
        while true do
            pcall(function(...)
                local egg = self:getBestEgg()
                if egg then
                    self:GoTo({["BoundsCFrame"] = CFrame.new(514, 71, -368)})
                    task.wait(0.1)
                    self:GoTo(egg)
                    task.wait(0.5)
                    local p = self:getproximitypromptforegg(egg)
                    if p then
                        fireproximityprompt(self:getproximitypromptforegg(egg))
                    end
                    task.wait(0.1)
                    self:GoTo({["BoundsCFrame"] = CFrame.new(514, 71, -368)})
                    task.wait(0.1)
                else
                    self:GoTo({["BoundsCFrame"] = CFrame.new(514, 71, -368)})
                    task.wait(0.1)
                end
            end)
            task.wait(1)
        end
    end)

    return warn("success init")
end

utility:init()
