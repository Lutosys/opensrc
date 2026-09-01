local utility = {
    Players = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Workspace = game:GetService("Workspace"),
    RunService = game:GetService("RunService"),
    Target = nil,
}

function utility:CreateSeed()
    local s, r = pcall(function(...)
        return ("%*:%*:%*"):format(self.LocalPlayer.UserId, 100, (math.floor(self.Workspace:GetServerTimeNow() * 1000)))
    end)
    if s and r then
        return r    
    end
    return nil
end

function utility:CanUseTool()
    local s, r = pcall(function(...)
        local c = self.LocalPlayer.Character
        if not c then
            return false
        end

        local t = c:FindFirstChildOfClass("Tool")
        if not t or t:GetAttribute("ItemType") ~= "Gear" then
            return false
        end

        local h = c and c:FindFirstChild("HumanoidRootPart")
        if not h then
            return false
        end

        local n = not self.ToolGameplayGuard.IsLocalInsideArena()
        if n then
            return false
        end

        if self.Workspace:GetAttribute("Event_MonsterEvent") then
            if h then
                local i = -268 < h.Position.Z

                if i then
                    return true
                end
            end
            return false  
        else
            return true  
        end
    end)
    
    if s and r then
        return r    
    end
    return false
end

function utility:attack(p)
    local s, r = pcall(function(...)
        return self["RE/BatSwing/Trigger"]:FireServer(p, self:CreateSeed())
    end)

    if s then
        return   
    end
   
    return warn('failed: '..tostring(r))
end

function utility:GetClosetPlayer()
    local c = nil
    local cd = math.huge

    for _, p in next, self.Players:GetPlayers() do
        if p == self.LocalPlayer then
            continue
        end
        local char = p.Character
        if not char then
            continue
        end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            continue
        end
        local dist = self.LocalPlayer:DistanceFromCharacter(hrp.Position)
        if dist < cd and dist <= 16.5 then
            cd = dist
            c = p
        end
    end
    return c
end

function utility:init()
    self.LocalPlayer = self.Players.LocalPlayer
    if not self.LocalPlayer then
        return warn('failed to get localplayer')
    end

    if not identifyexecutor then
        return self.LocalPlayer:Kick("Unsupported executor missing identifyexecutor")
    end

    local exc = identifyexecutor():lower()
    if exc:find("xeno") or exc:find("solara") then
        return self.LocalPlayer:Kick("Unsupported executor")
    end

    self.Packages = self.ReplicatedStorage:FindFirstChild("Packages")
    if not self.Packages then
        return warn('failed to get Packages')
    end

    self.Networking = self.Packages:FindFirstChild("Networking")
    if not self.Networking then
        return warn('failed to get Networking')
    end

    self["RE/BatSwing/Trigger"] = self.Networking:FindFirstChild("RE/BatSwing/Trigger")
    if not self["RE/BatSwing/Trigger"] then
        return warn('failed to get RE/BatSwing/Trigger')
    end

    self.Client = self.ReplicatedStorage:FindFirstChild("Client")
    if not self.Client then
        return warn("failed to get Client")
    end

    self.ToolGameplayGuard = require(self.Client:FindFirstChild("ToolGameplayGuard"))
    if not self.ToolGameplayGuard then
        return warn("failed to get ToolGameplayGuard")
    end

    self.last = tick()
    self.conn = self.RunService.Heartbeat:Connect(function()
        self.Target = self:GetClosetPlayer()
        if self.Target then
            if tick() - self.last >= 0.1 then
                if self:CanUseTool() then
                    self:attack(self.Target)
                    self.last = tick()
                end
            end
        end
    end)

    if not self.conn then
        return warn("failed to create runservice connection")
    end

    return warn("succesful init")
end

utility:init()
