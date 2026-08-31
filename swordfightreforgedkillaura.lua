local utility = {
    Players = game:GetService("Players"),
    target = nil,
}

function utility:getsword()
    local success, r = pcall(function(...)
        local s = self.LocalPlayer.Character:FindFirstChildOfClass("Tool")
        local h = s.Handle

        if h:FindFirstChild("TouchInterest") then
            return {s = s, h = h}
        end

        return {}
    end)
    if success and r.s and r.h then
        return r
    end
    return {}
end

function utility:getcloset()
    local closetdist = math.huge
    local closet = nil

    for _, plr in next, self.Players:GetPlayers() do
        if plr == self.LocalPlayer then
            continue
        end
        if plr.Name == "MiniMAAC" then
            continue
        end
        local char = plr.Character
        if not char then 
            continue 
        end   

        if char:FindFirstChildOfClass("ForceField") then
            continue
        end

        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then 
            continue 
        end   

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then 
            continue 
        end  

        local dist = self.LocalPlayer:DistanceFromCharacter(hrp.Position)
        if dist < closetdist and dist <= 10 then
            closetdist = dist
            closet = hrp
        end
    end

    return closet
end

utility.attack = function(handle, target)
    pcall(function(...)
        handle.Parent:Activate()
        firetouchinterest(handle, target, 0)
        firetouchinterest(handle, target, 1)
    end)
end

function utility:initkillaura()
    self.LocalPlayer = self.Players.LocalPlayer
    if not self.LocalPlayer then
        return warn("failed to get localplayer")
    end

    if not firetouchinterest then
        self.LocalPlayer:Kick("unsupport executor missing firetouchinterest")
    end

    task.spawn(function()
        while task.wait() do 
            pcall(function(...)
                self.target = self:getcloset()
                if self.target then
                    local data = self:getsword()
                    if data.s and data.h then 
                        self.attack(data.h, self.target)
                    end
                end
            end)
        end
    end)

    return warn('successful init')
end

utility:initkillaura()
