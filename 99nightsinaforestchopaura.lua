local utility = {
    ToolDamageObject = game:GetService("ReplicatedStorage").RemoteEvents.ToolDamageObject,
    EnemyHandler = require(game.Players.LocalPlayer.PlayerScripts.Client.EnemyHandler)
}

utility.HoldingAxe = function()
    local success, result = pcall(function()
        for _, model in ipairs(game.Players.LocalPlayer.Character:GetChildren()) do
            if model:IsA("Model") then
                if model:GetAttribute("ToolName") and model:GetAttribute("ToolName"):find("Axe") then
                    return model:FindFirstChild("OriginalItem").Value
                end
            end
        end
    end)

    if success then
        return result
    end

    return nil
end

utility.CanChop = function(self, tree)
    local success, result = pcall(function()
        if tostring(tree):find("Big") then
            for _, tool in pairs(game:GetService("Players").LocalPlayer.Inventory:GetChildren()) do
                if tool:GetAttribute("ToolName") and tool:GetAttribute("ToolName"):find("Chainsaw") then
                    return true
                end
            end
        else
            return true
        end
    end)

    if success then
        return result
    end

    return false
end

utility.GetClosestTree = function(self)
    local success, result = pcall(function()
        local closest = nil
        local closestdistance = math.huge

        local Trees = workspace:QueryDescendants('[$Resource]')

        if Trees and typeof(Trees) == "table" and #Trees ~= 0 then
            for _, tree in pairs(Trees) do
                if tree:FindFirstChild("Trunk") and self:CanChop(tree) then
                    local Trunk = tree:FindFirstChild("Trunk")
                    local distance = game.Players.LocalPlayer:DistanceFromCharacter(Trunk.Position)

                    if distance < closestdistance and distance < 100 then
                        closestdistance = distance
                        closest = tree
                    end
                end
            end
        end

        return closest
    end)

    if success then
        return result
    end
    return nil
end

utility.ChopClosetTree = function(self)
    local _, result = pcall(function()
        local closet = self:GetClosestTree()
        if not closet then return "failed to get closet tree" end

				local myroot = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				if not myroot then return "failed to get rootpart" end

        local axe = self.HoldingAxe()
        if not axe then return "failed to get axe" end

        return {closet.Name, self.ToolDamageObject:InvokeServer(
            closet,
            axe,
            self.EnemyHandler.GetHitRegId(),
            myroot.CFrame,
            true
        )}
    end)

    return result
end

task.spawn(function()
		while wait(0.1) do
				local result = utility:ChopClosetTree()
				if typeof(result) == "table" and #result == 2 and typeof(result[2]) == "table" then
						warn("Chop successfully on tree: "..tostring(result[1]))
				elseif typeof(result) == "string" then
						warn("error: "..tostring(result))
				end
		end
end)
