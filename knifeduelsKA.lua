local utility = {
    Players = cloneref(game:GetService("Players")),
    ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage")),
    RunService = cloneref(game:GetService("RunService")),
}

utility.Init = function(self)
    self.LocalPlayer = self.Players.LocalPlayer
    if not self.LocalPlayer then
        return warn("failed to get LocalPlayer")
    end

    self.PlayerScripts = self.LocalPlayer:WaitForChild("PlayerScripts", 3)
    if not self.PlayerScripts then
        return warn("failed to get PlayerScripts")
    end

    self.Controllers = self.PlayerScripts:WaitForChild("Controllers", 3)
    if not self.Controllers then
        return warn("failed to get Controllers")
    end

    self.Match = self.Controllers:WaitForChild("Match", 3)
    if not self.Match then
        return warn("failed to get Match")
    end

    self.MatchControllerSuccess, self.MatchController = pcall(require, self.Match:WaitForChild("MatchController", 3))
    if not self.MatchControllerSuccess then
        return warn("failed to get matchcontroller err: "..tostring(self.MatchController))
    end

    self.Combat = self.Controllers:WaitForChild("Combat", 3)
    if not self.Combat then
        return warn("failed to get Combat")
    end

    self.CombatNet = self.ReplicatedStorage:WaitForChild("CombatNet", 3)
    if not self.CombatNet then
        return warn("failed to get CombatNet")
    end

    self.requiresucces, self.CombatNetClient = pcall(require, self.Combat:WaitForChild("CombatNetClient", 3))
    if not self.requiresucces then
        return warn("failed to get CombatNetClient error: "..tostring(self.CombatNetClient))
    end

    self.Shared = self.ReplicatedStorage:WaitForChild("Shared", 3)
    if not self.Shared then
        return warn("failed to get Shared")
    end

    self.CombatRulesSuccess, self.CombatRules = pcall(require, self.Shared:WaitForChild("CombatRules", 3))
    if not self.CombatRulesSuccess then
        return warn("failed to get CombatRules")
    end

    self.getfenvsuccess, self.reporthitenv = pcall(getfenv, self.CombatNetClient.ReportHit)
    if not self.getfenvsuccess then
        return warn("failed to get report hit env error:"..tostring(self.reporthitenv))
    end

    self.ReportHitRemote = self.CombatNet:WaitForChild(tostring(self.reporthitenv.UGC), 3)
    if not self.ReportHitRemote then
        return warn("failed to get ReportHitRemote")
    end

    self.FakeDebug = {
        getmemorycategory = function()
            return "SettingsEffectsController"
        end,
    }

    self.clean = setmetatable({}, {
        __index = function(_, key)
            if key == "debug" then
                return self.FakeDebug
            elseif key == "getfenv" then
                return function(level)
                    local success, cleanenv = pcall(function()
                        local _, envr = pcall(getfenv, level)
                        if not envr then
                            envr = getfenv()
                        end

                        local cleanenv = {}
                        setmetatable(cleanenv, {
                            __index = function(_, key2)
                                local func = filtergc("function", {Name = key2, IgnoreExecutor = false}, true)

                                if func and isexecutorclosure(func) then
                                    return nil
                                end

                                return self.ReportHitRemote
                            end,
                        })

                        return cleanenv
                    end)
                    
                    if success then
                        return cleanenv
                    else
                        return self.reporthitenv
                    end
                end
            end
            return self.reporthitenv and self.reporthitenv[key]
        end,
    })

    self.successhook, self.err = pcall(setfenv, self.CombatNetClient.ReportHit, self.clean)
    if not self.successhook then
        return warn("failed to setenv error: "..tostring(self.err))
    end

    self.KAloop = self.RunService.Heartbeat:Connect(function()
        for _, plr in next, game.Players:GetPlayers() do
            if plr == game.Players.LocalPlayer then continue end
            local char = plr.Character
            if not char then continue end

            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end    
            
            if char:GetAttribute("Dead") then continue end
            if char:GetAttribute("HP") and char:GetAttribute("HP") <= 0 then continue end

            if self.MatchController:IsPlayerEnemy(plr) then
                if game.Players.LocalPlayer:DistanceFromCharacter(hrp.Position) < 20 then
                    self.CombatNetClient:ReportHit(char, self.CombatRules.AttackType.Knife, false, nil, game:GetService("HttpService"):GenerateGUID(), hrp.Position, 1)
                end
            end
        end
    end)

    if not self.KAloop then
        return warn("failed to create heartbeat loop")
    end

    return warn("success")
end

utility:Init()
